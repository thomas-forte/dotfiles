#!/bin/zsh
#
# Completion policy: fpath extras + styles.
# Antigen apply (in .zshrc) runs the single compinit after this file is sourced.

# Dump cache under XDG cache (Antigen honors this during apply)
if mkdir -p "${XDG_CACHE_HOME}/zsh" 2>/dev/null; then
  export ANTIGEN_COMPDUMP="${XDG_CACHE_HOME}/zsh/zcompdump-${ZSH_VERSION}"
fi

# Optional / custom completion dirs (N = ignore if missing).
# Earlier entries win when two dirs define the same _command.
fpath=(
  ${HOME}/.docker/completions(N)
  ${ZDOTDIR}/completions(N)
  ${XDG_DATA_HOME}/zsh/completions(N)
  $fpath
)

# Case-insensitive match, then partial word, then substring
zstyle ':completion:*' matcher-list \
  'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' \
  'r:|=*' \
  'l:|=* r:|=*'

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME}/zsh/completion-cache"
