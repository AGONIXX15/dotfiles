#!/bin/bash

BASE="$HOME/.config/hypr/themes"
WAYBAR="$HOME/.config/waybar"

THEME=$(cat "$BASE/current")
THEME_DIR="$BASE/$THEME"


WALL_FILE="$THEME_DIR/current_wall"

if [ -f "$WALL_FILE" ]; then
    IMG=$(cat "$WALL_FILE")
else
    IMG=$(find "$THEME_DIR/wallpapers" -type f | shuf -n 1)
fi

hyprctl hyprpaper preload "$IMG"
hyprctl hyprpaper wallpaper ",$IMG"


# if [ -f "$THEME_DIR/waybar.css" ]; then
#     cp "$THEME_DIR/waybar.css" "$WAYBAR/style.css"
#     killall waybar 2>/dev/null
#     waybar &
# fi
