pragma ComponentBehavior: Bound
import QtQuick
import qs.services
import qs.config

Text {
    text: TimeService.format("hh:mm")

    font.family: Config.font
    font.pixelSize: Config.fontSizeNormal
    font.bold: true

    color: Config.textColor
}
