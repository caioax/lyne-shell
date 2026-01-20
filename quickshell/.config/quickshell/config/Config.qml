pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick

Singleton {
    id: root

    // ========================================================================
    // TOKYO NIGHT COLOR PALETTE
    // ========================================================================

    // General Background (Bars, Menus)
    readonly property color backgroundColor: "#1a1b26"    // Background
    readonly property color surface0Color: "#24283b"      // Slightly lighter background
    readonly property color surface1Color: "#292e42"      // Inactive tab background
    readonly property color surface2Color: "#414868"      // Bright black (selection/highlight)

    // Text
    readonly property color textColor: "#c0caf5"           // Foreground
    readonly property color textReverseColor: "#1a1b26"    // Background color for inverted text

    // Subtext
    readonly property color subtextColor: "#a9b1d6"        // Color 7 (Lower contrast text)
    readonly property color subtextReverseColor: "#565f89" // Comment color

    // State and Highlight Colors
    readonly property color accentColor: "#7aa2f7"         // Blue (Active Tab / Focus)
    readonly property color successColor: "#9ece6a"        // Green
    readonly property color warningColor: "#e0af68"        // Yellow
    readonly property color errorColor: "#f7768e"          // Red

    // Specific Colors (Semantic Mapping)
    readonly property color mutedColor: "#545c7e"          // Inactive foreground
    readonly property color activeColor: "#c0caf5"         // Main foreground

    // Others (Extra variants from Tokyo Night)
    readonly property color grayBlueColor: "#283457"       // Selection background
    readonly property color blueDarkColor: "#16161e"       // Darker background variant

    // ========================================================================
    // GEOMETRY AND LAYOUT
    // ========================================================================

    readonly property int barHeight: 32
    readonly property int radiusSmall: 5
    readonly property int radius: 10
    readonly property int radiusLarge: 15
    readonly property int spacing: 8
    readonly property int padding: 6

    // ========================================================================
    // TYPOGRAPHY
    // ========================================================================

    readonly property string font: "Caskaydia Cove Nerd Font"

    readonly property int fontSizeSmall: 12
    readonly property int fontSizeNormal: 14
    readonly property int fontSizeLarge: 16
    readonly property int fontSizeIconSmall: 18
    readonly property int fontSizeIcon: 22
    readonly property int fontSizeIconLarge: 28

    // ========================================================================
    // ANIMATIONS
    // ========================================================================

    readonly property int animDurationShort: 100
    readonly property int animDuration: 200
    readonly property int animDurationLong: 400

    // ========================================================================
    // NOTIFICATIONS
    // ========================================================================

    readonly property int notifWidth: 350
    readonly property int notifImageSize: 40
    readonly property int notifTimeout: 5000
    readonly property int notifSpacing: 10
}
