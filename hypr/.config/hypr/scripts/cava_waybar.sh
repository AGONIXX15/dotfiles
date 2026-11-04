#!/bin/bash
# Barras de cava para waybar; solo mientras playerctl dice Playing.
# cava deja de escribir en silencio, así que se lee con timeout y se mata explícitamente.
trap 'kill $CAVA_PID 2>/dev/null' EXIT
playing() { [ "$(playerctl status 2>/dev/null)" = Playing ]; }

while true; do
    if playing; then
        coproc CAVA { exec cava -p ~/.config/cava/config; }
        last=$SECONDS
        while kill -0 "$CAVA_PID" 2>/dev/null; do
            if IFS= read -r -t 1 l <&"${CAVA[0]}"; then
                echo "${l//;/}" | sed 'y/01234567/▁▂▃▄▅▆▇█/'
            fi
            if (( SECONDS != last )); then last=$SECONDS; playing || break; fi
        done
        kill "$CAVA_PID" 2>/dev/null; wait "$CAVA_PID" 2>/dev/null
        echo
    else
        echo; sleep 1
    fi
done
