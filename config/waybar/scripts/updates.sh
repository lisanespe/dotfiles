#!/usr/bin/env bash
# Waybar custom/updates: counts pending pacman repo updates and prints JSON.
# checkupdates syncs into a temp DB, so it never causes a partial upgrade.

list=$(checkupdates 2>/dev/null)   # exit 2 = no updates, 1 = error
count=$(grep -c . <<< "$list")

# Empty text hides the module; many pending updates get the warning pill
text=""
class=""
if (( count > 0 )); then
    text=$count
    class="pending"
    (( count >= 50 )) && class="warning"
fi

jq -cn --arg text "$text" --arg tooltip "${list:-No updates}" --arg class "$class" \
    '{text: $text, tooltip: $tooltip, class: $class}'
