pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.config
import qs.services
import "../../quickSettings/"
import "../../../components/"

ColumnLayout {
    id: root
    spacing: 16

    signal closeWindow

    // 1. HEADER (Perfil e Info)
    RowLayout {
        Layout.fillWidth: true
        spacing: 12

        // Avatar / Ícone do Sistema
        Rectangle {
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            radius: 16
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Config.surface2Color
                }
                GradientStop {
                    position: 1.0
                    color: Config.surface1Color
                }
            }

            Text {
                anchors.centerIn: parent
                text: "󰣇"
                font.family: Config.font
                font.pixelSize: Config.fontSizeIconLarge
                color: Config.accentColor
            }
        }

        // Texto de Boas-vindas
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: Quickshell.env("USER")
                color: Config.textColor
                font.family: Config.font
                font.bold: true
                font.pixelSize: Config.fontSizeLarge
            }
            Text {
                text: TimeService.format("ddd, dd MMM")
                color: Config.subtextColor
                font.family: Config.font
                font.pixelSize: Config.fontSizeSmall
            }
        }

        // Espaçador
        Item {
            Layout.fillWidth: true
        }

        // Botão Power (Pequeno no canto)
        Rectangle {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            radius: Config.radius
            color: powerBtnHover.containsMouse ? Qt.rgba(Config.errorColor.r, Config.errorColor.g, Config.errorColor, 0.2) : "transparent"
            border.width: 1
            border.color: powerBtnHover.containsMouse ? Config.errorColor : Config.surface2Color

            Text {
                anchors.centerIn: parent
                text: ""
                font.family: Config.font
                color: Config.errorColor
            }

            MouseArea {
                id: powerBtnHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    powerRofi.running = true
                    root.closeWindow();
                }
            }

            // Temporáriamente usando o menu power antigo com rofi
            Process {
                id: powerRofi
                command: ["bash", "-c", "$HOME/.config/waybar/scripts/powermenu.sh"]
            }
        }
    }

    // 2. GRID DE BOTÕES (Estilo ToggleButton grande)
    GridLayout {
        columns: 2
        columnSpacing: 10
        rowSpacing: 10
        Layout.fillWidth: true

        // WI-FI BUTTON
        QuickSettingsTile {
            icon: NetworkService.systemIcon
            label: "Wi-Fi"
            // Sublabel mostra o SSID ou "Off"
            property string ssid: NetworkService.accessPoints.find(ap => ap.active)?.ssid || "Conectado"
            // Aqui adaptamos para mostrar um texto extra se quiser (sublabel)

            active: NetworkService.wifiEnabled
            hasDetails: true
            onToggled: NetworkService.toggleWifi()
            onOpenDetails: pageStack.currentIndex = 1
        }

        // BLUETOOTH BUTTON
        QuickSettingsTile {
            icon: BluetoothService.systemIcon
            label: "Bluetooth"
            active: BluetoothService.isPowered
            hasDetails: true
            onToggled: BluetoothService.togglePower()
            onOpenDetails: pageStack.currentIndex = 3
        }

        // Night Light
        QuickSettingsTile {
            icon: active ? "󰌵" : "󰌶"
            label: "Luz de leitura"
            active: false
            hasDetails: false
            onToggled: active = !active
        }

        // DND (Exemplo simples)
        QuickSettingsTile {
            icon: active ? "󰂛" : "󰂚"
            label: "DND"
            active: false
            hasDetails: false
            onToggled: active = !active
        }
    }

    // 3. SLIDERS
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 12
        Layout.topMargin: 4

        QsSlider {
            icon: ""
            value: AudioService.volume
            onMoved: val => AudioService.setVolume(val)
        }

        // Exemplo de Brilho (Mockup, precisaria de um BrightnessService)
        QsSlider {
            icon: "󰃠"
            value: 0.7
        }
    }
}
