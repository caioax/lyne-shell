pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.config
import qs.services
import "./pages/"

PopupWindow {
    id: root

    // Tamanho da janela
    implicitWidth: 380
    implicitHeight: (pageStack.currentIndex ? pageStack.implicitHeight : 300) + 20

    // Animação suave quando a altura muda (troca de página)
    Behavior on implicitHeight {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    color: "transparent"

    property bool isClosing: false
    property bool isOpening: false

    function closeWindow() {
        if (!visible)
            return;
        isClosing = true;
        closeTimer.restart();
    }

    // Timer de saída
    Timer {
        id: closeTimer
        interval: Config.animDuration
        onTriggered: {
            root.visible = false;
            isClosing = false;
            pageStack.currentIndex = 0;
        }
    }

    // --- Processos ---
    Process {
        id: createLock
        command: ["touch", "/tmp/QsQuickSettingsOpen"]
    }
    Process {
        id: removeLock
        command: ["rm", "/tmp/QsQuickSettingsOpen"]
    }

    // --- Foco ---
    HyprlandFocusGrab {
        id: focusGrab
        windows: [root]
        active: false
        onCleared: root.closeWindow()
    }

    Timer {
        id: grapTimer
        interval: 10
        onTriggered: {
            focusGrab.active = true;
            background.forceActiveFocus();
        }
    }

    // Gestão de estado ao abrir/fechar
    onVisibleChanged: {
        if (visible) {
            isClosing = false;
            isOpening = true;
            createLock.running = true;
            grapTimer.restart();
        } else {
            removeLock.running = true;
            pageStack.currentIndex = 0;
            focusGrab.active = false;
            isOpening = false;
        }
    }

    // Layout
    Rectangle {
        id: background
        anchors.fill: parent
        color: Config.backgroundColor
        radius: Config.radiusLarge
        // border.width: 1
        // border.color: Config.surface2Color
        clip: true

        transformOrigin: Item.TopRight
        property bool showState: visible && !isClosing && isOpening
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

        Keys.onEscapePressed: {
            root.closeWindow();
        }

        StackLayout {
            id: pageStack
            anchors.fill: parent
            anchors.margins: 16
            currentIndex: 0

            // ==========================
            // PÁGINA 0: DASHBOARD
            // ==========================
            DashboardPage {
                onCloseWindow: root.closeWindow()
            }

            // ==========================
            // PÁGINA 1: WI-FI
            // ==========================
            WifiPage {
                onBackRequested: pageStack.currentIndex = 0
                onPasswordRequested: ssid => {
                    wifiPasswordPage.targetSsid = ssid;
                    pageStack.currentIndex = 2;
                }
            }

            // ==========================
            // PÁGINA 2: SENHA WI-FI
            // ==========================
            WifiPasswordPage {
                id: wifiPasswordPage
                onCancelled: pageStack.currentIndex = 1
                onConnectClicked: password => {
                    NetworkService.connect(targetSsid, password);
                    pageStack.currentIndex = 1;
                }
            }

            // ==========================
            // PÁGINA 3: BLUETOOTH
            // ==========================
            BluetoothPage {
                onBackRequested: pageStack.currentIndex = 0
            }
        }
    }
}
