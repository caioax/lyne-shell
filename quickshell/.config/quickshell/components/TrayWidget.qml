pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services

RowLayout {
    id: root
    spacing: 5

    // Estado da gaveta
    property bool isOpen: false

    // Criamos o objeto TrayMenu aqui, mas ele começa invisível.
    TrayMenu {
        id: sharedMenu
        visible: false

        onVisibleChanged: {
            if (visible)
                TrayService.registerActiveMenu(sharedMenu);
        }
    }

    Item {
        id: drawer

        clip: true

        Layout.preferredHeight: 30
        Layout.preferredWidth: root.isOpen ? (iconsRow.implicitWidth + 5) : 0

        Behavior on Layout.preferredWidth {
            NumberAnimation {
                duration: Config.animDurationLong
                easing.type: Easing.OutExpo
            }
        }

        opacity: root.isOpen ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: Config.animDuration }
        }

        // Conteúdo da gaveta
        Row {
            id: iconsRow
            spacing: 3
            anchors.verticalCenter: parent.verticalCenter

            anchors.right: parent.right
            anchors.rightMargin: root.isOpen ? 5 : -iconsRow.implicitWidth

            Behavior on anchors.rightMargin {
                NumberAnimation {
                    duration: Config.animDurationLong
                    easing.type: Easing.OutExpo
                }
            }

            Repeater {
                model: TrayService.items

                delegate: Rectangle {
                    id: trayDelegate
                    required property var modelData

                    implicitWidth: 24
                    implicitHeight: 24
                    radius: width / 2
                    color: mouseArea.containsMouse ? Config.surface2Color : "transparent"

                    Image {
                        anchors.centerIn: parent
                        width: 18
                        height: 18
                        source: TrayService.getIconSource(trayDelegate.modelData.icon)
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        sourceSize: Qt.size(32, 32)
                        mipmap: false
                        smooth: true
                        onStatusChanged: if (status === Image.Error)
                            source = "image://icon/application-default-icon"
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor

                        onClicked: mouse => {
                            if (mouse.button === Qt.LeftButton) {
                                trayDelegate.modelData.activate();
                                sharedMenu.close();
                            } else if (mouse.button === Qt.RightButton) {
                                if (trayDelegate.modelData.hasMenu) {
                                    // 1. Pega a posição absoluta do ícone na tela
                                    var globalPos = trayDelegate.mapToGlobal(0, trayDelegate.height);

                                    // 2. Configura o menu compartilhado
                                    sharedMenu.rootMenuHandle = trayDelegate.modelData.menu;
                                    sharedMenu.anchorX = globalPos.x;
                                    sharedMenu.anchorY = globalPos.y + 5;

                                    // 3. Abre o menu
                                    sharedMenu.open();
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Botão de toggle
    Rectangle {
        id: toggleBtn

        visible: TrayService.hasItems
        Layout.preferredWidth: 24
        Layout.preferredHeight: 24
        radius: width / 2

        color: toggleMouse.containsMouse ? Config.surface2Color : "transparent"

        // Ícone de Seta
        Text {
            anchors.centerIn: parent
            text: root.isOpen ? "" : ""
            font.family: Config.font
            font.pixelSize: Config.fontSizeSmall
            font.bold: true
            color: root.isOpen ? Config.accentColor : Config.textColor
        }

        MouseArea {
            id: toggleMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.isOpen = !root.isOpen
        }
    }
}
