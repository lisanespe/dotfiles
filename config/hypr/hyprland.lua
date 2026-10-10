-- ~/.config/hypr/hyprland.lua
-- Migrated from hyprland.conf (hyprlang) to the Lua config format.
-- Requires Hyprland 0.55 or newer.
-- Wiki: https://wiki.hypr.land/Configuring/Start/

------------------
---- MONITORS ----
------------------
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Samsung LS27AG55x (Odyssey G5) on DP-1. Values taken from `hyprctl monitors all`.
-- Note: `preferred` was already selecting this mode. Pinning it is insurance
-- against mode-list reordering after a Mesa/firmware update, not a fix.
hl.monitor({
    output   = "DP-1",
    mode     = "2560x1440@164.84",
    position = "0x0",
    scale    = 1,
})

---------------------
---- MY PROGRAMS ----
---------------------
local terminal    = "kitty"
local fileManager = "dolphin"
local browser     = "firefox"
local menu        = "wofi --show drun"

-------------------
---- AUTOSTART ----
-------------------
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
-- Replaces the old `exec-once =` lines.

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("hypridle")   -- idle lock / screen off (config/hypr/hypridle.conf)
    hl.exec_cmd("swaync")     -- notifications; start before D-Bus can activate mako
    -- Clipboard history: store every text / image copy in cliphist
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("/home/lisanespe/.local/bin/wallpaper-start")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("spotify-launcher")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "breeze_cursors")    -- same cursor as GTK (config/gtk-3.0)
hl.env("HYPRCURSOR_THEME", "breeze_cursors")
-- Qt apps (Dolphin) borrow the GTK theme colors and icons, so they match
-- Tokyo Night without qt6ct or Kvantum. Plugin ships with qt6-base.
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")

-- SSH agent variables, read from the same environment.d file systemd uses
-- (config/environment.d/ssh-agent.conf), so they are defined only once.
-- Top level, so autostarted programs inherit them too.
-- environment.d syntax: KEY=VALUE lines, # comments, ${VAR} expansion.
local function load_environment_d(path)
    local f = io.open(path)
    if not f then return end
    for line in f:lines() do
        local key, value = line:match("^%s*([%w_]+)=(.*)$")
        if key then
            value = value:gsub("%${([%w_]+)}", function(name) return os.getenv(name) or "" end)
            hl.env(key, value)
        end
    end
    f:close()
end
load_environment_d(os.getenv("HOME") .. "/.config/environment.d/10-ssh-agent.conf")

-- Optional, but recommended on your setup:
-- hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")  -- native Wayland for Electron apps
-- hl.env("LIBVA_DRIVER_NAME", "radeonsi")         -- only if vainfo misbehaves; usually auto on AMD

-----------------------
----- PERMISSIONS -----
-----------------------
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Changes here need a full Hyprland restart, they are not hot-reloaded.
--
-- hl.config({ ecosystem = { enforce_permissions = true } })
--
-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

-----------------------
---- LOOK AND FEEL ----
-----------------------
-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in     = 4,   -- between windows
        gaps_out    = 8,   -- to screen edges; room for the 8px rounding
        border_size = 1,

        col = {
            -- Tokyo Night, same palette as Waybar (config/waybar/colors.css):
            -- blue -> purple on the focused window, muted grey-blue elsewhere.
            active_border   = { colors = { "rgb(7aa2f7)", "rgb(bb9af7)" }, angle = 45 },
            inactive_border = "rgb(414868)",
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 8,   -- same radius as the Waybar pills
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            -- Lua takes ARGB as a number: rgba(1a1b26ee) becomes 0xee1a1b26
            -- (Tokyo Night bg, see config/waybar/colors.css)
            color        = 0xee1a1b26,
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true, -- was: enabled = yes, please :)
    },
})

-- Curves, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1} } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1} } })

-- Spring curve: windows overshoot a little and settle, like a soft bounce.
-- Springs use `spring = ` in hl.animation instead of `bezier = `.
hl.curve("easy", { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
-- Workspaces slide left/right on switch (special workspaces slide vertically)
hl.animation({ leaf = "workspaces",    enabled = true, speed = 3,    bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "easeOutQuint", style = "slidevert" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })

-- Frosted glass behind Waybar: blur what is under its semi-transparent
-- background. ignore_alpha skips fully transparent gaps between the pills.
hl.layer_rule({
    name         = "waybar-blur",
    match        = { namespace = "waybar" },
    blur         = true,
    ignore_alpha = 0.3,
})

-- Smart gaps: a lone tiled window (w[tv1]) or a maximized one (f[1]) fills
-- the screen with no gaps, border or rounding. Two or more windows get the
-- normal 4 / 8 gaps again.
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })

hl.window_rule({
    name  = "no-gaps-wtv1",
    match = { float = false, workspace = "w[tv1]" },
    border_size = 0,
    rounding    = 0,
})

hl.window_rule({
    name  = "no-gaps-f1",
    match = { float = false, workspace = "f[1]" },
    border_size = 0,
    rounding    = 0,
})

-----------------
---- LAYOUTS ----
-----------------
hl.config({
    dwindle = {
        preserve_split = true, -- you probably want this
    },
    master = {
        new_status = "master",
    },
})

--------------
---- MISC ----
--------------
hl.config({
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,

        -- Adaptive sync. Your G5 is FreeSync Premium and this was off (vrr = 0).
        -- 2 = fullscreen only. Start here: always-on (1) can cause visible
        -- brightness flicker on VA panels when framerate drops low.
        vrr = 2,

        -- If hyprlock crashes, the session stays locked (red screen). This
        -- lets a new hyprlock take over: from a TTY (Ctrl+Alt+F3) run
        --   hyprctl --instance 0 dispatch 'hl.dsp.exec_cmd("hyprlock")'
        allow_session_lock_restore = true,
    },
})

---------------
---- INPUT ----
---------------
hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "intl",

        -- FIXED: your conf had kb_model = "grp:alt_shift_toggle".
        -- That string is an XKB *option*, not a model. Wrong field = the whole
        -- keymap can fail to compile and XKB silently falls back to plain us.
        kb_model   = "",
        kb_options = "",

        -- If what you actually wanted was toggling US <-> Latin American with
        -- Alt+Shift, use these two lines instead of the four above:
        -- kb_layout  = "us,latam",
        -- kb_variant = "intl,",
        -- kb_options = "grp:alt_shift_toggle",

        follow_mouse = 1,
        sensitivity  = 0, -- -1.0 to 1.0, 0 means no modification
    },
})

---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER"

hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal), { description = "Terminal (kitty)" })
hl.bind(mainMod .. " + C", hl.dsp.window.close(), { description = "Close window" })
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"), { description = "Exit Hyprland" })
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager), { description = "File manager (Dolphin)" })
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(browser), { description = "Browser (Firefox)" })
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating" })
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu), { description = "App launcher (wofi)" })
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo(), { description = "Pseudo-tile window" })
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"), { description = "Toggle split direction" }) -- dwindle only

-- Dispatchers below confirmed present in your build via:
--   hyprctl repl 'for k in pairs(hl.dsp.window) do print(k) end'
-- Check argument signatures in ~/dotfiles/config/hypr/hl.meta.lua before editing.
hl.bind(mainMod .. " + SPACE", hl.dsp.window.fullscreen(), { description = "Fullscreen" })
hl.bind(mainMod .. " + G",     hl.dsp.window.center(), { description = "Center floating window" })
hl.bind(mainMod .. " + T",     hl.dsp.window.pin(), { description = "Pin window (all workspaces)" })

-- Lock screen (config: hyprlock.conf). `pidof` stops a second instance.
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("pidof hyprlock || hyprlock"), { description = "Lock screen" })

-- Notification center panel (swaync)
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t -sw"), { description = "Notification center" })

-- Clipboard history: pick an entry with wofi and copy it back.
-- SUPER+CTRL+V wipes the whole history.
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("cliphist list | wofi --dmenu --prompt Clipboard --cache-file /dev/null | cliphist decode | wl-copy"), { description = "Clipboard history" })
hl.bind(mainMod .. " + CTRL + V",  hl.dsp.exec_cmd([[cliphist wipe && notify-send "Clipboard" "History cleared"]]), { description = "Clear clipboard history" })

-- Color picker: click any pixel, its hex (lowercase, like colors.css) goes to
-- the clipboard and a notification. -b drops ANSI colors from the output.
-- Escape cancels (empty output, so no notification).
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd([[c=$(hyprpicker -a -b -l -f hex) && [ -n "$c" ] && notify-send "Color picked" "$c copied"]]), { description = "Color picker" })

-- Screenshot region to clipboard. [[ ]] is a Lua raw string, so the inner
-- double quotes and $(...) survive untouched.
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]]), { description = "Screenshot region to clipboard" })

-- Keybind cheat sheet: lists every bind's `description` in wofi.
-- Keep a description on each new hl.bind so it shows up here.
hl.bind(mainMod .. " + F1", hl.dsp.exec_cmd("~/.config/hypr/scripts/keybinds.sh"), { description = "Keybind cheat sheet" })

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }), { description = "Focus left" })
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), { description = "Focus right" })
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }), { description = "Focus up" })
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }), { description = "Focus down" })

-- Workspaces 1-10, and move-window-to-workspace with SHIFT.
-- Your 20 hand-written lines collapse into this loop.
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,           hl.dsp.focus({ workspace = i }),       { description = "Go to workspace " .. i })
    hl.bind(mainMod .. " + SHIFT + " .. key,   hl.dsp.window.move({ workspace = i }), { description = "Move window to workspace " .. i })
end

-- Side keyboard keys 4-6. keyd remaps them to F13-F15 (config/keyd/default.conf).
-- XKB's default `inet` symbols turn KEY_F13-F15 into these keysyms, so "F13"
-- would never match. (`code:191` binds are silently dropped by the Lua API.)
local sideKeys = { "XF86Tools", "XF86Launch5", "XF86Launch6" }
for i, key in ipairs(sideKeys) do
    hl.bind(key, hl.dsp.focus({ workspace = i }), { description = "Go to workspace " .. i .. " (side key)" })
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S",       hl.dsp.workspace.toggle_special("magic"), { description = "Toggle scratchpad" })
hl.bind(mainMod .. " + ALT + S", hl.dsp.window.move({ workspace = "special:magic" }), { description = "Move window to scratchpad" })

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Next workspace" })
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }), { description = "Previous workspace" })

-- Move/resize with mainMod + LMB/RMB drag
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true, description = "Drag window" })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window" })

-- Media keys. (No brightness binds: the DP monitor has no backlight control.)
-- locked = true    -> works with the screen locked (old `bindl`)
-- repeating = true -> holds down to repeat        (old `binde`)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true, description = "Volume up" })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true, description = "Volume down" })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true, description = "Mute audio" })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true, description = "Mute microphone" })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true, description = "Next track" })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Play / pause" })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Play / pause" })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true, description = "Previous track" })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

hl.window_rule({
    -- Ignore maximize requests from all apps
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- Small tools and dialogs float centered instead of taking half the screen
hl.window_rule({
    name   = "float-tools",
    match  = { class = "^(org\\.pulseaudio\\.pavucontrol|\\.?blueman-manager.*|nm-connection-editor)$" },
    float  = true,
    size   = { "(monitor_w*0.4)", "(monitor_h*0.5)" },
    center = true,
})

hl.window_rule({
    name   = "float-file-dialogs",
    match  = { title = "^(Open File|Open Files|Save As|Save File|Open Folder|Select Folder|File Upload|Choose Files).*" },
    float  = true,
    size   = { "(monitor_w*0.5)", "(monitor_h*0.6)" },
    center = true,
})

hl.window_rule({
    name   = "float-steam-popups",
    match  = { class = "^steam$", title = "^(Friends List|Steam Settings|Screenshot Manager|Steam - News.*)$" },
    float  = true,
    center = true,
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
    name      = "spotify-to-magic",
    match     = { class = "^(spotify)$" },
    workspace = "special:magic",
})
