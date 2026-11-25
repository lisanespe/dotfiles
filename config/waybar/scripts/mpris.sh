#!/usr/bin/env bash
# Waybar custom/mpris: now-playing line from playerctl, printed as JSON.
# Replaces the built-in mpris module, which segfaults in waybar 0.15.0
# (use-after-free in its playerctl signal handlers). Here the playerctl
# client lives in a separate process, so a player event cannot crash the bar.

# Fields are tab-separated; titles with tabs are rare enough to ignore.
fmt=$'{{status}}\t{{playerName}}\t{{title}}\t{{artist}}'

emit() {
    local status=$1 player=$2 title=$3 artist=$4

    # No player (or it vanished): empty text hides the module
    if [[ -z $status || $status == Stopped ]]; then
        echo '{"text":"","class":"stopped"}'
        return
    fi

    local icon
    case $player in
        spotify) icon="󰓇" ;;
        firefox) icon="󰈹" ;;
        *)       icon="󰎆" ;;
    esac

    local line=$title
    [[ -n $artist ]] && line="$title - $artist"

    jq -cn --arg line "$line" --arg icon "$icon" --arg status "$status" '
        # Pango markup: escape before wrapping in <i>
        def esc: gsub("&"; "&amp;") | gsub("<"; "&lt;") | gsub(">"; "&gt;");
        ($line | if length > 40 then .[0:39] + "…" else . end | esc) as $short
        | {
            text: (if $status == "Paused" then "󰏤 <i>\($short)</i>" else "\($icon) \($short)" end),
            tooltip: ($line | esc),
            class: ($status | ascii_downcase)
          }'
}

# Waybar does not kill custom-module children when it exits, and playerctl
# --follow blocks forever, so watch waybar and tear down with it.
parent=$PPID
trap 'pkill -P $$; exit' TERM
( while kill -0 "$parent" 2>/dev/null; do sleep 5; done; kill $$ ) &

# playerctl exits if D-Bus hiccups; restart it instead of leaving the bar stale.
# Pipeline runs in background + wait so the TERM trap fires immediately.
while true; do
    playerctl --follow metadata --format "$fmt" 2>/dev/null |
        while IFS=$'\t' read -r status player title artist; do
            emit "$status" "$player" "$title" "$artist"
        done &
    wait $!
    emit
    sleep 2
done
