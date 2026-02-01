pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import "../../components/"

QsPopupWindow {
    id: root

    popupWidth: 380
    popupMaxHeight: 700
    anchorSide: "left"
    moduleName: "SystemMonitor"
    contentImplicitHeight: content.implicitHeight

    readonly property bool hasGpu: SystemMonitorService.gpuType !== "unknown"

    // Color helpers
    function usageColor(usage: int): color {
        if (usage >= 90)
            return Config.errorColor;
        if (usage >= 70)
            return Config.warningColor;
        return Config.accentColor;
    }

    function tempColor(temp: int): color {
        if (temp >= 85)
            return Config.errorColor;
        if (temp >= 70)
            return Config.warningColor;
        return Config.successColor;
    }

    ColumnLayout {
        id: content
        anchors.fill: parent
        spacing: 12

        // ==================== HEADER ====================
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                radius: Config.radius
                color: Qt.alpha(Config.accentColor, 0.15)

                Text {
                    anchors.centerIn: parent
                    text: "󰍛"
                    font.family: Config.font
                    font.pixelSize: Config.fontSizeLarge
                    color: Config.accentColor
                }
            }

            Text {
                text: "System Monitor"
                font.family: Config.font
                font.bold: true
                font.pixelSize: Config.fontSizeLarge
                color: Config.textColor
                Layout.fillWidth: true
            }

            // Uptime badge
            Rectangle {
                Layout.preferredHeight: 26
                Layout.preferredWidth: uptimeContent.implicitWidth + 14
                radius: Config.radius
                color: Config.surface1Color

                RowLayout {
                    id: uptimeContent
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "󰅐"
                        font.family: Config.font
                        font.pixelSize: Config.fontSizeSmall
                        color: Config.subtextColor
                    }

                    Text {
                        text: SystemMonitorService.uptime
                        font.family: Config.font
                        font.pixelSize: Config.fontSizeSmall
                        font.bold: true
                        color: Config.subtextColor
                    }
                }
            }
        }

        // ==================== SEPARATOR ====================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Config.surface1Color
        }

        // ==================== GAUGES (CPU + GPU) ====================
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 20

            ArcGauge {
                label: "CPU"
                usage: SystemMonitorService.cpuUsage
                temp: SystemMonitorService.cpuTemp
                arcColor: root.usageColor(SystemMonitorService.cpuUsage)
                badgeColor: root.tempColor(SystemMonitorService.cpuTemp)
            }

            ArcGauge {
                visible: root.hasGpu
                label: "GPU"
                subtitle: SystemMonitorService.gpuType.toUpperCase()
                usage: SystemMonitorService.gpuUsage
                temp: SystemMonitorService.gpuTemp
                arcColor: root.usageColor(SystemMonitorService.gpuUsage)
                badgeColor: root.tempColor(SystemMonitorService.gpuTemp)
            }
        }

        // ==================== SEPARATOR ====================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Config.surface1Color
        }

        // ==================== RAM ====================
        MetricBar {
            icon: "󰘚"
            label: "RAM"
            usage: SystemMonitorService.ramUsage
            detail: SystemMonitorService.ramUsed + " / " + SystemMonitorService.ramTotal + " GiB"
            barColor: root.usageColor(SystemMonitorService.ramUsage)
        }

        // ==================== DISK ====================
        MetricBar {
            icon: "󰋊"
            label: "Disk (/)"
            usage: SystemMonitorService.diskUsage
            detail: SystemMonitorService.diskUsed + " / " + SystemMonitorService.diskTotal + " GiB"
            barColor: root.usageColor(SystemMonitorService.diskUsage)
        }

        // ==================== SEPARATOR ====================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Config.surface1Color
        }

        // ==================== NETWORK ====================
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "󰛳"
                    font.family: Config.font
                    font.pixelSize: Config.fontSizeLarge
                    color: Config.accentColor
                }

                Text {
                    text: "Network"
                    font.family: Config.font
                    font.pixelSize: Config.fontSizeNormal
                    font.bold: true
                    color: Config.textColor
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // Download
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 34
                    radius: Config.radius
                    color: Config.surface0Color

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 6

                        Text {
                            text: "󰁅"
                            font.family: Config.font
                            font.pixelSize: Config.fontSizeNormal
                            color: Config.successColor
                        }

                        Text {
                            text: SystemMonitorService.networkDown
                            font.family: Config.font
                            font.pixelSize: Config.fontSizeSmall
                            font.bold: true
                            color: Config.textColor
                            Layout.fillWidth: true
                        }
                    }
                }

                // Upload
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 34
                    radius: Config.radius
                    color: Config.surface0Color

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 6

                        Text {
                            text: "󰁝"
                            font.family: Config.font
                            font.pixelSize: Config.fontSizeNormal
                            color: Config.warningColor
                        }

                        Text {
                            text: SystemMonitorService.networkUp
                            font.family: Config.font
                            font.pixelSize: Config.fontSizeSmall
                            font.bold: true
                            color: Config.textColor
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }
    }

    // ====================================================================
    // ARC GAUGE COMPONENT
    // ====================================================================
    component ArcGauge: ColumnLayout {
        id: gauge

        required property string label
        property string subtitle: ""
        required property int usage
        required property int temp
        required property color arcColor
        required property color badgeColor

        spacing: 8
        Layout.alignment: Qt.AlignHCenter

        property real animatedUsage: 0
        Behavior on animatedUsage {
            NumberAnimation {
                duration: Config.animDuration
                easing.type: Easing.OutQuad
            }
        }
        onUsageChanged: animatedUsage = usage

        Item {
            Layout.preferredWidth: 120
            Layout.preferredHeight: 120
            Layout.alignment: Qt.AlignHCenter

            Canvas {
                id: canvas
                anchors.fill: parent
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();

                    var cx = width / 2;
                    var cy = height / 2;
                    var radius = 50;
                    var lineWidth = 8;
                    var startAngle = (135 * Math.PI) / 180;
                    var sweepAngle = (270 * Math.PI) / 180;
                    var endAngle = startAngle + sweepAngle;

                    ctx.beginPath();
                    ctx.arc(cx, cy, radius, startAngle, endAngle);
                    ctx.strokeStyle = Config.surface2Color.toString();
                    ctx.lineWidth = lineWidth;
                    ctx.lineCap = "round";
                    ctx.stroke();

                    if (gauge.animatedUsage > 0) {
                        var valueEnd = startAngle + (gauge.animatedUsage / 100) * sweepAngle;
                        ctx.beginPath();
                        ctx.arc(cx, cy, radius, startAngle, valueEnd);
                        ctx.strokeStyle = gauge.arcColor.toString();
                        ctx.lineWidth = lineWidth;
                        ctx.lineCap = "round";
                        ctx.stroke();
                    }
                }

                Connections {
                    target: gauge
                    function onAnimatedUsageChanged() {
                        canvas.requestPaint();
                    }
                    function onArcColorChanged() {
                        canvas.requestPaint();
                    }
                }

                Connections {
                    target: Config
                    function onSurface2ColorChanged() {
                        canvas.requestPaint();
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: gauge.usage + "%"
                font.family: Config.font
                font.pixelSize: 22
                font.bold: true
                color: gauge.arcColor

                Behavior on color {
                    ColorAnimation {
                        duration: Config.animDuration
                    }
                }
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: gauge.subtitle ? (gauge.label + " · " + gauge.subtitle) : gauge.label
            font.family: Config.font
            font.pixelSize: Config.fontSizeSmall
            font.bold: true
            color: Config.textColor
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: tempText.implicitWidth + 14
            Layout.preferredHeight: 24
            radius: 8
            color: Qt.alpha(gauge.badgeColor, 0.15)

            Behavior on color {
                ColorAnimation {
                    duration: Config.animDuration
                }
            }

            RowLayout {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text: "󰔏"
                    font.family: Config.font
                    font.pixelSize: 12
                    color: gauge.badgeColor

                    Behavior on color {
                        ColorAnimation {
                            duration: Config.animDuration
                        }
                    }
                }

                Text {
                    id: tempText
                    text: gauge.temp + "°C"
                    font.family: Config.font
                    font.pixelSize: Config.fontSizeSmall
                    font.bold: true
                    color: gauge.badgeColor

                    Behavior on color {
                        ColorAnimation {
                            duration: Config.animDuration
                        }
                    }
                }
            }
        }
    }

    // ====================================================================
    // METRIC BAR COMPONENT (RAM, Disk)
    // ====================================================================
    component MetricBar: ColumnLayout {
        id: metric

        required property string icon
        required property string label
        required property int usage
        required property string detail
        required property color barColor

        Layout.fillWidth: true
        spacing: 6

        property real animatedUsage: 0
        Behavior on animatedUsage {
            NumberAnimation {
                duration: Config.animDuration
                easing.type: Easing.OutQuad
            }
        }
        onUsageChanged: animatedUsage = usage

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: metric.icon
                font.family: Config.font
                font.pixelSize: Config.fontSizeLarge
                color: metric.barColor

                Behavior on color {
                    ColorAnimation {
                        duration: Config.animDuration
                    }
                }
            }

            Text {
                text: metric.label
                font.family: Config.font
                font.pixelSize: Config.fontSizeNormal
                font.bold: true
                color: Config.textColor
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                text: metric.detail
                font.family: Config.font
                font.pixelSize: Config.fontSizeSmall
                color: Config.subtextColor
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 8
            radius: 4
            color: Config.surface2Color

            Rectangle {
                width: parent.width * (metric.animatedUsage / 100)
                height: parent.height
                radius: 4
                color: metric.barColor

                Behavior on color {
                    ColorAnimation {
                        duration: Config.animDuration
                    }
                }
            }
        }

        Text {
            text: metric.usage + "% used"
            font.family: Config.font
            font.pixelSize: 11
            color: Config.subtextColor
            Layout.alignment: Qt.AlignRight
        }
    }
}
