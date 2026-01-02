pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config

PanelWindow {
    id: root

    // Propriedades recebidas ao abrir
    property var rootMenuHandle: null
    property int anchorX: 0
    property int anchorY: 0

    // --- CONFIGURAÇÃO DA JANELA ---
    color: "transparent"

    // Tamanho
    implicitWidth: Math.max(220, mainColumn.implicitWidth)
    implicitHeight: mainColumn.implicitHeight

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.exclusiveZone: -1

    // Posiciona onde o mouse clicou (ou ícone)
    anchors {
        left: true
        top: true
    }
    margins {
        left: Math.min(root.screen.width - implicitWidth - 10, root.anchorX)
        top: Math.min(root.screen.height - implicitHeight - 10, root.anchorY)
    }

    // --- SISTEMA DE NAVEGAÇÃO ---
    // Mantém o histórico de onde estamos. Se vazio, estamos na raiz.
    ListModel {
        id: menuStack
    }

    function pushSubMenu(menuItem) {
        if (menuItem && menuItem.menu) {
            // Adiciona o submenu ao histórico
            menuStack.append({
                "handle": menuItem.menu
            });
        }
    }

    function popSubMenu() {
        if (menuStack.count > 0) {
            menuStack.remove(menuStack.count - 1);
        }
    }

    // Define qual menu mostrar: o último da pilha ou o raiz
    property var currentMenuHandle: {
        if (menuStack.count > 0) {
            return menuStack.get(menuStack.count - 1).handle;
        }
        return root.rootMenuHandle;
    }

    // --- FOCO E FECHAMENTO ---
    HyprlandFocusGrab {
        id: focusGrab
        windows: [root]
        active: false
        onCleared: root.close()
    }

    function open() {
        root.visible = true;
        focusTimer.restart();
    }

    function close() {
        root.visible = false;
        menuStack.clear(); // Reseta navegação ao fechar
        focusGrab.active = false;
    }

    Timer {
        id: focusTimer
        interval: 50
        onTriggered: {
            focusGrab.active = true;
            background.forceActiveFocus();
        }
    }

    // O objeto que lê os itens do menu atual
    QsMenuOpener {
        id: menuOpener
        menu: root.currentMenuHandle
    }

    // --- VISUAL ---
    Rectangle {
        id: background
        anchors.fill: parent
        color: Config.surface0Color
        border.color: Config.surface2Color
        border.width: 1
        radius: Config.radius
        clip: true

        focus: true
        Keys.onEscapePressed: {
            if (menuStack.count > 0)
                popSubMenu();
            else
                root.close();
        }

        ColumnLayout {
            id: mainColumn
            width: parent.width
            spacing: 0

            // --- CABEÇALHO / VOLTAR ---
            // Só aparece se estivermos dentro de um submenu
            Rectangle {
                visible: menuStack.count > 0
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                color: backMouse.containsMouse ? Config.surface1Color : "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 5
                    Text {
                        text: "⬅ Voltar"
                        color: Config.accentColor
                        font.family: Config.font
                        font.bold: true
                        font.pixelSize: Config.fontSizeSmall
                    }
                }
                MouseArea {
                    id: backMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: popSubMenu()
                }
            }

            // Divisor se tiver botão voltar
            Rectangle {
                visible: menuStack.count > 0
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Config.surface2Color
            }

            // --- LISTA DE ITENS ---
            Repeater {
                model: menuOpener.children

                delegate: Rectangle {
                    id: itemDelegate

                    required property var modelData
                    required property int index

                    // Helpers
                    property bool isSeparator: (modelData.type === "separator" || modelData.isSeparator === true)
                    property bool isEnabled: modelData.enabled !== false
                    property bool hasSubMenu: (modelData.children && modelData.children.length > 0) || modelData.type === "menu"

                    Layout.fillWidth: true
                    Layout.preferredHeight: isSeparator ? 6 : 32

                    color: itemMouse.containsMouse && !isSeparator ? Config.surface1Color : "transparent"
                    opacity: isEnabled ? 1.0 : 0.5

                    // Separador
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width - 10
                        height: 1
                        color: Config.surface2Color
                        visible: parent.isSeparator
                    }

                    // Item Conteúdo
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 10
                        visible: !parent.isSeparator

                        // Ícone
                        Image {
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 16
                            source: (modelData.icon) ? ("image://icon/" + modelData.icon) : ""
                            visible: source !== "" && status === Image.Ready
                            fillMode: Image.PreserveAspectFit
                        }

                        // Checkbox
                        Rectangle {
                            Layout.preferredWidth: 10
                            Layout.preferredHeight: 10
                            radius: (modelData.toggleType === 2) ? 5 : 2
                            color: "transparent"
                            border.color: Config.textColor
                            visible: (modelData.toggleType > 0) && (modelData.checked === true || modelData.status === "active")
                            Rectangle {
                                anchors.centerIn: parent
                                width: 6
                                height: 6
                                radius: parent.radius - 1
                                color: Config.textColor
                            }
                        }

                        // Texto
                        Text {
                            text: {
                                var txt = modelData.text || modelData.title || "";
                                return txt.replace(/&/g, "").replace(/_/g, "");
                            }
                            color: Config.textColor
                            font.family: Config.font
                            font.pixelSize: Config.fontSizeSmall
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        // Seta de Submenu
                        Text {
                            visible: parent.parent.hasSubMenu
                            text: "›"
                            color: Config.subtextColor
                            font.pixelSize: 14
                        }
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: !parent.isSeparator && parent.isEnabled
                        enabled: hoverEnabled
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (parent.hasSubMenu) {
                                // Empilha o submenu e a interface atualiza sozinha
                                root.pushSubMenu(modelData);
                            } else {
                                // Ação Normal
                                if (typeof modelData.activate === 'function')
                                    modelData.activate();
                                else if (typeof modelData.triggered === 'function')
                                    modelData.triggered();
                                else if (typeof modelData.click === 'function')
                                    modelData.click();

                                root.close();
                            }
                        }
                    }
                }
            }
        }
    }
}
