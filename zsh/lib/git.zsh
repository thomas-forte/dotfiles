#!/bin/zsh

function git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local ref
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default,stable,master}; do
    if command git show-ref -q --verify $ref; then
      echo ${ref:t}
      return 0
    fi
  done

  echo master
  return 1
}

_github_repos() {
  local d
  for d in ${HOME}/github/*(N/); do
    print -r -- "${d:t}"
  done
}

alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gfp='gfa && git pull'
alias gsp='git stash --include-untracked && gfp && git stash pop'
alias gcm='git checkout $(git_main_branch)'
alias gcb='git checkout -b'
alias gcB='git checkout -B'
alias gcl='git clone --recurse-submodules'

function github() {
  if (( $# )); then
    cd "$HOME/github/$1" || return
  else
    cd "$HOME/github" || return
  fi
}
