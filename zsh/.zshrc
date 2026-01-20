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
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-vi-mode)

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
export PATH="$HOME/.local/bin:$PATH"
export PATH=$PATH:/home/caio/.spicetify
