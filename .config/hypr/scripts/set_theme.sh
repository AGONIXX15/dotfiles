#!/bin/bash

BASE="$HOME/.config/hypr/themes"
WAYBAR="$HOME/.config/waybar"

# select theme
THEME=$(find "$BASE" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | rofi -dmenu -p "Theme")

[ -z "$THEME" ] && exit

# guardar tema actual
echo "$THEME" > "$BASE/current"

THEME_DIR="$BASE/$THEME"


WALL_FILE="$THEME_DIR/current_wall"

# is file and not empty
if [ -f "$WALL_FILE" ] && [ -s "$WALL_FILE" ]; then
    IMG=$(cat "$WALL_FILE")
    
    # still exist
    if [ ! -f "$IMG" ]; then
        IMG=$(find "$THEME_DIR/wallpapers" -type f | shuf -n 1)
        echo "$IMG" > "$WALL_FILE"
    fi
else
    IMG=$(find "$THEME_DIR/wallpapers" -type f | shuf -n 1)
    echo "$IMG" > "$WALL_FILE"
fi
hyprctl hyprpaper preload "$IMG"
hyprctl hyprpaper wallpaper ",$IMG"


# if [ -f "$THEME_DIR/waybar.css" ]; then
#     cp "$THEME_DIR/waybar.css" "$WAYBAR/style.css"
#     killall waybar 2>/dev/null
#     waybar &
# fi


# 
# if [ -f "$THEME_DIR/kitty.conf" ]; then
#     cp "$THEME_DIR/kitty.conf" ~/.config/kitty/kitty.conf
# fi


#notify
notify-send "Theme changed" "$THEME"
