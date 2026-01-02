#!/usr/bin/env bash

# Define as opções do menu
options="󰓃  Output devices
󰌌  Input devices
󰒓  More settings"

# Chamar o rofi e capturar a escolha
choice=$(echo -e "$options" | rofi -dmenu -p "Áudio")

# Se o usuário apertar Esc, choice vem vazio
[ -z "$choice" ] && exit 0

# Decisão baseada  na escolha
case "$choice" in
"󰓃  Output devices")
  exec "$HOME/.config/waybar/scripts/audio-menu/output/outputs.sh"
  exit 0
  ;;
"󰌌  Input devices")
  exec "$HOME/.config/waybar/scripts/audio-menu/input/inputs.sh"
  exit 0
  ;;
"󰒓  More settings")
  pavucontrol
  exit 0
  ;;
esac
