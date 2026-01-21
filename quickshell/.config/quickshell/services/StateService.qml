pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ========================================================================
    // PROPRIEDADES
    // ========================================================================

    // Caminho do arquivo de estado
    readonly property string statePath: Quickshell.env("HOME") + "/.config/quickshell/state.json"

    // Estado atual (objeto JS)
    property var state: ({})

    // Flag para evitar salvar durante carregamento
    property bool isLoading: true

    // ========================================================================
    // INICIALIZAÇÃO
    // ========================================================================

    Component.onCompleted: {
        loadState();
    }

    // ========================================================================
    // FUNÇÕES PÚBLICAS
    // ========================================================================

    // Obtém um valor do estado
    function get(key: string, defaultValue) {
        if (state.hasOwnProperty(key)) {
            return state[key];
        }
        return defaultValue;
    }

    // Define um valor no estado e salva
    function set(key: string, value) {
        state[key] = value;
        if (!isLoading) {
            saveState();
        }
    }

    // Remove uma chave do estado
    function remove(key: string) {
        if (state.hasOwnProperty(key)) {
            delete state[key];
            if (!isLoading) {
                saveState();
            }
        }
    }

    // Força o salvamento
    function save() {
        saveState();
    }

    // ========================================================================
    // FUNÇÕES INTERNAS
    // ========================================================================

    function loadState() {
        isLoading = true;
        loadProc.running = true;
    }

    function saveState() {
        // Converte o estado para JSON
        const jsonStr = JSON.stringify(state, null, 2);
        saveProc.command = ["bash", "-c", 
            "mkdir -p \"$(dirname '" + statePath + "')\" && " +
            "echo '" + jsonStr.replace(/'/g, "'\\''") + "' > '" + statePath + "'"
        ];
        saveProc.running = true;
    }

    // ========================================================================
    // PROCESSOS
    // ========================================================================

    // Carrega o estado do arquivo
    Process {
        id: loadProc
        command: ["bash", "-c", "cat '" + root.statePath + "' 2>/dev/null || echo '{}'"]
        
        property string buffer: ""
        
        stdout: SplitParser {
            onRead: data => {
                loadProc.buffer += data + "\n";
            }
        }
        
        onExited: (exitCode, exitStatus) => {
            try {
                const parsed = JSON.parse(loadProc.buffer.trim());
                root.state = parsed;
                console.log("[State] Loaded state:", JSON.stringify(root.state));
            } catch (e) {
                console.error("[State] Failed to parse state file:", e);
                root.state = {};
            }
            root.isLoading = false;
            loadProc.buffer = "";
            
            // Emite sinal de que o estado foi carregado
            root.stateLoaded();
        }
    }

    // Salva o estado no arquivo
    Process {
        id: saveProc
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                console.log("[State] State saved successfully");
            } else {
                console.error("[State] Failed to save state, exit code:", exitCode);
            }
        }
    }

    // ========================================================================
    // SINAIS
    // ========================================================================

    signal stateLoaded()
}
