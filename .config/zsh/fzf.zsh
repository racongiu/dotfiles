#!/usr/bin/env zsh

# Sourced unconditionally by .zshrc, so everything here is guarded: without fzf
# this file defines nothing and prints nothing.
((${+commands[fzf]})) || return 0

# --- Source command ---
# fd when available, else find. -path … -prune is portable on GNU and BSD.
if ((${+commands[fd]})); then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix'
  # Same source, without the hidden files (Ctrl+F widget below).
  _FZF_NO_HIDDEN_COMMAND='fd --type f --strip-cwd-prefix'
else
  export FZF_DEFAULT_COMMAND="find . -path '*/.git' -prune -o -type f -print"
  _FZF_NO_HIDDEN_COMMAND="find . -path '*/.*' -prune -o -type f -print"
fi
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_DEFAULT_OPTS='
--height=60%
--layout=reverse
--border=rounded
--prompt=" "
--pointer=" "
--preview-window=right:65%:wrap:border-left'

# bat is optional too: head is always there.
if ((${+commands[bat]})); then
  _FZF_PREVIEW_CMD='bat --color=always --style=plain,numbers --line-range=:500 {}'
else
  _FZF_PREVIEW_CMD='head -n 500 -- {}'
fi
export FZF_CTRL_T_OPTS="--preview '$_FZF_PREVIEW_CMD'"

# --- Ctrl+F: files, hidden ones excluded ---
_fzf_file_no_hidden() {
  local result
  result=$(eval "$_FZF_NO_HIDDEN_COMMAND" | fzf --preview "$_FZF_PREVIEW_CMD") &&
    LBUFFER+="$result"
  zle reset-prompt
}
zle -N _fzf_file_no_hidden
# Declared next to the widget it uses, so it can never outlive it.
bindkey '^F' _fzf_file_no_hidden

# The fzf-git.sh commands are NOT declared here: they live in
# shell/aliases.sh, as functions that fall back to plain git. Sharing them
# with bash is the point, and one namespace beats two.
