pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Audio/Volume service using wpctl (optimized)
Singleton {
    id: root

    property int volume: 50
    property bool muted: false

    // Single process for volume + mute state
    Process {
        id: volumeProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: function(line) {
                // Format: "Volume: 0.50" or "Volume: 0.50 [MUTED]"
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

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: volumeProc.running = true
    }

    Process {
        id: setVolumeProc
        property real vol: 0.5
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", vol.toString()]
    }

    Process {
        id: toggleMuteProc
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
        onExited: volumeProc.running = true
    }

    function setVolume(val) {
        val = Math.max(0, Math.min(100, Math.round(val)))
        root.volume = val
        setVolumeProc.vol = val / 100
        setVolumeProc.running = true
    }

    function toggleMute() {
        root.muted = !root.muted
        toggleMuteProc.running = true
    }
}
