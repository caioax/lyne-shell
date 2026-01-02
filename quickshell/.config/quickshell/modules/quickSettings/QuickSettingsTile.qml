pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.config

Rectangle {
    id: root

    // Propriedades para personalizar cada botão
    property string icon: ""
    property string label: ""
    property bool active: false
    property bool hasDetails: false

    // Sinais para quem usar esse componente saber o que aconteceu
    signal toggled
    signal openDetails

    Layout.fillWidth: true
    height: 40
    radius: 30

    // Cor muda se estiver ativo ou não
    color: active ? Config.accentColor : Config.surface1Color

    RowLayout {
        anchors.fill: parent
        anchors.margins: 30, 0, 30, 0
        anchors.centerIn: parent
        spacing: 10

        // Área Principal (Ícone + Texto)
        MouseArea {
            Layout.fillWidth: true
            Layout.fillHeight: true
            cursorShape: Qt.PointingHandCursor

            onClicked: root.toggled()

            RowLayout {
                anchors.fill: parent
                Column {

                    Text {
                        text: "  " + root.icon
                        font.pixelSize: 20
                        color: root.active ? "#FFF" : Config.textColor
                    }
                }

                Text {
                    text: root.label
                    font.bold: true
                    color: root.active ? "#FFF" : Config.textColor
                    Layout.fillWidth: true
                }
            }
        }

        // Botão de configurações
        Text {
            visible: root.hasDetails
            text: "   "
            font.bold: true
            color: root.active ? "#FFF" : Config.textColor

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                // Importante: propagar cliques apenas se quiser
                onClicked: root.openDetails()
            }
        }
    }
}
