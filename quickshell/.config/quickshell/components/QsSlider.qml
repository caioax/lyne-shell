pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.config

Control {
    id: root

    // --- Propriedades ---
    property real value: 0
    property real from: 0
    property real to: 1
    property string icon: ""

    // Sinal emitido quando o usuário arrasta
    signal moved(real newValue)

    implicitHeight: 46
    Layout.fillWidth: true

    background: Rectangle {
        id: bg
        radius: Config.radiusLarge
        color: Config.surface1Color

        // Barra de preenchimento (Progresso)
        Rectangle {
            width: parent.width * ((root.value - root.from) / (root.to - root.from))
            height: parent.height
            radius: Config.radiusLarge
            color: Config.accentColor

            // Animação suave para mudanças externas (ex: teclas de volume)
            Behavior on width {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutQuad
                }
            }
        }

        // Ícone (Esquerda)
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 15
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            font.family: Config.font
            font.pixelSize: Config.fontSizeIcon
            font.bold: true
            color: Config.textColor
        }

        // Texto de Porcentagem (Direita - Aparece no Hover/Click)
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 15
            anchors.verticalCenter: parent.verticalCenter

            // Calcula a porcentagem baseada no range from-to
            text: Math.round(((root.value - root.from) / (root.to - root.from)) * 100) + "%"

            font.family: Config.font
            font.bold: true
            color: Config.textColor

            // Só mostra quando interage
            visible: mouseArea.containsMouse || mouseArea.pressed
            opacity: visible ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }
        }
    }

    // --- Interação ---
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        // Função para calcular o valor baseado na posição X do clique
        function updateValue(mouseX) {
            let percentage = mouseX / width;
            // Garante que fique entre 0 e 1 (clamp)
            percentage = Math.max(0, Math.min(1, percentage));

            // Converte a porcentagem para o range real (ex: 0.0 a 1.5)
            let finalValue = root.from + (root.to - root.from) * percentage;
            root.moved(finalValue);
        }

        onPressed: mouse => updateValue(mouse.x)
        onPositionChanged: mouse => {
            if (pressed)
                updateValue(mouse.x);
        }
    }
}
