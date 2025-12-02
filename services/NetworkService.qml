pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Network service using busctl (direct D-Bus) with smart polling
// Faster than nmcli, simpler than dbus-monitor streaming
Singleton {
    id: root

    property bool connected: false
    property bool wifiEnabled: true
    property string type: "none" // wifi, ethernet, none
    property string ssid: ""
    property int strength: 0
    
    // Adaptive polling: fast after changes, slow when stable
    property int _stableCount: 0
    readonly property int _interval: _stableCount > 2 ? 15000 : 5000

    // Single busctl call for all network state (faster than nmcli)
    Process {
        id: networkProc
        command: ["sh", "-c", `
w=$(busctl get-property org.freedesktop.NetworkManager /org/freedesktop/NetworkManager org.freedesktop.NetworkManager WirelessEnabled 2>/dev/null | grep -q true && echo 1 || echo 0)
s=$(busctl get-property org.freedesktop.NetworkManager /org/freedesktop/NetworkManager org.freedesktop.NetworkManager State 2>/dev/null | awk '{print $2}')
t=$(busctl get-property org.freedesktop.NetworkManager /org/freedesktop/NetworkManager org.freedesktop.NetworkManager PrimaryConnectionType 2>/dev/null | sed 's/s "//;s/"//')
c=$(busctl get-property org.freedesktop.NetworkManager /org/freedesktop/NetworkManager org.freedesktop.NetworkManager PrimaryConnection 2>/dev/null | sed 's/o "//;s/"//')
echo "$w|$s|$t|$c"
[ "$c" != "/" ] && [ -n "$c" ] && busctl get-property org.freedesktop.NetworkManager "$c" org.freedesktop.NetworkManager.Connection.Active Id 2>/dev/null | sed 's/s "//;s/"//;s/^/SSID:/'
nmcli -t -f SIGNAL,ACTIVE dev wifi 2>/dev/null | grep ':yes' | cut -d: -f1 | head -1 | sed 's/^/SIG:/'
`]
        property bool _prevConnected: false
        property string _prevType: "none"
        
        stdout: SplitParser {
            onRead: function(line) {
                if (line.startsWith("SSID:")) {
                    root.ssid = line.substring(5)
                } else if (line.startsWith("SIG:")) {
                    let sig = parseInt(line.substring(4))
                    if (!isNaN(sig)) root.strength = sig
                } else if (line.includes("|")) {
                    let parts = line.split("|")
                    root.wifiEnabled = parts[0] === "1"
                    let state = parseInt(parts[1])
                    root.connected = state >= 50  // NM: 50+=connected
                    let connType = parts[2]
                    if (connType.includes("wireless")) root.type = "wifi"
                    else if (connType.includes("ethernet")) root.type = "ethernet"
                    else if (root.connected) root.type = "other"
                    else root.type = "none"
                }
            }
        }
        onExited: {
            // Adaptive: reset counter on state change
            let changed = (root.connected !== _prevConnected || root.type !== _prevType)
            _prevConnected = root.connected
            _prevType = root.type
            root._stableCount = changed ? 0 : Math.min(root._stableCount + 1, 5)
            
            // Clear on disconnect
            if (!root.connected) {
                root.ssid = ""
                root.strength = 0
            }
        }
    }

    Timer {
        interval: root._interval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: networkProc.running = true
    }

    // WiFi toggle (busctl is faster than nmcli)
    Process {
        id: wifiToggleProc
        property bool targetState: true
        command: ["busctl", "set-property", "org.freedesktop.NetworkManager",
                  "/org/freedesktop/NetworkManager", "org.freedesktop.NetworkManager",
                  "WirelessEnabled", "b", targetState ? "true" : "false"]
        onExited: { root._stableCount = 0; networkProc.running = true }
    }

    function toggleWifi() {
        wifiToggleProc.targetState = !root.wifiEnabled
        root.wifiEnabled = !root.wifiEnabled
        wifiToggleProc.running = true
        if (!root.wifiEnabled) {
            root.connected = false
            root.type = "none"
            root.ssid = ""
            root.strength = 0
        }
    }
}
