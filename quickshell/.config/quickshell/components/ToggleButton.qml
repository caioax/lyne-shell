pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.config

Button {
    id: root

    // --- Propriedades ---
    property bool active: false          // O estado principal (true = ligado/colorido)
    property string iconOn: ""           // Ícone quando ativo
    property string iconOff: ""          // Ícone quando inativo (opcional)
    property string tooltipText: ""      // Texto do tooltip
    property int size: 30                // Tamanho do botão

    // --- Ajuste Fino (Offsets) ---
    // Use se o ícone da fonte não estiver visualmente centralizado
    property real iconOffsetX: 0
    property real iconOffsetY: 0

    // Se iconOff não for definido, usa o mesmo ícone para os dois estados
    readonly property string currentIcon: active ? iconOn : (iconOff !== "" ? iconOff : iconOn)

    // Layout
    implicitWidth: size
    implicitHeight: size
    Layout.preferredWidth: size
    Layout.preferredHeight: size

    // --- Fundo ---
    background: Rectangle {
        radius: root.width / 2

        color: {
            if (root.active)
                return Config.accentColor;
            if (root.hovered)
                return Config.surface2Color;
            return Config.surface1Color;
        }

        Behavior on color {
            ColorAnimation {
                duration: Config.animDuration
            }
        }
    }

    // --- Ícone ---
    contentItem: Item {
        anchors.fill: parent

        Text {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: root.iconOffsetX
            anchors.verticalCenterOffset: root.iconOffsetY

            text: root.currentIcon

            font.family: Config.font
            font.pixelSize: Config.fontSizeNormal
            font.bold: true

            // Se ativo, usa cor de contraste (preto/escuro). Se inativo, usa cor de texto normal.
            color: root.active ? Config.textReverseColor : Config.textColor

            // Leve transparência quando inativo para indicar que está "desligado"
            opacity: root.active ? 1.0 : 0.6
        }
    }

    // --- Tooltip ---
    ToolTip.visible: root.hovered && root.tooltipText !== ""
    ToolTip.text: root.tooltipText
    ToolTip.delay: 500
}
