#!/bin/bash
# Menú rofi de bluetooth. `bluetooth.sh --list` imprime las líneas sin rofi.
THEME=~/.config/rofi/menu.rasi

bluetoothctl show >/dev/null 2>&1 || { notify-send -u critical "Bluetooth" "No hay controlador (¿bluetooth.service apagado?)"; exit 1; }

build() {
    LINES=(); ACTS=()
    if bluetoothctl show | grep -q 'Powered: yes'; then
        LINES+=("󰂯  Bluetooth: on"); ACTS+=(toggle)
        LINES+=("󰂰  Escanear (5 s)"); ACTS+=(scan)
        while read -r _ mac name; do
            info=$(bluetoothctl info "$mac")
            if grep -q 'Connected: yes' <<<"$info"; then ic=󰂱; st="conectado"
            elif grep -q 'Paired: yes' <<<"$info"; then ic=󰨋; st="emparejado"
            else ic=󰨋; st=""; fi
            bat=$(sed -n 's/.*Battery Percentage: 0x\([0-9a-f]*\).*/\1/p' <<<"$info")
            l="$ic  $name"
            [ -n "$st" ] && l+="  ($st)"
            [ -n "$bat" ] && l+="  󰁹 $((16#$bat))%"
            LINES+=("$l"); ACTS+=("dev:$mac:$st")
        done < <(bluetoothctl devices)
    else
        LINES+=("󰂲  Bluetooth: off"); ACTS+=(toggle)
    fi
}

build
[ "$1" = --list ] && { printf '%s\n' "${LINES[@]}"; exit; }

i=$(printf '%s\n' "${LINES[@]}" | rofi -dmenu -i -format i -p "󰂯" -mesg "Bluetooth" -theme "$THEME")
[ -z "$i" ] && exit
act=${ACTS[$i]}
case $act in
    toggle) bluetoothctl show | grep -q 'Powered: yes' && bluetoothctl power off || bluetoothctl power on; sleep 1; exec "$0" ;;
    scan)   bluetoothctl --timeout 5 scan on >/dev/null 2>&1; exec "$0" ;;
    dev:*)
        rest=${act#dev:}; mac=${rest:0:17}; st=${rest:18}
        case $st in
            conectado) bluetoothctl disconnect "$mac" >/dev/null && notify-send "Bluetooth" "Desconectado" ;;
            emparejado) bluetoothctl connect "$mac" >/dev/null 2>&1 && notify-send "Bluetooth" "Conectado" || notify-send -u critical "Bluetooth" "No se pudo conectar" ;;
            *) bluetoothctl pair "$mac" >/dev/null 2>&1 && bluetoothctl trust "$mac" >/dev/null && bluetoothctl connect "$mac" >/dev/null 2>&1 \
                   && notify-send "Bluetooth" "Emparejado y conectado" || notify-send -u critical "Bluetooth" "Falló el emparejamiento" ;;
        esac ;;
esac
