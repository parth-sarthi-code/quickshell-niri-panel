import QtQuick
import QtQuick.Layouts
import "../.."
import "../../services"

// Connectivity module with WiFi, Bluetooth, Airplane mode, AirDrop-like
Rectangle {
    id: module

    color: Config.ccModuleBackground
    radius: Config.ccModuleRadius

    GridLayout {
        anchors {
            fill: parent
            margins: 10
        }
        columns: 2
        rowSpacing: 8
        columnSpacing: 8

        // WiFi toggle
        CCToggleButton {
            Layout.fillWidth: true
            Layout.fillHeight: true
            icon: "󰤨"
            iconOff: "󰤭"
            label: NetworkService.connected && NetworkService.type === "wifi" ? NetworkService.ssid : "Wi-Fi"
            sublabel: NetworkService.connected && NetworkService.type === "wifi" ? "Connected" : "Off"
            active: NetworkService.connected && NetworkService.type === "wifi"
            onClicked: NetworkService.toggleWifi()
            onLongPressed: {
                // Expand to show available networks
                controlCenter.wifiExpanded = !controlCenter.wifiExpanded
                controlCenter.btExpanded = false
            }
        }

        // Bluetooth toggle
        CCToggleButton {
            Layout.fillWidth: true
            Layout.fillHeight: true
            icon: "󰂯"
            iconOff: "󰂲"
            label: BluetoothService.connected ? BluetoothService.deviceName : "Bluetooth"
            sublabel: BluetoothService.powered ? (BluetoothService.connected ? "Connected" : "On") : "Off"
            active: BluetoothService.powered
            onClicked: BluetoothService.togglePower()
            onLongPressed: {
                // Expand to show paired devices
                controlCenter.btExpanded = !controlCenter.btExpanded
                controlCenter.wifiExpanded = false
            }
        }

        // Airplane mode toggle (placeholder)
        CCToggleButton {
            Layout.fillWidth: true
            Layout.fillHeight: true
            icon: "󰀝"
            label: "Airplane"
            sublabel: "Off"
            active: false
            onClicked: active = !active
        }

        // Network (ethernet indicator)
        CCToggleButton {
            Layout.fillWidth: true
            Layout.fillHeight: true
            icon: NetworkService.type === "ethernet" ? "󰈀" : "󰀂"
            label: NetworkService.type === "ethernet" ? "Ethernet" : "Mobile"
            sublabel: NetworkService.type === "ethernet" ? "Connected" : "Off"
            active: NetworkService.connected && NetworkService.type === "ethernet"
        }
    }
}
