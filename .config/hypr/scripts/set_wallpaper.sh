#!/bin/bash

BASE="$HOME/.config/hypr/themes"
THEME=$(cat "$BASE/current")
DIR="$BASE/$THEME/wallpapers"

# verificar carpeta
if [ ! -d "$DIR" ]; then
    notify-send "Error" "No wallpapers directory in theme: $THEME"
    exit 1
fi

# construir mapa: nombre|ruta
MAP=$(find "$DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | while read -r f; do
    echo "$(basename "$f")|$f"
done)

# verificar si hay wallpapers
if [ -z "$MAP" ]; then
    notify-send "Error" "No wallpapers found in $THEME"
    exit 1
fi

# mostrar solo nombres en rofi
SELECTED=$(echo "$MAP" | cut -d'|' -f1 | rofi -dmenu -p "Wallpaper ($THEME)")

[ -z "$SELECTED" ] && exit

# obtener ruta real
IMG=$(echo "$MAP" | grep "^$SELECTED|" | head -n1 | cut -d'|' -f2)

# guardar estado
echo "$IMG" > "$BASE/$THEME/current_wall"

# aplicar wallpaper
hyprctl hyprpaper preload "$IMG"
hyprctl hyprpaper wallpaper ",$IMG"

# notificación
notify-send "Wallpaper changed" "$SELECTED"
