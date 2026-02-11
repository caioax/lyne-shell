pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services

Rectangle {
    id: root

    property var actions: []
    property int selectedIndex: 0

    width: contentColumn.implicitWidth + 48
    height: contentColumn.implicitHeight + 40

    anchors.centerIn: parent

    radius: Config.radiusLarge
    color: Config.backgroundTransparentColor
    border.width: 1
    border.color: Config.surface2Color

    signal actionExecuted(var action)

    function executeSelected() {
        if (actions.length > 0 && selectedIndex >= 0) {
            let selectedAction = actions[selectedIndex];
            root.actionExecuted(selectedAction);

            if (selectedAction.callback)
                selectedAction.callback();
        }
    }

    ColumnLayout {
        id: contentColumn
        anchors.centerIn: parent
        spacing: 20

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 12

            Repeater {
                model: root.actions

                delegate: Rectangle {
                    id: actionBtn

                    required property var modelData
                    required property int index

                    Layout.preferredWidth: 83
                    Layout.preferredHeight: 93

                    radius: Config.radius

                    property bool isSelected: index === root.selectedIndex

                    color: {
                        if (isSelected)
                            return Config.surface1Color;
                        if (btnMouse.containsMouse)
                            return Config.surface0Color;
                        return "transparent";
                    }

                    border.width: 2
                    border.color: isSelected ? modelData.color : "transparent"

                    scale: btnMouse.pressed ? 0.95 : 1.0

                    Behavior on color {
                        ColorAnimation {
                            duration: Config.animDuration
                        }
                    }
                    Behavior on scale {
                        NumberAnimation {
                            duration: 80
                        }
                    }
                    Behavior on border.width {
                        NumberAnimation {
                            duration: Config.animDuration
                        }
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 44
                            Layout.preferredHeight: 44
                            radius: Config.radiusLarge
                            color: actionBtn.isSelected ? Qt.alpha(actionBtn.modelData.color, 0.2) : Config.surface0Color

                            Text {
                                anchors.centerIn: parent
                                text: actionBtn.modelData.icon
                                font.family: Config.font
                                font.pixelSize: 22
                                color: actionBtn.isSelected || btnMouse.containsMouse ? actionBtn.modelData.color : Config.textColor
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: actionBtn.modelData.label
                            font.family: Config.font
                            font.pixelSize: Config.fontSizeSmall
                            color: actionBtn.isSelected ? Config.textColor : Config.subtextColor
                        }
                    }

                    Rectangle {
                        visible: actionBtn.isSelected
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 4
                        width: 18
                        height: 18
                        radius: 4
                        color: Config.surface2Color

                        Text {
                            anchors.centerIn: parent
                            text: String(actionBtn.index + 1)
                            font.family: Config.font
                            font.pixelSize: 10
                            font.bold: true
                            color: Config.subtextColor
                        }
                    }

                    MouseArea {
                        id: btnMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (actionBtn.isSelected) {
                                root.executeSelected();
                            } else {
                                root.selectedIndex = actionBtn.index;
                            }
                        }
                    }
                }
            }
        }
    }
}
