#!/bin/bash
# Instalador para Arch Linux. Idempotente. Uso: ./install.sh [--dry-run]
set -u
cd "$(dirname "$(readlink -f "$0")")" || exit 1

DRY=0; [ "${1:-}" = "--dry-run" ] && DRY=1
PKGS=(hypr waybar rofi kitty swaync matugen fastfetch gsimplecal cava btop gtk nvim zsh starship git)
BACKUP="$HOME/.dotfiles-backup-$(date +%F-%H%M)"
DONE=(); FAILED=()

run() {  # run <descripción> <comando...>
    local desc=$1; shift
    echo "-> $desc"
    if [ $DRY -eq 1 ]; then echo "   [dry-run] $*"; DONE+=("$desc (simulado)"); return; fi
    if "$@"; then DONE+=("$desc"); else FAILED+=("$desc"); fi
}

# 1. yay
if ! command -v yay >/dev/null; then
    run "instalar yay" bash -c 'tmp=$(mktemp -d) && git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay" && cd "$tmp/yay" && makepkg -si --noconfirm'
fi

# 2. paquetes
run "paquetes pacman" bash -c 'sudo pacman -S --needed - < packages/pacman.txt'
run "paquetes AUR"    bash -c 'yay -S --needed - < packages/aur.txt'

# 3. configs: respaldar lo que choque y enlazar con stow
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

# 4. servicios y shell
run "habilitar NetworkManager" sudo systemctl enable NetworkManager
run "habilitar bluetooth"      sudo systemctl enable bluetooth
[ "$(basename "${SHELL:-}")" = zsh ] || run "shell por defecto: zsh" chsh -s "$(command -v zsh || echo /usr/bin/zsh)"

# 5. wallpapers, miniaturas y primer wallpaper (matugen genera los colores)
run "descargar wallpapers" wallpapers/download.sh
[ -f "$HOME/.config/hypr/themes/current" ] || { [ $DRY -eq 1 ] || echo nature > "$HOME/.config/hypr/themes/current"; }
run "miniaturas" "$HOME/.config/hypr/scripts/set_wallpaper.sh" --thumbs
first=$(find "$HOME/.config/hypr/themes/$(cat "$HOME/.config/hypr/themes/current" 2>/dev/null || echo nature)/wallpapers" -maxdepth 1 -type f 2>/dev/null | sort | head -1)
[ -n "$first" ] || [ $DRY -eq 1 ] || FAILED+=("no hay wallpapers para aplicar")
run "aplicar wallpaper inicial" "$HOME/.config/hypr/scripts/set_wallpaper.sh" "${first:-/nonexistent}"

# 6. resumen
echo; echo "== Resumen =="
printf 'OK:     %s\n' "${DONE[@]:-ninguno}"
[ ${#FAILED[@]} -gt 0 ] && printf 'FALLÓ:  %s\n' "${FAILED[@]}"
[ -d "$BACKUP" ] && echo "Respaldo de configs previas: $BACKUP"
exit ${#FAILED[@]}
