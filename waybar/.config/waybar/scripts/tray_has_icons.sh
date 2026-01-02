#!/usr/bin/env bash

# Detecta se há ícones na tray
icons=$(gdbus call --session \
  --dest org.kde.StatusNotifierWatcher \
  --object-path /StatusNotifierWatcher \
  --method org.freedesktop.DBus.Properties.Get \
  org.kde.StatusNotifierWatcher RegisteredStatusNotifierItems)

# Se houver pelo menos 1 ícone, retorna • (ou outro caractere qualquer)
if [[ $icons != *"[]"* ]]; then
    echo " "
else
    # Se não houver ícones, retorna vazio
    echo ""
fi
