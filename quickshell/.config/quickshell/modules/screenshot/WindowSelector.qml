pragma ComponentBehavior: Bound
import QtQuick
import qs.config

Item {
    id: root

    required property var screenshot
    required property var monitorScreen

    // Window highlight rectangle
    Rectangle {
        visible: root.screenshot.selectionWidth > 0

        x: root.screenshot.selectionX - 4
        y: root.screenshot.selectionY - 4
        width: root.screenshot.selectionWidth + 8
        height: root.screenshot.selectionHeight + 8

        color: "transparent"
        radius: Config.radius + 4
        border.width: 3
        border.color: Config.accentColor

        // Outer glow
        Rectangle {
            anchors.fill: parent
            anchors.margins: -6
            radius: parent.radius + 6
            color: "transparent"
            border.width: 10
            border.color: Qt.alpha(Config.accentColor, 0.2)
            z: -1
        }
    }
}
