pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

// Battery service using UPower
Singleton {
    id: root

    readonly property bool available: UPower.displayDevice.isLaptopBattery
    readonly property real percentage: available ? UPower.displayDevice.percentage : 1.0
    readonly property bool charging: available && UPower.displayDevice.state === UPowerDeviceState.Charging
    readonly property bool pluggedIn: charging || (available && UPower.displayDevice.state === UPowerDeviceState.PendingCharge)
    readonly property bool fullyCharged: available && UPower.displayDevice.state === UPowerDeviceState.FullyCharged
    readonly property real timeToEmpty: available ? UPower.displayDevice.timeToEmpty : 0
    readonly property real timeToFull: available ? UPower.displayDevice.timeToFull : 0
    readonly property real energyRate: available ? UPower.displayDevice.changeRate : 0

    readonly property bool isLow: percentage <= 0.20
    readonly property bool isCritical: percentage <= 0.10

    function formatTime(seconds) {
        if (seconds <= 0) return ""
        let hours = Math.floor(seconds / 3600)
        let minutes = Math.floor((seconds % 3600) / 60)
        if (hours > 0) {
            return hours + "h " + minutes + "m"
        }
        return minutes + "m"
    }

    function getStatusText() {
        if (!available) return "No battery"
        if (fullyCharged) return "Fully charged"
        if (charging) return "Charging - " + formatTime(timeToFull) + " until full"
        if (pluggedIn) return "Plugged in"
        return formatTime(timeToEmpty) + " remaining"
    }
}
