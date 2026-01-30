pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import "../../../components/"

Item {
    id: root

    signal backRequested

    Layout.fillWidth: true
    implicitHeight: main.implicitHeight

    ColumnLayout {
        id: main
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 15

        // Header
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 10
            spacing: 10

            BackButton {
                onClicked: root.backRequested()
            }

            Text {
                text: "Theme"
                color: Config.textColor
                font.bold: true
                font.pixelSize: Config.fontSizeIcon
                Layout.fillWidth: true
            }

            // Current theme badge
            Rectangle {
                Layout.preferredHeight: 28
                Layout.preferredWidth: badgeText.implicitWidth + 16
                radius: Config.radius
                color: Qt.alpha(Config.accentColor, 0.15)
                border.width: 1
                border.color: Qt.alpha(Config.accentColor, 0.3)

                Text {
                    id: badgeText
                    anchors.centerIn: parent
                    text: ThemeService.currentThemeName
                    font.family: Config.font
                    font.pixelSize: Config.fontSizeSmall
                    font.bold: true
                    color: Config.accentColor
                }
            }
        }

        // Theme grid
        GridLayout {
            Layout.fillWidth: true
            Layout.margins: 10
            columns: 2
            columnSpacing: 10
            rowSpacing: 10

            Repeater {
                model: ThemeService.availableThemes

                delegate: Rectangle {
                    id: card

                    required property string modelData
                    required property int index

                    readonly property bool isCurrent: modelData === ThemeService.currentThemeName
                    readonly property var preview: ThemeService.themePreviews[modelData] || {}
                    readonly property var previewPalette: preview.palette || {}
                    readonly property string displayName: preview.name || modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: 90
                    radius: Config.radius
                    color: cardMouse.containsMouse ? Config.surface1Color : Config.surface0Color
                    border.width: isCurrent ? 2 : 1
                    border.color: isCurrent ? Config.accentColor : (cardMouse.containsMouse ? Config.surface2Color : Config.surface1Color)

                    Behavior on color {
                        ColorAnimation { duration: Config.animDurationShort }
                    }
                    Behavior on border.color {
                        ColorAnimation { duration: Config.animDurationShort }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8

                        // Theme name
                        Text {
                            text: card.displayName
                            font.family: Config.font
                            font.pixelSize: Config.fontSizeNormal
                            font.bold: card.isCurrent
                            color: card.isCurrent ? Config.accentColor : Config.textColor
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        // Color preview dots
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Repeater {
                                model: [
                                    card.previewPalette.background || "#1a1b26",
                                    card.previewPalette.accent || "#7aa2f7",
                                    card.previewPalette.success || "#9ece6a",
                                    card.previewPalette.warning || "#e0af68",
                                    card.previewPalette.error || "#f7768e"
                                ]

                                delegate: Rectangle {
                                    required property string modelData
                                    width: 18
                                    height: 18
                                    radius: 9
                                    color: modelData
                                    border.width: 1
                                    border.color: Qt.alpha(Config.textColor, 0.15)
                                }
                            }

                            Item { Layout.fillWidth: true }
                        }

                        // Active indicator
                        Text {
                            text: card.isCurrent ? "Active" : ""
                            font.family: Config.font
                            font.pixelSize: 10
                            color: Config.accentColor
                            visible: card.isCurrent
                        }
                    }

                    MouseArea {
                        id: cardMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (!card.isCurrent) {
                                ThemeService.applyTheme(card.modelData);
                            }
                        }
                    }
                }
            }
        }
    }
}
