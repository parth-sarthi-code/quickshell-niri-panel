pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Audio/Volume service using wpctl with real-time updates via pactl subscribe
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

    // Subscribe to PulseAudio/PipeWire events for real-time updates
    Process {
        id: subscribeProc
        command: ["pactl", "subscribe"]
        running: true
        stdout: SplitParser {
            onRead: function(line) {
                // Listen for sink changes (volume/mute)
                if (line.includes("sink") && line.includes("change")) {
                    volumeProc.running = true
                }
            }
        }
        onExited: function(exitCode, exitStatus) {
            // Restart if it dies
            restartTimer.running = true
        }
    }

    Timer {
        id: restartTimer
        interval: 1000
        onTriggered: subscribeProc.running = true
    }

    // Initial fetch on startup
    Timer {
        interval: 100
        running: true
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
