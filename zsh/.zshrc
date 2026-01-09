# === SMART TMUX START ===
# Verifica se o tmux está instalado e se não estamos já dentro de uma sessão
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
    # Define o nome da sessão principal
    SESSION_NAME="main"

    # Verifica se a sessão 'main' existe
    if tmux has-session -t $SESSION_NAME 2>/dev/null; then
        # Verifica se a sessão 'main' já tem alguém conectado (attached)
        if tmux list-sessions | grep -q "^$SESSION_NAME.*(attached)"; then
            # Se já está aberta em outro lugar, cria uma nova sessão independente
            ID=1
            while tmux has-session -t $ID 2>/dev/null; do
                ((ID++))
            done 
            exec tmux new-session -s $ID
        else
            # Se existe mas ninguém está usando, conecta nela
            exec tmux attach-session -t $SESSION_NAME
        fi
    else
        # Se a sessão 'main' não existe, cria ela
        exec tmux new-session -s $SESSION_NAME
    fi
fi

# === POWERLEVEL10K INSTANT PROMPT ===
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# === OMZ CONFIGURATION ===
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# --- Tmux Plugin Settings ---
ZSH_TMUX_AUTOSTART=false
ZSH_TMUX_AUTOCONNECT=false
ZSH_TMUX_DEFAULT_SESSION_NAME="main"
ZSH_TMUX_UNICODE=true

# --- Plugins List ---
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-vi-mode tmux)

source $ZSH/oh-my-zsh.sh

# === EDITOR SETTINGS ===
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# === CUSTOM FIXES & INTEGRATIONS ===

# Clipboard Fix
function zvm_vi_yank() {
    zvm_yank
    echo -n "${CUTBUFFER}" | wl-copy
}

# Configurações do Vi-Mode
ZVM_CURSOR_STYLE_ENABLED=true
autoload -U edit-command-line
zle -N edit-command-line

function zvm_after_init() {
  # Ctrl+v abre o comando atual no Neovim para editar
  zvm_bindkey vicmd '^V' edit-command-line
  zvm_bindkey viins '^V' edit-command-line
}

# === ALIASES ===
alias all-update='sudo pacman -Syu && yay -Syu && flatpak update'

# Dotfiles Management
alias dots='git -C ~/.arch-dots'

# === FINALIZERS ===
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PATH=$PATH:/home/caio/.spicetify
