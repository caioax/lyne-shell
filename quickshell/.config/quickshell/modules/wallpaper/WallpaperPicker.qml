pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../../components/"
import qs.services
import qs.config

PanelWindow {
    id: root

    visible: WallpaperService.pickerVisible

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "qs_wallpaper"

    color: "transparent"

    // Click on background closes or clears selection
    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (WallpaperService.selectedCount > 0) {
                WallpaperService.clearSelection();
            } else {
                WallpaperService.hide();
            }
        }
    }

    // Main content
    Rectangle {
        id: content
        anchors.centerIn: parent
        width: Math.min(900, root.width - 100)
        height: Math.min(650, root.height - 100)
        radius: Config.radiusLarge
        color: Config.backgroundTransparentColor
        border.color: Qt.alpha(Config.accentColor, 0.2)
        border.width: 1

        // Entry animation
        scale: WallpaperService.pickerVisible ? 1 : 0.9
        opacity: WallpaperService.pickerVisible ? 1 : 0

        Behavior on scale {
            NumberAnimation {
                duration: Config.animDuration
                easing.type: Easing.OutBack
                easing.overshoot: 1.1
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Config.animDuration
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Config.spacing + 8
            spacing: Config.spacing

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: Config.spacing

                Text {
                    text: "󰸉"
                    font.family: Config.font
                    font.pixelSize: Config.fontSizeIcon
                    color: Config.accentColor
                }

                Text {
                    text: "Wallpapers"
                    font.family: Config.font
                    font.pixelSize: Config.fontSizeLarge
                    font.weight: Font.DemiBold
                    color: Config.textColor
                }

                Item {
                    Layout.fillWidth: true
                }

                // Counter
                Rectangle {
                    Layout.preferredWidth: countText.implicitWidth + 16
                    Layout.preferredHeight: 26
                    radius: height / 2
                    color: Config.surface1Color

                    Text {
                        id: countText
                        anchors.centerIn: parent
                        text: WallpaperService.wallpapers.length + " images"
                        font.family: Config.font
                        font.pixelSize: Config.fontSizeSmall
                        color: Config.subtextColor
                    }
                }

                // Lock wallpaper button
                ToggleButton {
                    active: WallpaperService.dynamicWallpaper
                    iconOn: "󰥶"
                    iconOff: "󱪱"
                    tooltipText: active ? "Dynamic Wallpaper On" : "Dynamic Wallpaper Off"

                    onClicked: WallpaperService.toggleDynamicWallpaper()
                }

                // Add button
                Rectangle {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    radius: Config.radius
                    color: addMouse.containsMouse ? Config.surface2Color : Config.surface1Color

                    Behavior on color {
                        ColorAnimation {
                            duration: Config.animDurationShort
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰐕"
                        font.family: Config.font
                        font.pixelSize: Config.fontSizeIcon
                        color: Config.successColor
                    }

                    MouseArea {
                        id: addMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: WallpaperService.addWallpapers()
                    }

                    ToolTip {
                        visible: addMouse.containsMouse
                        text: "Add wallpapers"
                        delay: 500
                    }
                }

                // Random button
                Rectangle {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    radius: Config.radius
                    color: randomMouse.containsMouse ? Config.surface2Color : Config.surface1Color

                    Behavior on color {
                        ColorAnimation {
                            duration: Config.animDurationShort
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰒝"
                        font.family: Config.font
                        font.pixelSize: Config.fontSizeIcon
                        color: Config.accentColor
                    }

                    MouseArea {
                        id: randomMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: WallpaperService.setRandomWallpaper()
                    }

                    ToolTip {
                        visible: randomMouse.containsMouse
                        text: "Random wallpaper"
                        delay: 500
                    }
                }

                // Close button
                Rectangle {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    radius: Config.radius
                    color: closeMouse.containsMouse ? Config.errorColor : Config.surface1Color

                    Behavior on color {
                        ColorAnimation {
                            duration: Config.animDurationShort
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰅖"
                        font.family: Config.font
                        font.pixelSize: Config.fontSizeNormal
                        color: closeMouse.containsMouse ? Config.textColor : Config.subtextColor
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: WallpaperService.hide()
                    }
                }
            }

            // Separator
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Config.surface1Color
            }

            // Wallpaper grid
            GridView {
                id: wallpaperGrid
                Layout.fillWidth: true
                Layout.fillHeight: true

                clip: true
                cellWidth: 200
                cellHeight: 130

                model: WallpaperService.wallpapers

                delegate: Item {
                    id: wallpaperItem
                    required property int index
                    required property string modelData

                    width: wallpaperGrid.cellWidth
                    height: wallpaperGrid.cellHeight

                    property bool isHovered: itemMouse.containsMouse
                    property bool isCurrent: modelData === WallpaperService.currentWallpaper
                    property bool isSelected: WallpaperService.isSelected(modelData)

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 6
                        radius: Config.radius
                        color: Config.surface0Color
                        border.width: wallpaperItem.isSelected ? 2 : (wallpaperItem.isCurrent ? 2 : (wallpaperItem.isHovered ? 1 : 0))
                        border.color: wallpaperItem.isSelected ? Config.successColor : (wallpaperItem.isCurrent ? Config.accentColor : Config.surface2Color)

                        Behavior on border.width {
                            NumberAnimation {
                                duration: Config.animDurationShort
                            }
                        }

                        Behavior on border.color {
                            ColorAnimation {
                                duration: Config.animDurationShort
                            }
                        }

                        // Rounded clip thumbnail
                        Item {
                            anchors.fill: parent
                            anchors.margins: 4

                            Rectangle {
                                anchors.fill: parent
                                radius: Config.radiusSmall
                                clip: true

                                Image {
                                    id: thumbnail
                                    anchors.fill: parent
                                    source: "file://" + wallpaperItem.modelData
                                    sourceSize: Qt.size(256, 144)
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: true
                                }
                            }
                        }

                        // Loading overlay
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 4
                            radius: Config.radiusSmall
                            color: Config.surface1Color
                            visible: thumbnail.status === Image.Loading

                            Text {
                                anchors.centerIn: parent
                                text: "󰑓"
                                font.family: Config.font
                                font.pixelSize: Config.fontSizeIcon
                                color: Config.mutedColor

                                RotationAnimator on rotation {
                                    from: 0
                                    to: 360
                                    duration: 1000
                                    loops: Animation.Infinite
                                    running: thumbnail.status === Image.Loading
                                }
                            }
                        }

                        // Selection overlay
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 4
                            radius: Config.radiusSmall
                            color: Qt.alpha(Config.successColor, 0.2)
                            visible: wallpaperItem.isSelected
                        }

                        // Current wallpaper badge
                        Rectangle {
                            visible: wallpaperItem.isCurrent
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.margins: 8
                            width: 24
                            height: 24
                            radius: height / 2
                            color: Config.accentColor

                            Text {
                                anchors.centerIn: parent
                                text: "󰄬"
                                font.family: Config.font
                                font.pixelSize: 12
                                color: Config.textReverseColor
                            }
                        }

                        // Selected badge
                        Rectangle {
                            visible: wallpaperItem.isSelected
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 8
                            width: 24
                            height: 24
                            radius: height / 2
                            color: Config.successColor

                            Text {
                                anchors.centerIn: parent
                                text: "󰄬"
                                font.family: Config.font
                                font.pixelSize: 12
                                color: Config.textReverseColor
                            }
                        }

                        // Scale effect on hover
                        scale: wallpaperItem.isHovered ? 1.02 : 1

                        Behavior on scale {
                            NumberAnimation {
                                duration: Config.animDurationShort
                                easing.type: Easing.OutCubic
                            }
                        }

                        MouseArea {
                            id: itemMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton

                            onClicked: mouse => {
                                if (mouse.modifiers & Qt.ControlModifier) {
                                    // Ctrl+Click: add/remove from selection
                                    WallpaperService.toggleSelection(wallpaperItem.modelData);
                                } else {
                                    // Normal click: select only this one
                                    WallpaperService.selectOnly(wallpaperItem.modelData);
                                }
                            }

                            onDoubleClicked: {
                                // Double click: apply wallpaper
                                WallpaperService.setWallpaper(wallpaperItem.modelData);
                            }
                        }
                    }
                }

                // Empty state
                Column {
                    anchors.centerIn: parent
                    spacing: Config.spacing
                    visible: wallpaperGrid.count === 0

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰸉"
                        font.family: Config.font
                        font.pixelSize: 48
                        color: Config.mutedColor
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "No wallpapers found"
                        font.family: Config.font
                        font.pixelSize: Config.fontSizeNormal
                        color: Config.subtextColor
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Add images to ~/.local/wallpapers"
                        font.family: Config.font
                        font.pixelSize: Config.fontSizeSmall
                        color: Config.mutedColor
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded

                    contentItem: Rectangle {
                        implicitWidth: 4
                        radius: 2
                        color: Config.surface2Color
                        opacity: parent.active ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Config.animDurationShort
                            }
                        }
                    }
                }
            }

            // Action bar (appears when there's a selection)
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: WallpaperService.selectedCount > 0 ? 50 : 0
                radius: Config.radius
                color: Config.surface0Color
                visible: Layout.preferredHeight > 0
                clip: true

                Behavior on Layout.preferredHeight {
                    NumberAnimation {
                        duration: Config.animDuration
                        easing.type: Easing.OutCubic
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Config.spacing + 4
                    anchors.rightMargin: Config.spacing + 4
                    spacing: Config.spacing

                    // Selection info
                    Text {
                        text: WallpaperService.selectedCount + " selected"
                        font.family: Config.font
                        font.pixelSize: Config.fontSizeNormal
                        color: Config.subtextColor
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // Delete confirmation (appears when needed)
                    Row {
                        visible: WallpaperService.confirmDelete
                        spacing: Config.spacing

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Delete " + WallpaperService.selectedCount + " wallpapers?"
                            font.family: Config.font
                            font.pixelSize: Config.fontSizeNormal
                            color: Config.warningColor
                        }

                        Rectangle {
                            width: 80
                            height: 32
                            radius: Config.radiusSmall
                            color: confirmYesMouse.containsMouse ? Config.errorColor : Config.surface1Color

                            Text {
                                anchors.centerIn: parent
                                text: "Yes"
                                font.family: Config.font
                                font.pixelSize: Config.fontSizeNormal
                                color: confirmYesMouse.containsMouse ? Config.textColor : Config.errorColor
                            }

                            MouseArea {
                                id: confirmYesMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: WallpaperService.deleteSelected()
                            }
                        }

                        Rectangle {
                            width: 80
                            height: 32
                            radius: Config.radiusSmall
                            color: confirmNoMouse.containsMouse ? Config.surface2Color : Config.surface1Color

                            Text {
                                anchors.centerIn: parent
                                text: "No"
                                font.family: Config.font
                                font.pixelSize: Config.fontSizeNormal
                                color: Config.subtextColor
                            }

                            MouseArea {
                                id: confirmNoMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: WallpaperService.cancelDelete()
                            }
                        }
                    }

                    // Action buttons (hidden during confirmation)
                    Row {
                        visible: !WallpaperService.confirmDelete
                        spacing: Config.spacing

                        // Apply button (only when 1 selected)
                        Rectangle {
                            visible: WallpaperService.selectedCount === 1
                            width: 100
                            height: 32
                            radius: Config.radiusSmall
                            color: applyMouse.containsMouse ? Config.accentColor : Config.surface1Color

                            Behavior on color {
                                ColorAnimation {
                                    duration: Config.animDurationShort
                                }
                            }

                            Row {
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    text: "󰄬"
                                    font.family: Config.font
                                    font.pixelSize: Config.fontSizeNormal
                                    color: applyMouse.containsMouse ? Config.textReverseColor : Config.accentColor
                                }

                                Text {
                                    text: "Apply"
                                    font.family: Config.font
                                    font.pixelSize: Config.fontSizeNormal
                                    color: applyMouse.containsMouse ? Config.textReverseColor : Config.textColor
                                }
                            }

                            MouseArea {
                                id: applyMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: WallpaperService.applySelected()
                            }
                        }

                        // Delete button
                        Rectangle {
                            width: 100
                            height: 32
                            radius: Config.radiusSmall
                            color: deleteMouse.containsMouse ? Config.errorColor : Config.surface1Color

                            Behavior on color {
                                ColorAnimation {
                                    duration: Config.animDurationShort
                                }
                            }

                            Row {
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    text: "󰅖"
                                    font.family: Config.font
                                    font.pixelSize: Config.fontSizeNormal
                                    color: deleteMouse.containsMouse ? Config.textColor : Config.errorColor
                                }

                                Text {
                                    text: "Delete"
                                    font.family: Config.font
                                    font.pixelSize: Config.fontSizeNormal
                                    color: deleteMouse.containsMouse ? Config.textColor : Config.textColor
                                }
                            }

                            MouseArea {
                                id: deleteMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: WallpaperService.requestDelete()
                            }
                        }

                        // Clear selection button
                        Rectangle {
                            width: 32
                            height: 32
                            radius: Config.radiusSmall
                            color: clearMouse.containsMouse ? Config.surface2Color : Config.surface1Color

                            Text {
                                anchors.centerIn: parent
                                text: "󰜺"
                                font.family: Config.font
                                font.pixelSize: Config.fontSizeNormal
                                color: Config.subtextColor
                            }

                            MouseArea {
                                id: clearMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: WallpaperService.clearSelection()
                            }

                            ToolTip {
                                visible: clearMouse.containsMouse
                                text: "Clear selection"
                                delay: 500
                            }
                        }
                    }
                }
            }
        }

        // Keyboard shortcuts
        Keys.onEscapePressed: {
            if (WallpaperService.confirmDelete) {
                WallpaperService.cancelDelete();
            } else if (WallpaperService.selectedCount > 0) {
                WallpaperService.clearSelection();
            } else {
                WallpaperService.hide();
            }
        }
        Keys.onDeletePressed: WallpaperService.requestDelete()
        Keys.onReturnPressed: WallpaperService.applySelected()
        Keys.onPressed: event => {
            if (event.key === Qt.Key_R) {
                WallpaperService.setRandomWallpaper();
                event.accepted = true;
            } else if (event.key === Qt.Key_A && (event.modifiers & Qt.ControlModifier)) {
                // Ctrl+A: select all
                WallpaperService.selectedWallpapers = [...WallpaperService.wallpapers];
                event.accepted = true;
            }
        }

        Component.onCompleted: forceActiveFocus()
    }

    // Focus grab
    HyprlandFocusGrab {
        windows: [root]
        active: root.visible
        onCleared: WallpaperService.hide()
    }
}
