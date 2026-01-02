#!/usr/bin/env bash

pw_id="$1"
node_name="$2"
sink_name="$3"

[ -z "$pw_id" ] && exit 1

action=$(printf "󰓃  Set as default\n󰀥  Profiles\n󰒓  More settings\nBack" |
  rofi -dmenu \
    -p "$sink_name")

[ -z "$action" ] && exit 0

case "$action" in
"󰓃  Set as default")
  wpctl set-default "$pw_id"
  exec "$HOME/.config/waybar/scripts/audio-menu/output/outputs.sh"
  ;;
"󰀥  Profiles")
  exec "$HOME/.config/waybar/scripts/audio-menu/output/output-profiles.sh" "$pw_id" "$node_name" "$sink_name"
  exit 0
  ;;
"󰒓  More settings")
  pavucontrol
  exit 0
  ;;
"Back")
  exec "$HOME/.config/waybar/scripts/audio-menu/output/outputs.sh"
  exit 0
  ;;
esac
