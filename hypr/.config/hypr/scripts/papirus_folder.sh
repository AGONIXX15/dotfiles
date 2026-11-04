#!/bin/bash
# Colorea las carpetas de Papirus según el tono de primary (#rrggbb). Solo si sudo funciona sin contraseña.
sudo -n true 2>/dev/null || exit 0
color=$(python3 - "$1" <<'PY'
import colorsys, sys
h = sys.argv[1].lstrip('#')
r, g, b = (int(h[i:i+2], 16) / 255 for i in (0, 2, 4))
hue, light, sat = colorsys.rgb_to_hls(r, g, b)
if sat < 0.15: print("grey"); raise SystemExit
hue *= 360
m = {"red": 0, "orange": 25, "yellow": 50, "green": 120, "teal": 170, "cyan": 190,
     "blue": 215, "indigo": 245, "violet": 270, "magenta": 300, "pink": 335}
print(min(m, key=lambda k: min(abs(hue - m[k]), 360 - abs(hue - m[k]))))
PY
)
sudo -n papirus-folders -C "$color" --theme Papirus-Dark >/dev/null 2>&1
