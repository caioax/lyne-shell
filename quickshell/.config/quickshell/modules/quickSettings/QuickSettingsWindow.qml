pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.config
import qs.services
import "./pages/"

PopupWindow {
    id: root

    // Defina o tamanho fixo da sua janela
    implicitWidth: 400
    implicitHeight: 400

    color: "transparent"

    // Processos para Criar/Apagar o arquivo de trava
    Process {
        id: createLock
        command: ["touch", "/tmp/QsQuickSettingsOpen"]
    }

    Process {
        id: removeLock
        command: ["rm", "/tmp/QsQuickSettingsOpen"]
    }

    HyprlandFocusGrab {
        id: focusGrab

        windows: [root]

        active: false

        onCleared: {
            root.visible = false;
        }
    }

    // Timer para garantir que a janela já existe antes de pedir o foco
    Timer {
        id: grapTimer
        interval: 10
        repeat: false
        onTriggered: {
            focusGrab.active = true;
            background.forceActiveFocus();
        }
    }

    // Lógica manual de ativação
    onVisibleChanged: {
        if (visible) {
            createLock.running = true;

            grapTimer.restart();
        } else {
            removeLock.running = true;

            pageStack.currentIndex = 0; // Volta para o menu principal
            grapTimer.stop();
            focusGrab.active = false;
        }
    }

    Rectangle {
        id: background

        anchors.fill: parent
        color: Config.backgroundColor
        radius: Config.radius
        border.width: 0
        border.color: Config.surface2Color
        clip: true
        focus: true
        Keys.onEscapePressed: {
            root.visible = false;
        }

        StackLayout {
            id: pageStack
            anchors.fill: parent
            anchors.margins: 10
            currentIndex: 0 // 0 = Menu Principal

            // --- PÁGINA 0: MENU PRINCIPAL ---
            ColumnLayout {
                spacing: 10

                Text {
                    text: "Quick Settings"
                    font.bold: true
                    color: Config.textColor
                    Layout.alignment: Qt.AlignHCenter
                }

                // Exemplo de layout em grade para os botões
                GridLayout {
                    columns: 2
                    Layout.fillWidth: true

                    // Botão WI-FI
                    QuickSettingsTile {
                        icon: NetworkService.systemIcon
                        label: "Wi-Fi"
                        active: NetworkService.wifiEnabled
                        hasDetails: true

                        onToggled: NetworkService.toggleWifi()
                        onOpenDetails: pageStack.currentIndex = 1
                    }

                    // Botão BLUETOOTH
                    QuickSettingsTile {
                        icon: BluetoothService.systemIcon
                        label: "Bluetooth"
                        active: BluetoothService.isPowered
                        hasDetails: true

                        onToggled: BluetoothService.togglePower()
                        onOpenDetails: pageStack.currentIndex = 3
                    }

                    // Outros botões (ex: Modo Escuro, sem detalhes)
                    QuickSettingsTile {
                        icon: "󰽥 "
                        label: "Dark"
                        hasDetails: false
                        onToggled: active = !active
                    }
                }

                // Espaço vazio para empurrar tudo pra cima
                Item {
                    Layout.fillHeight: true
                }
            }

            // Wifi
            WifiPage {
                onBackRequested: pageStack.currentIndex = 0

                onPasswordRequested: ssid => {
                    console.log("Pedido senha para: " + ssid);
                    wifiPasswordPage.targetSsid = ssid;
                    pageStack.currentIndex = 2;
                }
            }

            // Senha Wifi
            WifiPasswordPage {
                id: wifiPasswordPage

                onCancelled: pageStack.currentIndex = 1

                onConnectClicked: password => {
                    NetworkService.connect(targetSsid, password);
                    pageStack.currentIndex = 1;
                }
            }

            // Bluetooth
            BluetoothPage {
                onBackRequested: pageStack.currentIndex = 0
            }
        }
    }
}
