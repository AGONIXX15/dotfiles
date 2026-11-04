-- Migrado desde hyprland.conf + keybinds.conf + workspaces.conf + monitors.conf
-- (Hyprland 0.57 solo lee Lua). Default original en hyprland.lua.default

------------------
---- MONITORS ----
------------------
hl.monitor({ output = "eDP-1", mode = "1920x1080@144", position = "0x0", scale = 1.5, mirror = "HDMI-A-1" })
hl.monitor({ output = "HDMI-A-1", disabled = true })

hl.config({ xwayland = { force_zero_scaling = true } })

---------------------
---- MY PROGRAMS ----
---------------------
local terminal    = "kitty"
local fileManager = "dolphin"
local browser     = "brave"

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("awww-daemon")
    -- awww restore falla en el primer arranque (sin caché): aplica current_wall o el primer wallpaper de nature
    hl.exec_cmd("sh -c 'sleep 1; awww restore || ~/.config/hypr/scripts/set_wallpaper.sh \"$(cat ~/.config/hypr/themes/$(cat ~/.config/hypr/themes/current)/current_wall 2>/dev/null || ls ~/.config/hypr/themes/nature/wallpapers/* | head -1)\"'")
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("swayosd-server")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("hyprsunset")
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 24")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("OZONE_PLATFORM", "wayland")

-----------------------
---- LOOK AND FEEL ----
-----------------------
-- colors.lua lo genera matugen; si no existe se usan estos valores
local ok, colors = pcall(dofile, os.getenv("HOME") .. "/.config/hypr/colors.lua")
if not ok then
    colors = { primary = "rgba(33ccffee)", secondary = "rgba(00ff99ee)", tertiary = "rgba(00ff99ee)", outline = "rgba(595959aa)", shadow = "rgba(33ccff44)" }
end

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,
        border_size = 2,
        col = {
            active_border   = { colors = {colors.primary, colors.tertiary}, angle = 45 },
            inactive_border = colors.outline,
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 0.95,
        dim_inactive     = true,
        dim_strength     = 0.08,
        shadow = {
            enabled      = true,
            range        = 20,
            render_power = 4,
            color        = colors.shadow,
        },
        blur = {
            enabled   = true,
            size      = 6,
            passes    = 3,
            popups    = true,
            vibrancy  = 0.1696,
        },
    },

    animations = { enabled = true },

    master = { new_status = "master" },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
    },
})

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}    } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}  } })
hl.curve("easy", { type = "spring", mass = 1, stiffness = 238.1191, damping = 24.21279333 })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "borderangle",   enabled = true, speed = 30,   bezier = "linear",       style = "loop" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  spring = "easy", style = "popin 80%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 80%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "easeOutQuint", style = "slidefade 15%" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "easeOutQuint", style = "slidefade 15%" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "easeOutQuint", style = "slidefade 15%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2.5, bezier = "easeOutQuint", style = "slidefadevert" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })

---------------
---- INPUT ----
---------------
hl.config({
    input = {
        kb_layout  = "es",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = { natural_scroll = true },
    },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })

---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER"

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu -theme ~/.config/rofi/menu.rasi | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("c=$(hyprpicker -a) && notify-send 'Color' \"$c\""))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/set_wallpaper.sh"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("~/.config/rofi/powermenu/type-1/powermenu.sh"))
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))
hl.bind(mainMod .. " + CONTROL + Return", hl.dsp.exec_cmd("~/.config/rofi/launchers/type-2/launcher.sh"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/debug_waybar.sh"))

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("swayosd-client --brightness raise"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("swayosd-client --brightness lower"),                  { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

hl.bind("Print", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh region"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh output"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh window"))

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})

hl.window_rule({
    name   = "pavucontrol",
    match  = { class = "^(pavucontrol)$" },
    float  = true,
    size   = "600 400",
    center = true,
})

-- blur en capas (glass)
for _, ns in ipairs({ "waybar", "rofi", "swaync-control-center", "swaync-notification-window", "swayosd" }) do
    hl.layer_rule({ name = "blur-" .. ns, match = { namespace = ns }, blur = true, ignore_alpha = 0.3 })
end
hl.layer_rule({ name = "anim-rofi", match = { namespace = "rofi" }, animation = "popin 80%" })

for _, c in ipairs({ "blueman-manager", "nm-connection-editor" }) do
    hl.window_rule({ name = c, match = { class = "^(" .. c .. ")$" }, float = true, center = true })
end

hl.window_rule({
    name   = "gsimplecal",
    match  = { class = "^(gsimplecal)$" },
    float  = true,
    pin    = true,
    rounding = 14,
    border_size = 1,
    animation = "popin 80%",
    move   = "(monitor_w*0.5-window_w*0.5) 56",
})

hl.window_rule({
    name  = "floating-tui",
    match = { class = "^(floating-tui)$" },
    float = true,
    center = true,
    size  = "900 600",
})
