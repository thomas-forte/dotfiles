#!/bin/zsh

# my favorite aliases that I got from ohmyzsh

function git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local ref
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default,stable,master}; do
    if command git show-ref -q --verify $ref; then
      echo ${ref:t}
      return 0
    fi
  done

  # If no main branch was found, fall back to master but return error
  echo master
  return 1
}

alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gcm='git checkout $(git_main_branch)'
alias gcb='git checkout -b'
alias gcB='git checkout -B'

alias gcl='git clone --recurse-submodules'