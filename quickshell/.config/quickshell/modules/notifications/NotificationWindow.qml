pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.config
import qs.services
import "../../components/"

QsPopupWindow {
    id: root

    popupWidth: 400
    popupMaxHeight: 600
    anchorSide: "right"
    moduleName: "NotificationWindow"
    contentImplicitHeight: popupMaxHeight - 32

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // ========== HEADER ==========
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // Decorative icon
            Rectangle {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                radius: Config.radius
                color: NotificationService.dndEnabled ? Qt.alpha(Config.warningColor, 0.2) : Qt.alpha(Config.accentColor, 0.15)

                Behavior on color {
                    ColorAnimation {
                        duration: Config.animDuration
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: NotificationService.dndEnabled ? "󰂛" : "󰂚"
                    font.family: Config.font
                    font.pixelSize: Config.fontSizeLarge
                    color: NotificationService.dndEnabled ? Config.warningColor : Config.accentColor
                }
            }

            // Title and counter
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: "Notifications"
                    font.family: Config.font
                    font.bold: true
                    font.pixelSize: Config.fontSizeLarge
                    color: Config.textColor
                }

                Text {
                    visible: NotificationService.count > 0 || NotificationService.dndEnabled
                    text: {
                        if (NotificationService.dndEnabled)
                            return "Do not disturb active";
                        return NotificationService.count + (NotificationService.count === 1 ? " notification" : " notifications");
                    }
                    font.family: Config.font
                    font.pixelSize: Config.fontSizeSmall
                    color: NotificationService.dndEnabled ? Config.warningColor : Config.subtextColor
                }
            }

            // Spacer
            Item {
                Layout.fillWidth: true
            }

            // DND Toggle Button
            ActionButton {
                size: 32
                icon: NotificationService.dndEnabled ? "󰂛" : "󰂚"
                iconSize: 14
                text: "DND"
                baseColor: NotificationService.dndEnabled ? Config.warningColor : Config.surface1Color
                hoverColor: NotificationService.dndEnabled ? Config.warningColor : Config.surface2Color
                textColor: NotificationService.dndEnabled ? Config.textReverseColor : Config.subtextColor
                hoverTextColor: NotificationService.dndEnabled ? Config.textReverseColor : Config.subtextColor
                onClicked: NotificationService.toggleDnd()
            }

            // Clear All Button
            ClearButton {
                visible: NotificationService.count > 0
                icon: "󰆴"
                text: "Clear"

                onClicked: NotificationService.clearAll()
            }
        }

        // ========== SEPARATOR ==========
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Config.surface1Color
        }

        // ========== NOTIFICATION LIST ==========
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: listView
                anchors.fill: parent
                clip: true
                spacing: 10
                visible: NotificationService.count > 0

                model: NotificationService.notifications

                add: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: Config.animDuration
                    }
                    NumberAnimation {
                        property: "x"
                        from: 30
                        to: 0
                        duration: Config.animDuration
                        easing.type: Easing.OutQuad
                    }
                }

                remove: Transition {
                    NumberAnimation {
                        property: "opacity"
                        to: 0
                        duration: Config.animDurationShort
                    }
                }

                displaced: Transition {
                    NumberAnimation {
                        properties: "y"
                        duration: Config.animDuration
                        easing.type: Easing.OutQuad
                    }
                }

                delegate: NotificationCard {
                    required property var modelData

                    wrapper: modelData
                    popupMode: false
                    width: listView.width
                }

                ScrollBar.vertical: ScrollBar {
                    active: listView.moving || listView.contentHeight > listView.height
                    policy: ScrollBar.AsNeeded

                    contentItem: Rectangle {
                        implicitWidth: 4
                        implicitHeight: 100
                        radius: 2
                        color: Config.surface2Color
                        opacity: parent.active ? 0.8 : 0
                    }

                    background: Rectangle {
                        implicitWidth: 4
                        color: "transparent"
                    }
                }
            }

            // Empty state
            Column {
                anchors.centerIn: parent
                spacing: 12
                visible: NotificationService.count === 0

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 64
                    height: 64
                    radius: 32
                    color: NotificationService.dndEnabled ? Qt.alpha(Config.warningColor, 0.2) : Config.surface1Color

                    Text {
                        anchors.centerIn: parent
                        text: NotificationService.dndEnabled ? "󰂛" : "󰂜"
                        font.family: Config.font
                        font.pixelSize: Config.fontSizeIconLarge
                        color: NotificationService.dndEnabled ? Config.warningColor : Config.subtextColor
                        opacity: NotificationService.dndEnabled ? 1.0 : 0.5
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: NotificationService.dndEnabled ? "Do Not Disturb" : "No notifications"
                    font.family: Config.font
                    font.pixelSize: Config.fontSizeNormal
                    color: NotificationService.dndEnabled ? Config.warningColor : Config.subtextColor
                    opacity: 0.7
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: NotificationService.dndEnabled ? "Notifications silenced" : "You're all caught up!"
                    font.family: Config.font
                    font.pixelSize: Config.fontSizeSmall
                    color: Config.subtextColor
                    opacity: 0.5
                }
            }
        }
    }
}
