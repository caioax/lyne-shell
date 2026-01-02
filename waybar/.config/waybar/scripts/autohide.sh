#!/bin/bash

bar_visible=true

while true; do
  # pega posição do ponteiro via hyprctl
  Y=$(hyprctl cursorpos -j | sed -n '4p' | cut -d':' -f2)
  # se ponteiro estiver no topo da tela (< 5px) e barra escondida, mostra
  if [ "$Y" -le 5 ] && [ "$bar_visible" = false ]; then
    killall -SIGUSR1 waybar
    bar_visible=true
  # se ponteiro sair do topo (> 50px) e barra visível, esconde
  elif [ "$Y" -gt 50 ] && [ "$bar_visible" = true ]; then
    killall -SIGUSR1 waybar
    bar_visible=false
  fi
  sleep 0.2
done
