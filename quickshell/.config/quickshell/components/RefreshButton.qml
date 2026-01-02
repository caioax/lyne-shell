pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.config

Button {
    id: root

    // --- Propriedades---
    property bool loading: false         // Controla se mostra o Spinner ou o Ícone
    property int size: 30                // Tamanho do botão
    property string tooltipText: "Atualizar"

    // --- Ajuste Fino (Offsets) ---
    property real iconOffsetX: 0.5
    property real iconOffsetY: 0.5

    // --- Layout ---
    implicitWidth: size
    implicitHeight: size
    Layout.preferredWidth: size
    Layout.preferredHeight: size

    // --- Fundo ---
    background: Rectangle {
        radius: root.height / 2

        color: {
            if (root.loading)
                return Config.accentColor;
            if (root.hovered)
                return Config.surface2Color
            return Config.surface1Color;
        }

        Behavior on color {
            ColorAnimation {
                duration: Config.animDuration
            }
        }
    }

    // --- Conteúdo ---
    contentItem: Item {
        anchors.centerIn: root

        // Ícone de Refresh (Visível quando NÃO está carregando)
        Text {
            anchors.centerIn: parent

            // Offsets manuais
            anchors.horizontalCenterOffset: root.iconOffsetX
            anchors.verticalCenterOffset: root.iconOffsetY

            text: ""
            font.family: Config.font
            font.pixelSize: Config.fontSizeNormal
            color: Config.textColor

            visible: !root.loading
        }

        // Spinner (Visível quando ESTÁ carregando)
        Spinner {
            anchors.centerIn: parent
            running: root.loading
            size: Config.fontSizeNormal + 2
            color: Config.textReverseColor
        }
    }

    // --- Tooltip ---
    ToolTip.visible: root.hovered && root.tooltipText !== ""
    ToolTip.text: root.tooltipText
    ToolTip.delay: 500
}
