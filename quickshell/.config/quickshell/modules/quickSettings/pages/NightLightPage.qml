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
        spacing: 12

        // Header
        PageHeader {
            icon: BrightnessService.nightLightEnabled ? "󰌵" : "󰌶"
            iconColor: BrightnessService.nightLightEnabled ? Config.warningColor : Config.subtextColor
            title: "Night Light"
            onBackClicked: root.backRequested()

            // On/Off Switch
            QsSwitch {
                checked: BrightnessService.nightLightEnabled
                onToggled: BrightnessService.toggleNightLight()
            }
        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Config.surface1Color
        }

        // Content
        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: 10
            spacing: 16

            // Large icon
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64
                radius: 32
                color: BrightnessService.nightLightEnabled ? Qt.alpha(Config.warningColor, 0.2) : Config.surface1Color

                Behavior on color {
                    ColorAnimation {
                        duration: Config.animDuration
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: BrightnessService.nightLightEnabled ? "󰌵" : "󰌶"
                    font.family: Config.font
                    font.pixelSize: Config.fontSizeIconLarge
                    color: BrightnessService.nightLightEnabled ? Config.warningColor : Config.subtextColor
                }
            }

            // Status
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 4

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: BrightnessService.nightLightEnabled ? "Enabled" : "Disabled"
                    font.family: Config.font
                    font.pixelSize: Config.fontSizeLarge
                    font.bold: true
                    color: Config.textColor
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: BrightnessService.nightLightEnabled ? "Temperature: " + BrightnessService.nightLightTemperature + "K" : "Reduces blue light from the screen"
                    font.family: Config.font
                    font.pixelSize: Config.fontSizeSmall
                    color: Config.subtextColor
                }
            }

            // Intensity Slider
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Intensity"
                        font.family: Config.font
                        font.pixelSize: Config.fontSizeNormal
                        font.bold: true
                        color: Config.textColor
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: Math.round((1 - BrightnessService.nightLightIntensity) * 100) + "%"
                        font.family: Config.font
                        font.pixelSize: Config.fontSizeSmall
                        color: Config.subtextColor
                    }
                }

                // Custom intensity slider
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40

                    RowLayout {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right

                        Text {
                            text: "Warmer"
                            font.family: Config.font
                            font.pixelSize: Config.fontSizeSmall
                            color: Config.warningColor
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "Cooler"
                            font.family: Config.font
                            font.pixelSize: Config.fontSizeSmall
                            color: Config.subtextColor
                        }
                    }

                    Rectangle {
                        id: sliderTrack
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 8
                        radius: 4

                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop {
                                position: 0.0
                                color: "#ff9500"
                            }
                            GradientStop {
                                position: 0.5
                                color: "#ffcc00"
                            }
                            GradientStop {
                                position: 1.0
                                color: "#ffffff"
                            }
                        }

                        Rectangle {
                            id: sliderThumb
                            width: 20
                            height: 20
                            radius: 10
                            y: (parent.height - height) / 2
                            x: (1 - BrightnessService.nightLightIntensity) * (parent.width - width)

                            color: Config.textColor
                            border.width: 2
                            border.color: Config.accentColor

                            Behavior on x {
                                NumberAnimation {
                                    duration: sliderMouse.pressed ? 0 : Config.animDurationShort
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: -2
                                radius: parent.radius + 2
                                color: "transparent"
                                border.width: 2
                                border.color: Qt.alpha(Config.backgroundColor, 0.5)
                                z: -1
                            }
                        }

                        MouseArea {
                            id: sliderMouse
                            anchors.fill: parent
                            anchors.margins: -10

                            onPressed: mouse => updateFromMouse(mouse.x)
                            onPositionChanged: mouse => {
                                if (pressed)
                                    updateFromMouse(mouse.x);
                            }

                            function updateFromMouse(mouseX) {
                                let percent = (mouseX - 10) / (sliderTrack.width - 20);
                                percent = Math.max(0, Math.min(1, percent));
                                BrightnessService.setNightLightIntensity(1 - percent);
                            }
                        }
                    }
                }
            }

            // Temperature presets
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10
                Layout.topMargin: 6

                Text {
                    text: "Presets"
                    font.family: Config.font
                    font.pixelSize: Config.fontSizeNormal
                    font.bold: true
                    color: Config.textColor
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Repeater {
                        model: [
                            {
                                label: "Cool",
                                temp: 5500,
                                color: "#fff5e6"
                            },
                            {
                                label: "Neutral",
                                temp: 4500,
                                color: "#ffcc00"
                            },
                            {
                                label: "Warm",
                                temp: 3500,
                                color: "#ff9500"
                            },
                            {
                                label: "Candle",
                                temp: 2500,
                                color: "#ff6b00"
                            }
                        ]

                        delegate: Rectangle {
                            id: presetBtn

                            required property var modelData
                            required property int index

                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            radius: Config.radius

                            color: {
                                if (presetMouse.pressed)
                                    return Qt.darker(modelData.color, 1.2);
                                if (presetMouse.containsMouse)
                                    return Qt.alpha(modelData.color, 0.3);
                                if (BrightnessService.nightLightTemperature === modelData.temp)
                                    return Qt.alpha(modelData.color, 0.2);
                                return Config.surface1Color;
                            }

                            border.width: BrightnessService.nightLightTemperature === modelData.temp ? 1 : 0
                            border.color: modelData.color

                            Text {
                                anchors.centerIn: parent
                                text: modelData.label
                                font.family: Config.font
                                font.pixelSize: Config.fontSizeSmall
                                font.bold: BrightnessService.nightLightTemperature === modelData.temp
                                color: presetMouse.containsMouse || BrightnessService.nightLightTemperature === modelData.temp ? modelData.color : Config.textColor
                            }

                            MouseArea {
                                id: presetMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    BrightnessService.setNightLightTemperature(modelData.temp);
                                    if (!BrightnessService.nightLightEnabled) {
                                        BrightnessService.enableNightLight();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
