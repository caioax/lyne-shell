#!/usr/bin/env bash
# ==============================================================================
# Hyprland Multi-Monitor Workspace Manager (MODULAR)
# Gerencia workspaces isoladas por monitor (1-100 por monitor)
# 100% dinâmico - funciona com qualquer número de monitores e qualquer nome
# ==============================================================================

set -euo pipefail

# --- Configurações ---
readonly OFFSET_SIZE=100
readonly MAX_WORKSPACES_PER_MONITOR=99
readonly CONFIG_FILE="$HOME/.config/hypr/workspace-monitor-rules.conf"

# --- Funções Auxiliares ---
log_error() {
    echo "ERROR: $*" >&2
}

log_info() {
    echo "$*"
}

get_monitors_ordered() {
    # Retorna lista de monitores ordenados por posição X (esquerda -> direita)
    hyprctl monitors -j | jq -r 'sort_by(.x) | .[].name'
}

get_focused_monitor() {
    hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name'
}

get_monitor_index() {
    local monitor_name="$1"
    local monitors_json
    monitors_json=$(hyprctl monitors -j)

    # Retorna o índice do monitor (0-based) baseado na posição X
    local index
    index=$(echo "$monitors_json" | jq -r \
        --arg mon "$monitor_name" \
        'sort_by(.x) | map(.name) | index($mon) // 0')

    # Garante que é um número
    echo "${index:-0}"
}

calculate_offset() {
    local monitor_index="$1"
    echo $((monitor_index * OFFSET_SIZE))
}

get_current_workspace_id() {
    hyprctl activeworkspace -j | jq -r '.id'
}

# Aguarda Hyprland estar completamente pronto
wait_for_hyprland() {
    local max_attempts=30
    local attempt=0

    while ((attempt < max_attempts)); do
        if hyprctl monitors -j &>/dev/null; then
            local monitor_count
            monitor_count=$(hyprctl monitors -j | jq 'length')

            if ((monitor_count > 0)); then
                log_info "✓ Hyprland pronto com $monitor_count monitor(es)"
                return 0
            fi
        fi

        ((attempt++))
        sleep 0.5
    done

    log_error "Timeout aguardando Hyprland"
    return 1
}

# --- Inicialização Modular ---
init_monitors() {
    log_info "🚀 Inicializando workspaces por monitor (modo modular)..."
    log_info ""

    local monitors
    monitors=$(get_monitors_ordered)

    local monitor_count
    monitor_count=$(echo "$monitors" | wc -l)

    log_info "📊 Monitores detectados: $monitor_count"

    # Cria arquivo de configuração temporário
    local temp_config="/tmp/hyprland-workspace-rules-$$.conf"

    cat >"$temp_config" <<'HEADER'
# ==============================================================================
# Hyprland Workspace Rules - Auto-generated
# Gerado automaticamente pelo workspace-manager.sh
# NÃO edite manualmente - será sobrescrito
# ==============================================================================

HEADER

    # Converte para array para evitar problemas com subprocessos consumindo stdin
    local -a monitor_array=()
    while IFS= read -r mon; do
        [[ -n "$mon" ]] && monitor_array+=("$mon")
    done <<<"$monitors"

    local -a workspace_list=()

    for idx in "${!monitor_array[@]}"; do
        local monitor="${monitor_array[$idx]}"
        local base_ws=$((idx * OFFSET_SIZE + 1))

        workspace_list+=("$base_ws")

        log_info "  Monitor $idx: $monitor → workspace base $base_ws"

        # Regras de workspace para este monitor
        # default:true garante que novas janelas sem regra vão para a workspace padrão
        echo "workspace = $base_ws, monitor:$monitor, default:true" >>"$temp_config"

        # Regra para vincular o range de workspaces ao monitor
        # Isso garante que workspaces 1-100 vão para monitor 0, 101-200 para monitor 1, etc.
        local ws_start=$((idx * OFFSET_SIZE + 1))

        for offset in $(seq 0 9); do
            local ws=$((ws_start + offset))
            echo "workspace = $ws, monitor:$monitor" >>"$temp_config"
        done
    done

    # Move arquivo temporário para local permanente
    mkdir -p "$(dirname "$CONFIG_FILE")"
    mv "$temp_config" "$CONFIG_FILE"

    log_info ""
    log_info "✅ Arquivo de configuração gerado: $CONFIG_FILE"

    # Verifica se já está sendo usado
    if grep -q "source.*workspace-monitor-rules.conf" "$HOME/.config/hypr/hyprland.conf" 2>/dev/null; then
        log_info "✓ Já está configurado no hyprland.conf"
    else
        log_info ""
        log_info "📝 Adicione esta linha ao seu hyprland.conf:"
        log_info "   source = $CONFIG_FILE"
        log_info ""

        read -p "Deseja adicionar automaticamente? (y/N) " -n 1 -r
        echo

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Backup
            cp "$HOME/.config/hypr/hyprland.conf" "$HOME/.config/hypr/hyprland.conf.backup-$(date +%s)"

            # Adiciona source ao final
            {
                echo ""
                echo "# Workspace multi-monitor (auto-generated)"
                echo "source = $CONFIG_FILE"
            } >>"$HOME/.config/hypr/hyprland.conf"

            log_info "✓ Adicionado ao hyprland.conf"
            log_info "✓ Backup criado"
        fi
    fi

    log_info ""
    log_info "Aplicando workspaces aos monitores..."

    # Agora move cada monitor para sua workspace base
    # Fazemos isso DEPOIS de gerar o config e com pequenos delays
    for idx in "${!monitor_array[@]}"; do
        local mon="${monitor_array[$idx]}"
        local ws="${workspace_list[$idx]}"

        log_info "  Movendo $mon → workspace $ws"

        # Usa batch para executar ambos comandos atomicamente
        hyprctl --batch "dispatch focusmonitor $mon; dispatch workspace $ws" 2>/dev/null || true

        # Pequeno delay para garantir que o comando foi processado
        sleep 0.1
    done

    log_info ""
    log_info "Estado atual dos monitores:"
    hyprctl monitors -j | jq -r '.[] | "  \(.name): workspace \(.activeWorkspace.id)"'

    log_info ""
    log_info "✅ Inicialização completa!"
}

# --- Atualização Dinâmica (exec-once) ---
# Esta função é chamada no boot via exec-once
# Detecta monitores e atualiza o config automaticamente
auto_update_on_boot() {
    log_info "🔄 Auto-update no boot..."

    # Aguarda Hyprland estar pronto
    if ! wait_for_hyprland; then
        log_error "Falha ao aguardar Hyprland"
        exit 1
    fi

    # Aguarda um pouco mais para monitores estabilizarem
    # (alguns monitores demoram para negociar resolução)
    sleep 1

    # Gera novo config baseado nos monitores conectados
    init_monitors
}

# --- Navegação de Workspaces ---
switch_workspace() {
    local target="$1"

    # Validação
    if ! [[ "$target" =~ ^[0-9]+$ ]] || ((target < 1 || target > MAX_WORKSPACES_PER_MONITOR)); then
        log_error "Workspace $target fora do range (1-$MAX_WORKSPACES_PER_MONITOR)"
        return 1
    fi

    local focused_monitor
    focused_monitor=$(get_focused_monitor)

    local monitor_index
    monitor_index=$(get_monitor_index "$focused_monitor")

    local base_offset
    base_offset=$(calculate_offset "$monitor_index")

    local target_ws=$((base_offset + target))

    hyprctl dispatch workspace "$target_ws"
}

move_to_workspace() {
    local target="$1"

    # Validação
    if ! [[ "$target" =~ ^[0-9]+$ ]] || ((target < 1 || target > MAX_WORKSPACES_PER_MONITOR)); then
        log_error "Workspace $target fora do range (1-$MAX_WORKSPACES_PER_MONITOR)"
        return 1
    fi

    local focused_monitor
    focused_monitor=$(get_focused_monitor)

    local monitor_index
    monitor_index=$(get_monitor_index "$focused_monitor")

    local base_offset
    base_offset=$(calculate_offset "$monitor_index")

    local target_ws=$((base_offset + target))

    hyprctl dispatch movetoworkspace "$target_ws"
}

move_to_workspace_silent() {
    local target="$1"

    # Validação
    if ! [[ "$target" =~ ^[0-9]+$ ]] || ((target < 1 || target > MAX_WORKSPACES_PER_MONITOR)); then
        log_error "Workspace $target fora do range (1-$MAX_WORKSPACES_PER_MONITOR)"
        return 1
    fi

    local focused_monitor
    focused_monitor=$(get_focused_monitor)

    local monitor_index
    monitor_index=$(get_monitor_index "$focused_monitor")

    local base_offset
    base_offset=$(calculate_offset "$monitor_index")

    local target_ws=$((base_offset + target))

    hyprctl dispatch movetoworkspacesilent "$target_ws"
}

navigate() {
    local direction="$1"

    local current_ws
    current_ws=$(get_current_workspace_id)

    local focused_monitor
    focused_monitor=$(get_focused_monitor)

    local monitor_index
    monitor_index=$(get_monitor_index "$focused_monitor")

    local base_offset
    base_offset=$(calculate_offset "$monitor_index")

    local relative_ws=$((current_ws - base_offset))

    # Corrige se estiver fora do range (pode acontecer em edge cases)
    if ((relative_ws < 1 || relative_ws > MAX_WORKSPACES_PER_MONITOR)); then
        relative_ws=1
    fi

    local new_relative
    if [[ "$direction" == "next" ]]; then
        new_relative=$((relative_ws + 1))
        if ((new_relative > MAX_WORKSPACES_PER_MONITOR)); then
            # Já está no limite, não faz nada
            return 0
        fi
    else
        new_relative=$((relative_ws - 1))
        if ((new_relative < 1)); then
            # Já está no limite, não faz nada
            return 0
        fi
    fi

    local target_ws=$((base_offset + new_relative))
    hyprctl dispatch workspace "$target_ws"
}

move_and_navigate() {
    local direction="$1"

    local current_ws
    current_ws=$(get_current_workspace_id)

    local focused_monitor
    focused_monitor=$(get_focused_monitor)

    local monitor_index
    monitor_index=$(get_monitor_index "$focused_monitor")

    local base_offset
    base_offset=$(calculate_offset "$monitor_index")

    local relative_ws=$((current_ws - base_offset))

    if ((relative_ws < 1 || relative_ws > MAX_WORKSPACES_PER_MONITOR)); then
        relative_ws=1
    fi

    local new_relative
    if [[ "$direction" == "next" ]]; then
        new_relative=$((relative_ws + 1))
        if ((new_relative > MAX_WORKSPACES_PER_MONITOR)); then
            # Já está no limite, não faz nada
            return 0
        fi
    else
        new_relative=$((relative_ws - 1))
        if ((new_relative < 1)); then
            # Já está no limite, não faz nada
            return 0
        fi
    fi

    local target_ws=$((base_offset + new_relative))
    hyprctl dispatch movetoworkspace "$target_ws"
}

# --- Status ---
status() {
    echo "=== Workspace Manager Status ==="
    echo ""

    echo "Monitores (ordenados por posição X):"
    local monitors
    monitors=$(get_monitors_ordered)

    local idx=0
    while IFS= read -r monitor; do
        local base_ws=$((idx * OFFSET_SIZE + 1))
        local end_ws=$((idx * OFFSET_SIZE + MAX_WORKSPACES_PER_MONITOR))
        local current_ws
        current_ws=$(hyprctl monitors -j | jq -r --arg mon "$monitor" '.[] | select(.name == $mon) | .activeWorkspace.id')
        local relative=$((current_ws - idx * OFFSET_SIZE))

        local focused=""
        if hyprctl monitors -j | jq -e --arg mon "$monitor" '.[] | select(.name == $mon and .focused == true)' &>/dev/null; then
            focused=" [FOCUSED]"
        fi

        echo "  [$idx] $monitor$focused"
        echo "      Range: $base_ws-$end_ws"
        echo "      Atual: $current_ws (relativo: $relative)"
        echo ""

        ((idx++))
    done <<<"$monitors"

    echo "Arquivo de config: $CONFIG_FILE"
    if [[ -f "$CONFIG_FILE" ]]; then
        echo "  ✓ Existe"
    else
        echo "  ✗ Não existe (rode --init)"
    fi
}

# --- CLI Main ---
main() {
    local action="${1:-}"
    local arg="${2:-}"

    case "$action" in
    --init)
        init_monitors
        ;;
    --auto-update)
        auto_update_on_boot
        ;;
    --status | status)
        status
        ;;
    switch)
        if [[ -z "$arg" ]]; then
            log_error "Uso: $0 switch <1-$MAX_WORKSPACES_PER_MONITOR>"
            exit 1
        fi
        switch_workspace "$arg"
        ;;
    move)
        if [[ -z "$arg" ]]; then
            log_error "Uso: $0 move <1-$MAX_WORKSPACES_PER_MONITOR>"
            exit 1
        fi
        move_to_workspace "$arg"
        ;;
    movesilent)
        if [[ -z "$arg" ]]; then
            log_error "Uso: $0 movesilent <1-$MAX_WORKSPACES_PER_MONITOR>"
            exit 1
        fi
        move_to_workspace_silent "$arg"
        ;;
    next)
        navigate "next"
        ;;
    prev)
        navigate "prev"
        ;;
    move_next)
        move_and_navigate "next"
        ;;
    move_prev)
        move_and_navigate "prev"
        ;;
    *)
        cat <<EOF
Uso: $0 <comando> [argumentos]

Comandos:
  --init              Gera configuração baseada nos monitores atuais
  --auto-update       Auto-detecta e atualiza no boot (use no exec-once)
  --status            Mostra status atual dos monitores e workspaces
  
  switch <N>          Muda para workspace N (1-$MAX_WORKSPACES_PER_MONITOR)
  move <N>            Move janela para workspace N e segue
  movesilent <N>      Move janela para workspace N (sem seguir)
  next                Próxima workspace (com wrap-around)
  prev                Workspace anterior (com wrap-around)
  move_next           Move janela para próxima workspace
  move_prev           Move janela para workspace anterior

Setup (apenas uma vez):
  $0 --init

Modo automático (recomendado no hyprland.conf):
  exec-once = $0 --auto-update
  source = ~/.config/hypr/workspace-monitor-rules.conf

Exemplo de keybinds:
  bind = SUPER, 1, exec, $0 switch 1
  bind = SUPER SHIFT, 1, exec, $0 move 1
  bind = SUPER, mouse_down, exec, $0 next
  bind = SUPER, mouse_up, exec, $0 prev
EOF
        exit 1
        ;;
    esac
}

main "$@"
