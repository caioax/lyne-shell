pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Singleton {
    id: root

    // Helper function to shorten the service call
    function getState(path, fallback) {
        return StateService.get(path, fallback);
    }
    function setState(path, value) {
        StateService.set(path, value);
    }

    // ========================================================================
    // PROPERTIES
    // ========================================================================

    property bool caffeineEnabled: getState("idle.caffeine", false)
    property bool dpmsEnabled: getState("idle.dpmsEnabled", true)
    property int lockTimeout: getState("idle.lockTimeout", 600)
    property int dpmsTimeout: getState("idle.dpmsTimeout", 300)

    // ========================================================================
    // STATE PERSISTENCE
    // ========================================================================

    Connections {
        target: StateService

        function onStateLoaded() {
            root.caffeineEnabled = root.getState("idle.caffeine", false);
            root.dpmsEnabled = root.getState("idle.dpmsEnabled", true);
            root.lockTimeout = root.getState("idle.lockTimeout", 600);
            root.dpmsTimeout = root.getState("idle.dpmsTimeout", 300);
            console.log("[Idle] Loaded state - caffeine:", root.caffeineEnabled, "dpms:", root.dpmsEnabled, "lockTimeout:", root.lockTimeout + "s", "dpmsTimeout:", root.dpmsTimeout + "s");
        }
    }

    // ========================================================================
    // IDLE INHIBITOR (CAFFEINE)
    // ========================================================================

    PanelWindow {
        id: inhibitorWindow
        visible: root.caffeineEnabled
        implicitWidth: 0
        implicitHeight: 0
        color: "transparent"
        mask: Region {}

        IdleInhibitor {
            enabled: root.caffeineEnabled
            window: inhibitorWindow
        }
    }

    // ========================================================================
    // PROCESSES
    // ========================================================================

    Process {
        id: dpmsOffProc
        command: ["hyprctl", "dispatch", "dpms", "off"]
    }

    Process {
        id: dpmsOnProc
        command: ["hyprctl", "dispatch", "dpms", "on"]
    }

    // ========================================================================
    // PUBLIC FUNCTIONS
    // ========================================================================

    function lock() {
        console.log("[Idle] Locking screen");
        LockService.lock();
    }

    function toggleCaffeine() {
        caffeineEnabled = !caffeineEnabled;
        root.setState("idle.caffeine", caffeineEnabled);
        console.log("[Idle] Caffeine:", caffeineEnabled);
    }

    function dpmsOn() {
        dpmsOnProc.running = true;
    }

    function dpmsOff() {
        dpmsOffProc.running = true;
    }
}
