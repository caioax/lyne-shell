pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.config

Rectangle {
    id: root

    // --- Propriedades Obrigatórias ---
    property string title: ""
    property string subtitle: ""
    property string icon: ""
    property string statusText: ""

    // --- Estados ---
    property bool active: false
    property bool connecting: false
    property bool secured: false

    // --- Menu ---
    property bool showMenu: false
    property var menuModel: []

    // --- Sinais ---
    signal clicked
    signal menuAction(string actionId)

    // --- Layout ---
    width: ListView.view ? ListView.view.width : 300
    height: 60
    radius: Config.radiusLarge

    // Borda colorida baseada no estado
    border.width: 1
    border.color: {
        if (root.active)
            return Config.accentColor;
        if (root.connecting)
            return Config.warningColor;
        return "transparent";
    }

    // Cor de fundo com hover
    color: {
        if (mouseArea.containsMouse)
            return Config.surface1Color;
        return Qt.alpha(Config.surface1Color, 0.4);
    }
    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    // Clique Principal
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        // Círculo com Ícone
        Rectangle {
            implicitWidth: 36
            implicitHeight: 36
            radius: parent.width / 2
            color: {
                if (root.active)
                    return Config.accentColor;
                if (root.connecting)
                    return Config.warningColor;
                return Config.surface2Color;
            }

            Item {
                anchors.fill: parent

                // Texto (Ícone)
                Text {
                    anchors.centerIn: parent
                    visible: !root.connecting
                    text: root.icon
                    font.family: Config.font
                    font.pixelSize: Config.fontSizeIcon
                    color: root.active ? Config.textReverseColor : Config.textColor
                }

                // Spinner
                Spinner {
                    anchors.centerIn: parent
                    running: root.connecting
                    color: Config.textReverseColor
                    size: Config.fontSizeIcon
                }
            }
        }

        // Informações (Texto)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: root.title
                color: Config.textColor
                font.bold: true
                font.pixelSize: Config.fontSizeNormal
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: 5

                // Subtítulo (Endereço MAC ou Detalhe)
                Text {
                    visible: root.subtitle !== ""
                    text: root.subtitle
                    color: Config.textColor
                    font.pixelSize: Config.fontSizeSmall
                    elide: Text.ElideRight
                }

                // Bolinha separadora (só se tiver subtítulo E status)
                Text {
                    visible: root.subtitle !== "" && root.statusText !== ""
                    text: "•"
                    color: Config.textColor
                    font.pixelSize: Config.fontSizeSmall
                }

                // Status (Conectado, Pareado...)
                Text {
                    text: root.statusText
                    color: {
                        if (root.active)
                            return Config.accentColor;
                        if (root.connecting)
                            return Config.warningColor;
                        return Config.subtextColor;
                    }
                    font.pixelSize: Config.fontSizeSmall
                    font.bold: root.active
                }
            }
        }

        // Ícone de Cadeado (Exclusivo Wi-Fi)
        Text {
            visible: root.secured && !root.active && !root.connecting
            text: ""
            font.family: Config.font
            color: Config.subtextColor
            font.pixelSize: Config.fontSizeSmall
        }

        // Botão do menu ---
        Rectangle {
            id: menuButton
            visible: root.showMenu
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            radius: 15
            color: menuMouse.containsMouse || menuPopup.opened ? Config.surface2Color : "transparent"

            Text {
                anchors.centerIn: parent
                text: "" // Ícone de 3 pontos verticais (mdi-dots-vertical)
                font.family: Config.font
                color: Config.textColor
                font.pixelSize: Config.fontSizeNormal
            }

            MouseArea {
                id: menuMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: menuPopup.open()
            }

            // --- Popup do menu ---
            Popup {
                id: menuPopup
                x: -width + 30 // Alinha à direita do botão
                y: 35 // Abre para baixo
                width: 140
                height: menuColumn.implicitHeight + 10

                padding: 0

                background: Rectangle {
                    color: Config.surface0Color
                    border.color: Config.surface2Color
                    border.width: 1
                    radius: Config.radius
                }

                ColumnLayout {
                    id: menuColumn
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 2

                    Repeater {
                        model: root.menuModel
                        delegate: Rectangle {
                            id: menuItem

                            required property var modelData

                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            radius: Config.radiusSmall
                            color: itemMouse.containsMouse ? Config.surface1Color : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 10

                                Text {
                                    visible: modelData.icon !== undefined
                                    text: modelData.icon || ""
                                    font.family: Config.font
                                    color: modelData.iconColor ?? Config.textColor
                                }

                                Text {
                                    text: modelData.text
                                    color: modelData.textColor ?? Config.textColor
                                    font.pixelSize: Config.fontSizeSmall
                                    Layout.fillWidth: true
                                }
                            }

                            MouseArea {
                                id: itemMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    menuPopup.close();
                                    root.menuAction(modelData.action);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
