pragma ComponentBehavior: Bound
import QtQuick
import qs.config

Text {
    id: root

    // --- Propriedades Configuráveis ---
    property bool running: true          // Controla se gira e aparece
    property int size: Config.fontSizeIcon

    // Cor padrão é a do texto normal, mas pode ser sobrescrita
    color: Config.textColor

    // --- Configuração Visual ---
    text: ""
    font.family: Config.font
    font.pixelSize: size

    // Visibilidade atrelada ao funcionamento
    visible: running

    // --- Animação ---
    RotationAnimator on rotation {
        from: 0
        to: 360
        duration: 1000
        loops: Animation.Infinite
        running: root.running
    }
}
