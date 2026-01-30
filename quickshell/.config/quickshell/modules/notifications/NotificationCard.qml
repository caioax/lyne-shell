pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import qs.config
import qs.services

Item {
    id: root

    // ========================================================================
    // PROPERTIES
    // ========================================================================

    // The notification wrapper (from NotificationService)
    required property var wrapper

    // Popup mode (true) or history mode (false)
    property bool popupMode: false

    // Internal state for exit animation
    property bool isExiting: false
    property bool isCollapsed: false

    // ========================================================================
    // PROPERTIES DERIVED FROM WRAPPER
    // ========================================================================

    readonly property int notifId: wrapper ? wrapper.notifId : -1
    readonly property string summary: wrapper ? wrapper.summary : ""
    readonly property string body: wrapper ? wrapper.body : ""
    readonly property string appName: wrapper ? wrapper.appName : "System"
    readonly property string appIcon: wrapper ? wrapper.appIcon : ""
    readonly property string image: wrapper ? wrapper.image : ""
    readonly property int urgency: wrapper ? wrapper.urgency : 0
    readonly property bool isUrgent: wrapper ? wrapper.isUrgent : false
    readonly property var actions: wrapper ? wrapper.actions : []
    readonly property bool hasActions: wrapper ? wrapper.hasActions : false
    readonly property bool showPopup: wrapper ? wrapper.popup : false
    readonly property string timeStr: wrapper ? wrapper.timeStr : ""

    // Timer progress (0.0 to 1.0) - comes directly from the wrapper
    readonly property real progress: wrapper ? wrapper.progress : 0.0

    // Check if paused (hover)
    readonly property bool isPaused: wrapper && wrapper.isPaused

    // Filter actions that should not be shown as buttons
    readonly property var visibleActions: {
        if (!actions || actions.length === 0)
            return [];

        let filtered = [];
        for (let i = 0; i < actions.length; i++) {
            const action = actions[i];
            if (!action)
                continue;

            const identifier = (action.identifier || "").toLowerCase();
            const text = action.text || "";

            if (identifier === "default" && text === "")
                continue;
            if (identifier === "activate" && text === "")
                continue;
            if (text.toLowerCase() === identifier && (identifier === "default" || identifier === "activate"))
                continue;

            if (text !== "") {
                filtered.push(action);
            }
        }
        return filtered;
    }

    readonly property bool hasVisibleActions: visibleActions && visibleActions.length > 0

    function getActionLabel(action) {
        if (!action)
            return "";

        const text = action.text || "";
        if (text !== "")
            return text;

        const id = action.identifier || "";
        if (id === "")
            return "Open";

        return id.charAt(0).toUpperCase() + id.slice(1);
    }

    // ========================================================================
    // DIMENSIONS
    // ========================================================================

    readonly property int visualHeight: contentColumn.implicitHeight + 24
    implicitWidth: Config.notifWidth

    implicitHeight: {
        if (isCollapsed)
            return 0;
        if (popupMode && !showPopup)
            return 0;
        if (!wrapper)
            return 0;
        return visualHeight + Config.notifSpacing;
    }

    visible: !isCollapsed && (popupMode ? showPopup : true) && opacity > 0 && wrapper !== null

    // ========================================================================
    // VISUAL
    // ========================================================================

    // Container with clipping
    Item {
        id: clippedContainer
        width: parent.width
        height: root.visualHeight
        visible: root.wrapper !== null

        // Mask for rounded border
        Rectangle {
            id: maskRect
            anchors.fill: parent
            radius: Config.radiusLarge
            visible: false
        }

        layer.enabled: true
        layer.samples: 4
        layer.effect: OpacityMask {
            maskSource: maskRect
        }

        // Background
        Rectangle {
            anchors.fill: parent
            color: Config.backgroundTransparentColor
        }

        // Progress bar (only in popup mode)
        Rectangle {
            visible: root.popupMode
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            height: 3
            width: parent.width * (1.0 - root.progress)
            color: root.isUrgent ? Config.errorColor : Config.accentColor
        }

        // Content
        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            // Main row: Icon + Text
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // Icon / Image
                Rectangle {
                    Layout.preferredWidth: 42
                    Layout.preferredHeight: 42
                    Layout.alignment: Qt.AlignTop
                    radius: width / 2
                    color: root.isUrgent ? Qt.alpha(Config.errorColor, 0.2) : Config.surface1Color

                    Image {
                        id: notifImage
                        anchors.fill: parent
                        anchors.margins: root.image !== "" ? 0 : 8
                        fillMode: Image.PreserveAspectCrop

                        mipmap: true
                        antialiasing: true
                        smooth: true
                        sourceSize: Qt.size(128, 128)

                        source: NotificationService.getIconSource(root.appIcon, root.image)

                        onStatusChanged: {
                            if (status === Image.Error && source !== "") {
                                source = "image://icon/dialog-information";
                            }
                        }

                        // Circular mask for the image
                        layer.enabled: root.image !== ""
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: notifImage.width
                                height: notifImage.height
                                radius: width / 2
                                visible: false
                            }
                        }
                    }

                    // Fallback icon if there is no image
                    Text {
                        visible: notifImage.status === Image.Error || (notifImage.source + "") === ""
                        anchors.centerIn: parent
                        text: "󰍡"
                        font.family: Config.font
                        font.pixelSize: 20
                        color: Config.subtextColor
                    }
                }

                // Texts
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    // Header: Title + App Name + Time
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            text: root.summary
                            color: Config.textColor
                            font.family: Config.font
                            font.pixelSize: Config.fontSizeNormal
                            font.bold: true
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            textFormat: Text.StyledText
                        }

                        Text {
                            text: root.appName
                            color: root.isUrgent ? Config.errorColor : Config.accentColor
                            font.family: Config.font
                            font.pixelSize: 10
                            font.bold: true
                            opacity: 0.8
                        }
                    }

                    // Time (only in history)
                    Text {
                        visible: !root.popupMode && root.timeStr !== ""
                        text: root.timeStr
                        color: Config.subtextColor
                        font.family: Config.font
                        font.pixelSize: 10
                        opacity: 0.7
                    }

                    // Notification body
                    Text {
                        text: root.body
                        color: Config.subtextColor
                        font.family: Config.font
                        font.pixelSize: Config.fontSizeSmall
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        visible: text !== ""
                        textFormat: Text.StyledText
                        onLinkActivated: link => Qt.openUrlExternally(link)
                    }
                }
            }
        }
    }

    // Outer border (hover state)
    Rectangle {
        width: parent.width
        height: root.visualHeight
        radius: Config.radiusLarge
        color: "transparent"
        border.width: 1
        border.color: {
            if (root.isUrgent)
                return Config.errorColor;
            if (mouseArea.containsMouse)
                return Config.surface2Color;
            return "transparent";
        }
    }

    // Main MouseArea
    MouseArea {
        id: mouseArea
        width: parent.width
        height: root.visualHeight
        hoverEnabled: true
        acceptedButtons: Qt.RightButton | Qt.LeftButton

        onEntered: NotificationService.setHovered(root.notifId)
        onExited: NotificationService.clearHovered()

        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                root.startExitAnimation(true);
            } else {
                if (root.popupMode) {
                    root.startExitAnimation(false);
                }
            }
        }
    }

    // ========================================================================
    // EXIT ANIMATION
    // ========================================================================

    function startExitAnimation(removeCompletely) {
        if (isExiting)
            return;
        isExiting = true;
        exitAnim.removeCompletely = removeCompletely;
        exitAnim.start();
    }

    SequentialAnimation {
        id: exitAnim
        property bool removeCompletely: false

        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "opacity"
                to: 0
                duration: Config.animDuration
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: root
                property: "x"
                to: 50
                duration: Config.animDuration
                easing.type: Easing.InQuad
            }
        }

        ScriptAction {
            script: root.isCollapsed = true
        }

        PauseAnimation {
            duration: Config.animDuration
        }

        ScriptAction {
            script: {
                const id = root.notifId;

                if (exitAnim.removeCompletely) {
                    NotificationService.removeNotification(id);
                } else {
                    NotificationService.expireNotification(id);
                }

                root.opacity = 1;
                root.x = 0;
                root.isCollapsed = false;
                root.isExiting = false;
            }
        }
    }
}
