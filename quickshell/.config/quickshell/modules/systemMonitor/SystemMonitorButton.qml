pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import QtQuick.Layouts
import qs.config
import qs.services

Rectangle {
    id: root

    implicitWidth: buttonContent.implicitWidth + (Config.padding * 4)
    implicitHeight: Config.barHeight - 10
    radius: height / 2

    color: {
        if (monitorWindow.visible)
            return Config.surface1Color;
        if (hoverHandler.hovered)
            return Config.surface1Color;
        return "transparent";
    }

    RowLayout {
        id: buttonContent
        anchors.centerIn: parent
        spacing: Config.spacing

        Text {
            text: "󰍛"
            font.family: Config.font
            font.pixelSize: Config.fontSizeLarge
            color: monitorWindow.visible ? Config.accentColor : Config.textColor
        }
    }

    SystemMonitorWindow {
        id: monitorWindow
        visible: false
    }

    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: monitorWindow.visible = !monitorWindow.visible
    }
}
