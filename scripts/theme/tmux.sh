#!/usr/bin/env sh
# theme/tmux.sh: re-sources a tmux theme file, and ONLY when the answer
# changed -- the status line calls this every status-interval. Prints nothing.
# @theme holds the last answer: it lives in the tmux server and dies with it.
set -u

_cfg="${XDG_CONFIG_HOME:-$HOME/.config}"
_want=$("$_cfg/scripts/theme/detect.sh" 2>/dev/null)

[ -n "$_want" ] || exit 0
[ "$_want" = "$(tmux show-option -gqv @theme 2>/dev/null)" ] && exit 0

case "$_want" in
  light) _file=latte ;;
  *) _file=mocha ;;
esac

tmux set-option -g @theme "$_want" >/dev/null 2>&1
tmux source-file "$_cfg/tmux/themes/$_file.conf" >/dev/null 2>&1
