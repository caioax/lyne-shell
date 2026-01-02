pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.config
import "../../components/"
import "../quickSettings/"

Scope {
    id: root

    readonly property int gapIn: 5
    readonly property int gapOut: 15

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            property bool enableAutoHide: false

            // --- CONFIGURAÇÃO DA BARRA ---
            implicitHeight: 30
            color: "transparent"
            screen: modelData

            // Overlay garante que fique sobre jogos/fullscreen
            // WlrLayershell.layer: WlrLayer.Overlay

            // Define o modo de exclusão
            exclusionMode: enableAutoHide ? ExclusionMode.Ignore : ExclusionMode.Normal

            // Garante o tamanho da área reservada quando em modo Normal
            exclusiveZone: enableAutoHide ? 0 : height

            anchors {
                top: true
                left: true
                right: true
            }

            // --- LÓGICA DE AUTOHIDE ---
            // Se o mouse estiver em cima, margem é 0 (mostra tudo).
            // Se não, margem é -29 (esconde, deixando 1px no topo para pegar o mouse).
            margins.top: enableAutoHide ? mouseSensor.hovered ? 0 : (-1 * (height - 1)) : 0

            // Animação suave no movimento da janela
            Behavior on margins.top {
                NumberAnimation {
                    duration: Config.animDuration
                    easing.type: Easing.OutExpo
                }
            }

            // --- SENSOR DE MOUSE ---
            // Cobre toda a janela. Como a janela nunca "some" (só sai da tela),
            // o pedacinho de 1px que sobra ainda detecta o mouse.
            HoverHandler {
                id: mouseSensor
            }

            Rectangle {
                id: barContent
                anchors.fill: parent
                color: Config.backgroundColor

                // --- ESQUERDA ---
                RowLayout {
                    anchors.left: parent.left
                    anchors.leftMargin: root.gapOut
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: root.gapIn

                    Workspaces {}
                }

                // --- CENTRO ---
                RowLayout {
                    anchors.centerIn: parent
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: root.gapIn

                    Clock {}
                }

                // --- DIREITA ---
                RowLayout {
                    anchors.right: parent.right
                    anchors.rightMargin: root.gapOut
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: root.gapIn

                    TrayWidget {}
                    QuickSettingsButton {}
                }
            }
        }
    }
}
