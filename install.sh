#!/bin/bash
# Instalador para Arch Linux. Idempotente.
# Uso: ./install.sh [--dry-run] [--minimal] [--hardware]
#   --dry-run   muestra lo que haría sin cambiar nada
#   --minimal   omite packages/extra.txt y packages/aur-extra.txt (apps pesadas)
#   --hardware  instala también packages/hardware.txt (nvidia, intel, grub, kernel...)
set -u
cd "$(dirname "$(readlink -f "$0")")" || exit 1

DRY=0; MINIMAL=0; HARDWARE=0
for a in "$@"; do
    case $a in
        --dry-run) DRY=1 ;; --minimal) MINIMAL=1 ;; --hardware) HARDWARE=1 ;;
        *) echo "opción desconocida: $a"; exit 2 ;;
    esac
done

PKGS=(hypr waybar rofi kitty swaync matugen fastfetch gsimplecal cava btop gtk nvim zsh starship git code-cp)
BACKUP="$HOME/.dotfiles-backup-$(date +%F-%H%M)"
THEMES="$HOME/.config/hypr/themes"
DONE=(); FAILED=()

run() {  # run <descripción> <comando...>
    local desc=$1; shift
    echo "-> $desc"
    if [ $DRY -eq 1 ]; then echo "   [dry-run] $*"; DONE+=("$desc (simulado)"); return; fi
    if "$@"; then DONE+=("$desc"); else FAILED+=("$desc"); fi
}

# listas de paquetes (sin comentarios ni líneas vacías)
list() { cat "$@" | grep -v '^\s*\(#\|$\)'; }
PACMAN_LISTS=(packages/pacman.txt); AUR_LISTS=(packages/aur.txt)
[ $HARDWARE -eq 1 ] && PACMAN_LISTS+=(packages/hardware.txt)
[ $MINIMAL -eq 0 ] && { PACMAN_LISTS+=(packages/extra.txt); AUR_LISTS+=(packages/aur-extra.txt); }

# 1. herramientas base y multilib
run "git y base-devel" sudo pacman -S --needed --noconfirm git base-devel
if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
    run "activar [multilib]" sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
fi
run "sincronizar pacman" sudo pacman -Sy

# 2. paquetes oficiales
run "paquetes pacman" bash -c 'list() { cat "$@" | grep -v "^\s*\(#\|$\)"; }; list "$@" | sudo pacman -S --needed --noconfirm -' _ "${PACMAN_LISTS[@]}"

# 3. yay y paquetes AUR
if ! command -v yay >/dev/null; then
    run "instalar yay" bash -c 'tmp=$(mktemp -d) && git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay" && cd "$tmp/yay" && makepkg -si --noconfirm'
fi
run "paquetes AUR" bash -c 'cat "$@" | grep -v "^\s*\(#\|$\)" | xargs yay -S --needed --noconfirm' _ "${AUR_LISTS[@]}"

# 4. configs: respaldar lo que choque y enlazar con stow
for p in "${PKGS[@]}"; do
    while IFS= read -r f; do
        rel=${f#"$p"/}; dst="$HOME/$rel"
        if [ -e "$dst" ] && [ ! -L "$dst" ]; then
            echo "-> respaldo $dst"
            [ $DRY -eq 1 ] || { mkdir -p "$BACKUP/$(dirname "$rel")"; mv "$dst" "$BACKUP/$rel"; }
        fi
    done < <(find "$p" -type f)
    run "stow $p" stow --no-folding -R -t "$HOME" "$p"
done

# 4b. extensiones de la instancia cpv (VS Code para competitiva); las que no existan en Open VSX se reportan
if command -v code >/dev/null; then
    while IFS= read -r ext; do
        [ -z "$ext" ] && continue
        run "extensión cpv: $ext" code --user-data-dir "$HOME/.config/code-cp" --extensions-dir "$HOME/.local/share/code-cp/extensions" --install-extension "$ext"
    done < <(grep -v '^\s*\(#\|$\)' code-cp/.config/code-cp/extensions.txt)
fi

# 5. servicios y shell
run "habilitar NetworkManager" sudo systemctl enable NetworkManager
run "habilitar bluetooth"      sudo systemctl enable bluetooth
if list "${PACMAN_LISTS[@]}" | grep -qx sddm && ! systemctl is-enabled display-manager.service >/dev/null 2>&1; then
    run "habilitar sddm" sudo systemctl enable sddm
fi
[ "$(basename "${SHELL:-}")" = zsh ] || run "shell por defecto: zsh" chsh -s "$(command -v zsh || echo /usr/bin/zsh)"

# 6. wallpapers, miniaturas y colores
run "descargar wallpapers" wallpapers/download.sh
[ $DRY -eq 1 ] || [ -f "$THEMES/current" ] || echo nature > "$THEMES/current"
theme=$(cat "$THEMES/current" 2>/dev/null || echo nature)
run "miniaturas" "$HOME/.config/hypr/scripts/set_wallpaper.sh" --thumbs
first=$(find "$THEMES/$theme/wallpapers" -maxdepth 1 -type f 2>/dev/null | sort | head -1)
if [ -z "$first" ] && [ $DRY -eq 0 ]; then
    FAILED+=("no hay wallpapers en el tema $theme")
elif [ -n "${WAYLAND_DISPLAY:-}" ]; then
    run "aplicar wallpaper inicial" "$HOME/.config/hypr/scripts/set_wallpaper.sh" "${first:-/nonexistent}"
else
    # desde TTY no hay awww: solo guarda el wallpaper y genera los colores; Hyprland lo aplica al iniciar
    run "guardar wallpaper inicial" bash -c 'echo "$1" > "$2/$3/current_wall"' _ "$first" "$THEMES" "$theme"
    run "generar colores (matugen)" matugen image "$first" -m dark --prefer saturation
    if [ $DRY -eq 0 ]; then
        for f in "$HOME/.config/waybar/colors.css" "$HOME/.config/rofi/colors/matugen.rasi"; do
            [ -f "$f" ] && DONE+=("existe $f") || FAILED+=("falta $f")
        done
    fi
fi

# 7. resumen
echo; echo "== Resumen =="
printf 'OK:     %s\n' "${DONE[@]:-ninguno}"
[ ${#FAILED[@]} -gt 0 ] && printf 'FALLÓ:  %s\n' "${FAILED[@]}"
[ -d "$BACKUP" ] && echo "Respaldo de configs previas: $BACKUP"
exit ${#FAILED[@]}
