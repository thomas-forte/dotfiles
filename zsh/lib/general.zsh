#!/bin/zsh

# Direct navigation
alias config="cd $XDG_CONFIG_HOME"
alias sshconfig="cat $HOME/.ssh/config"
alias library="cd $HOME/Library"

# alias over cat with bat
if hash bat 2> /dev/null; then
  alias cat='bat'
fi

# fun
alias weather="curl 'wttr.in/Cleveland?0'"
alias shrug="echo '¯\_(ツ)_/¯' | pbcopy"
