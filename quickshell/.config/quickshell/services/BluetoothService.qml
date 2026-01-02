pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    // Pega o adaptador padrão do sistema. Pode ser null se não houver bluetooth.
    property var adapter: Bluetooth.defaultAdapter

    // Propriedades reativas (retornam false se não tiver adaptador)
    readonly property bool isPowered: (adapter && adapter.enabled) === true
    readonly property bool isDiscovering: (adapter && adapter.discovering) === true

    // Propriedade para saber se estamos visíveis para outros (útil para a UI)
    readonly property bool isDiscoverable: (adapter && adapter.discoverable) === true

    // Icone dos status atual do bluetooth
    readonly property string systemIcon: {
        if (!isPowered)
            return "󰂲";

        if (devicesList.some(dev => dev.connected))
            return "󰂱";

        return "";
    }

    // A lista inteligente de dispositivos
    readonly property var devicesList: {
        if (!adapter || !adapter.devices)
            return [];

        // O 'values' do Quickshell não é um Array puro JS, então convertemos
        // para garantir que o .sort() funcione sem erros.
        let list = Array.from(adapter.devices.values);

        // Função de Ordenação
        return list.sort((a, b) => {
            // Conectados aparecem primeiro no topo
            if (a.connected && !b.connected)
                return -1;
            if (!a.connected && b.connected)
                return 1;

            // Dispositivos conhecidos (Pareados ou Confiáveis) aparecem antes dos novos
            const aKnown = a.paired || a.trusted;
            const bKnown = b.paired || b.trusted;
            if (aKnown && !bKnown)
                return -1;
            if (!aKnown && bKnown)
                return 1;

            // Por fim, ordem alfabética pelo nome
            const nameA = (a.alias || a.name || "").toLowerCase();
            const nameB = (b.alias || b.name || "").toLowerCase();
            return nameA.localeCompare(nameB);
        });
    }

    // --- AÇÕES ---

    // Alternar Energia (On/Off)
    function togglePower() {
        if (adapter) {
            adapter.enabled = !adapter.enabled;
        }
    }

    // Alternar Busca (Scan)
    function toggleScan() {
        if (!adapter)
            return;

        if (adapter.discovering) {
            // Se o usuário clicou para parar manualmente
            adapter.discovering = false;
            scanTimer.stop();
        } else {
            // Se o usuário clicou para iniciar
            adapter.discovering = true;
            scanTimer.restart();
        }
    }

    // Timer para desligar o Scan automaticamente
    Timer {
        id: scanTimer
        interval: 5000 // 5 Segundos
        repeat: false
        onTriggered: {
            if (root.adapter && root.adapter.discovering) {
                root.adapter.discovering = false;
            }
        }
    }

    // Conectar/Desconectar
    function toggleConnection(device) {
        if (!device)
            return;

        if (device.connected) {
            device.disconnect();
            return;
        }

        if (device.state === BluetoothDeviceState.Connecting) {
            console.log("Aguarde, dispositivo já está conectando...");
        }

        // Tenta marcar como confiável antes de conectar.
        // Vital para fones de ouvido no Linux sem agente de PIN visual.
        try {
            device.trusted = true;
        } catch (e) {
            console.warn("Não foi possível definir trusted automaticamente." + e);
        }

        if (!device.paired) {
            try {
                device.pair();
            } catch (e) {
                console.error("Erro ao parear: " + e);
            }
            return;
        }

        device.connect();
    }

    // Tornar visível/invisivel para outros devices
    function toggleDiscoverable() {
        adapter.discoverable = !adapter.discoverable;
    }

    // Função para ver se o device esta tentando se conectar
    function getIsConnecting(device) {
        return device.state === BluetoothDeviceState.Connecting;
    }

    // Esquecer dispositivo
    function forgetDevice(device) {
        if (device) {
            device.forget();
        }
    }

    // Função para pegar ícones baseada no tipo real do device
    function getDeviceIcon(device) {
        if (!device)
            return ""; // Bluetooth padrão

        // 1. Tenta pegar a propriedade oficial do ícone do BlueZ e o nome
        const iconProp = (device.icon || "").toLowerCase();
        const name = (device.name || device.alias || "").toLowerCase();

        const safeName = name || "";

        // 2. Lista de palavras-chave para Áudio
        const audioKeywords = ["headset", "headphone", "airpod", "buds", "freebuds", "wh-", "wf-", "jbl", "audio", "soundcore"];

        // Verifica se é áudio pela propriedade técnica OU pelo nome
        if (iconProp.includes("headset") || iconProp.includes("audio") || audioKeywords.some(k => name.includes(k)))
            return "";
        if (iconProp.includes("mouse") || safeName.includes("mouse"))
            return "󰍽";
        if (iconProp.includes("keyboard") || safeName.includes("keyboard"))
            return "";
        if (iconProp.includes("phone") || safeName.includes("phone") || name.includes("android") || name.includes("iphone"))
            return "";
        if (iconProp.includes("gamepad") || iconProp.includes("joystick") || name.includes("controller"))
            return "";
        if (iconProp.includes("computer") || iconProp.includes("laptop") || name.includes("pc"))
            return " ";
        if (iconProp.includes("tv") || safeName.includes("tv"))
            return " ";

        return ""; // Padrão
    }
}
