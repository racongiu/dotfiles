#!/usr/bin/env sh
# Environment shared by bash and zsh, POSIX syntax. Also the BASH_ENV target,
# hence MINIMAL on purpose: env and PATH only, nothing interactive, so
# non-interactive scripts stay predictable.

# --- XDG Base Directories ---
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# --- Editor / locale ---
export EDITOR="nvim"
export VISUAL="$EDITOR"
# (no GIT_EDITOR: git already falls back to VISUAL then EDITOR)
export LANG="en_US.UTF-8"

# --- Repos / personal paths ---
# Two forges, two variables, holding the same name today. Kept apart so that
# renaming one account never silently rewrites the other's URLs: `glc` builds
# from GLUSER alone, `ghc` from GITUSER alone.
export GITUSER="racongiu"
export GLUSER="racongiu"
export REPOS="$HOME/lab"
export GHREPOS="$REPOS/github"
export GLREPOS="$REPOS/gitlab"
# Interactive comfort only (`cd $DOTFILES`): nothing reads them. DOTFILES
# hard-codes the README's clone path while `run` computes its own from $0 --
# a clone elsewhere makes the two diverge, and nothing catches it.
export DOTFILES="$HOME/.dotfiles"
if [ -d "$HOME/icloud" ]; then export ICLOUD="$HOME/icloud"; fi

# --- Pager / Browser ---
export PAGER="less"
export LESS="-R --quit-if-one-screen"

# GHSA-jgf3-f6rg-8x3h (High), no fixed version: 3.13.0+ plus this variable IS
# the fix, and its default is "all". "none" states the truth here. Why, and
# what to set the day it changes: docs/security.md.
export SOPS_HC_VAULT_ALLOWLIST="none"
# Only when firefox is actually on the PATH (macOS: fall back to `open`).
if command -v firefox >/dev/null 2>&1; then export BROWSER="firefox"; fi

# --- Tools / history files (XDG) ---
export LESSHISTFILE="${XDG_CACHE_HOME}/less/history"
export PYTHON_HISTORY="${XDG_DATA_HOME}/python/history"
# Tools that default to ~/<dotdir> and accept a redirect. Only tools this
# machine runs: an unused redirect is dead.
export ANSIBLE_HOME="${XDG_DATA_HOME}/ansible" # collections, roles, tmp
export npm_config_cache="${XDG_CACHE_HOME}/npm"

# --- PATH ---
# Prepend <dir> if it exists and is not already there. Idempotent: this file is
# read by every shell, including a re-source.
# zsh re-asserts the final order itself (docs/architecture.md).
env_path_prepend() {
  [ -d "$1" ] || return 0
  case ":$PATH:" in *":$1:"*) return 0 ;; esac
  PATH="$1:$PATH"
}
env_path_prepend "$HOME/.local/bin"
env_path_prepend "${XDG_CONFIG_HOME}/scripts"
env_path_prepend "${XDG_DATA_HOME}/mise/shims" # mise shims first

# Appended, not prepended: an extra that must never shadow a real tool. The -d
# check is the only guard needed: no JetBrains Toolbox, no entry.
env_path_append() {
  [ -d "$1" ] || return 0
  case ":$PATH:" in *":$1:"*) return 0 ;; esac
  PATH="$PATH:$1"
}
# JetBrains Toolbox launchers (idea, pycharm…). The path contains a space:
# every read of PATH here is quoted, and zsh keeps it as one array element.
env_path_append "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"

export PATH

# Sourced by EVERY shell: leave nothing behind.
unset -f env_path_prepend env_path_append
