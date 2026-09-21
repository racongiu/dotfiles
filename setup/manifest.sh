#!/usr/bin/env sh
# setup/manifest.sh: DATA only, no logic.
# Format: "<source in the repo>  <target under $HOME>", one per line.
# Adding a config = adding ONE line.

dotfiles_links() {
  cat <<'EOF'
# --- ~/.config ---
.config/shell          .config/shell
.config/zsh            .config/zsh
.config/tmux           .config/tmux
.config/git            .config/git
.config/lazygit        .config/lazygit
.config/ghostty        .config/ghostty
.config/kitty          .config/kitty
.config/bat            .config/bat
.config/nvim           .config/nvim
.config/starship.toml  .config/starship.toml
.config/mise           .config/mise
.config/yazi           .config/yazi
.config/uv             .config/uv
scripts                .config/scripts

# --- startup files at the root of $HOME ---
# .zshenv bootstraps ZDOTDIR (docs/architecture.md); .vimrc is the historic
# path, the only one every vim reads.
.zshenv                .zshenv
.vimrc                 .vimrc
.bashrc                .bashrc
.bash_profile          .bash_profile
EOF
}

# Directories to create, one per line. A belt: this step runs before any first
# shell. Three exist ONLY here -- ~/.cache/less and ~/.local/share/python,
# where less and python drop their history in silence when it is missing, and
# ~/.local/bin, which env_path_prepend skips if it does not yet exist.
dotfiles_dirs() {
  cat <<EOF
${XDG_CONFIG_HOME:-$HOME/.config}
${XDG_STATE_HOME:-$HOME/.local/state}/zsh
${XDG_STATE_HOME:-$HOME/.local/state}/bash
${XDG_CACHE_HOME:-$HOME/.cache}/zsh
${XDG_CACHE_HOME:-$HOME/.cache}/less
${XDG_DATA_HOME:-$HOME/.local/share}/mise
${XDG_DATA_HOME:-$HOME/.local/share}/python
$HOME/.local/bin
${REPOS:?REPOS must be set (exported by run)}/github
${REPOS}/gitlab
EOF
}

# History migrations: "<old absolute path>  <new absolute location>".
# UNQUOTED heredoc: $HOME and ${XDG_*:-default} are expanded here.
dotfiles_history_migrations() {
  cat <<EOF
$HOME/.bash_history    ${XDG_STATE_HOME:-$HOME/.local/state}/bash/history
$HOME/.zsh_history     ${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history
$HOME/.lesshst         ${XDG_CACHE_HOME:-$HOME/.cache}/less/history
$HOME/.python_history  ${XDG_DATA_HOME:-$HOME/.local/share}/python/history
EOF
}
