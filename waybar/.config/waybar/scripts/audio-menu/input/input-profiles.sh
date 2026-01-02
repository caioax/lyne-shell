#!/usr/bin/env bash

pw_id="$1"
node_name="$2"
source_name="$3"

# Extrai o "device_code" do node_name
device_code="$(echo "$node_name" | cut -d'.' -f2)"

# Extrai o bloco inteiro do card
profiles_block=$(pactl list cards |
  sed -n "/Name:.*$device_code/,/Active Profile:.*/p")
# echo "$profiles_block" | nl -ba

# Object serial
object_serial=$(echo "$profiles_block" |
  grep 'object.serial' | cut -d'"' -f2)
# echo "Objec Serial: $object_serial"

active_profile=$(echo "$profiles_block" |
  grep 'Active Profile:' | cut -d' ' -f3)
# echo "$active_profile" | nl -ba

profiles=$(echo "$profiles_block" |
  sed -n "/Profiles:/,/Active Profile:.*/p" |
  sed '1d;$d' |
  sed '/^[[:space:]]*off:/d')
# echo "$profiles" | nl -ba

mapfile -t profile_ids < <(
  echo "$profiles" |
    sed -E '
      s/^[[:space:]]*//;
      s/:.*//'
)
# echo "$profiles_ids" | nl -ba

mapfile -t profile_descs < <(
  echo "$profiles" |
    sed -E '
      s/^[^:]+:[[:space:]]*//;
      s/[[:space:]]*\(sinks:.*//'
)
# echo "$profile_descs" | nl -ba

menu=""

for i in "${!profile_ids[@]}"; do
  if [ "${profile_ids[$i]}" = "$active_profile" ]; then
    menu+="󰄬  ${profile_descs[$i]}\n"
    active_index="$i"
  else
    menu+="   ${profile_descs[$i]}\n"
  fi
done

menu+="Back"

choice_index=$(printf "%b" "$menu" |
  rofi -dmenu \
    -format i \
    -p "$source_name" \
    -theme-str 'listview { columns: 1; }')

[ -z "$choice_index" ] && exit 0

# Back é sempre a última linha
if [ "$choice_index" -ge "${#profile_ids[@]}" ]; then
  exec "$HOME/.config/waybar/scripts/audio-menu/input/input-actions.sh" "$pw_id" "$node_name" "$source_name"
  exit 0
fi

selected_profile="${profile_ids[$choice_index]}"
# echo "$selected_profile"

pactl set-card-profile "$object_serial" "$selected_profile"
exec "$HOME/.config/waybar/scripts/audio-menu/input/input-actions.sh" "$pw_id" "$node_name" "$source_name"
exit 0
