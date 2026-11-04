#!/bin/bash
# Menú rofi de wifi (NetworkManager). `wifi.sh --list` imprime las líneas sin rofi.
THEME=~/.config/rofi/menu.rasi

# nmcli -t -e yes: campos separados por ':' y ':' dentro del SSID escapado como '\:'
networks() {
    nmcli -t -e yes -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list | awk -F: '
        { use=$1; sig=$2; sec=$3; ssid=$4; for (i=5;i<=NF;i++) ssid=ssid ":" $i
          gsub(/\\:/, ":", ssid); gsub(/\\\\/, "\\", ssid)
          if (ssid=="" || seen[ssid]++) next
          print use "\t" sig "\t" sec "\t" ssid }' | sort -t$'\t' -k1,1r -k2,2nr
}

build() {
    LINES=(); ACTS=()
    if [ "$(nmcli radio wifi)" = enabled ]; then
        LINES+=("󰖩  Wifi: on"); ACTS+=(toggle)
        while IFS=$'\t' read -r use sig sec ssid; do
            if   [ "$sig" -ge 75 ]; then ic=󰤨; elif [ "$sig" -ge 50 ]; then ic=󰤥
            elif [ "$sig" -ge 25 ]; then ic=󰤢; else ic=󰤟; fi
            l="$ic  $ssid"
            [ -n "$sec" ] && l+="  󰌾"
            [ "$use" = '*' ] && l+="  ✓"
            LINES+=("$l"); ACTS+=("net:$ssid:${sec:+secure}")
        done < <(networks)
        LINES+=("󰑐  Re-escanear"); ACTS+=(rescan)
        command -v nm-connection-editor >/dev/null && { LINES+=("󰒓  Editor de conexiones"); ACTS+=(edit); }
    else
        LINES+=("󰖪  Wifi: off"); ACTS+=(toggle)
    fi
}

build
[ "$1" = --list ] && { printf '%s\n' "${LINES[@]}"; exit; }

i=$(printf '%s\n' "${LINES[@]}" | rofi -dmenu -i -format i -p "󰖩" -mesg "Redes wifi" -theme "$THEME")
[ -z "$i" ] && exit
act=${ACTS[$i]}
case $act in
    toggle) [ "$(nmcli radio wifi)" = enabled ] && nmcli radio wifi off || nmcli radio wifi on; sleep 1; exec "$0" ;;
    rescan) nmcli dev wifi rescan; sleep 2; exec "$0" ;;
    edit)   nm-connection-editor & ;;
    net:*)
        rest=${act#net:}; secure=${rest##*:}; ssid=${rest%:*}
        if nmcli -g NAME con show | grep -Fxq -- "$ssid"; then
            cmd=(nmcli con up id "$ssid")
        elif [ -z "$secure" ]; then
            cmd=(nmcli dev wifi connect "$ssid")
        else
            pass=$(rofi -dmenu -password -p "󰌾" -mesg "Contraseña para $ssid" -theme "$THEME" </dev/null)
            [ -z "$pass" ] && exit
            cmd=(nmcli dev wifi connect "$ssid" password "$pass")
        fi
        if "${cmd[@]}" >/dev/null 2>&1; then notify-send "Wifi" "Conectado a $ssid"
        else notify-send -u critical "Wifi" "No se pudo conectar a $ssid"; fi ;;
esac
