#!/bin/zsh

setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus

alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

alias -- -='cd -'
alias 1='cd -1'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'

mkcd() {
  mkdir -p "$1" && cd "$1" || return 1
}

# List directory contents
alias l='ls'
alias ll='ls -lha' # List all files with detailed info
alias lr='ls -R' # List files in sub-directories, recursively
alias lf='ls -A | grep' # Use grep to find files
alias lc='find . -type f | wc -l' # Shows number of files
alias ld='ls -l | grep "^d"' # List directories only
