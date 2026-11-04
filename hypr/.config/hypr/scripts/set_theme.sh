#!/bin/bash

BASE="$HOME/.config/hypr/themes"

# select theme
THEME=$(find "$BASE" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | rofi -dmenu -p "Theme")

[ -z "$THEME" ] && exit

# guardar tema actual
echo "$THEME" > "$BASE/current"

THEME_DIR="$BASE/$THEME"


WALL_FILE="$THEME_DIR/current_wall"

IMG=$(cat "$WALL_FILE" 2>/dev/null)
if [ ! -f "$IMG" ]; then
    IMG=$(find "$THEME_DIR/wallpapers" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)
    [ -z "$IMG" ] && { notify-send "Error" "No wallpapers found in $THEME"; exit 1; }
fi
~/.config/hypr/scripts/set_wallpaper.sh "$IMG"

notify-send "Theme changed" "$THEME"
