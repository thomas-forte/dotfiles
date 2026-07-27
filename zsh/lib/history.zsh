#!/bin/zsh

HISTFILE="${XDG_DATA_HOME}/.zhistory"
SAVEHIST=1000000
HISTSIZE=$(( SAVEHIST * 12 / 10 ))

## History command configuration
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when SAVEHIST/HISTSIZE exceeds
setopt hist_ignore_all_dups   # remove older duplicates when saving "move to newest position"
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data
setopt hist_no_store          # dont add history command to history