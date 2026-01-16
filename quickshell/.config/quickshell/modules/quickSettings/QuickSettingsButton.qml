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

    // Ícones
    RowLayout {
        id: iconsLayout
        anchors.centerIn: parent
        spacing: Config.spacing // Espaço entre os ícones

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

        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.rect: Qt.rect(0, 0, root.width, root.height + 10)

        visible: false
    }

    // Interação
    // Detecta o mouse passando por cima (Hover)
    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor // Muda o cursor para mãozinho
    }

    // Detecta o clique
    TapHandler {
        id: tapHandler
        onTapped: {
            quickSettingsWindow.visible = !quickSettingsWindow.visible;
        }
    }
}
