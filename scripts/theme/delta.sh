#!/usr/bin/env sh
# theme/delta.sh: delta, flavour chosen AT EACH CALL. An environment variable
# cannot do it: it is frozen when the shell starts, so a shell already open
# keeps serving the old flavour. Measured, and the reason this file exists.
# `--features` here REPLACES `features` in the git config.
set -u

case "$("${XDG_CONFIG_HOME:-$HOME/.config}/scripts/theme/detect.sh" 2>/dev/null)" in
  light) _flavour=catppuccin-latte ;;
  *) _flavour=catppuccin-mocha ;;
esac

exec delta --features="$_flavour" "$@"
