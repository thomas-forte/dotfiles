#!/bin/zsh

alias config="cd $XDG_CONFIG_HOME"
alias sshconfig="cat $HOME/.ssh/config"
alias weather="curl 'wttr.in/Cleveland?0'"

if [[ "$(uname -s)" == Darwin ]]; then
  alias library="cd $HOME/Library"
  alias shrug="echo '¯\_(ツ)_/¯' | pbcopy"
fi
