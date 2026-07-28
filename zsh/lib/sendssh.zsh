#!/bin/zsh
#
# sendssh - share ssh public keys through a central server.
#
# Configured in .zshenv:
#   SEND_SSH     - host holding the shared key list
#   SEND_SSH_ID  - identity file used to reach that host
#   SEND_SSH_USER - user to reach that host

SENDSSH_REMOTE_FILE="/etc/sendssh/data"
SENDSSH_LOCAL_FILE="${XDG_DATA_HOME}/sendssh/data"

sendssh() {
  case "$1" in
    new)  _sendssh_new "${@:2}" ;;
    send) _sendssh_send ;;
    get)  _sendssh_get ;;
    copy) _sendssh_copy ;;
    *)
      echo "usage: sendssh <command>"
      echo "  new <name> [-s]  create an ed25519 key pair at ~/.ssh/<hostname>_<name>_ed25519"
      echo "                   (-s/--send uploads the public key after creating it)"
      echo "  send             upload local public keys to \$SEND_SSH"
      echo "  get              pull shared public keys into ${SENDSSH_LOCAL_FILE}"
      echo "  copy             copy a local public key to the clipboard"
      return 1
      ;;
  esac
}

_sendssh_new() {
  local name upload=0 arg
  for arg in "$@"; do
    case "$arg" in
      -s|--send) upload=1 ;;
      *) name="$arg" ;;
    esac
  done
  if [[ -z "$name" ]]; then
    echo "usage: sendssh new <name> [-s|--send]   (e.g. 'sendssh new nuc' on host mini2 -> mini2_nuc_ed25519)"
    return 1
  fi

  local keyfile=~/.ssh/"${HOST%%.*}_${name}_ed25519"
  ssh-keygen -f "$keyfile" -t ed25519 || return 1

  if (( upload )); then
    _sendssh_env || return 1
    _sendssh_upload "${keyfile}.pub"
  else
    echo "done. run 'sendssh send' to share the public key."
  fi
}

_sendssh_send() {
  _sendssh_env || return 1

  local -a files
  files=("${(f)$(_sendssh_pick_pubs "select keys to upload to ${SEND_SSH}:${SENDSSH_REMOTE_FILE}")}") || return 1
  files=(${files:#})
  if (( $#files == 0 )); then
    echo "nothing selected"
    return 0
  fi

  _sendssh_upload "${files[@]}"
}

_sendssh_copy() {
  local file
  file="$(_sendssh_pick_pubs -1 "select a key to copy to the clipboard")" || return 1
  if [[ -z "$file" ]]; then
    echo "nothing selected"
    return 0
  fi

  # $(< file) drops the trailing newline, -n avoids adding one back
  print -rn -- "$(< "$file")" | pbcopy
  echo "copied ${file:t} to the clipboard"
}

# pick public keys from ~/.ssh, prints the chosen file paths.
# pass -1 as the first arg for single-choice mode.
_sendssh_pick_pubs() {
  local -a flags
  if [[ "$1" == "-1" ]]; then
    flags=(-1)
    shift
  fi

  local -a pubs idx
  pubs=(~/.ssh/*.pub(N))
  if (( $#pubs == 0 )); then
    echo "no public keys found in ~/.ssh (try 'sendssh new <name>')" >&2
    return 1
  fi

  echo "$1" >&2
  idx=("${(f)$(_sendssh_select $flags "${pubs[@]:t}")}") || return 1
  idx=(${idx:#})

  local i
  for i in "${idx[@]}"; do print -r -- "${pubs[i]}"; done
}

# append the given public key files to the remote data file,
# skipping keys the remote file already has
_sendssh_upload() {
  if cat "$@" | _sendssh_ssh 'while IFS= read -r k; do
      grep -qxF "$k" '"${SENDSSH_REMOTE_FILE}"' || printf "%s\n" "$k" >> '"${SENDSSH_REMOTE_FILE}"'
    done'; then
    echo "uploaded $# key(s) to ${SEND_SSH}"
  else
    echo "upload to ${SEND_SSH} failed"
    return 1
  fi
}

_sendssh_get() {
  _sendssh_env || return 1
  mkdir -p "${SENDSSH_LOCAL_FILE:h}"
  _sendssh_sync_authorized

  local -a remote
  remote=("${(f)$(_sendssh_ssh "cat ${SENDSSH_REMOTE_FILE}")}") || return 1
  remote=(${remote:#})
  if (( $#remote == 0 )); then
    echo "no keys on ${SEND_SSH} yet"
    return 0
  fi

  # keys are too long to render in the picker, so build short labels
  local -a labels parts
  local key
  for key in "${remote[@]}"; do
    parts=(${=key})
    labels+=("${${(j: :)parts[3,-1]}:-(no comment)} [${parts[1]} ${parts[2][1,16]}...]")
  done

  echo "select keys to add to ${SENDSSH_LOCAL_FILE}"
  local -a idx
  idx=("${(f)$(_sendssh_select "${labels[@]}")}") || return 1
  idx=(${idx:#})
  if (( $#idx == 0 )); then
    echo "nothing selected"
    return 0
  fi

  local i added=0
  for i in "${idx[@]}"; do
    if ! grep -qxF "${remote[i]}" "${SENDSSH_LOCAL_FILE}" 2> /dev/null; then
      print -r -- "${remote[i]}" >> "${SENDSSH_LOCAL_FILE}"
      (( added++ ))
    fi
  done
  echo "added ${added} new key(s) to ${SENDSSH_LOCAL_FILE}"
  _sendssh_sync_authorized
}

_sendssh_env() {
  if [[ -z "$SEND_SSH" || -z "$SEND_SSH_ID" || -z "$SEND_SSH_USER" ]]; then
    echo "SEND_SSH, SEND_SSH_ID, and SEND_SSH_USER must be set (see zsh/.zshenv)"
    return 1
  fi
}

_sendssh_ssh() {
  ssh -i "${SEND_SSH_ID/#\~/$HOME}" "$SEND_SSH_USER@$SEND_SSH" "$@"
}

# user-only setup: append any keys from the data file that are missing
# from ~/.ssh/authorized_keys so pulled keys can actually log in.
_sendssh_sync_authorized() {
  local auth=~/.ssh/authorized_keys
  [[ -s "${SENDSSH_LOCAL_FILE}" ]] || return 0
  mkdir -p ~/.ssh
  touch "$auth"
  chmod 600 "$auth"
  local key added=0
  while IFS= read -r key; do
    [[ -z "$key" ]] && continue
    if ! grep -qxF "$key" "$auth"; then
      print -r -- "$key" >> "$auth"
      (( added++ ))
    fi
  done < "${SENDSSH_LOCAL_FILE}"
  (( added )) && echo "authorized ${added} key(s) in ${auth}"
  return 0
}

# Interactive checkbox picker over the given labels, prints the selected
# indices (1-based, one per line) to stdout.
# Controls: arrows or j/k to move, space to toggle, enter to confirm, q to cancel.
# Pass -1 as the first arg for single-choice mode: no checkboxes, and
# space or enter picks the highlighted row.
_sendssh_select() {
  local single=0
  if [[ "$1" == "-1" ]]; then
    single=1
    shift
  fi

  local -a opts=("$@") marks=()
  local cur=1 i key
  for i in {1..$#opts}; do marks[i]=0; done

  print -n '\e[?25l' > /dev/tty
  _sendssh_draw
  while true; do
    read -sk1 key < /dev/tty
    if [[ "$key" == $'\e' ]]; then
      read -sk2 key < /dev/tty
      case "$key" in
        '[A') key=k ;;
        '[B') key=j ;;
      esac
    fi
    case "$key" in
      k) (( cur > 1 )) && (( cur-- )) ;;
      j) (( cur < $#opts )) && (( cur++ )) ;;
      ' ')
        if (( single )); then
          marks[cur]=1
          break
        fi
        (( marks[cur] = ! marks[cur] ))
        ;;
      $'\n'|$'\r')
        (( single )) && marks[cur]=1
        break
        ;;
      q) print -n '\e[?25h' > /dev/tty; return 1 ;;
    esac
    print -n "\e[${#opts}A" > /dev/tty
    _sendssh_draw
  done
  print -n '\e[?25h' > /dev/tty

  for i in {1..$#opts}; do
    (( marks[i] )) && print -r -- "$i"
  done
  return 0
}

# renders the picker, relies on zsh dynamic scoping for opts/marks/cur/single
_sendssh_draw() {
  local i box ptr
  for i in {1..$#opts}; do
    box="[ ] "; ptr="  "
    (( single )) && box=""
    (( marks[i] )) && box="[x] "
    (( i == cur )) && ptr="> "
    print -r -- $'\e[2K'"${ptr}${box}${opts[i]}" > /dev/tty
  done
}
