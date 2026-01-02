pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    // Mantém os objetos vivos na memória
    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    // Checar se o sink esta pronto para operar
    readonly property bool sinkReady: sink !== null && sink.audio !== null
    readonly property bool sourceReady: source !== null && source.audio !== null

    readonly property bool muted: sinkReady ? (sink.audio.muted ?? false) : false
    readonly property real volume: {
        if (!sinkReady)
            return 0;
        const vol = sink.audio.volume;
        return Math.max(0, Math.min(1, vol));
    }
    readonly property int percentage: Math.round(volume * 100)

    readonly property bool sourceMuted: sourceReady ? (source.audio.muted ?? false) : false
    readonly property real sourceVolume: sourceReady ? (source.audio.volume ?? 0) : 0
    readonly property int sourcePercentage: Math.round(sourceVolume * 100)

    function setVolume(newVolume) {
        if (sinkReady) {
            sink.audio.muted = false;
            sink.audio.volume = Math.max(0, Math.min(1, newVolume));
        }
    }

    function toggleMute() {
        if (sinkReady) {
            sink.audio.muted = !sink.audio.muted;
        }
    }

    function increaseVolume() {
        setVolume(volume + 0.05);
    }

    function decreaseVolume() {
        setVolume(volume - 0.05);
    }

    function setSourceVolume(newVolume) {
        if (sourceReady && source.audio) {
            source.audio.muted = false;
            source.audio.volume = Math.max(0, Math.min(1.5, newVolume));
        }
    }

    function toggleSourceMute() {
        if (sourceReady && source.audio) {
            source.audio.muted = !source.audio.muted;
        }
    }
}
