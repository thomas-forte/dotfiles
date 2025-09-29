#!/bin/zsh

py () {
  if (( ${+VIRTUAL_ENV} )); then
    deactivate
  elif [[ -d venv ]]; then
    source venv/bin/activate
  elif [[ -d .venv ]]; then
    source .venv/bin/activate
  else
    echo "I only work with venv and .venv!"
  fi
}
