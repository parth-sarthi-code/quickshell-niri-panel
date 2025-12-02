pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Network speed monitoring service - optimized
Singleton {
    id: root

    property real downloadSpeed: 0  // bytes per second
    property real uploadSpeed: 0    // bytes per second
    property string downloadText: "0 B/s"
    property string uploadText: "0 B/s"
    property bool enabled: false

    // Previous values for calculating delta
    property real _prevRx: 0
    property real _prevTx: 0
    property bool _initialized: false

    // Read /proc/net/dev directly - more efficient than awk
    Process {
        id: netStatProc
        command: ["cat", "/proc/net/dev"]
        stdout: SplitParser {
            onRead: function(line) {
                // Skip header lines
                if (line.includes("|") || line.trim() === "") return
                
                let parts = line.trim().split(/\s+/)
                if (parts.length >= 10 && !parts[0].startsWith("lo:")) {
                    // Accumulate rx (field 1) and tx (field 9) for non-loopback interfaces
                    root._tempRx += parseFloat(parts[1]) || 0
                    root._tempTx += parseFloat(parts[9]) || 0
                }
            }
        }
        onExited: function() {
            if (root._initialized) {
                // Calculate speed (bytes per interval)
                root.downloadSpeed = (root._tempRx - root._prevRx) / 3
                root.uploadSpeed = (root._tempTx - root._prevTx) / 3
                root.downloadText = formatSpeed(root.downloadSpeed)
                root.uploadText = formatSpeed(root.uploadSpeed)
            }
            
            root._prevRx = root._tempRx
            root._prevTx = root._tempTx
            root._tempRx = 0
            root._tempTx = 0
            root._initialized = true
        }
    }

    property real _tempRx: 0
    property real _tempTx: 0

    Timer {
        interval: 3000  // Poll every 3 seconds for efficiency
        running: root.enabled
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root._tempRx = 0
            root._tempTx = 0
            netStatProc.running = true
        }
    }

    // Reset when disabled
    onEnabledChanged: {
        if (!enabled) {
            downloadSpeed = 0
            uploadSpeed = 0
            downloadText = "0 B/s"
            uploadText = "0 B/s"
            _initialized = false
        }
    }

    function formatSpeed(bytesPerSec) {
        if (bytesPerSec < 1024) {
            return Math.round(bytesPerSec) + " B/s"
        } else if (bytesPerSec < 1024 * 1024) {
            return (bytesPerSec / 1024).toFixed(1) + " K/s"
        } else {
            return (bytesPerSec / 1024 / 1024).toFixed(1) + " M/s"
        }
    }
}
