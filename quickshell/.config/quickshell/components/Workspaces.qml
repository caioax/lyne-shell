pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.config

Item {
    id: root

    implicitWidth: viewportWidth
    implicitHeight: heightSizeActive + 4

    readonly property int widthSize: 19
    readonly property int heightSize: 19
    readonly property int widthSizeActive: 36
    readonly property int heightSizeActive: 20
    readonly property int itemSpacing: 3
    readonly property int visibleCount: 5
    readonly property int totalWorkspaces: 99  // Limitado a 99 para evitar bug no offset

    // Largura total do viewport
    readonly property real viewportWidth: (widthSize * visibleCount) + (widthSizeActive - widthSize) + (itemSpacing * (visibleCount - 1))

    // Largura de um item padrão + spacing
    readonly property real itemStep: widthSize + itemSpacing

    // --- Lógica do Monitor ---
    property var currentMonitor: {
        if (!screen)
            return Hyprland.focusedMonitor;

        const screenName = screen.name;
        const monitor = Hyprland.monitors.values.find(m => m.name === screenName);
        return monitor ?? Hyprland.focusedMonitor;
    }

    property int activeId: currentMonitor ? currentMonitor.activeWorkspace.id : 1

    // Calcula offset baseado no ID (1-99 = monitor 0, 101-199 = monitor 1, etc.)
    property int monitorOffset: Math.floor((activeId - 1) / 100) * 100

    // ID relativo (1-99)
    readonly property int relativeActiveId: {
        let relative = activeId - monitorOffset;
        // Garante que está no range válido
        return Math.max(1, Math.min(relative, totalWorkspaces));
    }

    // Índice (0-based)
    readonly property int targetIndex: Math.max(0, Math.min(relativeActiveId - 1, totalWorkspaces - 1))

    // Posição X alvo com clamping nas bordas
    readonly property real targetScrollX: {
        // Posição ideal (centralizado)
        let idealX = (targetIndex * itemStep) - (viewportWidth / 2) + (widthSizeActive / 2);

        // Limites
        let minX = 0;
        let maxX = (totalWorkspaces * itemStep) - itemSpacing - viewportWidth + (widthSizeActive - widthSize);

        // Clamp
        return Math.max(minX, Math.min(idealX, maxX));
    }

    // Clip para esconder items fora
    clip: true

    Item {
        id: container

        x: -root.targetScrollX

        width: (root.totalWorkspaces * root.itemStep) + (root.widthSizeActive - root.widthSize)
        height: parent.height

        // SmoothedAnimation
        Behavior on x {
            SmoothedAnimation {
                velocity: Config.animDuration
                duration: Config.animDurationLong
            }
        }

        Row {
            id: row

            spacing: root.itemSpacing
            height: parent.height

            Repeater {
                model: root.totalWorkspaces

                delegate: Rectangle {
                    id: workspaceItem

                    required property int index

                    readonly property int workspaceId: root.monitorOffset + index + 1
                    readonly property int visualId: index + 1

                    readonly property bool isActive: workspaceId === root.activeId
                    readonly property var wsObject: Hyprland.workspaces.values.find(ws => ws.id === workspaceId)
                    readonly property bool isEmpty: wsObject === undefined

                    width: isActive ? root.widthSizeActive : root.widthSize
                    height: isActive ? root.heightSizeActive : root.heightSize

                    anchors.verticalCenter: parent.verticalCenter

                    radius: Config.radius

                    color: {
                        if (isActive)
                            return Config.accentColor;
                        if (!isEmpty)
                            return Config.surface2Color;
                        return Config.surface0Color;
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: Config.animDuration
                        }
                    }

                    Behavior on width {
                        SmoothedAnimation {
                            velocity: 150
                        }
                    }

                    Behavior on height {
                        SmoothedAnimation {
                            velocity: 150
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: workspaceItem.visualId

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

                        Behavior on font.pixelSize {
                            SmoothedAnimation {
                                velocity: 50
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: Config.animDuration
                            }
                        }
                    }

                    TapHandler {
                        onTapped: {
                            Hyprland.dispatch("workspace " + workspaceItem.workspaceId);
                        }
                    }

                    HoverHandler {
                        id: hoverHandler
                        cursorShape: !workspaceItem.isActive ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }

                    opacity: hoverHandler.hovered && !isActive ? 0.7 : 1.0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Config.animDuration / 2
                        }
                    }
                }
            }
        }
    }
}
