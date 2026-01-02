pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import qs.config

Switch {
    id: root

    implicitWidth: 46
    implicitHeight: 26

    indicator: Rectangle {
        implicitWidth: root.implicitWidth
        implicitHeight: root.implicitHeight
        radius: Config.radiusLarge

        color: root.checked ? Config.accentColor : Config.surface2Color

        border.width: 1
        border.color: "transparent"

        Behavior on color {
            ColorAnimation {
                duration: Config.animDuration
            }
        }

        Rectangle {
            x: root.checked ? (parent.width - width - 4) : 4
            anchors.verticalCenter: parent.verticalCenter

            width: parent.height - 8
            height: parent.height - 8
            radius: width / 2

            color: Config.textColor

            Behavior on x {
                NumberAnimation {
                    duration: Config.animDuration
                    easing.type: Easing.OutExpo
                }
            }
        }
    }

    // Removemos o texto padrão para não atrapalhar o layout
    contentItem: Item {}
}
