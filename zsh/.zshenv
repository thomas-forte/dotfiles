#!/bin/zsh
#
# ZSH setup is based on https://github.com/marlonrichert/zsh-launchpad
# and https://github.com/Lissy93/dotfiles
export XDG_CONFIG_HOME="${HOME}/.config";
export XDG_DATA_HOME="${HOME}/.local/share";
export XDG_BIN_HOME="${HOME}/.local/bin";
export XDG_LIB_HOME="${HOME}/.local/lib";
export XDG_CACHE_HOME="${HOME}/.cache";

# terminal configs
export LANG='en_US.UTF-8';
export TZ='America/New_York'
export EDITOR="nano"
export PAGER="less"

# shell configs
export ZDOTDIR="${XDG_CONFIG_HOME}/zsh";
export ADOTDIR="${ZDOTDIR}/antigen"
export STARSHIP_CONFIG="${ZDOTDIR}/starship.toml"

# app config
export LESSHISTFILE="-" # Disable less history.
export BAT_CONFIG_PATH="${XDG_CONFIG_HOME}/bat.conf"
# export GIT_CONFIG_GLOBAL="${XDG_CONFIG_HOME}/git/config"
