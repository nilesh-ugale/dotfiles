-- Hyprland Lua config
-- https://wiki.hypr.land/Configuring/Start/


------------------
---- MONITORS ----
------------------

hl.monitor({
    output        = "DP-1",
    mode          = "2560x1440@144",
    position      = "0x0",
    scale         = 1,
    vrr           = 2,
    bitdepth      = 10,
    cm            = "hdr",
    sdrbrightness = 1.2,
    sdrsaturation = 0.98,
})


---------------------
---- MY PROGRAMS ----
---------------------

local terminal       = "kitty"
local fileManager    = "export EDITOR=nvim; kitty -e yazi"
local menu           = "wofi --conf ~/.config/wofi/config --style ~/.config/wofi/style.css --show drun"
local browser        = "~/.config/bin/launch-browser.sh"
local browserPrivate = browser .. " --private"
local wallpaper      = "~/.config/bin/wallpaper.sh"
local powermenu      = "~/.config/bin/powermenu.sh"
local notes          = "~/.config/bin/logseq.sh"


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar & ~/.config/bin/hyprpaper-start.sh")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("DXVK_HDR", "1")
hl.env("ENABLE_HDR_WSI", "1")
hl.env("xx_color_management_v4", "1")
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "30")
hl.env("HYPRCURSOR_THEME", "Adwaita")
hl.env("HYPRCURSOR_SIZE", "30")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")


-----------------------
----- PERMISSIONS -----
-----------------------

-- Permission changes require a Hyprland restart.
hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 5,

        border_size = 2,

        col = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        resize_on_border = false,
        allow_tearing    = false,

        layout = "scrolling",
    },

    cursor = {
        inactive_timeout = 5.0,
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    scrolling = {
        column_width             = 0.5,
        fullscreen_on_one_column = true,
        explicit_column_widths   = "0.5, 1.0",
        focus_fit_method         = 1,
        follow_focus             = true,
    },

    misc = {
        force_default_wallpaper         = 0,
        disable_hyprland_logo           = true,
        disable_hyprland_guiutils_check = true,
        disable_splash_rendering        = true,
        vrr                             = 1,
    },

    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.
    },
})

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}    } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}  } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

local function bind(keys, dispatcher, opts)
    hl.bind(mainMod .. " + " .. keys, dispatcher, opts)
end

bind("Return",    hl.dsp.exec_cmd(terminal))
bind("B",         hl.dsp.exec_cmd(browser))
bind("SHIFT + B", hl.dsp.exec_cmd(browserPrivate))
bind("Q",         hl.dsp.window.close(), { repeating = true })
bind("R",         hl.dsp.exec_cmd("pkill waybar; waybar &"))
bind("SHIFT + E", hl.dsp.exec_cmd(powermenu))
bind("M",         hl.dsp.exit())
bind("L",         hl.dsp.exec_cmd("hyprlock"))
bind("N",         hl.dsp.exec_cmd(notes))
bind("E",         hl.dsp.exec_cmd(fileManager))
bind("V",         hl.dsp.window.float({ action = "toggle" }))
bind("D",         hl.dsp.exec_cmd(menu))

-- Scrolling layout focus
bind("left",  hl.dsp.layout("focus l"), { repeating = true })
bind("right", hl.dsp.layout("focus r"), { repeating = true })
bind("up",    hl.dsp.layout("focus u"), { repeating = true })
bind("down",  hl.dsp.layout("focus d"), { repeating = true })

-- Switch between windows in a floating workspace
bind("Tab", hl.dsp.window.cycle_next())
bind("Tab", hl.dsp.window.bring_to_top())

bind("SHIFT + left",  hl.dsp.layout("movewindowto l"))
bind("SHIFT + right", hl.dsp.layout("movewindowto r"))
bind("CTRL + left",   hl.dsp.layout("swapcol l"))
bind("CTRL + right",  hl.dsp.layout("swapcol r"))

bind("SHIFT + F", hl.dsp.window.fullscreen())
bind("F",         hl.dsp.layout("colresize +conf"))

bind("W", hl.dsp.exec_cmd(wallpaper))

for i = 1, 9 do
    bind(tostring(i),              hl.dsp.focus({ workspace = i }))
    bind("SHIFT + " .. i,          hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
bind("S",         hl.dsp.workspace.toggle_special("magic"))
bind("SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces
bind("mouse_down", hl.dsp.focus({ workspace = "e+1" }))
bind("mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with LMB/RMB drag
bind("mouse:272", hl.dsp.window.drag(),   { mouse = true })
bind("mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Multimedia keys
local media = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+"), media)
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"),      media)
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     media)
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   media)
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  media)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  media)


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

hl.window_rule({
    name      = "spotify",
    match     = { class = "^(spotify)$" },
    workspace = "4",
})

hl.window_rule({
    name      = "brave-browser",
    match     = { class = "^(brave-browser)$" },
    workspace = "2",
})
