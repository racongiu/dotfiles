#!/usr/bin/env sh
# bash/zsh aliases, POSIX syntax.
# Guarded: a missing tool must not break ls/cat on a fresh machine.

if command -v eza >/dev/null 2>&1; then
  # `--icons=auto` and not `--icons`: the flag takes an OPTIONAL value, so a
  # bare `--icons` swallows the next argument as that value. `ls file` then
  # dies on "invalid value 'file' for '--icons [<WHEN>]'". The `=` binds the
  # value to the flag and nothing can be eaten. Measured on eza 0.23.5.
  alias ls='eza --icons=auto'
  alias ll='eza -lh --icons=auto --git'
  alias la='eza -lah --icons=auto --git'
  # A bare `--icons` is safe HERE: `--git` follows it, so no argument can be
  # swallowed. `--level=2` keeps the tree readable inside a deep repo.
  alias lt='eza --tree --level=2 --long --icons --git'
else
  alias ll='ls -lh'
  alias la='ls -lah'
  # `ls` gets no alias here on purpose: without eza it IS the system ls, and
  # adding flags would mean picking between the BSD and GNU spellings.
  if command -v tree >/dev/null 2>&1; then
    # -L 2: the same depth as the eza form above.
    alias lt='tree -L 2'
  fi
fi

command -v bat >/dev/null 2>&1 && alias cat='bat'
# BSD diff on macOS < 13 has no --color: a broken `diff` everywhere would be
# worse than a monochrome one.
if diff --color=auto /dev/null /dev/null >/dev/null 2>&1; then
  alias diff='diff --color=auto'
fi
alias df='df -h'

# One directory per line, in bash as in zsh.
alias path='printf "%s\n" "$PATH" | tr ":" "\n"'

alias v='nvim'
alias c='clear'

# The formula ships `gcc-16` and never a plain `gcc`: Homebrew will not shadow
# Apple's. PERISHABLE: bump the number when brew moves to gcc-17. A keyboard
# convenience only -- `make` runs `cc` as a program and never sees an alias.
command -v gcc-16 >/dev/null 2>&1 && alias gcc='gcc-16'

# Shell aliases, NOT git aliases: `gs` beats `git st`. The trade-off is that
# they live only in interactive shells; a script or an IDE sees plain git.
if command -v git >/dev/null 2>&1; then
  alias gad='git add'
  alias gad.='git add .'
  alias gst='git status'
  alias gc='git commit -m'
  alias gca='git commit -am'
  alias gpu='git pull origin'
  alias gp='git push'

  alias gd='git diff'
  alias gds='git diff --staged'

  alias gck='git checkout'
  alias gbd='git branch --delete'
  alias gbD='git branch -D'

  # `--oneline` IS `--pretty=oneline --abbrev-commit`, and `--decorate` is the
  # default on a terminal: both measured, both dropped.
  alias gl='git log --graph --oneline'
  alias gconf='git config --list --show-origin --show-scope'

  # --- fzf-git.sh, with a fallback ---
  # Functions, not aliases: the test runs when the command is TYPED, because
  # fzf-git.sh loads late or never (docs/usage.md). `command -v` finds a shell
  # FUNCTION, in dash as in bash and zsh -- measured.
  gb() { if command -v _fzf_git_branches >/dev/null 2>&1; then _fzf_git_branches "$@"; else git branch "$@"; fi; }
  gt() { if command -v _fzf_git_tags >/dev/null 2>&1; then _fzf_git_tags "$@"; else git tag "$@"; fi; }
  gr() { if command -v _fzf_git_remotes >/dev/null 2>&1; then _fzf_git_remotes "$@"; else git remote -v "$@"; fi; }
  gw() { if command -v _fzf_git_worktrees >/dev/null 2>&1; then _fzf_git_worktrees "$@"; else git worktree list "$@"; fi; }
  gh() { if command -v _fzf_git_hashes >/dev/null 2>&1; then _fzf_git_hashes "$@"; else git log --oneline "$@"; fi; }
  ger() { if command -v _fzf_git_each_ref >/dev/null 2>&1; then _fzf_git_each_ref "$@"; else git for-each-ref --format='%(refname:short)' "$@"; fi; }
  # No fallback: it prints the CTRL-G cheat sheet, which has no plain-git twin.
  gfk() {
    if command -v _fzf_git_list_bindings >/dev/null 2>&1; then
      _fzf_git_list_bindings "$@"
    else
      printf 'fzf-git.sh is not loaded (zsh only, through zinit).\n' >&2
      return 1
    fi
  }
fi

# ghc / glc <repo>: clone into $GHREPOS / $GLREPOS, then cd. TIDINESS only --
# git picks the identity from the remote URL, so a plain `git clone` anywhere
# works just as well (.config/git/README.md).
ghc() { git clone -- "git@github.com:${GITUSER}/$1.git" "${GHREPOS}/$1" && cd -- "${GHREPOS}/$1" || return 1; }
glc() { git clone -- "git@gitlab.com:${GLUSER}/$1.git" "${GLREPOS}/$1" && cd -- "${GLREPOS}/$1" || return 1; }
