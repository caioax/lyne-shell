pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.config
import qs.services

Item {
    id: root

    implicitWidth: Config.barHeight - 10
    implicitHeight: Config.barHeight - 10

    // Janela Popup
    NotificationWindow {
        id: notifWindow

        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.rect: Qt.rect(0, 0, root.width, root.height + 10)

        visible: false
    }

    // Botão Visual
    Rectangle {
        anchors.fill: parent
        radius: height / 2

        color: {
            if (notifWindow.visible || mouseArea.containsMouse)
                return Config.surface2Color;

            return "transparent";
        }

        Behavior on color {
            ColorAnimation {
                duration: Config.animDurationShort
            }
        }

        // Ícone (Sino) - sempre branco na barra
        Text {
            anchors.centerIn: parent
            text: {
                if (NotificationService.dndEnabled)
                    return "󰂛";
                if (NotificationService.count > 0)
                    return "󰂚";
                return "󰂜";
            }
            font.family: Config.font
            font.pixelSize: Config.fontSizeLarge
            // Cor sempre branca na barra, só muda se a janela estiver aberta
            color: notifWindow.visible ? Config.accentColor : Config.textColor
        }

        // Badge de contagem
        Rectangle {
            visible: NotificationService.count > 0 && !NotificationService.dndEnabled
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: -2
            anchors.rightMargin: -2

            width: Math.max(14, badgeText.implicitWidth + 6)
            height: 14
            radius: 7

            color: Config.errorColor

            Text {
                id: badgeText
                anchors.centerIn: parent
                text: NotificationService.count > 99 ? "99+" : NotificationService.count.toString()
                font.family: Config.font
                font.pixelSize: 9
                font.bold: true
                color: Config.textColor
            }
        }

        // Indicador de DND (pequeno ponto) - só quando DND ativo
        Rectangle {
            visible: NotificationService.dndEnabled && NotificationService.count === 0
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: -2
            anchors.rightMargin: -2

            width: 8
            height: 8
            radius: 4

            color: Config.warningColor
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                    NotificationService.toggleDnd();
                } else {
                    notifWindow.visible = !notifWindow.visible;
                }
            }
        }
    }
}
