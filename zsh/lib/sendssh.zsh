#!/bin/zsh
#
# sendssh - share ssh public keys through a central server.
#
# Configured in .zshenv:
#   SEND_SSH_DEST - host holding the shared key list
#   SEND_SSH_ID   - identity file used to reach that host
#   SEND_SSH_USER - user to reach that host

# Client configuration
SENDSSH_REMOTE_FILE="/etc/sendssh/data"
SENDSSH_LOCAL_FILE="${XDG_DATA_HOME}/sendssh/data"
SENDSSH_AUTH_FILE="${HOME}/.ssh/authorized_keys"

# Server configuration
# SENDSSH_REMOTE_FILE="~/.ssh/authorized_keys"
# SENDSSH_LOCAL_FILE="/etc/sendssh/data"

sendssh() {
  case "$1" in
    new)  _sendssh_new "${@:2}" ;;
    send) _sendssh_send ;;
    get)  _sendssh_get ;;
    list) _sendssh_list ;;
    copy) _sendssh_copy "${@:2}" ;;
    *)
      echo "usage: sendssh <command>"
      echo "  new <name> [-s]  create an ed25519 key pair at ~/.ssh/<hostname>_<name>_ed25519"
      echo "                   (-s/--send uploads the public key after creating it)"
      echo "  send             upload local public keys to \$SEND_SSH_DEST:${SENDSSH_REMOTE_FILE}"
      echo "  get              pull shared public keys into ${SENDSSH_LOCAL_FILE}"
      echo "  list             show local data-file keys and whether they are authorized"
      echo "  copy [-r]        copy a local (or remote with -r/--remote) public key to the clipboard"
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
    echo "usage: sendssh new <name> [-s|--send]   (e.g. 'sendssh new ci-box' on host imac -> imac_ci-box_ed25519)"
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
  files=("${(f)$(_sendssh_pick_pubs "select keys to upload to ${SEND_SSH_DEST}:${SENDSSH_REMOTE_FILE}")}") || return 1
  files=(${files:#})
  (( $#files )) || { echo "nothing selected"; return 0 }
  _sendssh_upload "${files[@]}"
}

_sendssh_copy() {
  local remote=0 arg
  for arg in "$@"; do
    case "$arg" in
      -r|--remote) remote=1 ;;
      *)
        echo "usage: sendssh copy [-r|--remote]"
        return 1
        ;;
    esac
  done

  if (( remote )); then
    _sendssh_copy_remote
    return
  fi

  local file
  file="$(_sendssh_pick_pubs -1 "select a key to copy to the clipboard")" || return 1
  [[ -n "$file" ]] || { echo "nothing selected"; return 0 }
  _sendssh_clip "$(< "$file")"
  echo "copied ${file:t} to the clipboard"
}

_sendssh_copy_remote() {
  _sendssh_env || return 1
  local -a remote
  _sendssh_load_remote || return 1
  remote=("$reply[@]")
  (( $#remote )) || { echo "no keys on remote yet"; return 0 }

  _sendssh_pick_records -1 "select a remote key to copy to the clipboard" "${remote[@]}" || return 1
  (( $#reply )) || { echo "nothing selected"; return 0 }
  _sendssh_clip "${reply[1]#*:}"
  echo "copied remote key to the clipboard"
}

_sendssh_list() {
  local -a recs
  _sendssh_read_keys "${SENDSSH_LOCAL_FILE}"
  recs=("$reply[@]")
  (( $#recs )) || { echo "no keys in ${SENDSSH_LOCAL_FILE}"; return 0 }

  typeset -A auth
  _sendssh_index_file "${SENDSSH_AUTH_FILE}" auth

  local rec name key mark
  for rec in "${recs[@]}"; do
    name="${rec%%:*}"
    key="${rec#*:}"
    mark="[          ]"
    (( ${+auth[$key]} )) && mark="[authorized]"
    print -r -- "${mark} $(_sendssh_format_label "$name" "$key")"
  done
}

_sendssh_get() {
  _sendssh_env || return 1
  mkdir -p "${SENDSSH_LOCAL_FILE:h}"
  _sendssh_sync_authorized

  local -a remote
  _sendssh_load_remote || return 1
  remote=("$reply[@]")
  (( $#remote )) || { echo "no keys on remote yet"; return 0 }

  _sendssh_pick_records "select keys to add to ${SENDSSH_LOCAL_FILE}" "${remote[@]}" || return 1
  (( $#reply )) || { echo "nothing selected"; return 0 }

  local rec added=0
  for rec in "$reply[@]"; do
    if _sendssh_append_line "$rec" "${SENDSSH_LOCAL_FILE}"; then
      (( added++ ))
    fi
  done
  echo "added ${added} new key(s) to ${SENDSSH_LOCAL_FILE}"
  _sendssh_sync_authorized
}

# user-only setup: append key bodies from the data file that are missing
# from ~/.ssh/authorized_keys so pulled keys can actually log in.
_sendssh_sync_authorized() {
  local -a recs
  _sendssh_read_keys "${SENDSSH_LOCAL_FILE}"
  recs=("$reply[@]")
  (( $#recs )) || return 0

  mkdir -p "${SENDSSH_AUTH_FILE:h}"
  touch "${SENDSSH_AUTH_FILE}"
  chmod 600 "${SENDSSH_AUTH_FILE}"

  typeset -A auth
  _sendssh_index_file "${SENDSSH_AUTH_FILE}" auth

  local rec key added=0
  for rec in "${recs[@]}"; do
    key="${rec#*:}"
    [[ -n "$key" ]] || continue
    (( ${+auth[$key]} )) && continue
    print -r -- "$key" >> "${SENDSSH_AUTH_FILE}"
    auth[$key]=1
    (( added++ ))
  done
  (( added )) && echo "authorized ${added} key(s) in ${SENDSSH_AUTH_FILE}"
  return 0
}

# --- records, files, remote ----------------------------------------------

_sendssh_env() {
  if [[ -z "$SEND_SSH_DEST" || -z "$SEND_SSH_ID" || -z "$SEND_SSH_USER" ]]; then
    echo "SEND_SSH_DEST, SEND_SSH_ID, and SEND_SSH_USER must be set (see zsh/.zshenv)"
    return 1
  fi
}

_sendssh_ssh() {
  ssh -i "${SEND_SSH_ID/#\~/$HOME}" "$SEND_SSH_USER@$SEND_SSH_DEST" "$@"
}

_sendssh_load_remote() {
  reply=("${(f)$(_sendssh_ssh "cat ${SENDSSH_REMOTE_FILE}")}") || return 1
  reply=(${reply:#})
}

# non-empty lines from a local file into $reply
_sendssh_read_keys() {
  reply=()
  local file=$1
  [[ -r "$file" && -s "$file" ]] || return 0
  reply=("${(f)$(<"$file")}")
  reply=(${reply:#})
}

# load exact lines of $1 into associative array named $2
_sendssh_index_file() {
  local file=$1 dest=$2 line
  eval "${dest}=()"
  [[ -r "$file" ]] || return 0
  while IFS= read -r line; do
    [[ -n "$line" ]] && eval "${dest}[\$line]=1"
  done < "$file"
}

_sendssh_append_line() {
  local line=$1 file=$2
  [[ -n "$line" && -r "$file" ]] && grep -qxF "$line" "$file" && return 1
  mkdir -p "${file:h}"
  print -r -- "$line" >> "$file"
  return 0
}

_sendssh_clip() {
  local text=$1
  if (( $+commands[pbcopy] )); then
    print -rn -- "$text" | pbcopy
  elif (( $+commands[wl-copy] )); then
    print -rn -- "$text" | wl-copy
  elif (( $+commands[xclip] )); then
    print -rn -- "$text" | xclip -selection clipboard
  else
    echo "no clipboard tool found (pbcopy, wl-copy, or xclip)" >&2
    return 1
  fi
}

# "(user) filename" — user is the ssh comment before '@'
_sendssh_format_label() {
  local name=$1 key=$2
  local -a parts=(${=key})
  local user="${${(j: :)parts[3,-1]}%%@*}"
  if [[ -n "$user" ]]; then
    print -r -- "($user) $name"
  else
    print -r -- "$name"
  fi
}

_sendssh_key_labels() {
  local -a labels
  local rec
  for rec in "$@"; do
    labels+=("$(_sendssh_format_label "${rec%%:*}" "${rec#*:}")")
  done
  print -l -- "${labels[@]}"
}

# selected records in $reply. pass -1 for single-choice.
_sendssh_pick_records() {
  local -a flags
  [[ "$1" == "-1" ]] && { flags=(-1); shift }
  local prompt=$1; shift
  local -a records=("$@") labels idx
  echo "$prompt" >&2
  labels=("${(f)$(_sendssh_key_labels "${records[@]}")}")
  idx=("${(f)$(_picker $flags "${labels[@]}")}") || return 1
  idx=(${idx:#})
  reply=()
  local i
  for i in "${idx[@]}"; do reply+=("${records[i]}"); done
}

# pick public keys from ~/.ssh; prints chosen file paths
_sendssh_pick_pubs() {
  local -a flags
  [[ "$1" == "-1" ]] && { flags=(-1); shift }

  local -a pubs idx labels
  pubs=(~/.ssh/*.pub(N))
  if (( $#pubs == 0 )); then
    echo "no public keys found in ~/.ssh (try 'sendssh new <name>')" >&2
    return 1
  fi

  echo "$1" >&2
  local pub content
  for pub in "${pubs[@]}"; do
    content="$(< "$pub")"
    labels+=("$(_sendssh_format_label "${pub:t}" "$content")")
  done
  idx=("${(f)$(_picker $flags "${labels[@]}")}") || return 1
  idx=(${idx:#})
  local i
  for i in "${idx[@]}"; do print -r -- "${pubs[i]}"; done
}

# append "filename:key" records, skipping lines the remote file already has
_sendssh_upload() {
  local file
  {
    for file in "$@"; do
      print -r -- "${file:t}:${$(< "$file")%%$'\n'}"
    done
  } | _sendssh_ssh 'while IFS= read -r k; do
      grep -qxF "$k" '"${SENDSSH_REMOTE_FILE}"' || printf "%s\n" "$k" >> '"${SENDSSH_REMOTE_FILE}"'
    done' || {
    echo "upload to ${SEND_SSH_DEST} failed"
    return 1
  }
  echo "uploaded $# key(s) to ${SEND_SSH_DEST}"
}
