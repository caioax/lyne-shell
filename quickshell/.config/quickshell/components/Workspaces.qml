pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.config

RowLayout {
    id: root

    spacing: 3

    readonly property int widthSize: 19
    readonly property int heightSize: 19
    readonly property int widthSizeActive: 36
    readonly property int heightSizeActive: 20

    // 1. Pega o ID atual (se for nulo, assume 1)
    readonly property int currentId: Hyprland.focusedWorkspace?.id ?? 1

    // Calcula onde a lista deve começar
    property int startId: 1

    Repeater {
        model: 10

        delegate: Rectangle {
            id: workspaceItem

            required property var modelData
            required property var index

            Layout.alignment: Qt.AlignVCenter
            radius: Config.radius

            // Tentamos pegar o objeto real do workspace na memória do Hyprland
            property var wsObject: Hyprland.workspaces.values.find(ws => ws.id === workspaceId)

            // Verifica se o workspace esta vazio
            property bool isEmpty: wsObject === undefined

            // Pega o id da workspace atual
            property int workspaceId: root.startId + index

            // Verifica se este workspace (workspace) é o focado (Hyprland.focusedWorkspace)
            property bool isActive: Hyprland.focusedWorkspace && workspaceId === Hyprland.focusedWorkspace.id

            // Escolhe o tamanho correto para o widget
            property int realWidth: isActive ? root.widthSizeActive : root.widthSize
            property int realHeight: isActive ? root.heightSizeActive : root.heightSize

            readonly property bool visibleState: isVisible()

            visible: Layout.preferredWidth > 0
            clip: true

            color: {
                if (isActive)
                    return Config.accentColor;
                if (!isEmpty)
                    return Config.surface2Color;
                return Config.surface0Color;
            }

            // border.width: isEmpty ? 1 : 0
            // border.color: Config.surface2Color

            Layout.preferredWidth: visibleState ? realWidth : 0
            Layout.preferredHeight: visibleState ? realHeight : 0

            // Verificas quais workspaces devem estar visiveis
            function isVisible(): bool {
                // Limite inferion: Foco - 2 (Ex: Se foco 4, mostra a partir do 2)
                var minVisible = root.currentId - 2;
                // Limite superior: Foco + 2 (Ex: Se foco 4, mostra até o 6)
                var maxVisible = root.currentId + 2;

                if (root.currentId < 3) {
                    minVisible = 1;
                    maxVisible = 5;
                } else if (root.currentId > 8) {
                    minVisible = 6;
                    maxVisible = 10;
                }

                return workspaceId >= minVisible && workspaceId <= maxVisible;
            }

            HoverHandler {
                cursorShape: !workspaceItem.isActive ? Qt.PointingHandCursor : undefined
                onHoveredChanged: {
                    workspaceItem.opacity = hovered && !workspaceItem.isActive ? 0.7 : 1.0;
                }
            }

            // Animações
            Behavior on color {
                ColorAnimation {
                    duration: Config.animDuration
                }
            }

            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: Config.animDuration
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Config.animDuration
                }
            }

            // O número do workspace
            Text {
                anchors.centerIn: parent
                text: workspaceItem.workspaceId

                font.family: Config.font
                font.bold: true

                font.pixelSize: workspaceItem.isActive ? Config.fontSizeNormal : Config.fontSizeSmall

                color: {
                    if (workspaceItem.isActive)
                        return Config.textReverseColor;
                    if (!workspaceItem.isEmpty)
                        return Config.textColor;
                    return Config.subtextColor;
                }
            }

            // --- Ação de clique ---
            TapHandler {
                onTapped: {
                    // Envia comando para o Hyprland trocar de workspace
                    Hyprland.dispatch("workspace " + workspaceItem.workspaceId);
                }
            }
        }
    }
}
