#!/usr/bin/env sh
# Step symlinks: apply the link manifest (setup/manifest.sh).

. "$DOTFILES_DIR/setup/manifest.sh"

dotfiles_links | while read -r _src _dst _rest; do
  [ -z "${_src:-}" ] && continue
  case "$_src" in \#*) continue ;; esac
  # A line is EXACTLY "<source> <target>". A missing target would link into
  # "$HOME/" itself; an extra field is a typo, or a path with spaces, which is
  # unsupported by design. Refuse both rather than link in the wrong place.
  if [ -z "${_dst:-}" ] || [ -n "${_rest:-}" ]; then
    log_error "manifest: invalid line, expected 2 fields: $_src ${_dst:-} ${_rest:-}"
    continue
  fi
  link_with_backup "$_src" "$_dst"
done

# Only once ~/.zshenv is really OUR link, since that link is what makes these
# files dead: moving them earlier would take away a working ~/.zshrc. A dry run
# passes the gate on purpose -- it shows what a real run WOULD move.
# shellcheck disable=SC3013  # -ef: extension supported by dash/bash/zsh
if [ "$DRY_RUN" = 1 ] ||
  { [ -L "$HOME/.zshenv" ] && [ "$HOME/.zshenv" -ef "$DOTFILES_DIR/.zshenv" ]; }; then
  dotfiles_superseded | while read -r _p _rest; do
    [ -z "${_p:-}" ] && continue
    case "$_p" in \#*) continue ;; esac
    # Unquoted on purpose: an entry may be a glob. No match leaves the pattern
    # itself, which the -e test below skips.
    # shellcheck disable=SC2086
    for _f in $_p; do
      { [ -e "$_f" ] || [ -L "$_f" ]; } || continue
      backup_file "$_f"
    done
  done
fi

# Also fixes the step's exit status: it is that of its LAST command, which
# without this line would be whichever link happened to come last.
log_done_clean "symlinks applied" \
  "symlinks: some could not be applied (see the ✗ above)"
