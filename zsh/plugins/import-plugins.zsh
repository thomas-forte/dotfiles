# Bundle registration only — `.zshrc` runs `antigen apply` and a single
# `compinit` after lib/completions.zsh so fpath/zstyle are final.
# Keep syntax-highlighting last among bundles (zle widget ordering).
#
# Note: when Antigen zcache (init.zsh) is active, `antigen bundle`/`apply`
# from sourced files may no-op; bundles still load from the cache. After
# changing plugin lists, run: antigen reset && exec zsh

antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting
