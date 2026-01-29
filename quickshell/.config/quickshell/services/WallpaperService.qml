pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ========================================================================
    // PROPRIEDADES
    // ========================================================================

    property bool pickerVisible: false
    property string currentWallpaper: ""
    property var wallpapers: []
    property var selectedWallpapers: []
    property bool confirmDelete: false

    readonly property string wallpaperDir: Quickshell.env("HOME") + "/.local/wallpapers"
    readonly property int selectedCount: selectedWallpapers.length

    // Transições disponíveis no swww
    readonly property var transitions: [
        "wipe",
        "wave",
        "grow",
        "center",
        "outer",
        "any"
    ]

    // ========================================================================
    // INICIALIZAÇÃO
    // ========================================================================

    Component.onCompleted: {
        refreshWallpapers();
        getCurrentWallpaper();
    }

    // ========================================================================
    // FUNÇÕES PÚBLICAS
    // ========================================================================

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
        if (pickerVisible) hide();
        else show();
    }

    // Seleção
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

    // Aplicar wallpaper
    function setWallpaper(path: string) {
        const transition = transitions[Math.floor(Math.random() * transitions.length)];
        const duration = (Math.random() * 1.5 + 0.5).toFixed(1);

        setWallpaperProc.command = [
            "swww", "img", path,
            "--transition-type", transition,
            "--transition-duration", duration,
            "--transition-fps", "60",
            "--transition-step", "90"
        ];
        setWallpaperProc.running = true;

        // Salvar wallpaper atual no arquivo .current para persistência
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
        if (wallpapers.length === 0) return;

        const available = wallpapers.filter(w => w !== currentWallpaper);
        if (available.length === 0) return;

        const randomIndex = Math.floor(Math.random() * available.length);
        setWallpaper(available[randomIndex]);
    }

    // Deletar
    function requestDelete() {
        if (selectedWallpapers.length === 0) return;

        if (selectedWallpapers.length === 1) {
            // Deleta direto se for só um
            deleteSelected();
        } else {
            // Pede confirmação se for mais de um
            confirmDelete = true;
        }
    }

    function deleteSelected() {
        for (const path of selectedWallpapers) {
            deleteWallpaperProc.command = ["rm", path];
            deleteWallpaperProc.running = true;

            // Remove da lista local
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

    // Adicionar
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
    // PROCESSOS
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
