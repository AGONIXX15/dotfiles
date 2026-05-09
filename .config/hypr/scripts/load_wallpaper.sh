#!/bin/bash

BASE="$HOME/.config/hypr/themes"
THEME=$(cat "$BASE/current")

FILE="$BASE/$THEME/current_wall"

# si no hay wallpaper guardado → random
if [ ! -f "$FILE" ]; then
  IMG=$(find "$BASE/$THEME/wallpapers" -type f | shuf -n 1)
else
  IMG=$(cat "$FILE")
fi

hyprctl hyprpaper preload "$IMG"
hyprctl hyprpaper wallpaper ",$IMG"
