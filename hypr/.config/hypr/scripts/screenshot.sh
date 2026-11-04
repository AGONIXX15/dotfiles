#!/bin/bash
# Uso: screenshot.sh region|window|output  -> hyprshot -> satty (anotar, copiar o guardar)
mode=${1:-region}
[ "$mode" = window ] && set -- -m window -m active || set -- -m "$mode"
hyprshot "$@" --raw | satty --filename - --copy-command wl-copy \
    --output-filename "$HOME/Pictures/Screenshots/shot-$(date +%Y%m%d-%H%M%S).png"
