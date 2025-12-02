pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Network service using nmcli (optimized)
Singleton {
    id: root

    property bool connected: false
    property bool wifiEnabled: true
    property string type: "none" // wifi, ethernet, none
    property string ssid: ""
    property int strength: 0

    // Single consolidated process for all network info
    Process {
        id: networkProc
        command: ["sh", "-c", "echo \"RADIO:$(nmcli radio wifi)\"; nmcli -t -f TYPE,STATE,CONNECTION device status 2>/dev/null; nmcli -t -f SIGNAL,ACTIVE dev wifi 2>/dev/null | grep ':yes'"]
        
        property bool _tmpWifiEnabled: true
        property bool _tmpConnected: false
        property string _tmpType: "none"
        property string _tmpSsid: ""
        property int _tmpStrength: 0
        
        stdout: SplitParser {
            onRead: function(line) {
                if (line.startsWith("RADIO:")) {
                    networkProc._tmpWifiEnabled = line.includes("enabled")
                } else if (line.includes(":yes")) {
                    // WiFi signal line: "85:yes"
                    let sig = parseInt(line.split(":")[0])
                    if (!isNaN(sig)) networkProc._tmpStrength = sig
                } else {
                    let parts = line.split(":")
                    if (parts.length >= 3 && parts[1].startsWith("connected")) {
                        let devType = parts[0]
                        let conn = parts[2]
                        if (devType === "wifi") {
                            networkProc._tmpConnected = true
                            networkProc._tmpType = "wifi"
                            networkProc._tmpSsid = conn
                        } else if (devType === "ethernet" && !networkProc._tmpConnected) {
                            networkProc._tmpConnected = true
                            networkProc._tmpType = "ethernet"
                            networkProc._tmpSsid = conn
                        }
                    }
                }
            }
        }
        onStarted: {
            _tmpWifiEnabled = root.wifiEnabled
            _tmpConnected = false
            _tmpType = "none"
            _tmpSsid = ""
            _tmpStrength = 0
        }
        onExited: {
            root.wifiEnabled = _tmpWifiEnabled
            root.connected = _tmpConnected
            root.type = _tmpType
            root.ssid = _tmpSsid
            root.strength = _tmpStrength
        }
    }

    Timer {
        interval: 8000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: networkProc.running = true
    }

    Process {
        id: wifiOnProc
        command: ["nmcli", "radio", "wifi", "on"]
        onExited: networkProc.running = true
    }

    Process {
        id: wifiOffProc
        command: ["nmcli", "radio", "wifi", "off"]
        onExited: networkProc.running = true
    }

    function toggleWifi() {
        root.wifiEnabled = !root.wifiEnabled
        if (root.wifiEnabled) {
            wifiOnProc.running = true
        } else {
            wifiOffProc.running = true
            root.connected = false
            root.type = "none"
            root.ssid = ""
            root.strength = 0
        }
    }
}
