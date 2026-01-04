pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import "../../../components/"

Item {
    id: root

    signal backRequested

    Layout.fillWidth: true
    implicitHeight: 400

    ColumnLayout {
        id: main
        anchors.fill: parent
        spacing: 15

        // Cabeçalho (Header)
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 10
            spacing: 10

            // Botão Voltar
            BackButton {
                onClicked: root.backRequested()
            }

            // Titulo
            Text {
                text: "Bluetooth"
                color: Config.textColor
                font.bold: true
                font.pixelSize: Config.fontSizeIcon
                Layout.fillWidth: true
            }

            // Botão de Escanear
            RefreshButton {
                visible: BluetoothService.isPowered
                loading: BluetoothService.isDiscovering

                onClicked: BluetoothService.toggleScan()
            }

            // Botão de Visibilidade
            ToggleButton {
                visible: BluetoothService.isPowered
                active: BluetoothService.isDiscoverable
                iconOffsetX: 0.5
                iconOffsetY: 0.5
                iconOn: ""
                iconOff: ""

                tooltipText: active ? "Visível para todos" : "Invisível"

                onClicked: BluetoothService.toggleDiscoverable()
            }

            // Switch de Ligar/Desligar
            QsSwitch {
                checked: BluetoothService.isPowered
                onToggled: {
                    if (!BluetoothService.isPowered)
                        startScanTimer.restart();
                    BluetoothService.togglePower();
                }
            }

            // Timer para começar o Scan após ligar o bluetooth
            Timer {
                id: startScanTimer
                interval: 300
                repeat: false
                onTriggered: BluetoothService.toggleScan()
            }
        }

        // Lista de Dispositivos
        ListView {
            id: deviceList
            clip: true
            spacing: 8

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 10

            model: BluetoothService.isPowered ? BluetoothService.devicesList : []

            delegate: DeviceCard {
                required property var modelData

                // Dados
                title: modelData.alias || modelData.name || "Unknown"
                subtitle: modelData.address || ""
                icon: BluetoothService.getDeviceIcon(modelData)

                // Estados
                active: modelData.connected
                connecting: BluetoothService.getIsConnecting(modelData)

                // Texto de status
                statusText: {
                    if (connecting)
                        return "Conectando...";
                    if (active)
                        return "Conectado";
                    if (modelData.paired)
                        return "Pareado";
                    return "";
                }

                // Configurações do menu
                showMenu: modelData.paired || modelData.trusted || modelData.connected

                menuModel: {
                    var list = [];
                    if (modelData.connected) {
                        list.push({
                            text: "Desconectar",
                            action: "disconnect",
                            icon: "",
                            textColor: Config.warningColor,
                            iconColor: Config.warningColor
                        });
                    } else {
                        list.push({
                            text: "Conectar",
                            action: "connect",
                            icon: "",
                            textColor: Config.successColor,
                            iconColor: Config.successColor
                        });
                    }
                    list.push({
                        text: "Esquecer",
                        action: "forget",
                        icon: "",
                        textColor: Config.errorColor,
                        iconColor: Config.errorColor
                    });
                    return list;
                }

                onMenuAction: actionId => {
                    if (actionId === "forget") {
                        BluetoothService.forgetDevice(modelData);
                    } else if (actionId === "disconnect") {
                        BluetoothService.toggleConnection(modelData);
                    } else if (actionId === "connect") {
                        BluetoothService.toggleConnection(modelData);
                    }
                }

                // Clique principal
                onClicked: BluetoothService.toggleConnection(modelData)
            }

            // Mensagem de lista vazia
            Text {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -40
                visible: !BluetoothService.isPowered || (parent.count === 0)
                text: {
                    if (!BluetoothService.isPowered)
                        return "Activate to connect";

                    if (BluetoothService.isDiscovering)
                        return "Search...";

                    return "No devices found";
                }
                color: Config.surface2Color
                font.pixelSize: Config.fontSizeNormal
                font.italic: true
            }
        }
    }
}
