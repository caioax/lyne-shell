#!/bin/bash
# =============================================================================
# Wallpaper Boot Script
# =============================================================================
# Aplica o wallpaper persistente no boot usando swww.
# Lê o path do wallpaper de ~/.local/wallpapers/.current
# =============================================================================

CURRENT_FILE="$HOME/.local/wallpapers/.current"
WALLPAPER_DIR="$HOME/.local/wallpapers"

# Lê o wallpaper salvo
if [[ -f "$CURRENT_FILE" ]]; then
    WALLPAPER="$(cat "$CURRENT_FILE")"
fi

# Fallback: se o arquivo não existe ou o wallpaper referenciado não existe
if [[ -z "$WALLPAPER" || ! -f "$WALLPAPER" ]]; then
    WALLPAPER="$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.webp' \) | head -1)"
fi

if [[ -n "$WALLPAPER" && -f "$WALLPAPER" ]]; then
    swww img "$WALLPAPER" \
        --transition-type grow \
        --transition-duration 1 \
        --transition-fps 60 \
        --transition-step 90
fi
