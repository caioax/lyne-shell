pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.services

Singleton {
    id: root

    // Helper function para encurtar a chamada do serviço
    function conf(path, fallback) {
        return StateService.get(path, fallback);
    }

    // ========================================================================
    // PALETTE (Cores do Tokyo Night)
    // ========================================================================
    readonly property color backgroundColor: conf("palette.background", "#1a1b26")
    readonly property color surface0Color: conf("palette.surface0", "#24283b")
    readonly property color surface1Color: conf("palette.surface1", "#292e42")
    readonly property color surface2Color: conf("palette.surface2", "#414868")
    readonly property color surface3Color: conf("palette.surface3", "#565f89")

    readonly property color textColor: conf("palette.text", "#c0caf5")
    readonly property color textReverseColor: conf("palette.textReverse", "#1a1b26")
    readonly property color subtextColor: conf("palette.subtext", "#a9b1d6")
    readonly property color subtextReverseColor: conf("palette.subtextReverse", "#565f89")

    readonly property color accentColor: conf("palette.accent", "#7aa2f7")
    readonly property color successColor: conf("palette.success", "#9ece6a")
    readonly property color warningColor: conf("palette.warning", "#e0af68")
    readonly property color errorColor: conf("palette.error", "#f7768e")

    readonly property color mutedColor: conf("palette.muted", "#545c7e")
    readonly property color greyBlueColor: conf("palette.greyBlue", "#283457")
    readonly property color blueDarkColor: conf("palette.blueDark", "#16161e")

    // ========================================================================
    // GEOMETRY & LAYOUT
    // ========================================================================
    readonly property int barHeight: conf("bar.height", 32)
    readonly property bool barAutoHide: conf("bar.autoHide", true)

    readonly property int radiusSmall: conf("geometry.radiusSmall", 5)
    readonly property int radius: conf("geometry.radius", 10)
    readonly property int radiusLarge: conf("geometry.radiusLarge", 15)
    readonly property int spacing: conf("geometry.spacing", 8)
    readonly property int padding: conf("geometry.padding", 6)

    // ========================================================================
    // TYPOGRAPHY
    // ========================================================================
    readonly property string font: conf("typography.font", "Caskaydia Cove Nerd Font")

    readonly property int fontSizeSmall: conf("typography.sizeSmall", 12)
    readonly property int fontSizeNormal: conf("typography.sizeNormal", 14)
    readonly property int fontSizeLarge: conf("typography.sizeLarge", 16)
    readonly property int fontSizeIconSmall: conf("typography.iconSmall", 18)
    readonly property int fontSizeIcon: conf("typography.icon", 22)
    readonly property int fontSizeIconLarge: conf("typography.iconLarge", 28)

    // ========================================================================
    // ANIMATIONS
    // ========================================================================
    readonly property int animDurationShort: conf("animations.short", 100)
    readonly property int animDuration: conf("animations.normal", 200)
    readonly property int animDurationLong: conf("animations.long", 400)

    // ========================================================================
    // NOTIFICATIONS
    // ========================================================================
    readonly property int notifWidth: conf("notifications.width", 350)
    readonly property int notifImageSize: conf("notifications.imageSize", 40)
    readonly property int notifTimeout: conf("notifications.timeout", 5000)
    readonly property int notifSpacing: conf("notifications.spacing", 10)
}
