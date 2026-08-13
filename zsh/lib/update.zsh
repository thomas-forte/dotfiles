#!/bin/zsh
#
# Platform package updates: refresh metadata, confirm, then upgrade.
# Uses `confirm` from lib/picker.zsh.
#
# Public: update [-a|--accept]
# Alias:  uupdate  →  update -a
#
# Linux upgrades always use sudo (apt/dnf need elevation).

# Recommended usage:
#   allow passwordless: Cmnd_Alias UPDATE = /usr/bin/dnf, /usr/bin/apt-get
#   admin ALL=(root) NOPASSWD: UPDATE

alias uupdate='update -a'

update() {
  local yes=0
  while (( $# )); do
    case "$1" in
      -a|--accept) yes=1; shift ;;
      -h|--help)
        print -r -- "usage: update [-a|--accept]"
        print -r -- "  (default)      prompt before upgrade"
        print -r -- "  -a, --accept   skip confirmation; non-interactive upgrade (-y)"
        return 0
        ;;
      *)
        echo "update: unknown option: $1" >&2
        echo "usage: update [-a|--accept]" >&2
        return 2
        ;;
    esac
  done

  case "$(uname -s)" in
    Darwin)
      _update_mac
      ;;
    Linux)
      local id="" like=""
      if [[ -r /etc/os-release ]]; then
        id=$(. /etc/os-release 2>/dev/null; print -r -- "${ID:-}")
        like=$(. /etc/os-release 2>/dev/null; print -r -- "${ID_LIKE:-}")
      fi
      case " ${id} ${like} " in
        *" debian "*|*" ubuntu "*)
          _update_debian
          ;;
        *" fedora "*)
          _update_fedora
          ;;
        *)
          echo "update: unsupported Linux distro (${id:-unknown})" >&2
          return 1
          ;;
      esac
      ;;
    *)
      echo "update: unsupported platform ($(uname -s))" >&2
      return 1
      ;;
  esac
}

# Uses caller's `yes` via zsh dynamic scoping.
_update_proceed() {
  if (( yes )); then
    return 0
  fi
  confirm "Proceed with upgrade?"
}

_update_debian() {
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "update: apt-get not found" >&2
    return 1
  fi

  print -r -- "Refreshing apt package lists..."
  sudo apt-get update || return $?

  print -r -- ""
  apt list --upgradable 2>/dev/null

  print -r -- ""
  if _update_proceed; then
    if (( yes )); then
      sudo apt-get upgrade -y
    else
      sudo apt-get upgrade
    fi
  else
    print -r -- "Upgrade cancelled."
    return 1
  fi
}

_update_fedora() {
  if ! command -v dnf >/dev/null 2>&1; then
    echo "update: dnf not found" >&2
    return 1
  fi

  print -r -- "Checking for dnf updates..."
  # dnf4: 100 = updates available. dnf5: often 0 even when upgrades exist.
  local rc=0
  dnf check-update || rc=$?
  if (( rc != 0 && rc != 100 )); then
    return "$rc"
  fi

  print -r -- ""
  if _update_proceed; then
    if (( yes )); then
      sudo dnf upgrade -y
    else
      sudo dnf upgrade
    fi
  else
    print -r -- "Upgrade cancelled."
    return 1
  fi
}

_update_mac() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "update: Homebrew (brew) not found" >&2
    return 1
  fi

  print -r -- "Updating Homebrew..."
  brew update || return $?

  print -r -- ""
  brew outdated

  print -r -- ""
  if _update_proceed; then
    brew upgrade
  else
    print -r -- "Upgrade cancelled."
    return 1
  fi
}
