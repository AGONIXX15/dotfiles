#!/bin/bash
h=$((10#$(date +%H)))
if [ $h -ge 6 ] && [ $h -lt 12 ]; then g="Buenos días"
elif [ $h -ge 12 ] && [ $h -lt 19 ]; then g="Buenas tardes"
else g="Buenas noches"; fi
echo "$g, $(whoami)"
