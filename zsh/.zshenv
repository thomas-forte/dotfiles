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

# app config
# export LESSHISTFILE="-" # Disable less history.
export LESSHISTFILE="$XDG_STATE_HOME/lesshst"
export BAT_CONFIG_PATH="${XDG_CONFIG_HOME}/bat.conf"
export WGETRC="${XDG_CONFIG_HOME}/.wgetrc"
export PYTHON_HISTORY="${XDG_CACHE_HOME}/.python_history"
export NVM_DIR="$XDG_DATA_HOME/nvm"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export SEND_SSH=""
export SEND_SSH_USER=""
export SEND_SSH_ID=""
# export GIT_CONFIG_GLOBAL="${XDG_CONFIG_HOME}/git/config"
