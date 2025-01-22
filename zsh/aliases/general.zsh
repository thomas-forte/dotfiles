#!/bin/zsh

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

# git
alias gmm='git commit -m'

# alias over cat with bat
if hash bat 2> /dev/null; then
  alias cat='bat'
fi

# directories
alias config="cd $XDG_CONFIG_HOME"
alias library="cd $HOME/Library"
alias github="cd $HOME/github"
alias work="cd $HOME/github/_work"

# fun
alias weather="curl 'wttr.in/Cleveland?0'"
alias shrug="echo '¯\_(ツ)_/¯' | pbcopy"
