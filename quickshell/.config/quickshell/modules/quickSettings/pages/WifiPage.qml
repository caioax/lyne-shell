pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import "../../../components/"

Item {
    id: root

    signal backRequested
    signal passwordRequested(string ssid)

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

            // Botão voltar
            BackButton {
                onClicked: root.backRequested()
            }

            // Titulo
            Text {
                text: "Wi-Fi"
                color: Config.textColor
                font.bold: true
                font.pixelSize: Config.fontSizeIcon
                Layout.fillWidth: true
            }

            // Botão Escanear
            RefreshButton {
                visible: NetworkService.wifiEnabled
                loading: NetworkService.scanning

                onClicked: NetworkService.scan()
            }

            // Switch de Ligar/Desligar
            QsSwitch {
                checked: NetworkService.wifiEnabled
                onToggled: NetworkService.toggleWifi()
            }
        }

        // Lista de Redes
        ListView {
            id: wifiList
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 10
            clip: true
            spacing: 8

            model: NetworkService.wifiEnabled ? NetworkService.accessPoints : []

            delegate: DeviceCard {
                required property var modelData

                // Helper para saber se este card está conectando
                property bool isConnectingThis: NetworkService.connectingSsid === modelData.ssid

                // Dados
                title: modelData.ssid || "Rede Oculta"
                subtitle: modelData.signal + "%"
                icon: NetworkService.getWifiIcon(modelData.signal)

                // Estados
                active: modelData.active
                connecting: isConnectingThis
                secured: modelData.secure && !active && !connecting

                // Texto de status
                statusText: {
                    if (connecting)
                        return "Conectando...";
                    if (active)
                        return "Conectado";
                    if (modelData.saved)
                        return "Salvo";
                    if (modelData.secure)
                        return "Protegido";
                    return "Aberta";
                }

                // Menu
                showMenu: !connecting

                menuModel: {
                    var list = [];
                    if (active) {
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
                    if (active || modelData.saved) {
                        list.push({
                            text: "Esquecer",
                            action: "forget",
                            icon: "",
                            textColor: Config.errorColor,
                            iconColor: Config.errorColor
                        });
                    }
                    return list;
                }

                onMenuAction: actionId => {
                    if (actionId === "disconnect") {
                        NetworkService.disconnect();
                    } else if (actionId === "connect") {
                        wifiToggleConnect();
                    } else if (actionId === "forget") {
                        NetworkService.forget(modelData.ssid);
                    }
                }

                // Clique principal
                onClicked: wifiToggleConnect()

                function wifiToggleConnect() {
                    if (active) {
                        NetworkService.disconnect();
                        return;
                    }
                    if (modelData.saved) {
                        NetworkService.connect(modelData.ssid, "");
                        return;
                    }
                    if (modelData.secure) {
                        root.passwordRequested(modelData.ssid);
                    }
                    NetworkService.connect(modelData.ssid, "");
                }
            }

            // Mensagem de lista vazia
            Text {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -40
                visible: !NetworkService.wifiEnabled || (parent.count === 0 && !NetworkService.scanning)
                text: {
                    if (!NetworkService.wifiEnabled)
                        return "Wi-Fi Desligado";
                    return "Nenhuma rede encontrada";
                }
                color: Config.surface2Color
                font.pixelSize: Config.fontSizeNormal
                font.italic: true
            }
        }
    }
}
