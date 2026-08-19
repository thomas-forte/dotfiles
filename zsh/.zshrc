#!/bin/zsh
#
# Interactive shells only (Cursor, Konsole, iTerm, `ssh host`).
# Scripts and `ssh host cmd` never load this file.

[[ $- != *i* ]] && return

# --- plugin manager -----------------------------------------------------------
if [[ -f "${ZDOTDIR}/lib/antigen.zsh" ]]; then
  source "${ZDOTDIR}/lib/antigen.zsh"
fi

# --- options + modules --------------------------------------------------------
# lib/ = startup modules (setopt, aliases, functions). Order matters.
if [[ -d "${ZDOTDIR}/lib" ]]; then
  source "${ZDOTDIR}/lib/history.zsh"      # HISTFILE, setopt
  source "${ZDOTDIR}/lib/picker.zsh"       # confirm, _picker (used by update/aws/sendssh)
  source "${ZDOTDIR}/lib/directories.zsh"  # cd options, ls aliases
  source "${ZDOTDIR}/lib/general.zsh"
  source "${ZDOTDIR}/lib/git.zsh"
  source "${ZDOTDIR}/lib/python.zsh"
  source "${ZDOTDIR}/lib/aws.zsh"
  source "${ZDOTDIR}/lib/sendssh.zsh"
  source "${ZDOTDIR}/lib/update.zsh"
fi

# --- antigen bundles ----------------------------------------------------------
if [[ -f "${ZDOTDIR}/lib/antigen-bundles.zsh" ]]; then
  source "${ZDOTDIR}/lib/antigen-bundles.zsh"
fi

# --- completions (after bundles, before compinit) -----------------------------
if [[ -f "${ZDOTDIR}/lib/completions.zsh" ]]; then
  source "${ZDOTDIR}/lib/completions.zsh"
fi

(( $+functions[antigen] )) && antigen apply

autoload -Uz add-zsh-hook compinit
add-zsh-hook -D precmd _antigen_compinit 2>/dev/null
if [[ -n "${ANTIGEN_COMPDUMP:-}" ]]; then
  compinit -d "${ANTIGEN_COMPDUMP}"
else
  compinit
fi

# git aliases in lib/git.zsh — compdef needs _git from compinit first
compdef git gf gfa gcm gcb gcB gcl

# --- PATH (interactive only; macOS brew + cargo + nvm) ------------------------
if [[ "$(uname -s)" == Darwin && -d /opt/homebrew/bin ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

if [[ -s /opt/homebrew/opt/nvm/nvm.sh ]]; then
  . /opt/homebrew/opt/nvm/nvm.sh
elif [[ -s "$NVM_DIR/nvm.sh" ]]; then
  . "$NVM_DIR/nvm.sh"
fi

# --- prompt + terminal --------------------------------------------------------
if hash starship 2> /dev/null; then
  eval "$(starship init zsh)"
fi

if [[ "$(uname -s)" == Darwin && -f "${ZDOTDIR}/.iterm2_shell_integration.zsh" ]]; then
  source "${ZDOTDIR}/.iterm2_shell_integration.zsh"
fi

export GPG_TTY=$(tty)
