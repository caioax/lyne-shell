pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import qs.config
import qs.services

Scope {
    id: root

    // =========================================================================
    // STATE
    // =========================================================================

    property bool active: false
    property string mode: "region"  // "region", "window", "screen"
    property string tempPath: ""

    // Selection coordinates (animated)
    property real selectionX: 0
    property real selectionY: 0
    property real selectionWidth: 0
    property real selectionHeight: 0

    // Confirmation state
    property bool hasSelection: false

    // Window info
    property string selectedWindowTitle: ""
    property string selectedWindowClass: ""

    // Current monitor tracking
    property var hyprlandMonitor: Hyprland.focusedMonitor
    property var activeScreen: null

    // Fresh data from hyprctl (updated on each capture)
    property var windowsFromIpc: []
    property var monitorsFromIpc: []

    readonly property var modes: ["region", "window", "screen"]
    readonly property var modeIcons: ({
            region: "󰩭",
            window: "󰖯",
            screen: "󰍹"
        })

    onActiveChanged: {
        if (!active)
            resetSelection();
    }
    // =========================================================================
    // ANIMATIONS
    // =========================================================================

    Behavior on selectionX {
        SpringAnimation {
            spring: 4
            damping: 0.4
        }
    }
    Behavior on selectionY {
        SpringAnimation {
            spring: 4
            damping: 0.4
        }
    }
    Behavior on selectionWidth {
        SpringAnimation {
            spring: 4
            damping: 0.4
        }
    }
    Behavior on selectionHeight {
        SpringAnimation {
            spring: 4
            damping: 0.4
        }
    }

    Component.onCompleted: {
        initializeMonitor();
    }

    // =========================================================================
    // MONITOR TRACKING
    // =========================================================================

    Connections {
        target: Hyprland
        enabled: root.activeScreen === null

        function onFocusedMonitorChanged() {
            root.initializeMonitor();
        }
    }

    // =========================================================================
    // WINDOW LIST FROM IPC (fresh data each capture)
    // =========================================================================

    // First: get monitors data
    Process {
        id: hyprctlMonitors
        command: ["hyprctl", "monitors", "-j"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                try {
                    root.monitorsFromIpc = JSON.parse(data);
                    console.log("[DEBUG] Parsed monitors:", root.monitorsFromIpc.length);
                } catch (e) {
                    console.log("[Screenshot] Failed to parse hyprctl monitors:", e);
                    root.monitorsFromIpc = [];
                }
            }
        }
        onExited: {
            // After monitors, get clients
            hyprctlClients.running = true;
        }
    }

    // Second: get clients/windows data
    Process {
        id: hyprctlClients
        command: ["hyprctl", "clients", "-j"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                try {
                    root.windowsFromIpc = JSON.parse(data);
                } catch (e) {
                    console.log("[Screenshot] Failed to parse hyprctl clients:", e);
                    root.windowsFromIpc = [];
                }
            }
        }
        onExited: {
            // After getting window data, capture the screen with grim
            root.startGrimCapture();
        }
    }

    // Third: capture screen with grim (must complete before showing overlay)
    Process {
        id: grimCapture
        onStarted: {
            console.log("[DEBUG] grim started with path:", root.tempPath);
        }
        onExited: (exitCode, exitStatus) => {
            console.log("[DEBUG] grim exited with code:", exitCode, "status:", exitStatus);
            // Only show overlay after grim has finished capturing
            root.active = true;
        }
    }

    function refreshWindowList() {
        // Start the chain: monitors -> clients -> grim -> show overlay
        hyprctlMonitors.running = true;
    }

    function startGrimCapture() {
        // Set command dynamically with current tempPath
        console.log("[DEBUG] startGrimCapture - tempPath:", root.tempPath);
        grimCapture.command = ["grim", root.tempPath];
        grimCapture.running = true;
    }

    // =========================================================================
    // FUNCTIONS
    // =========================================================================

    function initializeMonitor() {
        const monitor = Hyprland.focusedMonitor;
        if (!monitor)
            return;

        for (const screen of Quickshell.screens) {
            if (screen.name === monitor.name) {
                root.activeScreen = screen;
                root.hyprlandMonitor = monitor;
                // Don't set active here - it's set after grim captures
                return;
            }
        }
    }

    function startCapture() {
        // Prepare state and temp path first
        prepareCapture();
        // Start the chain: monitors -> clients -> grim -> show overlay
        refreshWindowList();
    }

    function prepareCapture() {
        // Reset state
        root.mode = "region";
        root.resetSelection();
        root.activeScreen = null;

        // Find current screen
        const monitor = Hyprland.focusedMonitor;
        if (monitor) {
            for (const screen of Quickshell.screens) {
                if (screen.name === monitor.name) {
                    root.activeScreen = screen;
                    root.hyprlandMonitor = monitor;
                    break;
                }
            }
        }

        // Create temp path for grim
        const timestamp = Date.now();
        root.tempPath = Quickshell.cachePath(`screenshot-${timestamp}.png`);
    }

    function cancelCapture() {
        root.active = false;
        root.hasSelection = false;
        // Temporarily disabled for debugging
        // if (root.tempPath !== "") {
        //     Quickshell.execDetached(["rm", "-f", root.tempPath]);
        // }
        console.log("[DEBUG] Cancelled - temp file kept at:", root.tempPath);
    }

    function resetSelection() {
        root.hasSelection = false;
        root.selectionX = 0;
        root.selectionY = 0;
        root.selectionWidth = 0;
        root.selectionHeight = 0;
        root.selectedWindowTitle = "";
        root.selectedWindowClass = "";
    }

    function setMode(newMode: string) {
        root.resetSelection();
        root.mode = newMode;

        if (newMode === "screen") {
            // Auto-select full screen
            root.selectionX = 0;
            root.selectionY = 0;
            root.selectionWidth = root.activeScreen?.width || 1920;
            root.selectionHeight = root.activeScreen?.height || 1080;
            root.hasSelection = true;
            root.selectedWindowTitle = root.hyprlandMonitor?.name || "Monitor";
        }
    }

    function saveScreenshot(x: real, y: real, width: real, height: real) {
        if (width < 5 || height < 5)
            return;

        const scale = root.hyprlandMonitor?.scale || 1;
        const monitorX = root.hyprlandMonitor?.x || 0;
        const monitorY = root.hyprlandMonitor?.y || 0;

        // Scale coordinates
        const scaledX = Math.round((x + monitorX) * scale);
        const scaledY = Math.round((y + monitorY) * scale);
        const scaledWidth = Math.round(width * scale);
        const scaledHeight = Math.round(height * scale);

        console.log("[DEBUG] saveScreenshot - tempPath:", root.tempPath);
        console.log("[DEBUG] saveScreenshot - selection:", x, y, width, height);
        console.log("[DEBUG] saveScreenshot - monitor offset:", monitorX, monitorY, "scale:", scale);
        console.log("[DEBUG] saveScreenshot - crop:", scaledWidth + "x" + scaledHeight + "+" + scaledX + "+" + scaledY);

        // Output path
        const picturesDir = Quickshell.env("XDG_PICTURES_DIR") || (Quickshell.env("HOME") + "/Pictures/Screenshots");
        const timestamp = Qt.formatDateTime(new Date(), "yyyy-MM-dd_hh-mm-ss");
        const outputPath = `${picturesDir}/screenshot-${timestamp}.png`;

        // Build and execute command
        const cmd = [`mkdir -p "${picturesDir}"`, `magick "${root.tempPath}" -crop ${scaledWidth}x${scaledHeight}+${scaledX}+${scaledY} +repage "${outputPath}"`, `wl-copy < "${outputPath}"`, `rm -f "${root.tempPath}"`, `notify-send -i accessories-screenshot -a "Screenshot" "Screenshot Saved!" "Copied to clipboard: ${outputPath}"`].join(" && ");

        console.log("[DEBUG] saveScreenshot - command:", cmd);

        // Hide overlay and execute
        root.active = false;
        root.hasSelection = false;

        Quickshell.execDetached(["sh", "-c", cmd]);
    }

    function confirmSelection() {
        root.saveScreenshot(root.selectionX, root.selectionY, root.selectionWidth, root.selectionHeight);
    }

    // =========================================================================
    // TIMERS
    // =========================================================================

    Timer {
        id: showTimer
        interval: 50
        repeat: false
        onTriggered: root.active = true
    }

    // =========================================================================
    // OVERLAY WINDOWS (one per screen) - only created after grim capture
    // =========================================================================

    Loader {
        active: root.active
        sourceComponent: overlayComponent
    }

    Component {
        id: overlayComponent

        Variants {
            model: Quickshell.screens

            delegate: PanelWindow {
                id: window

                required property var modelData

                screen: modelData
                visible: true  // Always visible when loaded (Loader controls creation)

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            color: "transparent"

            // Monitor info
            property var hyprMonitor: Hyprland.monitorFor(modelData)
            property bool isActiveMonitor: modelData === root.activeScreen

            function findWindowAt(mouseX, mouseY) {
                // Find monitor data from fresh IPC data (by screen name)
                const screenName = modelData.name;
                const monitorIpc = root.monitorsFromIpc.find(m => m.name === screenName);
                if (!monitorIpc)
                    return null;

                const monitorX = monitorIpc.x;
                const monitorY = monitorIpc.y;
                const monitorId = monitorIpc.id;
                const activeWorkspaceId = monitorIpc.activeWorkspace?.id;

                // Use fresh window list from hyprctl IPC
                const windows = root.windowsFromIpc;
                if (!windows || windows.length === 0)
                    return null;

                // Iterate backwards to respect Z-order (top-most windows first)
                for (let i = windows.length - 1; i >= 0; i--) {
                    let win = windows[i];
                    if (!win)
                        continue;

                    // Filter windows on this monitor and active workspace only
                    if (win.monitor !== monitorId)
                        continue;

                    if (win.workspace?.id !== activeWorkspaceId)
                        continue;

                    // DEFENSIVE CHECK:
                    if (!win.at || !win.size || win.at.length < 2 || win.size.length < 2)
                        continue;

                    // Filter out invalid or special windows
                    if ((win.title === "" && win.class === "") || win.hidden)
                        continue;

                    // Calculate window boundaries relative to the current monitor
                    let winX = win.at[0] - monitorX;
                    let winY = win.at[1] - monitorY;
                    let winW = win.size[0];
                    let winH = win.size[1];

                    // Check if the mouse coordinates are within the window area
                    if (mouseX >= winX && mouseX <= winX + winW && mouseY >= winY && mouseY <= winY + winH) {
                        return {
                            x: winX,
                            y: winY,
                            width: winW,
                            height: winH,
                            title: win.title || win.class || "Window",
                            className: win.class || ""
                        };
                    }
                }
                return null;
            }

            // =================================================================
            // FROZEN SCREEN CAPTURE - using grim captured image
            // =================================================================

            Image {
                anchors.fill: parent
                source: root.tempPath ? "file://" + root.tempPath : ""
                fillMode: Image.PreserveAspectCrop
                z: 0
                cache: false

                // Crop to show only this monitor's portion
                sourceClipRect: Qt.rect(
                    window.hyprMonitor?.x || 0,
                    window.hyprMonitor?.y || 0,
                    modelData.width,
                    modelData.height
                )
            }

            // =================================================================
            // DIMMING SHADER
            // =================================================================

            ShaderEffect {
                anchors.fill: parent
                z: 1
                visible: window.isActiveMonitor

                property vector4d selectionRect: Qt.vector4d(root.selectionX, root.selectionY, root.selectionWidth, root.selectionHeight)
                property real dimOpacity: 0.6
                property vector2d screenSize: Qt.vector2d(width, height)
                property real borderRadius: Config.radius
                property real outlineThickness: 2.0

                fragmentShader: Qt.resolvedUrl("dimming.frag.qsb")
            }

            // Dim inactive monitors
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.6)
                visible: !window.isActiveMonitor
                z: 1
            }


            // =================================================================
            // REGION SELECTOR GUIDES
            // =================================================================

            Canvas {
                id: guides
                anchors.fill: parent
                z: 2
                visible: window.isActiveMonitor && root.mode === "region"

                property real guideMouseX: mainMouse.mouseX
                property real guideMouseY: mainMouse.mouseY

                onGuideMouseXChanged: requestPaint()
                onGuideMouseYChanged: requestPaint()

                Connections {
                    target: root
                    function onSelectionXChanged() {
                        guides.requestPaint();
                    }
                    function onSelectionYChanged() {
                        guides.requestPaint();
                    }
                    function onSelectionWidthChanged() {
                        guides.requestPaint();
                    }
                    function onSelectionHeightChanged() {
                        guides.requestPaint();
                    }
                }

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);

                    ctx.beginPath();
                    ctx.strokeStyle = "rgba(255, 255, 255, 0.5)";
                    ctx.lineWidth = 1;
                    ctx.setLineDash([5, 5]);

                    if (!mainMouse.pressed && !root.hasSelection) {
                        // Crosshair at cursor
                        ctx.moveTo(guideMouseX, 0);
                        ctx.lineTo(guideMouseX, height);
                        ctx.moveTo(0, guideMouseY);
                        ctx.lineTo(width, guideMouseY);
                    } else if (root.selectionWidth > 0 && root.selectionHeight > 0) {
                        // Guides around selection
                        ctx.moveTo(root.selectionX, 0);
                        ctx.lineTo(root.selectionX, height);
                        ctx.moveTo(root.selectionX + root.selectionWidth, 0);
                        ctx.lineTo(root.selectionX + root.selectionWidth, height);
                        ctx.moveTo(0, root.selectionY);
                        ctx.lineTo(width, root.selectionY);
                        ctx.moveTo(0, root.selectionY + root.selectionHeight);
                        ctx.lineTo(width, root.selectionY + root.selectionHeight);
                    }

                    ctx.stroke();
                }
            }

            // =================================================================
            // WINDOW HIGHLIGHT (for window mode)
            // =================================================================

            Rectangle {
                visible: window.isActiveMonitor && root.mode === "window" && root.selectionWidth > 0
                z: 3

                x: root.selectionX - 4
                y: root.selectionY - 4
                width: root.selectionWidth + 8
                height: root.selectionHeight + 8

                color: "transparent"
                radius: Config.radius + 4
                border.width: 3
                border.color: Config.accentColor

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -6
                    radius: parent.radius + 6
                    color: "transparent"
                    border.width: 10
                    border.color: Qt.alpha(Config.accentColor, 0.2)
                    z: -1
                }
            }

            // =================================================================
            // MOUSE INTERACTION
            // =================================================================

            MouseArea {
                id: mainMouse
                anchors.fill: parent
                z: 5
                hoverEnabled: true

                cursorShape: {
                    if (root.mode === "window")
                        return Qt.PointingHandCursor;
                    if (root.mode === "screen")
                        return Qt.ArrowCursor;
                    return root.hasSelection ? Qt.ArrowCursor : Qt.CrossCursor;
                }

                property real startX: 0
                property real startY: 0
                property bool dragging: false

                onEntered: {
                    // Switch active monitor
                    root.activeScreen = window.modelData;
                    root.hyprlandMonitor = window.hyprMonitor;

                    if (root.mode === "screen") {
                        root.setMode("screen");
                    }
                }

                onPositionChanged: mouse => {
                    if (root.mode === "window" && !root.hasSelection) {
                        let found = window.findWindowAt(mouse.x, mouse.y);
                        if (found) {
                            root.selectionX = found.x;
                            root.selectionY = found.y;
                            root.selectionWidth = found.width;
                            root.selectionHeight = found.height;
                            root.selectedWindowTitle = found.title;
                            root.selectedWindowClass = found.className;
                        } else {
                            root.resetSelection();
                        }
                    }
                    // Update active monitor if changed
                    if (root.activeScreen !== window.modelData) {
                        root.activeScreen = window.modelData;
                        root.hyprlandMonitor = window.hyprMonitor;
                        if (root.mode === "screen") {
                            root.setMode("screen");
                        }
                    }

                    // Region mode: drag selection
                    if (dragging && root.mode === "region" && !root.hasSelection) {
                        root.selectionX = Math.min(startX, mouse.x);
                        root.selectionY = Math.min(startY, mouse.y);
                        root.selectionWidth = Math.abs(mouse.x - startX);
                        root.selectionHeight = Math.abs(mouse.y - startY);
                    }
                }

                onPressed: mouse => {
                    if (root.mode === "region" && !root.hasSelection) {
                        startX = mouse.x;
                        startY = mouse.y;
                        root.selectionX = mouse.x;
                        root.selectionY = mouse.y;
                        root.selectionWidth = 0;
                        root.selectionHeight = 0;
                        dragging = true;
                    }
                }

                onReleased: mouse => {
                    dragging = false;

                    if (root.mode === "region" && !root.hasSelection) {
                        if (root.selectionWidth > 10 && root.selectionHeight > 10) {
                            root.hasSelection = true;
                        }
                    } else if (root.mode === "window" && !root.hasSelection) {
                        // Confirm window selection on click (like original)
                        if (mouse.x >= root.selectionX && mouse.x <= root.selectionX + root.selectionWidth && mouse.y >= root.selectionY && mouse.y <= root.selectionY + root.selectionHeight) {
                            root.hasSelection = true;
                        }
                    }
                }
            }

            // =================================================================
            // ESCAPE KEY
            // =================================================================

            Shortcut {
                sequence: "Escape"
                onActivated: root.cancelCapture()
            }

            // =================================================================
            // CONTROL BAR
            // =================================================================

            Rectangle {
                id: controlBar
                visible: window.isActiveMonitor
                z: 10

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 40

                height: 50
                width: barContent.implicitWidth + 16
                radius: height / 2
                color: Config.surface0Color
                border.width: 1
                border.color: Config.surface2Color

                scale: root.active ? 1.0 : 0.9
                opacity: root.active ? 1.0 : 0.0

                Behavior on scale {
                    NumberAnimation {
                        duration: Config.animDuration
                        easing.type: Easing.OutBack
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: Config.animDurationShort
                    }
                }
                Behavior on width {
                    NumberAnimation {
                        duration: Config.animDuration
                        easing.type: Easing.OutCubic
                    }
                }

                Row {
                    id: barContent
                    anchors.centerIn: parent
                    spacing: 0

                    // Mode selector
                    Item {
                        width: 132
                        height: 42

                        // Sliding highlight
                        Rectangle {
                            height: 36
                            width: 36
                            y: 3
                            radius: height / 2
                            color: Config.accentColor
                            x: 3 + (root.modes.indexOf(root.mode) * 44)

                            Behavior on x {
                                NumberAnimation {
                                    duration: Config.animDuration
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }

                        Row {
                            anchors.fill: parent
                            spacing: 0

                            Repeater {
                                model: root.modes

                                Item {
                                    required property string modelData
                                    width: 44
                                    height: 42

                                    Text {
                                        anchors.centerIn: parent
                                        text: root.modeIcons[modelData]
                                        font.family: Config.font
                                        font.pixelSize: Config.fontSizeIcon
                                        color: root.mode === modelData ? Config.textReverseColor : Config.textColor
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.setMode(modelData)
                                    }
                                }
                            }
                        }
                    }

                    // Separator
                    Rectangle {
                        width: 1
                        height: 24
                        color: Config.surface2Color
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Action buttons
                    Row {
                        spacing: 0
                        anchors.verticalCenter: parent.verticalCenter

                        // Confirm button
                        Item {
                            width: root.hasSelection ? 44 : 0
                            height: 42
                            visible: root.hasSelection
                            clip: true

                            Behavior on width {
                                NumberAnimation {
                                    duration: Config.animDurationShort
                                }
                            }

                            Rectangle {
                                anchors.centerIn: parent
                                width: 36
                                height: 36
                                radius: width / 2
                                color: confirmArea.containsMouse ? Config.accentColor : Config.surface1Color

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰄬"
                                    font.family: Config.font
                                    font.pixelSize: Config.fontSizeIcon
                                    color: confirmArea.containsMouse ? Config.textReverseColor : Config.successColor
                                }

                                MouseArea {
                                    id: confirmArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.confirmSelection()
                                }
                            }
                        }

                        // Reset button
                        Item {
                            width: (root.hasSelection && root.mode !== "screen") ? 44 : 0
                            height: 42
                            visible: root.hasSelection && root.mode !== "screen"
                            clip: true

                            Behavior on width {
                                NumberAnimation {
                                    duration: Config.animDurationShort
                                }
                            }

                            Rectangle {
                                anchors.centerIn: parent
                                width: 36
                                height: 36
                                radius: width / 2
                                color: resetArea.containsMouse ? Config.surface2Color : Config.surface1Color

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰑓"
                                    font.family: Config.font
                                    font.pixelSize: Config.fontSizeIcon
                                    color: Config.warningColor
                                }

                                MouseArea {
                                    id: resetArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.resetSelection()
                                }
                            }
                        }

                        // Separator before cancel
                        Rectangle {
                            width: root.hasSelection ? 1 : 0
                            height: 24
                            color: Config.surface2Color
                            anchors.verticalCenter: parent.verticalCenter

                            Behavior on width {
                                NumberAnimation {
                                    duration: Config.animDurationShort
                                }
                            }
                        }

                        // Cancel button
                        Item {
                            width: 44
                            height: 42

                            Text {
                                anchors.centerIn: parent
                                text: "󰅖"
                                font.family: Config.font
                                font.pixelSize: Config.fontSizeLarge
                                color: cancelArea.containsMouse ? Config.errorColor : Config.subtextColor
                            }

                            MouseArea {
                                id: cancelArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.cancelCapture()
                            }
                        }
                    }
                }
            }

            // =================================================================
            // DIMENSION INDICATOR
            // =================================================================

            Rectangle {
                visible: window.isActiveMonitor && root.selectionWidth > 60 && root.selectionHeight > 40 && root.mode !== "screen"
                z: 6

                x: root.selectionX + root.selectionWidth / 2 - width / 2
                y: root.selectionY + root.selectionHeight / 2 - height / 2

                width: dimLabel.implicitWidth + 16
                height: dimLabel.implicitHeight + 8
                radius: Config.radiusSmall
                color: Qt.alpha(Config.surface0Color, 0.9)

                Text {
                    id: dimLabel
                    anchors.centerIn: parent
                    text: Math.round(root.selectionWidth) + " × " + Math.round(root.selectionHeight)
                    font.family: Config.font
                    font.pixelSize: Config.fontSizeSmall
                    font.bold: true
                    color: Config.textColor
                }
            }

            // =================================================================
            // WINDOW/MONITOR INFO
            // =================================================================

            Rectangle {
                visible: window.isActiveMonitor && (root.mode === "window" || root.mode === "screen") && root.selectedWindowTitle !== ""
                z: 6

                x: root.selectionX + 12
                y: root.selectionY + 12

                width: infoRow.implicitWidth + 20
                height: 40
                radius: Config.radius
                color: Qt.alpha(Config.surface0Color, 0.95)
                border.width: 2
                border.color: Config.accentColor

                Row {
                    id: infoRow
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        text: root.mode === "screen" ? "󰍹" : "󰖯"
                        font.family: Config.font
                        font.pixelSize: Config.fontSizeIcon
                        color: Config.accentColor
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            text: root.selectedWindowTitle
                            font.family: Config.font
                            font.pixelSize: Config.fontSizeSmall
                            font.bold: true
                            color: Config.textColor
                            elide: Text.ElideRight
                            width: Math.min(implicitWidth, 220)
                        }

                        Text {
                            visible: root.selectedWindowClass !== "" && root.selectedWindowClass !== root.selectedWindowTitle
                            text: root.selectedWindowClass
                            font.family: Config.font
                            font.pixelSize: Config.fontSizeSmall
                            color: Config.subtextColor
                        }
                    }
                }
            }

            // =================================================================
            // USAGE HINT
            // =================================================================

            Rectangle {
                visible: window.isActiveMonitor && !root.hasSelection && root.mode === "region"
                z: 10

                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.leftMargin: 20
                anchors.bottomMargin: 40

                width: hintRow.implicitWidth + 16
                height: 32
                radius: Config.radius
                color: Qt.alpha(Config.surface0Color, 0.9)

                Row {
                    id: hintRow
                    anchors.centerIn: parent
                    spacing: 8

                    Rectangle {
                        width: escLabel.implicitWidth + 8
                        height: escLabel.implicitHeight + 4
                        radius: 4
                        color: Config.surface1Color
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            id: escLabel
                            anchors.centerIn: parent
                            text: "ESC"
                            font.family: Config.font
                            font.pixelSize: Config.fontSizeSmall
                            font.bold: true
                            color: Config.subtextColor
                        }
                    }

                    Text {
                        text: "Drag to select region"
                        font.family: Config.font
                        font.pixelSize: Config.fontSizeSmall
                        color: Config.subtextColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
        }
    }
}
