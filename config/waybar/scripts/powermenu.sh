#!/usr/bin/env bash
# Power menu for Waybar custom/power, built on wofi --dmenu (no extra deps).
# Destructive entries (logout, reboot, shutdown) ask for confirmation.

pidof wofi >/dev/null && { pkill wofi; exit 0; }   # click again = close

menu() {
    wofi --dmenu --prompt "$1" --cache-file /dev/null \
        --hide-scroll --width 220 --lines "$2" --location top_right
}

confirm() {
    [[ $(printf '󰄬 Yes\n󰅖 No' | menu "$1?" 2) == "󰄬 Yes" ]]
}

choice=$(printf '%s\n' \
    "󰌾 Lock" "󰤄 Suspend" "󰍃 Logout" "󰜉 Reboot" "󰐥 Shutdown" \
    | menu "Power" 5)

case $choice in
    *Lock)     pidof hyprlock || hyprlock ;;
    *Suspend)  systemctl suspend ;;
    *Logout)   confirm "Logout"   && hyprctl dispatch 'hl.dsp.exit()' ;;
    *Reboot)   confirm "Reboot"   && systemctl reboot ;;
    *Shutdown) confirm "Shutdown" && systemctl poweroff ;;
esac
