#!/bin/zsh

antigen_dir="${ADOTDIR}"
antigen_git="https://raw.githubusercontent.com/zsh-users/antigen/master/bin/antigen.zsh"
antigen_bin="${ADOTDIR}/antigen.zsh"

# Import angigen if present, or prompt to install if missing
if [[ -f $antigen_bin ]]; then
  source $antigen_bin
else
  if read -q "choice?Would you like to install Antigen now? (y/N)"; then
    echo
    mkdir -p $antigen_dir
    curl -L $antigen_git > $antigen_bin
    source $antigen_bin
  fi
fi