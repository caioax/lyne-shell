pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import QtQuick.Layouts
import qs.config
import "../../components/"

Rectangle {
    id: root

    implicitWidth: iconsLayout.implicitWidth + (Config.padding * 4)
    implicitHeight: Config.barHeight - 10

    radius: height / 2

    color: {
        if (quickSettingsWindow.visible)
            return Config.surface1Color;

        if (hoverHandler.hovered)
            return Config.surface1Color;

        return "transparent";
    }

    // Icons
    RowLayout {
        id: iconsLayout
        anchors.centerIn: parent
        spacing: Config.spacing // Space between icons

        property string iconColor: quickSettingsWindow.visible ? Config.accentColor : Config.textColor

        WifiIcon {
            color: iconsLayout.iconColor
        }
        BluetoothIcon {
            color: iconsLayout.iconColor
        }
        BatteryIcon {
            color: iconsLayout.iconColor
        }
    }

    QuickSettingsWindow {
        id: quickSettingsWindow

        visible: false
    }

    // Interaction
    // Detects mouse hovering over (Hover)
    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor // Changes cursor to hand pointer
    }

    // Detects click
    TapHandler {
        id: tapHandler
        onTapped: {
            quickSettingsWindow.visible = !quickSettingsWindow.visible;
        }
    }
}
