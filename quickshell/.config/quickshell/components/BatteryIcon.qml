pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.services
import qs.config

Text {
    id: root

    font.family: Config.font
    font.pixelSize: Config.fontSizeNormal
    font.bold: true

    visible: BatteryService.hasBattery

    text: BatteryService.getBatteryIcon()

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    Layout.alignment: Qt.AlignVCenter

    color: {
        if (BatteryService.isCharging)
            return Config.successColor;

        if (BatteryService.percentage < 20)
            return Config.warningColor;

        return Config.textColor;
    }
}
