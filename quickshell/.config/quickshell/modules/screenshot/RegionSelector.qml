pragma ComponentBehavior: Bound
import QtQuick

Canvas {
    id: root

    required property var screenshot

    property real guideMouseX: 0
    property real guideMouseY: 0

    onGuideMouseXChanged: requestPaint()
    onGuideMouseYChanged: requestPaint()

    Connections {
        target: root.screenshot

        function onSelectionXChanged() {
            root.requestPaint();
        }
        function onSelectionYChanged() {
            root.requestPaint();
        }
        function onSelectionWidthChanged() {
            root.requestPaint();
        }
        function onSelectionHeightChanged() {
            root.requestPaint();
        }
    }

    // Track mouse position
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton

        onPositionChanged: mouse => {
            root.guideMouseX = mouse.x;
            root.guideMouseY = mouse.y;
        }
    }

    onPaint: {
        var ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);

        ctx.beginPath();
        ctx.strokeStyle = "rgba(255, 255, 255, 0.5)";
        ctx.lineWidth = 1;
        ctx.setLineDash([5, 5]);

        if (!root.screenshot.hasSelection && root.screenshot.selectionWidth === 0) {
            // Crosshair at cursor
            ctx.moveTo(guideMouseX, 0);
            ctx.lineTo(guideMouseX, height);
            ctx.moveTo(0, guideMouseY);
            ctx.lineTo(width, guideMouseY);
        } else if (root.screenshot.selectionWidth > 0 && root.screenshot.selectionHeight > 0) {
            // Guides around selection
            ctx.moveTo(root.screenshot.selectionX, 0);
            ctx.lineTo(root.screenshot.selectionX, height);
            ctx.moveTo(root.screenshot.selectionX + root.screenshot.selectionWidth, 0);
            ctx.lineTo(root.screenshot.selectionX + root.screenshot.selectionWidth, height);
            ctx.moveTo(0, root.screenshot.selectionY);
            ctx.lineTo(width, root.screenshot.selectionY);
            ctx.moveTo(0, root.screenshot.selectionY + root.screenshot.selectionHeight);
            ctx.lineTo(width, root.screenshot.selectionY + root.screenshot.selectionHeight);
        }

        ctx.stroke();
    }
}
