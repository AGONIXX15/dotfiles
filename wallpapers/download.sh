#!/bin/bash
# Descarga los wallpapers de wallpapers.txt (tema|url) a ~/.config/hypr/themes/<tema>/wallpapers/
cd "$(dirname "$0")" || exit 1
base="$HOME/.config/hypr/themes"
fail=0
grep -v '^#' wallpapers.txt | while IFS='|' read -r theme url; do
    [ -z "$url" ] && continue
    out="$base/$theme/wallpapers/$(basename "${url%%\?*}")"
    [ -s "$out" ] && continue
    mkdir -p "$(dirname "$out")"
    curl -sfL "$url" -o "$out" || { echo "falló: $url" >&2; rm -f "$out"; fail=1; }
done
exit $fail
