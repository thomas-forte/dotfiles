#!/bin/zsh
#
# ZSH setup is based on https://github.com/marlonrichert/zsh-launchpad
# and https://github.com/Lissy93/dotfiles
export XDG_CONFIG_HOME="${HOME}/.config";
export XDG_CACHE_HOME="${HOME}/.cache";
export XDG_DATA_HOME="${HOME}/.local/share";
export XDG_STATE_HOME="${HOME}/.local/state}";

export EDITOR="nano"
export PAGER="less"

# shell stuff
export ZDOTDIR="${XDG_CONFIG_HOME}/zsh";
export ADOTDIR="${ZDOTDIR}/antigen"
export STARSHIP_CONFIG="${ZDOTDIR}/starship.toml"

export LANG='en_US.UTF-8';
