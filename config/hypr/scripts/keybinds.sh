#!/usr/bin/env bash
# Keybind cheat sheet (SUPER+F1). Reads the live binds from Hyprland, so it
# always matches hyprland.lua: every hl.bind there carries a `description`.
# Type to filter; Escape closes. Selecting an entry does nothing.

pidof wofi >/dev/null && { pkill wofi; exit 0; }   # press again = close

hyprctl binds -j | jq -r '
  def mods:
    [ (if . / 64 | floor % 2 == 1 then "SUPER" else empty end),
      (if . /  4 | floor % 2 == 1 then "CTRL"  else empty end),
      (if . /  8 | floor % 2 == 1 then "ALT"   else empty end),
      (if .      % 2 == 1         then "SHIFT" else empty end) ];
  def keyname:
    { "mouse:272": "Left drag", "mouse:273": "Right drag",
      "mouse_down": "Scroll down", "mouse_up": "Scroll up",
      "XF86Tools": "Side key 4", "XF86Launch5": "Side key 5",
      "XF86Launch6": "Side key 6" }[.] // (sub("^XF86"; "") );
  .[] | select(.has_description)
      | ((.modmask | mods) + [.key | keyname] | join(" + ")) as $keys
      | "<span foreground=\"#7aa2f7\"><b>\($keys)</b></span>   \(.description)"
' | wofi --dmenu --allow-markup --prompt "Keybinds" --cache-file /dev/null \
        --width 650 --lines 15 >/dev/null
