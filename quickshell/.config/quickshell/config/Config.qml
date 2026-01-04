pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import QtQuick

Singleton {
    id: root

    // ========================================================================
    // PALETA DE CORES
    // ========================================================================

    // Fundo geral (Barras, Menus)
    readonly property color backgroundColor: "#141414"
    readonly property color surface0Color: "#1f2329"
    readonly property color surface1Color: "#323a45"
    readonly property color surface2Color: "#3e4756"

    // Texto
    readonly property color textColor: "#e3e6eb"           // Texto principal
    readonly property color textReverseColor: "#141414"    // Texto principal oposto

    // Subtexto
    readonly property color subtextColor: "#7a8491"        // Texto secundário
    readonly property color subtextReverseColor: "#4f5863" // Texto secundário oposto

    // Cores de Estado e Destaque
    readonly property color accentColor: "#7d9bba"         // Azul (Foco principal)
    readonly property color successColor: "#8ccf7e"        // Verde
    readonly property color warningColor: "#e5c07b"        // Amarelo
    readonly property color errorColor: "#d95e5e"          // Vermelho

    // Cores Específicas (Mapeamento semântico)
    readonly property color mutedColor: "#565f89"          // Cinza
    readonly property color activeColor: "#e3e6eb"         // Branco

    // Outros
    readonly property color grayBlueColor: "#3b4261"
    readonly property color blueDarkColor: "#1d202f"

    // ========================================================================
    // GEOMETRIA E LAYOUT
    // ========================================================================

    readonly property int barHeight: 32      // Altura padrão da barra
    readonly property int radiusSmall: 5     // Arredondamento pequeno
    readonly property int radius: 10         // Arredondamento padrão
    readonly property int radiusLarge: 15    // Arredondamento grande
    readonly property int spacing: 8         // Espaço entre widgets
    readonly property int padding: 6         // Padding interno dos widgets

    // ========================================================================
    // TIPOGRAFIA
    // ========================================================================

    // Defina a fonte de todo o shell aqui
    readonly property string font: "Caskaydia Cove Nerd Font"

    readonly property int fontSizeSmall: 12
    readonly property int fontSizeNormal: 14
    readonly property int fontSizeLarge: 16
    readonly property int fontSizeIcon: 18
    readonly property int fontSizeIconLarge: 28

    // ========================================================================
    // ANIMAÇÕES
    // ========================================================================

    readonly property int animDurationShort: 100   // Duração curta (ms)
    readonly property int animDuration: 200        // Duração padrão (ms)
    readonly property int animDurationLong: 400    // Duração longa (ms)
}
