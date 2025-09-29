#!/bin/zsh

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# OSX specific configurations
if [ "$(uname -s)" = "Darwin" ]; then

  # Add Brew to path, if it's installed
  if [[ -d /opt/homebrew/bin ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  # If using iTerm, import the shell integration if available
  if [[ -f "${ZDOTDIR}/.iterm2_shell_integration.zsh" ]]; then
    source "${ZDOTDIR}/.iterm2_shell_integration.zsh"
  fi
fi

# Import alias files
if [[ -d "${ZDOTDIR}/aliases" ]]; then
  source ${ZDOTDIR}/aliases/general.zsh
  source ${ZDOTDIR}/aliases/directories.zsh
  source ${ZDOTDIR}/aliases/git.zsh
  source ${ZDOTDIR}/aliases/python.zsh
  source ${ZDOTDIR}/aliases/aws.zsh
fi

# Import plugins
if [[ -d "${ZDOTDIR}/plugins" ]]; then
  # Setup Antigen, and import plugins
  source "${ZDOTDIR}/plugins/setup-antigen.zsh"
  source "${ZDOTDIR}/plugins/import-plugins.zsh"
fi

# Configure ZSH stuff
if [[ -d "${ZDOTDIR}/lib" ]]; then
  source "${ZDOTDIR}/lib/history.zsh"
fi

# Configure nvm
export NVM_DIR="$XDG_DATA_HOME/nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm

# add starship to shell
if hash starship 2> /dev/null; then
  eval "$(starship init zsh)"
fi

export CLICOLOR=1
export GPG_TTY=$(tty)

