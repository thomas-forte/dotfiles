#!/bin/zsh

# XDG Base Directory Specification
export XDG_CONFIG_HOME="${HOME}/.config";
export XDG_DATA_HOME="${HOME}/.local/share";
export XDG_BIN_HOME="${HOME}/.local/bin";
export XDG_LIB_HOME="${HOME}/.local/lib";
export XDG_CACHE_HOME="${HOME}/.cache";

# Locale, Timezone, Basics
export LANG='en_US.UTF-8';
export LC_ALL='C';
export TZ='America/New_York'
export EDITOR="nano"
export PAGER="less"
export CLICOLOR=1

# ZSH configs
export ZDOTDIR="${XDG_CONFIG_HOME}/zsh";
export ADOTDIR="${XDG_CACHE_HOME}/antigen"

# Application configs
export BAT_CONFIG_PATH="${XDG_CONFIG_HOME}/bat.conf"
export WGETRC="${XDG_CONFIG_HOME}/.wgetrc"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/config"

# Application data
export NVM_DIR="$XDG_DATA_HOME/nvm"

# Application caches
export LESSHISTFILE="$XDG_CACHE_HOME/lesshst"
export PYTHON_HISTORY="${XDG_CACHE_HOME}/.python_history"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"


# SendSSH configs
export SEND_SSH=""
export SEND_SSH_USER=""
export SEND_SSH_ID=""

# Other variables
export DOTNET_CLI_TELEMETRY_OPTOUT=1
