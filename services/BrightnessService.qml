pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Brightness service using brightnessctl (optimized)
Singleton {
    id: root

    property int brightness: 100
    property int maxBrightness: 100

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

    Timer {
        interval: 10000  // Brightness rarely changes externally
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: brightnessProc.running = true
    }

    Process {
        id: setBrightnessProc
        property int val: 100
        command: ["brightnessctl", "set", val + "%"]
    }

    function setBrightness(val) {
        val = Math.max(5, Math.min(100, Math.round(val)))
        root.brightness = val
        setBrightnessProc.val = val
        setBrightnessProc.running = true
    }
}
