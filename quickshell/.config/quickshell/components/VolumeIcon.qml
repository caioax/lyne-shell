pragma ComponentBehavior: Bound
import QtQuick
import qs.services
import qs.config

Text {
    id: root

    font.family: Config.font
    font.pixelSize: Config.fontSizeNormal
    font.bold: true

    color: {
        if (!AudioService.sinkReady)
            return Config.errorColor;      // Se não tiver áudio (Erro)
        return Config.textColor;         // Normal
    }

    // Lógica do texto
    text: {
        // Se o áudio não estiver pronto (Pipewire caiu ou sem placa)
        if (!AudioService.sinkReady)
            return " ";

        if (AudioService.muted)
            return " ";

        var icon = " ";
        if (AudioService.volume < 0.3)
            icon = " ";
        else if (AudioService.volume < 0.6)
            icon = " ";

        return icon;
    }

    // Interação como o mouse
    MouseArea {
        anchors.fill: parent

        // UX: Transforma o mouse na "Mãozinha" ao passar por cima
        cursorShape: Qt.PointingHandCursor

        // Aceita botão esquerdo para clique
        acceptedButtons: Qt.LeftButton

        // Lógica do Clique (Mute)
        onClicked: Audio.toggleMute()

        // Lógica do Scroll (Volume)
        onWheel: wheel => {
            // angleDelta.y > 0 significa scroll para CIMA
            if (wheel.angleDelta.y > 0) {
                Audio.increaseVolume();
            } else {
                Audio.decreaseVolume();
            }
        }
    }
}
