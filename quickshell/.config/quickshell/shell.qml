import QtQuick
import Quickshell
import Quickshell.Io
import "./modules/bar/"
import "./modules/notifications/"

ShellRoot {
    id: root

    readonly property string bluetoothAgentScriptPath: Qt.resolvedUrl("./scripts/bluetooth-agent.py").toString().replace("file://", "")
    Process {
        id: bluetoothAgent

        command: ["python3", root.bluetoothAgentScriptPath]
        running: true

        stdout: SplitParser {
            onRead: data => console.log("[BluetoothAgent]: " + data)
        }
        stderr: SplitParser {
            onRead: data => console.error("[BluetoothAgent]: " + data)
        }
    }

    Process {
        id: workspaceManager

        command: ["bash", "-c", "$HOME/.config/quickshell/scripts/workspace-manager.sh --auto-update"]
        running: true
    }

    Loader {
        active: true
        sourceComponent: Bar {}
    }

    NotificationOverlay {}
}
