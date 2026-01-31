pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

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

    property bool pickerVisible: false
    property string currentWallpaper: ""
    property var wallpapers: []
    property var selectedWallpapers: []
    property bool confirmDelete: false
    property bool dynamicWallpaper: getState("wallpaper.dynamic", true)

    readonly property string wallpaperDir: Quickshell.env("HOME") + "/.local/wallpapers"
    readonly property int selectedCount: selectedWallpapers.length

    // Available transitions in swww
    readonly property var transitions: ["wipe", "wave", "grow", "center", "outer", "any"]

    // ========================================================================
    // INITIALIZATION
    // ========================================================================

    Component.onCompleted: {
        refreshWallpapers();
        getCurrentWallpaper();
    }

    // ========================================================================
    // PUBLIC FUNCTIONS
    // ========================================================================

    function toggleDynamicWallpaper() {
        setState("wallpaper.dynamic", !dynamicWallpaper);
        dynamicWallpaper = getState("wallpaper.dynamic", true);
    }

    function show() {
        refreshWallpapers();
        selectedWallpapers = [];
        confirmDelete = false;
        pickerVisible = true;
    }

    function hide() {
        pickerVisible = false;
        selectedWallpapers = [];
        confirmDelete = false;
    }

    function toggle() {
        if (pickerVisible)
            hide();
        else
            show();
    }

    // Selection
    function isSelected(path: string): bool {
        return selectedWallpapers.includes(path);
    }

    function toggleSelection(path: string) {
        if (isSelected(path)) {
            selectedWallpapers = selectedWallpapers.filter(w => w !== path);
        } else {
            selectedWallpapers = [...selectedWallpapers, path];
        }
        confirmDelete = false;
    }

    function selectOnly(path: string) {
        selectedWallpapers = [path];
        confirmDelete = false;
    }

    function clearSelection() {
        selectedWallpapers = [];
        confirmDelete = false;
    }

    // Apply wallpaper
    function setWallpaper(path: string) {
        const transition = transitions[Math.floor(Math.random() * transitions.length)];
        const duration = (Math.random() * 1.5 + 0.5).toFixed(1);

        setWallpaperProc.command = ["swww", "img", path, "--transition-type", transition, "--transition-duration", duration, "--transition-fps", "60", "--transition-step", "90"];
        setWallpaperProc.running = true;

        // Save current wallpaper to .current file for persistence
        saveCurrentProc.command = ["bash", "-c", "echo '" + path + "' > '" + root.wallpaperDir + "/.current'"];
        saveCurrentProc.running = true;

        currentWallpaper = path;
        hide();
    }

    function applySelected() {
        if (selectedWallpapers.length === 1) {
            setWallpaper(selectedWallpapers[0]);
        }
    }

    function setRandomWallpaper() {
        if (wallpapers.length === 0)
            return;

        const available = wallpapers.filter(w => w !== currentWallpaper);
        if (available.length === 0)
            return;

        const randomIndex = Math.floor(Math.random() * available.length);
        setWallpaper(available[randomIndex]);
    }

    // Delete
    function requestDelete() {
        if (selectedWallpapers.length === 0)
            return;

        if (selectedWallpapers.length === 1) {
            // Delete directly if only one
            deleteSelected();
        } else {
            // Ask for confirmation if more than one
            confirmDelete = true;
        }
    }

    function deleteSelected() {
        for (const path of selectedWallpapers) {
            deleteWallpaperProc.command = ["rm", path];
            deleteWallpaperProc.running = true;

            // Remove from local list
            root.wallpapers = root.wallpapers.filter(w => w !== path);

            if (currentWallpaper === path) {
                currentWallpaper = "";
            }
        }
        selectedWallpapers = [];
        confirmDelete = false;
    }

    function cancelDelete() {
        confirmDelete = false;
    }

    // Add
    function addWallpapers() {
        hide();
        addWallpapersProc.running = true;
    }

    function refreshWallpapers() {
        listWallpapersProc.running = true;
    }

    function getCurrentWallpaper() {
        getCurrentProc.running = true;
    }

    // ========================================================================
    // PROCESSES
    // ========================================================================

    Process {
        id: listWallpapersProc
        command: ["bash", "-c", "ls -1 '" + root.wallpaperDir + "'/*.{png,jpg,jpeg,webp,gif} 2>/dev/null | sort"]
        stdout: SplitParser {
            onRead: data => {
                const trimmed = data.trim();
                if (trimmed && !trimmed.includes("*")) {
                    root.wallpapers = [...root.wallpapers, trimmed];
                }
            }
        }
        onStarted: root.wallpapers = []
    }

    Process {
        id: setWallpaperProc
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                console.log("[Wallpaper] Wallpaper changed successfully");
            } else {
                console.error("[Wallpaper] Failed to change wallpaper");
            }
        }
    }

    Process {
        id: getCurrentProc
        command: ["swww", "query"]
        stdout: SplitParser {
            onRead: data => {
                const match = data.match(/image:\s*(.+)/);
                if (match) {
                    root.currentWallpaper = match[1].trim();
                }
            }
        }
    }

    Process {
        id: addWallpapersProc
        command: ["bash", "-c", `
            files=$(kdialog --multiple --getopenfilename ~ "Image Files (*.png *.jpg *.jpeg *.webp *.gif)")
            if [ -n "$files" ]; then
                mkdir -p "${root.wallpaperDir}"
                echo "$files" | while read -r file; do
                    if [ -f "$file" ]; then
                        cp "$file" "${root.wallpaperDir}/"
                    fi
                done
                echo "done"
            else
                echo "cancelled"
            fi
        `]
        stdout: SplitParser {
            onRead: data => {
                const result = data.trim();
                if (result === "done" || result === "cancelled") {
                    root.refreshWallpapers();
                    root.show();
                }
            }
        }
    }

    Process {
        id: saveCurrentProc
    }

    Process {
        id: deleteWallpaperProc
    }
}
