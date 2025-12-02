pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Brightness service using brightnessctl
Singleton {
    id: root

    property int brightness: 100
    property int maxBrightness: 100

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: updateBrightness()
    }

    Process {
        id: brightnessProc
        command: ["brightnessctl", "-m"]
        stdout: SplitParser {
            onRead: function(line) {
                // Format: device,class,current,percentage,max
                let parts = line.split(",")
                if (parts.length >= 5) {
                    root.brightness = parseInt(parts[3].replace("%", ""))
                    root.maxBrightness = parseInt(parts[4])
                }
            }
        }
    }

    function updateBrightness() {
        brightnessProc.running = true
    }

    Process {
        id: setBrightnessProc
        property int val: 100
        command: ["brightnessctl", "set", val + "%"]
    }

    function setBrightness(val) {
        val = Math.max(5, Math.min(100, val)) // Min 5% to avoid black screen
        setBrightnessProc.val = val
        setBrightnessProc.running = true
        root.brightness = val
    }

    function increaseBrightness(step) {
        setBrightness(brightness + (step || 5))
    }

    function decreaseBrightness(step) {
        setBrightness(brightness - (step || 5))
    }
}
