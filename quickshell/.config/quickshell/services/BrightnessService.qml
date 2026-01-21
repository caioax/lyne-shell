pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ========================================================================
    // PROPRIEDADES PÚBLICAS - BRILHO
    // ========================================================================

    property real brightness: 1.0
    property int maxBrightness: 100
    property int currentBrightness: 100
    readonly property bool available: backlightDevice !== ""
    property string backlightDevice: ""
    readonly property int percentage: Math.round(brightness * 100)

    readonly property string icon: {
        if (brightness <= 0.1)
            return "󰃞";
        if (brightness <= 0.3)
            return "󰃟";
        if (brightness <= 0.6)
            return "󰃝";
        return "󰃠";
    }

    // ========================================================================
    // PROPRIEDADES PÚBLICAS - LUZ NOTURNA (HYPRSUNSET)
    // ========================================================================

    property bool nightLightEnabled: false
    
    // Temperatura em Kelvin (1000 = muito quente/laranja, 6500 = luz do dia)
    // Slider vai de 0.0 a 1.0, mapeado para 2500K - 5500K
    property int nightLightTemperature: 4000
    
    // Intensidade como valor 0.0 - 1.0 para o slider
    // 0.0 = mais quente (2500K), 1.0 = mais frio (5500K)
    property real nightLightIntensity: 0.5
    
    // Ícone da luz noturna
    readonly property string nightLightIcon: nightLightEnabled ? "󰌵" : "󰌶"

    // ========================================================================
    // INICIALIZAÇÃO
    // ========================================================================

    Component.onCompleted: {
        detectBacklight.running = true;
        ensureHyprsunsetRunning.running = true;
    }

    // Conexão com StateService para carregar estado persistido
    Connections {
        target: StateService
        
        function onStateLoaded() {
            // Carrega estado da luz noturna
            root.nightLightEnabled = StateService.get("nightLightEnabled", false);
            root.nightLightIntensity = StateService.get("nightLightIntensity", 0.5);
            root.updateTemperatureFromIntensity();
            
            console.log("[Brightness] Loaded state - enabled:", root.nightLightEnabled, "intensity:", root.nightLightIntensity);
            
            // Aplica o estado carregado
            if (root.nightLightEnabled) {
                // Pequeno delay para garantir que hyprsunset está pronto
                applyStateTimer.restart();
            }
        }
    }
    
    Timer {
        id: applyStateTimer
        interval: 1000
        onTriggered: {
            if (root.nightLightEnabled) {
                root.applyNightLight();
            }
        }
    }

    // ========================================================================
    // FUNÇÕES INTERNAS
    // ========================================================================
    
    // Converte intensidade (0-1) para temperatura Kelvin
    function updateTemperatureFromIntensity() {
        // 0.0 = 2500K (muito quente), 1.0 = 5500K (menos quente)
        nightLightTemperature = Math.round(2500 + (nightLightIntensity * 3000));
    }
    
    // Converte temperatura Kelvin para intensidade (0-1)
    function updateIntensityFromTemperature() {
        nightLightIntensity = (nightLightTemperature - 2500) / 3000;
    }

    // ========================================================================
    // DETECÇÃO DE BACKLIGHT
    // ========================================================================

    Process {
        id: detectBacklight
        command: ["bash", "-c", "ls /sys/class/backlight/ 2>/dev/null | head -1"]
        stdout: SplitParser {
            onRead: data => {
                const device = data.trim();
                if (device !== "") {
                    root.backlightDevice = device;
                    getMaxBrightness.running = true;
                }
            }
        }
    }

    Process {
        id: getMaxBrightness
        command: ["bash", "-c", "cat /sys/class/backlight/" + root.backlightDevice + "/max_brightness 2>/dev/null"]
        stdout: SplitParser {
            onRead: data => {
                const max = parseInt(data.trim());
                if (!isNaN(max) && max > 0) {
                    root.maxBrightness = max;
                    getCurrentBrightness.running = true;
                }
            }
        }
    }

    Process {
        id: getCurrentBrightness
        command: ["bash", "-c", "cat /sys/class/backlight/" + root.backlightDevice + "/brightness 2>/dev/null"]
        stdout: SplitParser {
            onRead: data => {
                const current = parseInt(data.trim());
                if (!isNaN(current)) {
                    root.currentBrightness = current;
                    root.brightness = current / root.maxBrightness;
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: root.available
        repeat: true
        onTriggered: getCurrentBrightness.running = true
    }

    // ========================================================================
    // FUNÇÕES PÚBLICAS - BRILHO
    // ========================================================================

    function setBrightness(value: real) {
        const clamped = Math.max(0.05, Math.min(1.0, value));
        const absoluteValue = Math.round(clamped * maxBrightness);

        root.brightness = clamped;
        root.currentBrightness = absoluteValue;

        setBrightnessProc.command = ["brightnessctl", "set", absoluteValue.toString()];
        setBrightnessProc.running = true;
    }

    function increaseBrightness() {
        setBrightness(brightness + 0.05);
    }

    function decreaseBrightness() {
        setBrightness(brightness - 0.05);
    }

    property real lastBrightness: 1.0

    function toggleBrightness() {
        if (brightness > 0.1) {
            lastBrightness = brightness;
            setBrightness(0.05);
        } else {
            setBrightness(lastBrightness);
        }
    }

    // ========================================================================
    // FUNÇÕES PÚBLICAS - LUZ NOTURNA
    // ========================================================================

    function toggleNightLight() {
        if (nightLightEnabled) {
            disableNightLight();
        } else {
            enableNightLight();
        }
    }

    function enableNightLight() {
        nightLightEnabled = true;
        StateService.set("nightLightEnabled", true);
        applyNightLight();
    }

    function disableNightLight() {
        nightLightEnabled = false;
        StateService.set("nightLightEnabled", false);
        disableNightLightProc.running = true;
    }
    
    // Define a intensidade e aplica se estiver ativo
    function setNightLightIntensity(intensity: real) {
        nightLightIntensity = Math.max(0.0, Math.min(1.0, intensity));
        updateTemperatureFromIntensity();
        StateService.set("nightLightIntensity", nightLightIntensity);
        
        if (nightLightEnabled) {
            applyNightLight();
        }
    }

    function setNightLightTemperature(temp: int) {
        nightLightTemperature = Math.max(2500, Math.min(5500, temp));
        updateIntensityFromTemperature();
        StateService.set("nightLightIntensity", nightLightIntensity);
        
        if (nightLightEnabled) {
            applyNightLight();
        }
    }
    
    // Aplica a temperatura atual
    function applyNightLight() {
        enableNightLightProc.command = ["hyprctl", "hyprsunset", "temperature", nightLightTemperature.toString()];
        enableNightLightProc.running = true;
    }

    // ========================================================================
    // PROCESSOS - BRILHO
    // ========================================================================

    Process {
        id: setBrightnessProc
    }

    // ========================================================================
    // PROCESSOS - LUZ NOTURNA (HYPRSUNSET)
    // ========================================================================

    Process {
        id: ensureHyprsunsetRunning
        command: ["bash", "-c", `
            if ! pgrep -x hyprsunset >/dev/null 2>&1; then
                hyprsunset &
                disown
                sleep 0.5
            fi
        `]
    }

    Process {
        id: enableNightLightProc
        stdout: SplitParser {
            onRead: data => {
                console.log("[Brightness] Enable night light response:", data);
            }
        }
        stderr: SplitParser {
            onRead: data => {
                console.error("[Brightness] Enable night light error:", data);
                if (data.includes("error") || data.includes("failed")) {
                    restartAndEnableProc.running = true;
                }
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                console.log("[Brightness] Night light enabled at", root.nightLightTemperature, "K");
            }
        }
    }

    Process {
        id: restartAndEnableProc
        command: ["bash", "-c", `
            pkill -x hyprsunset 2>/dev/null
            sleep 0.2
            hyprsunset &
            disown
            sleep 0.5
            hyprctl hyprsunset temperature ` + root.nightLightTemperature + `
        `]
    }

    Process {
        id: disableNightLightProc
        command: ["hyprctl", "hyprsunset", "identity"]
        onExited: (exitCode, exitStatus) => {
            console.log("[Brightness] Night light disabled");
        }
    }
}
