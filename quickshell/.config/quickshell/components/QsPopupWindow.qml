pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.services

PanelWindow {
    id: root

    property int popupWidth: 380
    property int popupMaxHeight: 700
    property string anchorSide: "left"
    property string moduleName: ""
    property real contentImplicitHeight: 0

    default property alias content: contentContainer.data

    signal closing

    readonly property int screenMargin: 5

    WlrLayershell.namespace: "qs_modules"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.exclusiveZone: -1

    anchors {
        top: true
        left: anchorSide === "left"
        right: anchorSide === "right"
    }

    margins {
        top: Config.barHeight + 10
        left: anchorSide === "left" ? 10 : 0
        right: anchorSide === "right" ? 10 : 0
    }

    implicitWidth: popupWidth + (screenMargin * 2)
    implicitHeight: popupMaxHeight
    color: "transparent"

    property bool isClosing: false
    property bool isOpening: false

    function closeWindow() {
        if (!visible)
            return;
        isClosing = true;
        closeTimer.restart();
    }

    Timer {
        id: closeTimer
        interval: Config.animDuration
        onTriggered: {
            root.closing();
            root.visible = false;
            root.isClosing = false;
        }
    }

    HyprlandFocusGrab {
        id: focusGrab
        windows: [root]
        active: false
        onCleared: root.closeWindow()
    }

    Timer {
        id: grabTimer
        interval: 10
        onTriggered: {
            focusGrab.active = true;
            background.forceActiveFocus();
        }
    }

    onVisibleChanged: {
        if (visible) {
            isClosing = false;
            isOpening = true;
            if (moduleName !== "")
                WindowManagerService.registerOpen(moduleName);
            grabTimer.restart();
        } else {
            focusGrab.active = false;
            isOpening = false;
            if (moduleName !== "")
                WindowManagerService.registerClose(moduleName);
        }
    }

    Item {
        anchors.fill: parent

        Rectangle {
            id: background
            width: root.popupWidth
            height: Math.min(root.popupMaxHeight, root.contentImplicitHeight + 32)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            color: Config.backgroundTransparentColor
            radius: Config.radiusLarge
            border.width: 1.0
            border.color: Config.surface2Color
            clip: true

            transformOrigin: root.anchorSide === "left" ? Item.TopLeft : Item.TopRight

            property bool showState: visible && !root.isClosing && root.isOpening

            scale: showState ? 1.0 : 0.9
            opacity: showState ? 1.0 : 0.0

            Behavior on scale {
                NumberAnimation {
                    duration: Config.animDurationLong
                    easing.type: Easing.OutExpo
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Config.animDurationShort
                }
            }

            Behavior on height {
                NumberAnimation {
                    duration: Config.animDuration
                    easing.type: Easing.OutQuad
                }
            }

            Keys.onEscapePressed: root.closeWindow()

            Item {
                id: contentContainer
                anchors.fill: parent
                anchors.margins: 16
            }
        }
    }
}
