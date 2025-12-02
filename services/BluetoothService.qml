pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Bluetooth service using bluetoothctl
Singleton {
    id: root

    property bool powered: false
    property bool connected: false
    property string deviceName: ""
    property int connectedDevices: 0

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: updateBluetooth()
    }

    Process {
        id: powerProc
        command: ["bluetoothctl", "show"]
        stdout: SplitParser {
            onRead: function(line) {
                if (line.includes("Powered:")) {
                    root.powered = line.includes("yes")
                }
            }
        }
    }

    Process {
        id: connectedProc
        command: ["sh", "-c", "bluetoothctl devices Connected 2>/dev/null | wc -l"]
        stdout: SplitParser {
            onRead: function(line) {
                let count = parseInt(line.trim())
                root.connectedDevices = isNaN(count) ? 0 : count
                root.connected = count > 0
            }
        }
    }

    Process {
        id: deviceNameProc
        command: ["sh", "-c", "bluetoothctl devices Connected 2>/dev/null | head -1 | cut -d' ' -f3-"]
        stdout: SplitParser {
            onRead: function(line) {
                root.deviceName = line.trim()
            }
        }
    }

    function updateBluetooth() {
        powerProc.running = true
        connectedProc.running = true
        deviceNameProc.running = true
    }

    Process {
        id: btPowerOnProc
        command: ["bluetoothctl", "power", "on"]
    }

    Process {
        id: btPowerOffProc
        command: ["bluetoothctl", "power", "off"]
    }

    Process {
        id: btSettingsProc
        command: ["sh", "-c", "blueman-manager || bluedevil-wizard || gnome-control-center bluetooth"]
    }

    function togglePower() {
        if (powered) {
            btPowerOffProc.running = true
        } else {
            btPowerOnProc.running = true
        }
        root.powered = !root.powered
        Qt.callLater(updateBluetooth)
    }

    function openSettings() {
        btSettingsProc.running = true
    }
}
