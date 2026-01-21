pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.services

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        delegate: PanelWindow {
            id: window

            required property var modelData
            screen: modelData

            visible: PowerService.overlayVisible

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.exclusiveZone: -1

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            color: "transparent"

            // Fundo escurecido com fade
            Rectangle {
                id: backdrop
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.75)

                opacity: PowerService.overlayVisible ? 1.0 : 0.0
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.animDuration
                        easing.type: Easing.OutQuad
                    }
                }

                // Fecha ao clicar fora
                MouseArea {
                    anchors.fill: parent
                    onClicked: PowerService.hideOverlay()
                }

                // Conteúdo central com fade (sem slide)
                Item {
                    anchors.centerIn: parent
                    width: contentColumn.width
                    height: contentColumn.height

                    // Apenas fade, sem movimento
                    opacity: PowerService.overlayVisible ? 1.0 : 0.0
                    scale: PowerService.overlayVisible ? 1.0 : 0.95

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Config.animDurationLong
                            easing.type: Easing.OutQuad
                        }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: Config.animDurationLong
                            easing.type: Easing.OutQuad
                        }
                    }

                    ColumnLayout {
                        id: contentColumn
                        spacing: 30

                        // Título
                        ColumnLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 8

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "⏻"
                                font.family: Config.font
                                font.pixelSize: 48
                                color: Config.textColor
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "O que deseja fazer?"
                                font.family: Config.font
                                font.pixelSize: Config.fontSizeLarge
                                font.bold: true
                                color: Config.textColor
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Pressione ESC para cancelar"
                                font.family: Config.font
                                font.pixelSize: Config.fontSizeSmall
                                color: Config.subtextColor
                            }
                        }

                        // Grid de botões
                        GridLayout {
                            Layout.alignment: Qt.AlignHCenter
                            columns: 3
                            columnSpacing: 20
                            rowSpacing: 20

                            Repeater {
                                model: [
                                    {
                                        id: "shutdown",
                                        label: "Desligar",
                                        icon: "⏻",
                                        color: "#f7768e",
                                        description: "Desliga o computador"
                                    },
                                    {
                                        id: "reboot",
                                        label: "Reiniciar",
                                        icon: "󰜉",
                                        color: "#e0af68",
                                        description: "Reinicia o computador"
                                    },
                                    {
                                        id: "suspend",
                                        label: "Suspender",
                                        icon: "󰒲",
                                        color: "#7aa2f7",
                                        description: "Suspende o sistema"
                                    },
                                    {
                                        id: "hibernate",
                                        label: "Hibernar",
                                        icon: "󰋊",
                                        color: "#9ece6a",
                                        description: "Hiberna o sistema"
                                    },
                                    {
                                        id: "lock",
                                        label: "Bloquear",
                                        icon: "󰌾",
                                        color: "#bb9af7",
                                        description: "Bloqueia a tela"
                                    },
                                    {
                                        id: "logout",
                                        label: "Sair",
                                        icon: "󰍃",
                                        color: "#7dcfff",
                                        description: "Encerra a sessão"
                                    }
                                ]

                                delegate: Rectangle {
                                    id: actionBtn

                                    required property var modelData
                                    required property int index

                                    Layout.preferredWidth: 120
                                    Layout.preferredHeight: 120
                                    radius: Config.radiusLarge

                                    color: {
                                        if (btnMouse.pressed)
                                            return Qt.darker(modelData.color, 1.2);
                                        if (btnMouse.containsMouse)
                                            return Qt.alpha(modelData.color, 0.3);
                                        return Config.surface1Color;
                                    }

                                    border.width: btnMouse.containsMouse ? 2 : 0
                                    border.color: modelData.color

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: Config.animDurationShort
                                        }
                                    }

                                    scale: btnMouse.pressed ? 0.95 : 1.0
                                    Behavior on scale {
                                        NumberAnimation {
                                            duration: Config.animDurationShort
                                        }
                                    }

                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 10

                                        Text {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: modelData.icon
                                            font.family: Config.font
                                            font.pixelSize: 36
                                            color: btnMouse.containsMouse ? modelData.color : Config.textColor
                                        }

                                        Text {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: modelData.label
                                            font.family: Config.font
                                            font.pixelSize: Config.fontSizeNormal
                                            font.bold: true
                                            color: btnMouse.containsMouse ? modelData.color : Config.textColor
                                        }
                                    }

                                    MouseArea {
                                        id: btnMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor

                                        onClicked: {
                                            PowerService.executeAction(modelData.id);
                                        }
                                    }

                                    // Tooltip com descrição
                                    Rectangle {
                                        visible: btnMouse.containsMouse
                                        anchors.top: parent.bottom
                                        anchors.topMargin: 8
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: tooltipText.implicitWidth + 16
                                        height: tooltipText.implicitHeight + 8
                                        radius: Config.radiusSmall
                                        color: Config.surface0Color

                                        Text {
                                            id: tooltipText
                                            anchors.centerIn: parent
                                            text: modelData.description
                                            font.family: Config.font
                                            font.pixelSize: Config.fontSizeSmall
                                            color: Config.subtextColor
                                        }
                                    }
                                }
                            }
                        }

                        // Botão cancelar
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 40
                            radius: Config.radius
                            color: cancelMouse.containsMouse ? Config.surface2Color : Config.surface1Color

                            Behavior on color {
                                ColorAnimation {
                                    duration: Config.animDurationShort
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "Cancelar"
                                font.family: Config.font
                                font.pixelSize: Config.fontSizeNormal
                                color: Config.textColor
                            }

                            MouseArea {
                                id: cancelMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: PowerService.hideOverlay()
                            }
                        }
                    }
                }

                // Teclas de atalho
                Keys.onEscapePressed: PowerService.hideOverlay()
                Keys.onPressed: event => {
                    // Atalhos numéricos (1-6)
                    const actions = ["shutdown", "reboot", "suspend", "hibernate", "lock", "logout"];
                    if (event.key >= Qt.Key_1 && event.key <= Qt.Key_6) {
                        const index = event.key - Qt.Key_1;
                        PowerService.executeAction(actions[index]);
                    }
                }

                Component.onCompleted: forceActiveFocus()
            }

            onVisibleChanged: {
                if (visible) {
                    backdrop.forceActiveFocus();
                }
            }
        }
    }
}
