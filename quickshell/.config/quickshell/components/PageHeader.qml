pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.config

RowLayout {
    id: root

    property string title: ""
    property string icon: ""
    property color iconColor: Config.accentColor

    signal backClicked

    Layout.fillWidth: true
    Layout.margins: 10
    spacing: 10

    BackButton {
        onClicked: root.backClicked()
    }

    // Decorative icon
    Rectangle {
        visible: root.icon !== ""
        Layout.preferredWidth: 36
        Layout.preferredHeight: 36
        radius: Config.radius
        color: Qt.alpha(root.iconColor, 0.15)

        Text {
            anchors.centerIn: parent
            text: root.icon
            font.family: Config.font
            font.pixelSize: Config.fontSizeLarge
            color: root.iconColor
        }
    }

    Text {
        text: root.title
        color: Config.textColor
        font.bold: true
        font.pixelSize: Config.fontSizeLarge
        Layout.fillWidth: true
    }
}
