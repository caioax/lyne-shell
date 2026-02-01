pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import qs.config
import qs.services

Rectangle {
    id: root

    visible: MprisService.hasPlayer

    Layout.fillWidth: true
    implicitHeight: 110
    radius: Config.radiusLarge
    color: Config.surface1Color

    // --- BACKGROUND ---
    Item {
        anchors.fill: parent
        layer.enabled: true

        // The Actual Image (Hidden, serves as source)
        Image {
            id: bgSource
            anchors.fill: parent
            source: MprisService.artUrl
            fillMode: Image.PreserveAspectCrop
            visible: false
        }

        // The Mask (To get the shape on the image: Rounded rectangle)
        Rectangle {
            id: bgMask
            anchors.fill: parent
            radius: Config.radiusLarge
            visible: false
        }

        OpacityMask {
            anchors.fill: parent
            source: bgSource
            maskSource: bgMask
            opacity: 0.25
        }
    }

    // --- CONTENT ---
    RowLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        // --- ALBUM COVER (Small) ---
        Item {
            Layout.preferredWidth: 80
            Layout.preferredHeight: 80

            // Gray fallback background
            Rectangle {
                anchors.fill: parent
                radius: Config.radius
                color: Config.surface2Color
            }

            // Cover image (Source)
            Image {
                id: coverSource
                anchors.fill: parent
                source: MprisService.artUrl
                fillMode: Image.PreserveAspectCrop
                visible: false
            }

            // Cover mask
            Rectangle {
                id: coverMask
                anchors.fill: parent
                radius: Config.radius
                visible: false
            }

            // Combining the two
            OpacityMask {
                anchors.fill: parent
                source: coverSource
                maskSource: coverMask
            }

            // Fallback icon (On top of everything)
            Text {
                visible: MprisService.artUrl == ""
                anchors.centerIn: parent
                text: ""
                font.family: Config.font
                font.pixelSize: Config.fontSizeIcon
                color: Config.subtextColor
            }
        }

        // --- INFO AND CONTROLS ---
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 5
            Layout.alignment: Qt.AlignVCenter

            // Track and Artist
            ColumnLayout {
                spacing: 0
                Text {
                    text: MprisService.title
                    color: Config.textColor
                    font.bold: true
                    font.pixelSize: Config.fontSizeNormal
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                Text {
                    text: MprisService.artist
                    color: Config.subtextColor
                    font.pixelSize: Config.fontSizeSmall
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    opacity: 0.8
                }
            }

            // Buttons
            RowLayout {
                spacing: 15
                Layout.alignment: Qt.AlignLeft
                Layout.topMargin: 5

                ControlButton {
                    icon: ""
                    onClicked: MprisService.previous()
                }

                // Play / Pause
                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: playBtnMouse.containsMouse ? Qt.lighter(Config.accentColor, 1.1) : Config.accentColor

                    scale: playBtnMouse.pressed ? 0.9 : 1.0
                    Behavior on scale {
                        NumberAnimation {
                            duration: Config.animDurationShort
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: Config.animDurationShort
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: MprisService.isPlaying ? "" : ""
                        font.family: Config.font
                        font.pixelSize: Config.fontSizeLarge
                        color: Config.textReverseColor
                        anchors.horizontalCenterOffset: MprisService.isPlaying ? 0 : 2
                    }

                    MouseArea {
                        id: playBtnMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: MprisService.playPause()
                    }
                }

                ControlButton {
                    icon: ""
                    onClicked: MprisService.next()
                }
            }
        }
    }

    // --- BUTTONS COMPONENT ---
    component ControlButton: Item {
        id: btn
        property string icon: ""
        signal clicked

        width: 30
        height: 30

        Text {
            anchors.centerIn: parent
            text: btn.icon
            font.family: Config.font
            font.pixelSize: Config.fontSizeIcon
            color: mouseArea.containsMouse ? Config.accentColor : Config.textColor
            Behavior on color {
                ColorAnimation {
                    duration: Config.animDurationShort
                }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: btn.clicked()
            onPressedChanged: btn.scale = pressed ? 0.9 : 1.0
        }
        Behavior on scale {
            NumberAnimation {
                duration: Config.animDurationShort
            }
        }
    }
}
