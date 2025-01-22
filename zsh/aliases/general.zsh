#!/bin/zsh

py () {
  if (( ${+VIRTUAL_ENV} )); then
    deactivate
  else
    source venv/bin/activate
  fi
}

alias gmm='git commit -m'

# alias over cat with bat
if hash bat 2> /dev/null; then
  alias cat='bat'
fi

alias weather="curl 'wttr.in/Cleveland?0'"
