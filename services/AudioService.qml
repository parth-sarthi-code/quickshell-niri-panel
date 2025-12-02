pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Audio/Volume service using pactl/wpctl
Singleton {
    id: root

    property int volume: 50
    property bool muted: false
    property string sink: ""

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: updateVolume()
    }

    Process {
        id: volumeProc
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oP '\\d+%' | head -1"]
        stdout: SplitParser {
            onRead: function(line) {
                // wpctl format: "Volume: 0.50" or "Volume: 0.50 [MUTED]"
                // pactl format: "50%"
                line = line.trim()
                if (line.includes("Volume:")) {
                    let parts = line.split(" ")
                    let vol = parseFloat(parts[1]) * 100
                    root.volume = Math.round(vol)
                    root.muted = line.includes("[MUTED]")
                } else if (line.includes("%")) {
                    root.volume = parseInt(line.replace("%", ""))
                }
            }
        }
    }

    Process {
        id: muteProc
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep -q MUTED && echo muted || pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null"]
        stdout: SplitParser {
            onRead: function(line) {
                root.muted = line.toLowerCase().includes("muted") || line.toLowerCase().includes("yes")
            }
        }
    }

    function updateVolume() {
        volumeProc.running = true
        muteProc.running = true
    }

    Process {
        id: setVolumeProc
        property string vol: "50"
        command: ["sh", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + (parseInt(vol) / 100) + " 2>/dev/null || pactl set-sink-volume @DEFAULT_SINK@ " + vol + "%"]
    }

    Process {
        id: toggleMuteProc
        command: ["sh", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle 2>/dev/null || pactl set-sink-mute @DEFAULT_SINK@ toggle"]
    }

    function setVolume(vol) {
        vol = Math.max(0, Math.min(100, vol))
        setVolumeProc.vol = vol.toString()
        setVolumeProc.running = true
        root.volume = vol
        Qt.callLater(updateVolume)
    }

    function toggleMute() {
        toggleMuteProc.running = true
        root.muted = !root.muted
        Qt.callLater(updateVolume)
    }

    function increaseVolume(step) {
        setVolume(volume + (step || 5))
    }

    function decreaseVolume(step) {
        setVolume(volume - (step || 5))
    }
}
