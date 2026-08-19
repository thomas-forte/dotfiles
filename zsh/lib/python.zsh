#!/bin/zsh

py () {
  if (( ${+VIRTUAL_ENV} )); then
    deactivate
  elif [[ -d venv ]]; then
    source venv/bin/activate
  elif [[ -d .venv ]]; then
    source .venv/bin/activate
  else
    echo "no venv/ or .venv/ here — try: python3 -m venv .venv"
  fi
}
