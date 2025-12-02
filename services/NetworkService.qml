pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Network service using nmcli
Singleton {
    id: root

    property bool connected: false
    property string type: "none" // wifi, ethernet, none
    property string ssid: ""
    property int strength: 0 // 0-100 for wifi signal
    property string ip: ""

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: updateNetwork()
    }

    Process {
        id: networkProc
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION,SIGNAL", "device", "status"]
        stdout: SplitParser {
            onRead: function(line) {
                let parts = line.split(":")
                if (parts.length >= 3) {
                    let devType = parts[0]
                    let state = parts[1]
                    let conn = parts[2]
                    
                    if (state === "connected") {
                        root.connected = true
                        if (devType === "wifi") {
                            root.type = "wifi"
                            root.ssid = conn
                        } else if (devType === "ethernet") {
                            root.type = "ethernet"
                            root.ssid = conn
                        }
                    }
                }
            }
        }
        onExited: function(exitCode) {
            if (exitCode !== 0) {
                root.connected = false
                root.type = "none"
            }
        }
    }

    Process {
        id: wifiStrengthProc
        command: ["sh", "-c", "nmcli -t -f SIGNAL,ACTIVE dev wifi | grep yes | cut -d: -f1"]
        stdout: SplitParser {
            onRead: function(line) {
                let sig = parseInt(line.trim())
                if (!isNaN(sig)) {
                    root.strength = sig
                }
            }
        }
    }

    function updateNetwork() {
        root.connected = false
        root.type = "none"
        root.ssid = ""
        root.strength = 0
        networkProc.running = true
        if (type === "wifi") {
            wifiStrengthProc.running = true
        }
    }

    Process {
        id: wifiOnProc
        command: ["nmcli", "radio", "wifi", "on"]
    }

    Process {
        id: wifiOffProc
        command: ["nmcli", "radio", "wifi", "off"]
    }

    Process {
        id: networkSettingsProc
        command: ["sh", "-c", "nm-connection-editor || gnome-control-center wifi || kde-open5 settings5://network"]
    }

    function toggleWifi() {
        if (connected && type === "wifi") {
            wifiOffProc.running = true
        } else {
            wifiOnProc.running = true
        }
        Qt.callLater(updateNetwork)
    }

    function openSettings() {
        networkSettingsProc.running = true
    }
}
