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

# Antigen first so workflow libs can use deferred `compdef`
if [[ -d "${ZDOTDIR}/plugins" ]]; then
  source "${ZDOTDIR}/plugins/setup-antigen.zsh"
fi

# Workflow libs (aliases + functions; may register completers via compdef)
if [[ -d "${ZDOTDIR}/lib" ]]; then
  source "${ZDOTDIR}/lib/general.zsh"
  source "${ZDOTDIR}/lib/directories.zsh"
  source "${ZDOTDIR}/lib/git.zsh"
  source "${ZDOTDIR}/lib/python.zsh"
  source "${ZDOTDIR}/lib/aws.zsh"
  source "${ZDOTDIR}/lib/sendssh.zsh"
fi

# Register antigen bundles (apply comes after completion policy)
if [[ -d "${ZDOTDIR}/plugins" ]]; then
  source "${ZDOTDIR}/plugins/import-plugins.zsh"
fi

# Completion policy (fpath extras + zstyle), then apply + one compinit
if [[ -f "${ZDOTDIR}/lib/completions.zsh" ]]; then
  source "${ZDOTDIR}/lib/completions.zsh"
fi

# Load any non-cached antigen work (deferred compdefs, etc.)
(( $+functions[antigen] )) && antigen apply

# Own a single compinit now that fpath is final.
# Antigen zcache otherwise defers this to precmd with a hardcoded dump path.
autoload -Uz add-zsh-hook compinit
add-zsh-hook -D precmd _antigen_compinit 2>/dev/null
if [[ -n "${ANTIGEN_COMPDUMP:-}" ]]; then
  compinit -d "${ANTIGEN_COMPDUMP}"
else
  compinit
fi

# History after completions — unrelated, but keeps lib sourcing intentional
if [[ -f "${ZDOTDIR}/lib/history.zsh" ]]; then
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

[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
