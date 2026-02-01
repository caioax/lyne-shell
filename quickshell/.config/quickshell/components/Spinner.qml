pragma ComponentBehavior: Bound
import QtQuick
import qs.config

Text {
    id: root

    property bool running: true
    property int size: Config.fontSizeIcon

    color: Config.textColor

    text: "󰑐"
    font.family: Config.font
    font.pixelSize: size

    visible: running

    RotationAnimator on rotation {
        from: 0
        to: 360
        duration: 800
        loops: Animation.Infinite
        running: root.running
    }
}
