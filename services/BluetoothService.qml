pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth

// Bluetooth service using native D-Bus (no CLI tools!)
Singleton {
    id: root

    // Use default adapter
    readonly property var adapter: Bluetooth.defaultAdapter

    // Reactive properties - automatically updated via D-Bus signals
    readonly property bool powered: adapter ? adapter.enabled : false
    readonly property bool connected: connectedDevices > 0
    readonly property string deviceName: {
        if (!adapter) return ""
        for (let i = 0; i < adapter.devices.count; i++) {
            let dev = adapter.devices.get(i)
            if (dev.connected) return dev.name
        }
        return ""
    }
    readonly property int connectedDevices: {
        if (!adapter) return 0
        let count = 0
        for (let i = 0; i < adapter.devices.count; i++) {
            if (adapter.devices.get(i).connected) count++
        }
        return count
    }

    function togglePower() {
        if (!adapter) return
        adapter.enabled = !adapter.enabled
    }
}
