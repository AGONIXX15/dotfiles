# dotfiles

Configuración de Arch Linux con Hyprland, gestionada con [GNU stow](https://www.gnu.org/software/stow/).
Los colores del escritorio se generan a partir del wallpaper con [matugen](https://github.com/InioX/matugen).

## Estructura

Cada carpeta es un paquete de stow que imita `$HOME`:

```
hypr/       Hyprland (hyprland.lua), hypridle, hyprlock, hyprsunset, scripts y tema retro
waybar/     barra
rofi/       launcher, selector de wallpaper, powermenu, menús de wifi y bluetooth
kitty/ swaync/ fastfetch/ gsimplecal/ cava/ btop/ nvim/
matugen/    config y plantillas que generan los colores
gtk/        settings.ini de gtk-3.0 y gtk-4.0
zsh/  starship/  git/  code-cp/ (VS Code para competitiva, comando cpv)
packages/   pacman.txt, aur.txt (base), extra.txt, aur-extra.txt (apps pesadas), hardware.txt (esta máquina)
wallpapers/ wallpapers.txt (tema|url) y download.sh
install.sh
```

Los archivos generados (colores de matugen, `current_wall`, wallpapers descargados) no se versionan; ver `.gitignore`.

## Instalación

```sh
git clone https://github.com/AGONIXX15/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh --dry-run   # muestra lo que haría
./install.sh             # instalación completa
```

Opciones:

| Flag | Efecto |
|---|---|
| `--dry-run` | no cambia nada, solo muestra los pasos |
| `--minimal` | omite `packages/extra.txt` y `packages/aur-extra.txt` (apps pesadas: wine, texlive, steam, IDEs...) |
| `--hardware` | instala también `packages/hardware.txt` (nvidia, intel, grub, kernel y firmware; solo para esta máquina) |

`install.sh` es idempotente. En orden: instala `git` y `base-devel`, activa `[multilib]` y sincroniza pacman, instala los paquetes
oficiales, instala yay y los paquetes AUR, respalda las configs que choquen (en `~/.dotfiles-backup-<fecha>`), enlaza todo con stow,
activa NetworkManager, bluetooth y sddm (si no hay otro gestor de login), cambia el shell a zsh, descarga los wallpapers, genera las
miniaturas y los colores con matugen.

Primer inicio de sesión: si ejecutaste el instalador desde un TTY, awww no está disponible todavía. El script solo genera los colores y
guarda el wallpaper inicial; Hyprland lo aplica al arrancar. Inicia sesión en Hyprland desde sddm o con `Hyprland` en el TTY.

## Agregar una config nueva

```sh
mkdir -p nuevo/.config/nuevo
mv ~/.config/nuevo/* nuevo/.config/nuevo/
stow --no-folding -t ~ nuevo
```

Agrega el nombre del paquete a `PKGS` en `install.sh`. Usa siempre `--no-folding` para que los
archivos generados o locales puedan convivir con los enlazados en la misma carpeta.

## Modos

- `nv`: desarrollo con Neovim (LazyVim con extras de TypeScript, Python, Java, Go, Rust, Dart, Docker, SQL y más; Mason instala los LSP).
- `cpv`: VS Code (Code - OSS) en una instancia aparte, sin Vim, para practicar programación competitiva: en concursos tipo ICPC no hay Vim.
  Usa Competitive Companion en el navegador para traer los casos de prueba, la extensión CPH para correrlos, `F5` para compilar y
  ejecutar con `input.txt` si existe, y la plantilla en `~/.config/code-cp/template.cpp`. Abre `~/cp` por defecto.

## Atajos de teclado (SUPER = tecla Windows)

| Atajo | Acción |
|---|---|
| SUPER + Return | terminal (kitty) |
| SUPER + CTRL + Return | launcher (rofi) |
| SUPER + B / E | navegador / archivos |
| SUPER + Q | cerrar ventana |
| SUPER + F | pantalla completa |
| SUPER + SHIFT + V | alternar flotante |
| SUPER + P / J | pseudo / cambiar división |
| SUPER + flechas | mover el foco |
| SUPER + 1..0 | ir al workspace |
| SUPER + SHIFT + 1..0 | mover ventana al workspace |
| SUPER + S / SHIFT + S | workspace especial / mover a él |
| SUPER + rueda | cambiar de workspace |
| SUPER + clic izq. / der. | mover / redimensionar ventana |
| SUPER + SHIFT + W | selector de wallpaper (Alt+←/→ categoría, Alt+a todas, Alt+r aleatorio) |
| SUPER + N | panel de notificaciones |
| SUPER + X | menú de apagado |
| SUPER + ESCAPE | bloquear pantalla |
| SUPER + V | historial del portapapeles |
| SUPER + SHIFT + C | selector de color |
| Print / SHIFT + Print / SUPER + Print | captura de región / pantalla / ventana (satty) |
| SUPER + M | salir de Hyprland |
| SUPER + W | depurar waybar |
| teclas de volumen, brillo y multimedia | OSD (swayosd) y playerctl |

En waybar: clic en el reloj abre el calendario, clic derecho alterna la luz nocturna; clic en red y bluetooth
abre sus menús.
