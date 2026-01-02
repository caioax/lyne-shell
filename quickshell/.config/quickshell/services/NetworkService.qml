pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var accessPoints: []
    property var savedSsids: []
    property bool wifiEnabled: true
    property string wifiInterface: ""
    property string connectingSsid: ""
    readonly property bool scanning: rescanProc.running
    readonly property string systemIcon: {
        if (!wifiEnabled)
            return "󰤮";
        const activeNetwork = accessPoints.find(ap => ap.active === true);
        if (activeNetwork)
            return getWifiIcon(activeNetwork.signal);
        return "󰤫";
    }

    // --- FUNÇÕES ---

    function getWifiIcon(signal) {
        if (signal > 80) return "󰤨";
        if (signal > 60) return "󰤥";
        if (signal > 40) return "󰤢";
        if (signal > 20) return "󰤟";
        return "󰤫";
    }

    function toggleWifi() {
        const cmd = wifiEnabled ? "off" : "on";
        toggleWifiProc.command = ["nmcli", "radio", "wifi", cmd];
        toggleWifiProc.running = true;
    }

    function scan() {
        if (!scanning)
            rescanProc.running = true;
    }

    function disconnect() {
        if (wifiInterface !== "") {
            console.log("Desconectando interface: " + wifiInterface);
            disconnectProc.command = ["nmcli", "dev", "disconnect", wifiInterface];
            disconnectProc.running = true;
        }
    }

    function connect(ssid, password) {
        console.log("Tentando conectar a:", ssid);
        root.connectingSsid = ssid; // Marca qual estamos tentando

        if (password && password.length > 0) {
            connectProc.command = ["nmcli", "dev", "wifi", "connect", ssid, "password", password];
        } else {
            // Tenta conectar usando perfil salvo
            connectProc.command = ["nmcli", "dev", "wifi", "connect", ssid];
        }
        connectProc.running = true;
    }

    function forget(ssid) {
        console.log("Esquecendo rede: " + ssid);
        forgetProc.command = ["nmcli", "connection", "delete", "id", ssid];
        forgetProc.running = true;
    }

    // Função interna para limpar conexões que falharam
    function cleanUpBadConnection(ssid) {
        console.warn("Conexão falhou. Removendo perfil inválido de: " + ssid);
        // Usa o forgetProc para deletar, pois é a mesma lógica
        forget(ssid);
    }

    // --- PROCESSOS ---

    // Processo de Conexão
    Process {
        id: connectProc

        stdout: SplitParser {
            onRead: data => console.log("[Wifi] " + data)
        }
        stderr: SplitParser {
            onRead: data => console.error("[Wifi Erro] " + data)
        }

        onExited: code => {
            // Se o código for 0, sucesso. Se não, houve erro (senha errada, timeout, etc).
            if (code !== 0) {
                console.error("Falha ao conectar. Código de saída: " + code);

                // SE FALHOU: Deletamos o perfil criado para não ficar marcado como "Salvo" incorretamente
                if (root.connectingSsid !== "") {
                    root.cleanUpBadConnection(root.connectingSsid);
                }
            } else {
                console.log("Conectado com sucesso!");
            }

            // Reseta estado e atualiza listas
            root.connectingSsid = "";
            getSavedProc.running = true;
            getNetworksProc.running = true;
        }
    }

    // Detectar Interface Wifi
    Process {
        id: findInterfaceProc
        command: ["nmcli", "-g", "DEVICE,TYPE", "device"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const lines = data.trim().split("\n");
                lines.forEach(line => {
                    const parts = line.split(":");
                    if (parts.length >= 2 && parts[1] === "wifi") {
                        root.wifiInterface = parts[0];
                    }
                });
            }
        }
    }

    // Monitor de Status (Enabled/Disabled)
    Process {
        id: statusProc
        command: ["nmcli", "radio", "wifi"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                root.wifiEnabled = (data.trim() === "enabled");
                if (root.wifiEnabled)
                    getSavedProc.running = true;
                getNetworksProc.running = true;
            }
        }
    }

    // Toggle On/Off
    Process {
        id: toggleWifiProc
        onExited: statusProc.running = true
    }

    // Rescan (Refresh)
    Process {
        id: rescanProc
        command: ["nmcli", "dev", "wifi", "list", "--rescan", "yes"]
        onExited: getNetworksProc.running = true
    }

    // Disconnect
    Process {
        id: disconnectProc
        onExited: getNetworksProc.running = true
    }

    // Esquecer Rede
    Process {
        id: forgetProc
        // O comando é definido dinamicamente antes de rodar
        onExited: {
            getSavedProc.running = true;
            getNetworksProc.running = true;
        }
    }

    // Timer de Atualização Automática
    Timer {
        interval: 10000
        running: root.wifiEnabled
        repeat: true
        onTriggered: {
            getSavedProc.running = true;
            getNetworksProc.running = true;
        }
    }

    // Listar Redes Salvas (Saved)
    Process {
        id: getSavedProc
        command: ["nmcli", "-g", "NAME,TYPE", "connection", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                var savedList = [];
                lines.forEach(line => {
                    const parts = line.split(":");
                    if (parts.length >= 2 && parts[1] === "802-11-wireless") {
                        savedList.push(parts[0]);
                    }
                });
                root.savedSsids = savedList;
            }
        }
    }

    // Listar Redes Disponíveis (Scan)
    Process {
        id: getNetworksProc
        command: ["nmcli", "-g", "IN-USE,SIGNAL,SSID,SECURITY,BSSID,CHAN,RATE", "dev", "wifi", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                var tempParams = [];
                const seen = new Set();

                lines.forEach(line => {
                    if (line.length < 5)
                        return;
                    const parts = line.split(":");
                    if (parts.length < 7)
                        return;

                    const inUse = parts[0] === "*";
                    const signal = parseInt(parts[1]) || 0;
                    const ssid = parts[2];
                    const security = parts[3];
                    const bssid = parts[4];
                    const channel = parts[5];
                    const rate = parts[6];

                    if (!ssid)
                        return;
                    if (seen.has(ssid))
                        return; // Evita duplicatas visuais
                    seen.add(ssid);

                    const isSaved = root.savedSsids.includes(ssid);

                    tempParams.push({
                        ssid: ssid,
                        signal: signal,
                        active: inUse,
                        secure: security.length > 0,
                        securityType: security || "Aberta",
                        saved: isSaved,
                        bssid: bssid,
                        channel: channel,
                        rate: rate
                    });
                });

                // Ordenação: Conectado > Salvo > Sinal
                tempParams.sort((a, b) => {
                    if (a.active)
                        return -1;
                    if (b.active)
                        return 1;
                    if (a.saved && !b.saved)
                        return -1;
                    if (!a.saved && b.saved)
                        return 1;
                    return b.signal - a.signal;
                });

                root.accessPoints = tempParams;
            }
        }
    }
}
