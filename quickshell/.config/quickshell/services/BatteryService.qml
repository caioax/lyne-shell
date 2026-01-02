pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    // Retorna true se encontrou uma bateria de laptop
    readonly property bool hasBattery: mainBattery !== null

    // Porcentagem (0 a 100)
    readonly property int percentage: mainBattery ? Math.round(mainBattery.percentage * 100) : 0

    // Estado (Carregando, Descarregando, Cheio...)
    readonly property int state: mainBattery ? mainBattery.state : UPowerDeviceState.Unknown

    // Helper booleano para facilitar bindings na UI
    readonly property bool isCharging: state === UPowerDeviceState.Charging

    // Guarda a referência ao objeto da bateria
    property var mainBattery: null

    // O Instantiator varre a lista de dispositivos sem criar visual
    Instantiator {
        model: UPower.devices

        delegate: QtObject {
            required property var modelData
            
            // Quando um dispositivo é criado ou muda, checamos se é a bateria principal
            Component.onCompleted: checkDevice()
            
            function checkDevice() {
                if (modelData && modelData.isLaptopBattery) {
                    root.mainBattery = modelData
                }
            }
        }
    }

    // Lógica do ícone aqui. 
    function getBatteryIcon() {
        if (state === UPowerDeviceState.Charging) return "󰂄"

        const p = percentage
        if (p >= 90) return "󰁹"
        if (p >= 60) return "󰂀"
        if (p >= 40) return "󰁾"
        if (p >= 10) return "󰁼"
        return "󰁺"
    }
}