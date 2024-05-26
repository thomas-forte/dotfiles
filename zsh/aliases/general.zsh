#!/bin/zsh

alias py='source venv/bin/activate'
alias _py='deactivate'

alias gmm='git commit -m'

# alias over cat with bat
if hash bat 2> /dev/null; then
  alias cat='bat'
fi