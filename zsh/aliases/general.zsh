#!/bin/zsh

# ssh
alias sshconfig="cat $HOME/.ssh/config"
alias copyssh="pbcopy < $HOME/.ssh/id_ed25519.pub"

# python
py () {
  if (( ${+VIRTUAL_ENV} )); then
    deactivate
  elif [[ -d venv ]]; then
    source venv/bin/activate
  elif [[ -d .venv ]]; then
    source .venv/bin/activate
  else
    echo "I only work with venv and .venv!"
  fi
}

# alias over cat with bat
if hash bat 2> /dev/null; then
  alias cat='bat'
fi

# fun
alias weather="curl 'wttr.in/Cleveland?0'"
alias shrug="echo '¯\_(ツ)_/¯' | pbcopy"
