#!/usr/bin/env bash

# Descobre o sink padrão atual
default_sink=$(wpctl status |
  sed -n '/Sinks:/,/Sources:/p' |
  grep '*' |
  sed 's/^[^0-9]*[0-9]\+\. //' |
  sed 's/\s*\[vol:.*//')

# Lista os sinks
menu=$(wpctl status |
  sed -n '/Sinks:/,/Sources:/p' |
  grep -E '[0-9]+\.\s' |
  sed 's/^[^0-9]*//' |
  sed 's/\s*\[vol:.*//')

declare -A SINKS
declare -A DISPLAY_MAP 

while read -r line; do
  id="${line%%.*}"
  name="${line#*. }"
  SINKS["$name"]="$id"
done <<< "$menu"

menu=""

for name in "${!SINKS[@]}"; do
  if [ "$name" = "$default_sink" ]; then
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
    -p "Output devices"
)

[ -z "$choice" ] && exit 0

if [ "$choice" = "Back" ]; then
  exec "$HOME/.config/waybar/scripts/audio-menu/audio-menu.sh"
  exit 0
fi

# Extrai o ID
pw_id="${SINKS[${DISPLAY_MAP[$choice]}]}"
# echo "PipeWire ID: $pw_id"

node_name=$(wpctl inspect "$pw_id" |
  grep 'node.name' |
  awk -F'"' '{print $2}')
# echo "Node Name: $node_name"

# Abre o sub menu do device
exec "$HOME/.config/waybar/scripts/audio-menu/output/output-actions.sh" "$pw_id" "$node_name" "$choice"
exit 0
