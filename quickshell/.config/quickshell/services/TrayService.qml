pragma Singleton
import QtQuick
import Quickshell.Services.SystemTray

QtObject {
    id: root

    // Lista de itens na tray
    readonly property var items: SystemTray.items.values

    // Verifica se tem ou não itens na tray
    readonly property bool hasItems: items.length > 0

    // --- LÓGICA DE ÍCONES ---
    function getIconSource(iconString) {
        if (!iconString)
            return "image://icon/image-missing";

        // Correção para parâmetros de URL (comum em apps Electron/Steam)
        if (iconString.includes("?path=")) {
            const split = iconString.split("?path=");
            if (split.length === 2) {
                const name = split[0];
                const path = split[1];
                let fileName = name;
                if (fileName.includes("/")) {
                    fileName = fileName.substring(fileName.lastIndexOf("/") + 1);
                }
                return "file://" + path + "/" + fileName;
            }
        }

        // Caminhos absolutos
        if (iconString.startsWith("/"))
            return "file://" + iconString;
        if (iconString.startsWith("file://"))
            return iconString;

        // Ícones do tema (Freedesktop)
        if (!iconString.includes(":"))
            return "image://icon/" + iconString;

        return iconString;
    }

    // Mantém referência do menu aberto atualmente para garantir que só 1 exista no sistema todo
    property var activeMenu: null

    function registerActiveMenu(menuInstance) {
        if (activeMenu && activeMenu !== menuInstance) {
            // Se já tem um menu aberto e tentamos abrir outro, fecha o anterior
            if (typeof activeMenu.close === "function") {
                activeMenu.close();
            } else {
                activeMenu.visible = false;
            }
        }
        activeMenu = menuInstance;
    }
}
