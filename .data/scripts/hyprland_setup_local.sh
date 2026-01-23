#!/bin/bash

# --- Paths ---
HYPR_LOCAL_DIR="$HOME/.config/hypr/local"
UWSM_ENV_D="$HOME/.config/uwsm/env.d"

# Create directories
mkdir -p "$HYPR_LOCAL_DIR"
mkdir -p "$UWSM_ENV_D"

# --- Ask for Nvidia ---
read -p "Do you have an Nvidia Hybrid GPU? [y/N]: " is_nvidia

# --- Helper function ---
init_file() {
    local FILE=$1
    local CONTENT=$2
    if [ ! -f "$FILE" ]; then
        echo -e "$CONTENT" >"$FILE"
        echo "Initialized: $FILE"
    else
        echo "Skipping: $FILE (exists)"
    fi
}

# --- 1. UWSM GLOBAL (env) ---
# Aqui entram variáveis que afetam qualquer Wayland compositor
UWSM_GLOBAL_CONTENT="#!/bin/bash\n"
if [[ $is_nvidia =~ ^[Yy]$ ]]; then
    UWSM_GLOBAL_CONTENT+="export LIBVA_DRIVER_NAME=nvidia\nexport __GLX_VENDOR_LIBRARY_NAME=nvidia\nexport NVD_BACKEND=direct"
fi
init_file "$UWSM_ENV_D/global_hardware.sh" "$UWSM_GLOBAL_CONTENT"

# --- 2. UWSM HYPRLAND SPECIFIC (env_hyprland) ---
# Aqui entra o que é específico da renderização do Hyprland (Aquamarine)
UWSM_HYPR_CONTENT="#!/bin/bash\n"
if [[ $is_nvidia =~ ^[Yy]$ ]]; then
    UWSM_HYPR_CONTENT+="# export AQ_DRM_DEVICES=\"/dev/dri/nvidia-dgpu:/dev/dri/intel-igpu\""
fi
init_file "$UWSM_ENV_D/hyprland_hardware.sh" "$UWSM_HYPR_CONTENT"

# --- 3. HYPRLAND CONFIG (environment.conf) ---
# Arquivos que o hyprland.conf lê via 'source'
if [[ $is_nvidia =~ ^[Yy]$ ]]; then
    HYPR_ENV_CONTENT="env = LIBVA_DRIVER_NAME,nvidia\nenv = __GLX_VENDOR_LIBRARY_NAME,nvidia\nenv = NVD_BACKEND,direct\n# env = AQ_DRM_DEVICES,/dev/dri/nvidia-dgpu:/dev/dri/intel-igpu"
else
    HYPR_ENV_CONTENT=""
fi
init_file "$HYPR_LOCAL_DIR/extra_environment.conf" "$HYPR_ENV_CONTENT"

# Outros arquivos locais necessários
init_file "$HYPR_LOCAL_DIR/autostart.conf" "# Local autostart"
init_file "$HYPR_LOCAL_DIR/extra_keybinds.conf" "# Local keybinds"

echo "Setup finalized for both UWSM and Hyprland."
