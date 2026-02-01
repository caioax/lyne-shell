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
    implicitHeight: 350

    ColumnLayout {
        id: main
        anchors.fill: parent
        spacing: 12

        // Header
        PageHeader {
            icon: BluetoothService.systemIcon
            title: "Bluetooth"
            onBackClicked: root.backRequested()

            // Scan Button
            RefreshButton {
                visible: BluetoothService.isPowered
                loading: BluetoothService.isDiscovering
                onClicked: BluetoothService.toggleScan()
            }

            // Visibility Button
            ActionButton {
                visible: BluetoothService.isPowered
                icon: BluetoothService.isDiscoverable ? "󰈈" : "󰈉"
                baseColor: BluetoothService.isDiscoverable ? Config.accentColor : Config.surface1Color
                hoverColor: BluetoothService.isDiscoverable ? Config.accentColor : Config.surface2Color
                textColor: BluetoothService.isDiscoverable ? Config.textReverseColor : Config.textColor
                onClicked: BluetoothService.toggleDiscoverable()
            }

            // On/Off Switch
            QsSwitch {
                checked: BluetoothService.isPowered
                onToggled: {
                    if (!BluetoothService.isPowered)
                        startScanTimer.restart();
                    BluetoothService.togglePower();
                }
            }

            // Timer to start scanning after turning on bluetooth
            Timer {
                id: startScanTimer
                interval: 300
                repeat: false
                onTriggered: BluetoothService.toggleScan()
            }
        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Config.surface1Color
        }

        // Device List
        ListView {
            id: deviceList
            clip: true
            spacing: 8

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 10

            model: BluetoothService.isPowered ? BluetoothService.devicesList : []

            delegate: DeviceCard {
                required property var modelData

                title: modelData.alias || modelData.name || "Unknown"
                subtitle: modelData.address || ""
                icon: BluetoothService.getDeviceIcon(modelData)

                active: modelData.connected
                connecting: BluetoothService.getIsConnecting(modelData)

                statusText: {
                    if (connecting)
                        return "Connecting...";
                    if (active)
                        return "Connected";
                    if (modelData.paired)
                        return "Paired";
                    return "";
                }

                showMenu: modelData.paired || modelData.trusted || modelData.connected

                menuModel: {
                    var list = [];
                    if (modelData.connected) {
                        list.push({
                            text: "Disconnect",
                            action: "disconnect",
                            icon: "",
                            textColor: Config.warningColor,
                            iconColor: Config.warningColor
                        });
                    } else {
                        list.push({
                            text: "Connect",
                            action: "connect",
                            icon: "",
                            textColor: Config.successColor,
                            iconColor: Config.successColor
                        });
                    }
                    list.push({
                        text: "Forget",
                        action: "forget",
                        icon: "",
                        textColor: Config.errorColor,
                        iconColor: Config.errorColor
                    });
                    return list;
                }

                onMenuAction: actionId => {
                    if (actionId === "forget") {
                        BluetoothService.forgetDevice(modelData);
                    } else if (actionId === "disconnect") {
                        BluetoothService.toggleConnection(modelData);
                    } else if (actionId === "connect") {
                        BluetoothService.toggleConnection(modelData);
                    }
                }

                onClicked: BluetoothService.toggleConnection(modelData)
            }

            // Empty state
            Column {
                anchors.centerIn: parent
                spacing: 12
                visible: !BluetoothService.isPowered || (deviceList.count === 0)

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 64
                    height: 64
                    radius: 32
                    color: Config.surface1Color

                    Text {
                        anchors.centerIn: parent
                        text: {
                            if (!BluetoothService.isPowered)
                                return "󰂲";
                            if (BluetoothService.isDiscovering)
                                return "󰂱";
                            return "󰂳";
                        }
                        font.family: Config.font
                        font.pixelSize: Config.fontSizeIconLarge
                        color: Config.subtextColor
                        opacity: 0.5
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: {
                        if (!BluetoothService.isPowered)
                            return "Bluetooth Off";
                        if (BluetoothService.isDiscovering)
                            return "Searching...";
                        return "No devices found";
                    }
                    font.family: Config.font
                    font.pixelSize: Config.fontSizeNormal
                    color: Config.subtextColor
                    opacity: 0.7
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: {
                        if (!BluetoothService.isPowered)
                            return "Turn on to connect";
                        if (BluetoothService.isDiscovering)
                            return "Looking for devices";
                        return "Make sure devices are discoverable";
                    }
                    font.family: Config.font
                    font.pixelSize: Config.fontSizeSmall
                    color: Config.subtextColor
                    opacity: 0.5
                }
            }
        }
    }
}
