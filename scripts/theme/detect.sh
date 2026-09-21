#!/usr/bin/env sh
# theme/detect.sh: prints "light" or "dark", nothing else. Twin of the file of
# the same name in the school repo, identical below this header.
# The order of the probes, and what each one covers: docs/outils.md.
set -u

case "${TERM_THEME:-}" in
  light | dark)
    printf '%s\n' "$TERM_THEME"
    exit 0
    ;;
esac

# gdbus prints "(<uint32 2>,)" and busctl "v u 2": the value is the LAST
# number, "uint32" contributing a stray 32.
_portal_color_scheme() {
  gdbus call --session --dest org.freedesktop.portal.Desktop \
    --object-path /org/freedesktop/portal/desktop \
    --method org.freedesktop.portal.Settings.ReadOne \
    org.freedesktop.appearance color-scheme 2>/dev/null ||
    busctl --user call org.freedesktop.portal.Desktop \
      /org/freedesktop/portal/desktop org.freedesktop.portal.Settings \
      ReadOne ss org.freedesktop.appearance color-scheme 2>/dev/null
}

_light=false
case "$(uname -s)" in
  Darwin)
    # `defaults read` EXITS 1 when the key is absent, and absent IS light.
    [ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" != "Dark" ] && _light=true
    ;;
  Linux)
    # 2 light, 1 dark, 0 no preference -- 0 decides nothing and falls through.
    case "$(_portal_color_scheme | tr -cs '0-9' ' ' | awk '{print $NF}')" in
      2) _light=true ;;
      1) ;;
      *)
        gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null |
          grep -q prefer-light && _light=true
        ;;
    esac
    ;;
esac

if [ "$_light" = true ]; then
  printf 'light\n'
else
  printf 'dark\n'
fi
