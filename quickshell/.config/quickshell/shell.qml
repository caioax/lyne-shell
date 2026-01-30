//@ pragma Env QS_NO_RELOAD_POPUP=1
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.services
import "./modules/bar/"

ShellRoot {
    id: root

    // =========================================================================
    // GLOBAL MODULE STATE
    // =========================================================================

    property bool screenshotActive: false

    // =========================================================================
    // BLUETOOTH AGENT
    // =========================================================================

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

    // =========================================================================
    // UI COMPONENTS - LAZY LOADING
    // =========================================================================

    // Bar - always active (main component)
    Bar {}

    // Notifications - loads on demand when there are notifications
    Loader {
        id: notificationLoader
        active: NotificationService.activePopupCount > 0 || NotificationService.popups.length > 0
        source: "./modules/notifications/NotificationOverlay.qml"

        onStatusChanged: {
            if (status === Loader.Ready)
                console.log("[Shell] NotificationOverlay loaded");
        }
    }

    // Power Overlay - loads on demand when requested
    Loader {
        id: powerLoader
        active: PowerService.overlayVisible
        source: "./modules/power/PowerOverlay.qml"

        onStatusChanged: {
            if (status === Loader.Ready)
                console.log("[Shell] PowerOverlay loaded");
        }
    }

    // Screenshot Manager - loads on demand
    Loader {
        id: screenshotLoader
        active: root.screenshotActive
        source: "./modules/screenshot/ScreenshotManager.qml"

        onStatusChanged: {
            if (status === Loader.Ready) {
                console.log("[Shell] ScreenshotManager loaded");
                screenshotLoader.item.startCapture();
            }
        }

        // Deactivate when screenshot finishes
        Connections {
            target: screenshotLoader.item
            enabled: screenshotLoader.status === Loader.Ready

            function onActiveChanged() {
                if (screenshotLoader.item && !screenshotLoader.item.active) {
                    root.screenshotActive = false;
                }
            }
        }
    }

    // Launcher
    Loader {
        active: true
        source: "./modules/launcher/Launcher.qml"
    }

    // OSD - loads on demand
    Loader {
        active: OsdService.visible
        source: "./modules/osd/OsdOverlay.qml"
    }

    // Wallpaper Picker - loads on demand
    Loader {
        active: WallpaperService.pickerVisible
        source: "./modules/wallpaper/WallpaperPicker.qml"
    }

    // Clipboard History - loads on demand
    Loader {
        active: ClipboardService.visible
        source: "./modules/clipboard/ClipboardHistory.qml"
    }

    // =========================================================================
    // GLOBAL SHORTCUTS
    // =========================================================================

    // Shortcut: Screenshot (Print)
    GlobalShortcut {
        name: "take_screenshot"
        description: "Screenshot capture"

        onPressed: {
            console.log("[Shell] Screenshot requested");
            root.screenshotActive = true;
        }
    }

    // Shortcut: Power Menu
    GlobalShortcut {
        name: "power_menu"
        description: "Power menu"

        onPressed: {
            console.log("[Shell] Power menu requested");
            PowerService.showOverlay();
        }
    }

    // Shortcut: Launcher
    GlobalShortcut {
        name: "app_launcher"
        description: "App Launcher"

        onPressed: LauncherService.show()
    }

    // Shortcut: Volume Up
    GlobalShortcut {
        name: "volume_up"
        description: "Increase volume"

        onPressed: {
            AudioService.increaseVolume();
            OsdService.showVolume(AudioService.volume, AudioService.muted);
        }
    }

    // Shortcut: Volume Down
    GlobalShortcut {
        name: "volume_down"
        description: "Decrease volume"

        onPressed: {
            AudioService.decreaseVolume();
            OsdService.showVolume(AudioService.volume, AudioService.muted);
        }
    }

    // Shortcut: Volume Mute
    GlobalShortcut {
        name: "volume_mute"
        description: "Mute volume"

        onPressed: {
            AudioService.toggleMute();
            OsdService.showVolume(AudioService.volume, AudioService.muted);
        }
    }

    // Shortcut: Brightness Up
    GlobalShortcut {
        name: "brightness_up"
        description: "Increase brightness"

        onPressed: {
            BrightnessService.increaseBrightness();
            OsdService.showBrightness(BrightnessService.brightness);
        }
    }

    // Shortcut: Brightness Down
    GlobalShortcut {
        name: "brightness_down"
        description: "Decrease brightness"

        onPressed: {
            BrightnessService.decreaseBrightness();
            OsdService.showBrightness(BrightnessService.brightness);
        }
    }

    // Shortcut: Wallpaper Picker
    GlobalShortcut {
        name: "wallpaper_picker"
        description: "Wallpaper picker"

        onPressed: WallpaperService.toggle()
    }

    // Shortcut: Clipboard History
    GlobalShortcut {
        name: "clipboard_history"
        description: "Clipboard history"

        onPressed: ClipboardService.toggle()
    }
}
