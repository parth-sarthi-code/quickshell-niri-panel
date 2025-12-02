pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Brightness service using direct sysfs (no CLI tools for reading!)
Singleton {
    id: root

    property int brightness: 100
    property int maxBrightness: 100
    
    // Auto-detect backlight device
    readonly property string backlightPath: "/sys/class/backlight/nvidia_wmi_ec_backlight"

    // Read brightness directly from sysfs
    Process {
        id: readProc
        command: ["cat", root.backlightPath + "/brightness", root.backlightPath + "/max_brightness"]
        property var lines: []
        stdout: SplitParser {
            onRead: function(line) {
                readProc.lines.push(line.trim())
            }
        }
        onStarted: lines = []
        onExited: {
            if (lines.length >= 2) {
                let current = parseInt(lines[0]) || 0
                let max = parseInt(lines[1]) || 100
                root.maxBrightness = max
                root.brightness = Math.round((current / max) * 100)
            }
        }
    }

    // FileView alternative - more efficient but may need permissions
    // For now use Process with cat as fallback
    
    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: readProc.running = true
    }

    // Still need brightnessctl for setting (requires root/udev rules)
    Process {
        id: setBrightnessProc
        property int val: 100
        command: ["brightnessctl", "set", val + "%"]
        onExited: readProc.running = true
    }

    function setBrightness(val) {
        val = Math.max(5, Math.min(100, Math.round(val)))
        root.brightness = val  // Optimistic update
        setBrightnessProc.val = val
        setBrightnessProc.running = true
    }
}
