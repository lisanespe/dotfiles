#!/bin/bash
choice=$(echo -e "Suspend\nHibernate\nShutdown\nReboot" | wofi --dmenu --prompt "Power")

case $choice in
    "Suspend") systemctl suspend ;;
    "Hibernate") systemctl hibernate ;;
    "Shutdown") systemctl poweroff ;;
    "Reboot") systemctl reboot ;;
esac
