#!/bin/bash
# Alterna luz nocturna: 4000K <-> 6500K (el horario de hyprsunset.conf vuelve a mandar en el siguiente cambio de perfil)
pgrep -x hyprsunset >/dev/null || { setsid -f hyprsunset >/dev/null 2>&1; sleep 1; }
t=$(hyprctl hyprsunset temperature | grep -o '[0-9]\+' | head -1)
if [ "${t:-6500}" -ge 6000 ]; then hyprctl hyprsunset temperature 4000; else hyprctl hyprsunset temperature 6500; fi
