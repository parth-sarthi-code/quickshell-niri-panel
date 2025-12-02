import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../.."
import "../../services"

// Expandable Bluetooth devices panel
Rectangle {
    id: btPanel

    signal close()

    implicitHeight: column.implicitHeight + 20
    color: Config.ccModuleBackground
    radius: Config.ccModuleRadius

    property var pairedDevices: []
    property var availableDevices: []
    property bool scanning: false

    Component.onCompleted: refreshDevices()

    // Get paired devices
    Process {
        id: pairedProc
        command: ["bluetoothctl", "devices", "Paired"]
        stdout: SplitParser {
            onRead: function(line) {
                // Format: Device XX:XX:XX:XX:XX:XX DeviceName
                let match = line.match(/Device\s+([0-9A-F:]+)\s+(.+)/i)
                if (match) {
                    let device = {
                        mac: match[1],
                        name: match[2],
                        paired: true,
                        connected: false
                    }
                    let newList = btPanel.pairedDevices.slice()
                    newList.push(device)
                    btPanel.pairedDevices = newList
                }
            }
        }
        onStarted: btPanel.pairedDevices = []
        onExited: connectedProc.running = true
    }

    // Check which devices are connected
    Process {
        id: connectedProc
        command: ["bluetoothctl", "devices", "Connected"]
        stdout: SplitParser {
            onRead: function(line) {
                let match = line.match(/Device\s+([0-9A-F:]+)\s+(.+)/i)
                if (match) {
                    // Mark as connected in paired list
                    let newList = []
                    for (let i = 0; i < btPanel.pairedDevices.length; i++) {
                        let d = btPanel.pairedDevices[i]
                        newList.push({
                            mac: d.mac,
                            name: d.name,
                            paired: d.paired,
                            connected: d.mac === match[1] ? true : d.connected
                        })
                    }
                    btPanel.pairedDevices = newList
                }
            }
        }
    }

    // Scan for new devices
    Process {
        id: scanProc
        command: ["sh", "-c", "timeout 5 bluetoothctl scan on 2>/dev/null; bluetoothctl devices"]
        stdout: SplitParser {
            onRead: function(line) {
                let match = line.match(/Device\s+([0-9A-F:]+)\s+(.+)/i)
                if (match) {
                    let mac = match[1]
                    let name = match[2]
                    // Only add if not in paired list
                    let isPaired = btPanel.pairedDevices.some(function(d) { return d.mac === mac })
                    let isInAvailable = btPanel.availableDevices.some(function(d) { return d.mac === mac })
                    if (!isPaired && !isInAvailable) {
                        let newList = btPanel.availableDevices.slice()
                        newList.push({
                            mac: mac,
                            name: name,
                            paired: false,
                            connected: false
                        })
                        btPanel.availableDevices = newList
                    }
                }
            }
        }
        onStarted: {
            btPanel.availableDevices = []
            btPanel.scanning = true
        }
        onExited: btPanel.scanning = false
    }

    // Connect to device
    Process {
        id: connectProc
        property string mac: ""
        command: ["bluetoothctl", "connect", mac]
        onExited: function(code) {
            BluetoothService.updateBluetooth()
            refreshDevices()
        }
    }

    // Disconnect device
    Process {
        id: disconnectProc
        property string mac: ""
        command: ["bluetoothctl", "disconnect", mac]
        onExited: function(code) {
            BluetoothService.updateBluetooth()
            refreshDevices()
        }
    }

    function refreshDevices() {
        pairedProc.running = true
    }

    function scanForDevices() {
        scanProc.running = true
    }

    function connectDevice(mac) {
        connectProc.mac = mac
        connectProc.running = true
    }

    function disconnectDevice(mac) {
        disconnectProc.mac = mac
        disconnectProc.running = true
    }

    ColumnLayout {
        id: column
        anchors {
            fill: parent
            margins: 10
        }
        spacing: 8

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "󰂯"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 18
                color: Config.accentColor
            }

            Text {
                Layout.fillWidth: true
                text: "Bluetooth Devices"
                font.family: Config.fontFamily
                font.pixelSize: 14
                font.weight: Font.Medium
                color: Config.panelForeground
            }

            // Scan button
            Rectangle {
                width: 28
                height: 28
                radius: 14
                color: scanMa.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "󰑓"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 14
                    color: Config.inactiveColor
                    rotation: scanning ? 360 : 0

                    Behavior on rotation {
                        RotationAnimation {
                            duration: 1000
                            loops: scanning ? Animation.Infinite : 1
                        }
                    }
                }

                MouseArea {
                    id: scanMa
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: scanForDevices()
                }
            }

            // Close button
            Rectangle {
                width: 28
                height: 28
                radius: 14
                color: closeMa.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "󰅖"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 14
                    color: Config.inactiveColor
                }

                MouseArea {
                    id: closeMa
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: btPanel.close()
                }
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(1, 1, 1, 0.1)
        }

        // Paired devices section
        Text {
            visible: pairedDevices.length > 0
            text: "MY DEVICES"
            font.family: Config.fontFamily
            font.pixelSize: 10
            font.weight: Font.Medium
            color: Config.inactiveColor
            font.letterSpacing: 1
        }

        ListView {
            id: pairedList
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(contentHeight, 120)
            visible: pairedDevices.length > 0
            clip: true
            spacing: 4

            model: btPanel.pairedDevices

            delegate: Rectangle {
                width: pairedList.width
                height: 44
                radius: 10
                color: pairedMa.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"

                RowLayout {
                    anchors {
                        fill: parent
                        margins: 10
                    }
                    spacing: 10

                    // Device icon
                    Text {
                        text: "󰋋" // Headphones icon (generic)
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 16
                        color: modelData.connected ? Config.accentColor : Config.inactiveColor
                    }

                    // Device name
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            Layout.fillWidth: true
                            text: modelData.name
                            font.family: Config.fontFamily
                            font.pixelSize: 13
                            font.weight: modelData.connected ? Font.Medium : Font.Normal
                            color: modelData.connected ? Config.accentColor : Config.panelForeground
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.connected ? "Connected" : "Not Connected"
                            font.family: Config.fontFamily
                            font.pixelSize: 10
                            color: Config.inactiveColor
                        }
                    }

                    // Connected indicator
                    Text {
                        visible: modelData.connected
                        text: "󰄬"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 16
                        color: Config.accentColor
                    }
                }

                MouseArea {
                    id: pairedMa
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (modelData.connected) {
                            disconnectDevice(modelData.mac)
                        } else {
                            connectDevice(modelData.mac)
                        }
                    }
                }
            }
        }

        // Available devices section
        Text {
            visible: availableDevices.length > 0
            text: "OTHER DEVICES"
            font.family: Config.fontFamily
            font.pixelSize: 10
            font.weight: Font.Medium
            color: Config.inactiveColor
            font.letterSpacing: 1
        }

        ListView {
            id: availableList
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(contentHeight, 100)
            visible: availableDevices.length > 0
            clip: true
            spacing: 4

            model: btPanel.availableDevices

            delegate: Rectangle {
                width: availableList.width
                height: 44
                radius: 10
                color: availMa.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"

                RowLayout {
                    anchors {
                        fill: parent
                        margins: 10
                    }
                    spacing: 10

                    Text {
                        text: "󰂱"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 16
                        color: Config.inactiveColor
                    }

                    Text {
                        Layout.fillWidth: true
                        text: modelData.name
                        font.family: Config.fontFamily
                        font.pixelSize: 13
                        color: Config.panelForeground
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    id: availMa
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: connectDevice(modelData.mac)
                }
            }
        }

        // Empty state
        Text {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            visible: pairedDevices.length === 0 && !scanning
            text: "No paired devices"
            font.family: Config.fontFamily
            font.pixelSize: 13
            color: Config.inactiveColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        // Scanning indicator
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            visible: scanning
            spacing: 8

            Text {
                text: "󰑓"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 14
                color: Config.inactiveColor
                rotation: 360

                RotationAnimation on rotation {
                    duration: 1000
                    loops: Animation.Infinite
                    running: scanning
                }
            }

            Text {
                text: "Scanning for devices..."
                font.family: Config.fontFamily
                font.pixelSize: 13
                color: Config.inactiveColor
            }
        }

        // Settings button
        Rectangle {
            Layout.fillWidth: true
            height: 40
            radius: 10
            color: settingsMa.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : Config.ccSliderBackground

            RowLayout {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    text: "󰒓"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 14
                    color: Config.panelForeground
                }

                Text {
                    text: "Bluetooth Settings..."
                    font.family: Config.fontFamily
                    font.pixelSize: 12
                    color: Config.panelForeground
                }
            }

            MouseArea {
                id: settingsMa
                anchors.fill: parent
                hoverEnabled: true
                onClicked: BluetoothService.openSettings()
            }
        }
    }
}
