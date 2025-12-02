pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Bluetooth service using bluetoothctl (optimized)
Singleton {
    id: root

    property bool powered: false
    property bool connected: false
    property string deviceName: ""
    property int connectedDevices: 0

    // Single consolidated process for all BT info
    Process {
        id: btInfoProc
        command: ["sh", "-c", "bluetoothctl show 2>/dev/null | grep -E 'Powered' | head -1; bluetoothctl devices Connected 2>/dev/null"]
        
        property bool _tmpPowered: false
        property int _tmpCount: 0
        property string _tmpName: ""
        
        stdout: SplitParser {
            onRead: function(line) {
                if (line.includes("Powered:")) {
                    btInfoProc._tmpPowered = line.includes("yes")
                } else if (line.startsWith("Device")) {
                    btInfoProc._tmpCount++
                    if (btInfoProc._tmpName === "") {
                        // Extract device name: "Device XX:XX:XX:XX:XX:XX DeviceName"
                        let parts = line.split(" ")
                        if (parts.length >= 3) {
                            btInfoProc._tmpName = parts.slice(2).join(" ")
                        }
                    }
                }
            }
        }
        onStarted: {
            _tmpPowered = false
            _tmpCount = 0
            _tmpName = ""
        }
        onExited: {
            root.powered = _tmpPowered
            root.connectedDevices = _tmpCount
            root.connected = _tmpCount > 0
            root.deviceName = _tmpName
        }
    }

    Timer {
        interval: 8000  // Reduced frequency - BT doesn't change often
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: btInfoProc.running = true
    }

    Process {
        id: btPowerOnProc
        command: ["bluetoothctl", "power", "on"]
        onExited: btInfoProc.running = true
    }

    Process {
        id: btPowerOffProc
        command: ["bluetoothctl", "power", "off"]
        onExited: btInfoProc.running = true
    }

    function togglePower() {
        // Optimistic update
        root.powered = !root.powered
        if (root.powered) {
            btPowerOnProc.running = true
        } else {
            btPowerOffProc.running = true
            root.connected = false
            root.deviceName = ""
            root.connectedDevices = 0
        }
    }
}
