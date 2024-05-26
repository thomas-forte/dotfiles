#!/bin/zsh

HISTFILE="${XDG_DATA_HOME}/.zhistory"
SAVEHIST=$(( 10 * 1000 ))
HISTSIZE=$(( 1.2 * SAVEHIST ))

## History command configuration
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data
setopt hist_no_store          # dont add history command to history