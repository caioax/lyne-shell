import QtQuick
import Quickshell
import Quickshell.Io
import "./modules/bar/"
import "./modules/notifications/"
import "./modules/power/"

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

    Loader {
        active: true
        sourceComponent: Bar {}
    }

    NotificationOverlay {}

    PowerOverlay {}
}
