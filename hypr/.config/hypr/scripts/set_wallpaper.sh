#!/bin/bash
# Uso: set_wallpaper.sh [imagen]   aplica esa imagen
#      set_wallpaper.sh            selector rofi (Alt+r random, Alt+←/→ category, Alt+a all)
#      set_wallpaper.sh --thumbs   (re)genera miniaturas de todos los temas

BASE="$HOME/.config/hypr/themes"
CACHE="$HOME/.cache/wallthumbs"

thumb_of() { echo "$CACHE/$(basename "$(dirname "$(dirname "$1")")")/$(basename "$1").jpg"; }

make_thumb() {
    t=$(thumb_of "$1")
    [ "$1" -nt "$t" ] || return 0
    mkdir -p "$(dirname "$t")"
    magick "$1" -thumbnail 600x900^ -gravity center -extent 600x900 -quality 85 "$t"
}

if [ "$1" = "--thumbs" ]; then
    export -f make_thumb thumb_of; export CACHE
    find "$BASE"/*/wallpapers -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \) -print0 \
        | xargs -0 -P"$(nproc)" -I{} bash -c 'make_thumb "$1"' _ {}
    exit
fi

THEME=$(cat "$BASE/current")
DIR="$BASE/$THEME/wallpapers"

if [ -n "$1" ]; then
    IMG="$1"
else
    "$0" --thumbs   # solo genera las que faltan

    mapfile -t THEMES < <(for d in "$BASE"/*/wallpapers; do basename "$(dirname "$d")"; done | sort)
    PRIMARY=$(sed -n 's/.*selected: *\(#[0-9a-fA-F]\{6\}\).*/\1/p' ~/.config/rofi/colors/matugen.rasi)
    ALL=0; ORIG=$THEME
    while true; do
        # mapa "tema/nombre" -> ruta completa
        declare -A MAP=()
        for t in "${THEMES[@]}"; do
            [ $ALL -eq 0 ] && [ "$t" != "$THEME" ] && continue
            while IFS= read -r f; do MAP["$t/$(basename "$f")"]="$f"; done < <(find "$BASE/$t/wallpapers" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \) | sort)
        done
        [ ${#MAP[@]} -eq 0 ] && { notify-send "Error" "No wallpapers found in $THEME"; exit 1; }

        # barra de categorías (pango); la activa en color primary
        MESG=""
        for t in "${THEMES[@]}" all; do
            if { [ $ALL -eq 0 ] && [ "$t" = "$THEME" ]; } || { [ $ALL -eq 1 ] && [ "$t" = all ]; }; then
                MESG+="<span foreground='$PRIMARY' weight='bold'>[$t]</span>   "
            else MESG+="$t   "; fi
        done
        MESG+=$'\n'"<span size='small' alpha='60%'>Alt+← → category  ·  Alt+A all  ·  Alt+R random  ·  type to search</span>"

        SELECTED=$(printf '%s\n' "${!MAP[@]}" | sort | while IFS= read -r n; do
            printf '%s\0icon\x1f%s\n' "$n" "$(thumb_of "${MAP[$n]}")"
        done | rofi -dmenu -show-icons -p "󰸉  $([ $ALL -eq 1 ] && echo all || echo "$THEME")" -mesg "$MESG" \
            -kb-custom-1 "Alt+r" -kb-custom-2 "Alt+Right" -kb-custom-3 "Alt+Left" -kb-custom-4 "Alt+a" \
            -theme ~/.config/rofi/wallpaper.rasi)
        rc=$?

        # índice del tema actual para moverse entre categorías
        idx=0; for k in "${!THEMES[@]}"; do [ "${THEMES[$k]}" = "$THEME" ] && idx=$k; done
        n=${#THEMES[@]}
        case $rc in
            11) [ $ALL -eq 1 ] && ALL=0 || idx=$(( (idx + 1) % n )); THEME=${THEMES[$idx]}; echo "$THEME" > "$BASE/current"; continue ;;
            12) [ $ALL -eq 1 ] && ALL=0 || idx=$(( (idx + n - 1) % n )); THEME=${THEMES[$idx]}; echo "$THEME" > "$BASE/current"; continue ;;
            13) ALL=1; continue ;;
            10) KEYS=("${!MAP[@]}"); SELECTED="${KEYS[RANDOM % ${#KEYS[@]}]}" ;;
        esac
        break
    done
    [ -z "$SELECTED" ] && { echo "$ORIG" > "$BASE/current"; exit; }   # cancelar no cambia de tema
    IMG="${MAP[$SELECTED]}"
fi

# el wallpaper se guarda en el tema al que pertenece la imagen
case "$IMG" in "$BASE"/*/wallpapers/*) THEME=$(basename "$(dirname "$(dirname "$IMG")")"); echo "$THEME" > "$BASE/current" ;; esac

[ -f "$IMG" ] || { notify-send "Error" "Wallpaper not found: $IMG"; exit 1; }

echo "$IMG" > "$BASE/$THEME/current_wall"

# posición del cursor en píxeles físicos desde abajo-izquierda; si falla, centro
POS=$(hyprctl monitors | awk '/^Monitor/{n++} n==1 && /@/{split($1,r,"[x@]"); h=r[2]} n==1 && /scale:/{s=$2} END{print h" "s}')
read -r H S <<< "$POS"
IFS=', ' read -r CX CY < <(hyprctl cursorpos)
if [ -n "$H" ] && [ -n "$S" ] && [ -n "$CX" ]; then
    TPOS=$(awk -v x="$CX" -v y="$CY" -v h="$H" -v s="$S" 'BEGIN{printf "%d,%d", x*s, h-y*s}')
else
    TPOS=center
fi

pgrep -x awww-daemon >/dev/null || { setsid -f awww-daemon; sleep 1; }
TYPES=(grow wave outer wipe center)
awww img "$IMG" --transition-type "${TYPES[RANDOM % 5]}" --transition-pos "$TPOS" --transition-duration 1.2 --transition-fps 60

# lo lento va en segundo plano
(
    cp "$IMG" ~/.cache/current_wall   # para hyprlock y rofi
    matugen image "$IMG" -m dark --prefer saturation >/dev/null 2>&1
    T=$(thumb_of "$IMG"); [ -f "$T" ] || T="$IMG"
    notify-send -i "$T" "Wallpaper changed" "$(basename "$IMG")"
) >/dev/null 2>&1 &
disown
