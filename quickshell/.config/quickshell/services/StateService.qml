pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string statePath: Quickshell.env("HOME") + "/.config/quickshell/state.json"
    readonly property string defaultsPath: Quickshell.env("HOME") + "/.lyne-dots/.data/quickshell/defaults.json"

    property var state: ({})
    property bool isLoading: true

    signal stateLoaded

    Component.onCompleted: loadState()

    // Watch state.json for external changes (e.g. from lyne CLI)
    FileView {
        id: stateWatcher
        path: root.statePath
        watchChanges: true

        onFileChanged: _reloadDebounce.restart()
    }

    Timer {
        id: _reloadDebounce
        interval: 150
        onTriggered: {
            if (!loadProc.running)
                root.loadState();
        }
    }

    // --- Dot Notation Functions ---
    function get(path: string, defaultValue) {
        const keys = path.split('.');
        let current = state;
        for (const key of keys) {
            if (current !== null && typeof current === 'object' && key in current) {
                current = current[key];
            } else {
                return defaultValue;
            }
        }
        return current;
    }

    function set(path: string, value) {
        const keys = path.split('.');
        let current = state;
        for (let i = 0; i < keys.length - 1; i++) {
            const key = keys[i];
            if (!(key in current) || typeof current[key] !== 'object')
                current[key] = {};
            current = current[key];
        }
        current[keys[keys.length - 1]] = value;
        if (!isLoading)
            saveState();
    }

    // --- IO Logic ---
    function loadState() {
        isLoading = true;
        loadProc.running = true;
    }

    function saveState() {
        const jsonStr = JSON.stringify(state, null, 2);
        saveProc.command = ["bash", "-c", "mkdir -p \"$(dirname '" + statePath + "')\" && " + "echo '" + jsonStr.replace(/'/g, "'\\''") + "' > '" + statePath + "'"];
        saveProc.running = true;
    }

    Process {
        id: loadProc
        command: ["bash", "-c", "cat '" + root.statePath + "' 2>/dev/null || cat '" + root.defaultsPath + "' 2>/dev/null || echo '{}'"]

        property string buffer: ""
        stdout: SplitParser {
            onRead: data => loadProc.buffer += data
        }

        onExited: (exitCode, exitStatus) => {
            try {
                const newState = JSON.parse(loadProc.buffer.trim());
                const changed = JSON.stringify(root.state) !== JSON.stringify(newState);
                root.state = newState;
                root.isLoading = false;
                loadProc.buffer = "";
                if (changed)
                    root.stateLoaded();
            } catch (e) {
                console.error("[StateService] JSON Parse Error:", e);
                root.isLoading = false;
                loadProc.buffer = "";
            }
        }
    }

    Process {
        id: saveProc
    }
}
