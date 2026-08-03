#!/bin/zsh
#
# Interactive terminal pickers / prompts.
#
#   confirm "question?"        [y/N]; true only for y/yes (any case)
#   _picker LABEL...           multi-select checkboxes; prints 1-based indices
#   _picker -1 LABEL...        single-select; prints one 1-based index
#
# Picker controls: arrows or j/k move, space toggles (multi) or chooses (single),
# enter confirms, q or Esc cancels (returns 1). UI goes to /dev/tty; results on stdout.

# Confirm [y/N]. Empty / anything else = no. y/yes (any case) = yes.
confirm() {
  local reply
  print -n -- "$1 [y/N] "
  read -r reply
  [[ "${reply:l}" == y || "${reply:l}" == yes ]]
}

_picker() {
  local single=0
  if [[ "$1" == "-1" ]]; then
    single=1
    shift
  fi

  if (( $# == 0 )); then
    echo "_picker: no options" >&2
    return 1
  fi

  local -a opts=("$@") marks=()
  local cur=1 i key
  for i in {1..$#opts}; do marks[i]=0; done

  print -n '\e[?25l' > /dev/tty
  _picker_draw
  while true; do
    read -sk1 key < /dev/tty
    if [[ "$key" == $'\e' ]]; then
      # Arrow keys send ESC + two bytes; bare Esc times out → quit.
      if read -sk2 -t 0.1 key < /dev/tty; then
        case "$key" in
          '[A') key=k ;;
          '[B') key=j ;;
          *) continue ;;
        esac
      else
        key=q
      fi
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
    _picker_draw
  done
  print -n '\e[?25h' > /dev/tty

  for i in {1..$#opts}; do
    (( marks[i] )) && print -r -- "$i"
  done
  return 0
}

# relies on zsh dynamic scoping for opts/marks/cur/single
_picker_draw() {
  local i box ptr
  for i in {1..$#opts}; do
    box="[ ] "; ptr="  "
    (( single )) && box=""
    (( marks[i] )) && box="[x] "
    (( i == cur )) && ptr="> "
    print -r -- $'\e[2K'"${ptr}${box}${opts[i]}" > /dev/tty
  done
}
