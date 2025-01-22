#!/bin/zsh

# ssh
alias sshconfig="cat $HOME/.ssh/config"
alias copyssh="pbcopy < $HOME/.ssh/id_ed25519.pub"

# python
py () {
  if (( ${+VIRTUAL_ENV} )); then
    deactivate
  else
    source venv/bin/activate
  fi
}

# alias over cat with bat
if hash bat 2> /dev/null; then
  alias cat='bat'
fi

# fun
alias weather="curl 'wttr.in/Cleveland?0'"
alias shrug="echo '¯\_(ツ)_/¯' | pbcopy"
