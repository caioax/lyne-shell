#!/usr/bin/env bash

# Descobre o sink padrão atual
default_source=$(wpctl status |
  sed -n '/Audio/,/Video/p' |
  sed -n '/Sources:/,/Filters:/p' |
  grep '*' |
  sed 's/^[^0-9]*[0-9]\+\. //' |
  sed 's/\s*\[vol:.*//')

# Lista os sources
menu=$(wpctl status |
  sed -n '/Audio/,/Video/p' |
  sed -n '/Sources:/,/Filters:/p' |
  grep -E '[0-9]+\.\s' |
  sed 's/^[^0-9]*//' |
  sed 's/\s*\[vol:.*//')

declare -A SOURCES
declare -A DISPLAY_MAP

while read -r line; do
  id="${line%%.*}"
  name="${line#*. }"
  SOURCES["$name"]="$id"
done <<<"$menu"

menu=""

for name in "${!SOURCES[@]}"; do
  if [ "$name" = "$default_source" ]; then
    display="󰄬  $name"
  else
    display="   $name"
  fi

  DISPLAY_MAP["$display"]="$name"
  menu+="$display\n"
done

menu+="Back\n"

[ -z "$menu" ] && exit 0

# Abre o rofi
choice=$(
  printf "%b" "$menu" | rofi -dmenu \
    -p "Input devices" \
    -theme-str 'listview { columns: 1; }'
)

[ -z "$choice" ] && exit 0

if [ "$choice" = "Back" ]; then
  exec "$HOME/.config/waybar/scripts/audio-menu/audio-menu.sh"
  exit 0
fi

# Extrai o ID
pw_id="${SOURCES[${DISPLAY_MAP[$choice]}]}"
# echo "PipeWire ID: $pw_id"

node_name=$(wpctl inspect "$pw_id" |
  grep 'node.name' |
  awk -F'"' '{print $2}')
# echo "Node Name: $node_name"

# Abre o sub menu do device
exec "$HOME/.config/waybar/scripts/audio-menu/input/input-actions.sh" "$pw_id" "$node_name" "$choice"
exit 0
