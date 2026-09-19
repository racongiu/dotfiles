#!/usr/bin/env sh
# bootstrap-aidd.sh: install my agent config on a fresh machine.
# Clones aidd + library into ~/.config/aiddconf, then deploys the symlinks.
# Idempotent: safe to re-run (clone if missing, pull otherwise).
set -eu

readonly CONF="${XDG_CONFIG_HOME:-$HOME/.config}/aiddconf"
readonly AIDD_URL="git@github.com:racongiu/aidd.git"
readonly LIB_URL="git@github.com:racongiu/aidd-library.git"

# --- Prerequisites: git installed + GitHub SSH access ---
check_prereqs() {
  command -v git >/dev/null 2>&1 || {
    printf 'Error: git not found in PATH.\n' >&2
    exit 1
  }
  _out=$(ssh -o BatchMode=yes -o ConnectTimeout=5 -T git@github.com 2>&1 || true)
  case "$_out" in
    *"successfully authenticated"*) ;;
    *)
      printf 'Error: GitHub SSH access unavailable (key missing or not loaded).\n' >&2
      printf 'Check with: ssh -T git@github.com\n' >&2
      exit 1
      ;;
  esac
}

clone_or_pull() { # <url> <dest>
  _url="$1"
  _dest="$2"
  if [ -d "$_dest/.git" ]; then
    printf '[pull]  %s\n' "$_dest"
    git -C "$_dest" pull --ff-only ||
      printf '[warn] pull failed (%s), keeping current state\n' "$_dest" >&2
  else
    printf '[clone] %s -> %s\n' "$_url" "$_dest"
    git clone -- "$_url" "$_dest"
  fi
}

check_prereqs
mkdir -p -- "$CONF"
clone_or_pull "$AIDD_URL" "$CONF/aidd"
clone_or_pull "$LIB_URL" "$CONF/library"

# Deploy the symlinks to ~/.claude (install.sh computes conf = parent of aidd)
[ -x "$CONF/aidd/install.sh" ] || {
  printf 'Error: %s missing or not executable.\n' "$CONF/aidd/install.sh" >&2
  exit 1
}
"$CONF/aidd/install.sh"

printf '\nOK. Config deployed.\n'
printf 'In Claude Code: /library sync (or /library use <name> global) to reinstall your skills.\n'
