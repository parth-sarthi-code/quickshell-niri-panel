pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Audio/Volume service using wpctl - simplified
Singleton {
    id: root

    property int volume: 50
    property bool muted: false

    // Get volume + mute state
    Process {
        id: volumeProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: function(line) {
                line = line.trim()
                if (line.startsWith("Volume:")) {
                    let parts = line.split(" ")
                    if (parts.length >= 2) {
                        let vol = parseFloat(parts[1]) * 100
                        root.volume = Math.round(vol)
                    }
                    root.muted = line.includes("[MUTED]")
                }
            }
        }
    }

    // Poll less frequently - volume doesn't change often on its own
    Timer {
        interval: 5000  // 5s instead of 2s
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: volumeProc.running = true
    }

    Process {
        id: setVolumeProc
        property real vol: 0.5
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", vol.toString()]
        onExited: volumeProc.running = true  // Refresh after setting
    }

    Process {
        id: toggleMuteProc
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
        onExited: volumeProc.running = true
    }

    function setVolume(val) {
        val = Math.max(0, Math.min(100, Math.round(val)))
        root.volume = val  // Optimistic update
        setVolumeProc.vol = val / 100
        setVolumeProc.running = true
    }

    function toggleMute() {
        root.muted = !root.muted  // Optimistic update
        toggleMuteProc.running = true
    }

    function increaseVolume(amount) {
        setVolume(root.volume + amount)
    }

    function decreaseVolume(amount) {
        setVolume(root.volume - amount)
    }
}
