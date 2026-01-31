pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.config
import qs.services

Item {
    id: root

    implicitWidth: Config.barHeight - 10
    implicitHeight: Config.barHeight - 10

    // Notification Window
    NotificationWindow {
        id: notifWindow

        visible: false
    }

    // Visual Button
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

        // Icon (Bell) - always white on the bar
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
            // Color always white on the bar, only changes if the window is open
            color: notifWindow.visible ? Config.accentColor : Config.textColor
        }

        // Count badge
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
