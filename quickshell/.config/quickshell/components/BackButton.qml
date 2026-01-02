pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.config

Button {
    id: root

    // --- Propriedades ---
    property string iconText: ""        // O ícone (texto)
    property string tooltipText: "Voltar" // Texto de ajuda ao passar o mouse
    property int size: 40                // Tamanho do botão

    // --- Ajuste Fino (Offsets) ---
    // Use se o ícone da fonte não estiver visualmente centralizado
    property real iconOffsetX: -2
    property real iconOffsetY: 0

    // --- Layout ---
    implicitWidth: size
    implicitHeight: size
    Layout.preferredWidth: size
    Layout.preferredHeight: size

    // --- Fundo ---
    background: Rectangle {
        radius: root.height / 2 // Garante círculo perfeito

        // Cor muda no Hover (passar o mouse)
        color: root.hovered ? Config.surface2Color : "transparent"

        // Behavior on color {
        //     ColorAnimation {
        //         duration: Config.animDuration
        //     }
        // }
    }

    // --- Conteúdo (Ícone) ---
    Text {
        // Centraliza em relação ao wrapper
        anchors.centerIn: parent

        // Aplica os offsets manuais
        anchors.horizontalCenterOffset: root.iconOffsetX
        anchors.verticalCenterOffset: root.iconOffsetY

        text: root.iconText

        color: Config.textColor
        font.family: Config.font
        font.pixelSize: Config.fontSizeIcon
    }

    // --- Tooltip ---
    ToolTip.visible: root.hovered && root.tooltipText !== ""
    ToolTip.text: root.tooltipText
    ToolTip.delay: 500
}
