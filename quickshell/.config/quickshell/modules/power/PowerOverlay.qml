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

    // Use a dedicated property to track if we should be "visually" open
    property bool active: PowerService.overlayVisible

    // Keep the window alive as long as it's active OR the animation is running
    visible: active || backgroundCanvas.opacity > 0

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.namespace: "qs_powerOverlay"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    color: "transparent"

    property int selectedIndex: 0
    readonly property var actions: [
        {
            id: "shutdown",
            icon: "󰐥",
            color: Config.accentColor,
            label: "Shutdown"
        },
        {
            id: "reboot",
            icon: "󰜉",
            color: Config.accentColor,
            label: "Reboot"
        },
        {
            id: "suspend",
            icon: "󰒲",
            color: Config.accentColor,
            label: "Suspend"
        },
        {
            id: "logout",
            icon: "󰍃",
            color: Config.accentColor,
            label: "Log Out"
        },
        {
            id: "lock",
            icon: "󰌾",
            color: Config.accentColor,
            label: "Lock"
        }
    ]

    function navigate(delta: int) {
        selectedIndex = (selectedIndex + delta + actions.length) % actions.length;
    }

    function executeSelected() {
        PowerService.executeAction(actions[selectedIndex].id);
    }

    // Helper function to start the close sequence
    function close() {
        active = false; // Trigger fade out
        hideOverlayTimer.start(); // Eventually tell the service we are done
    }

    // Canvas for background and fade animation
    Rectangle {
        id: backgroundCanvas
        anchors.fill: parent
        color: Qt.alpha("black", 0.4)

        // Animates based on our internal 'active' state
        opacity: root.active ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: Config.animDuration
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }

        PowerWidget {
            id: powerWidget
            anchors.centerIn: parent
            selectedIndex: root.selectedIndex
            actions: root.actions

            onSelectedIndexChanged: root.selectedIndex = selectedIndex
            onActionExecuted: root.executeSelected()

            scale: root.active ? 1.0 : 0.95
            Behavior on scale {
                NumberAnimation {
                    duration: Config.animDuration
                    easing.type: Easing.OutQuint
                }
            }
        }
    }

    // Sync back with PowerService after animation finishes
    Timer {
        id: hideOverlayTimer
        interval: Config.animDuration
        onTriggered: PowerService.hideOverlay()
    }

    // Ensure our internal state resets when the service shows the overlay
    onVisibleChanged: {
        if (visible && PowerService.overlayVisible) {
            root.active = true;
            selectedIndex = 0;
            focusTimer.restart();
        }
    }

    Item {
        id: keyHandler
        focus: true
        Keys.onPressed: event => {
            switch (event.key) {
            case Qt.Key_Escape:
                root.close();
                break;
            case Qt.Key_Return:
            case Qt.Key_Enter:
                root.executeSelected();
                break;
            case Qt.Key_Left:
            case Qt.Key_H:
                root.navigate(-1);
                break;
            case Qt.Key_Right:
            case Qt.Key_L:
                root.navigate(1);
                break;
            case Qt.Key_1:
            case Qt.Key_2:
            case Qt.Key_3:
            case Qt.Key_4:
            case Qt.Key_5:
                let index = event.key - Qt.Key_1;
                if (index >= 0 && index < actions.length)
                    root.selectedIndex = index;
                break;
            }
            event.accepted = true;
        }
    }

    HyprlandFocusGrab {
        id: focusGrab
        windows: [root]
        active: false
        onCleared: root.close()
    }

    Timer {
        id: focusTimer
        interval: 50
        onTriggered: {
            focusGrab.active = true;
            keyHandler.forceActiveFocus();
        }
    }
}
