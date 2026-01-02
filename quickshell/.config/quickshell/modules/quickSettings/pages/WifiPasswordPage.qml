pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.config
import qs.services

Item {
    id: root

    // O Item wrapper serve para podermos centralizar o ColumnLayout na tela
    Layout.fillWidth: true
    Layout.fillHeight: true

    // Propriedades recebidas
    property string targetSsid: ""

    signal cancelled
    signal connectClicked(string password)

    // Intercepta cliques no fundo para perder o foco do input se clicar fora
    MouseArea {
        anchors.fill: parent
        onClicked: parent.forceActiveFocus()
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width * 0.85 // Ocupa 85% da largura da janela
        spacing: 20

        // --- Ícone de Destaque ---
        Text {
            text: ""
            font.family: Config.font
            font.pixelSize: 48
            color: Config.accentColor
            Layout.alignment: Qt.AlignHCenter
        }

        // --- Títulos ---
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 5

            Text {
                text: "Senha Necessária"
                color: Config.subtextColor
                font.pixelSize: Config.fontSizeNormal
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: root.targetSsid
                color: Config.textColor
                font.bold: true
                font.pixelSize: Config.fontSizeLarge
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: parent.width
            }
        }

        // --- Campo de Senha ---
        TextField {
            id: passInput
            Layout.fillWidth: true
            Layout.preferredHeight: 45

            placeholderText: "Digite a senha da rede..."
            placeholderTextColor: Qt.alpha(Config.subtextColor, 0.5)

            color: Config.textColor
            font.family: Config.font
            font.pixelSize: Config.fontSizeNormal

            verticalAlignment: TextInput.AlignVCenter
            leftPadding: 15
            rightPadding: 40 // Espaço para o ícone do olho

            echoMode: showPassToggle.checked ? TextInput.Normal : TextInput.Password
            passwordCharacter: "•"

            background: Rectangle {
                color: Config.surface1Color
                radius: Config.radius
                border.width: 1
                border.color: passInput.activeFocus ? Config.accentColor : Config.surface2Color

                // Animação suave na borda ao focar
                Behavior on border.color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }

            // Botão de Mostrar/Ocultar Senha (Olho)
            Text {
                id: eyeIcon
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter

                text: showPassToggle.checked ? "" : "" // Icones NerdFont (Olho aberto/fechado)
                font.family: Config.font
                font.pixelSize: 16
                color: showPassHover.containsMouse ? Config.textColor : Config.subtextColor

                MouseArea {
                    id: showPassHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: showPassToggle.checked = !showPassToggle.checked
                }
            }

            // Controle de estado invisível para o toggle
            Item {
                id: showPassToggle
                property bool checked: false
            }

            // Pede foco ao abrir
            onVisibleChanged: if (visible)
                forceActiveFocus()

            // Enter conecta
            onAccepted: {
                if (text.length > 0) {
                    root.connectClicked(text);
                    text = "";
                }
            }
        }

        // --- Botões de Ação ---
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 10
            spacing: 15

            // Botão Cancelar
            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                background: Rectangle {
                    color: parent.down ? Qt.darker(Config.surface1Color, 1.2) : parent.hovered ? Config.surface1Color : "transparent"
                    radius: Config.radius
                    border.width: 1
                    border.color: Config.surface2Color

                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }
                    }
                }

                contentItem: Text {
                    text: "Cancelar"
                    color: Config.subtextColor
                    font.family: Config.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    passInput.text = "";
                    showPassToggle.checked = false;
                    root.cancelled();
                }
            }

            // Botão Conectar
            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                enabled: passInput.text.length >= 8 // Validação básica WPA2 (min 8 chars)
                opacity: enabled ? 1.0 : 0.5

                background: Rectangle {
                    color: parent.down ? Qt.darker(Config.accentColor, 1.1) : Config.accentColor
                    radius: Config.radius

                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }
                    }
                }

                contentItem: Text {
                    text: "Conectar"
                    color: Config.textReverseColor
                    font.bold: true
                    font.family: Config.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    root.connectClicked(passInput.text);
                    passInput.text = "";
                    showPassToggle.checked = false;
                }
            }
        }
    }
}
