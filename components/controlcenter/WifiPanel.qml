import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../.."
import "../../services"

// Expandable WiFi networks panel
Rectangle {
    id: wifiPanel

    signal close()

    implicitHeight: column.implicitHeight + 20
    color: Config.ccModuleBackground
    radius: Config.ccModuleRadius

    property var networks: []
    property bool scanning: false

    Component.onCompleted: scanNetworks()

    // Scan for networks
    Process {
        id: scanProc
        command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY,IN-USE", "dev", "wifi", "list", "--rescan", "auto"]
        stdout: SplitParser {
            onRead: function(line) {
                let parts = line.split(":")
                if (parts.length >= 4 && parts[0].trim()) {
                    let network = {
                        ssid: parts[0],
                        signal: parseInt(parts[1]) || 0,
                        security: parts[2] || "Open",
                        connected: parts[3] === "*"
                    }
                    // Avoid duplicates
                    let exists = wifiPanel.networks.some(function(n) { return n.ssid === network.ssid })
                    if (!exists) {
                        let newList = wifiPanel.networks.slice()
                        newList.push(network)
                        wifiPanel.networks = newList
                    }
                }
            }
        }
        onStarted: {
            wifiPanel.networks = []
            wifiPanel.scanning = true
        }
        onExited: wifiPanel.scanning = false
    }

    Process {
        id: connectProc
        property string ssid: ""
        command: ["nmcli", "dev", "wifi", "connect", ssid]
        onExited: function(code) {
            if (code === 0) {
                NetworkService.updateNetwork()
            }
            scanNetworks()
        }
    }

    function scanNetworks() {
        scanProc.running = true
    }

    function connectToNetwork(ssid) {
        connectProc.ssid = ssid
        connectProc.running = true
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
                text: "󰤨"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 18
                color: Config.accentColor
            }

            Text {
                Layout.fillWidth: true
                text: "Wi-Fi Networks"
                font.family: Config.fontFamily
                font.pixelSize: 14
                font.weight: Font.Medium
                color: Config.panelForeground
            }

            // Refresh button
            Rectangle {
                width: 28
                height: 28
                radius: 14
                color: refreshMa.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

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
                    id: refreshMa
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: scanNetworks()
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
                    onClicked: wifiPanel.close()
                }
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(1, 1, 1, 0.1)
        }

        // Network list
        ListView {
            id: networkList
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(contentHeight, 200)
            clip: true
            spacing: 4

            model: wifiPanel.networks.sort((a, b) => b.signal - a.signal)

            delegate: Rectangle {
                width: networkList.width
                height: 44
                radius: 10
                color: itemMa.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"

                RowLayout {
                    anchors {
                        fill: parent
                        margins: 10
                    }
                    spacing: 10

                    // Signal strength icon
                    Text {
                        text: modelData.signal > 75 ? "󰤨" : (modelData.signal > 50 ? "󰤥" : (modelData.signal > 25 ? "󰤢" : "󰤟"))
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 16
                        color: modelData.connected ? Config.accentColor : Config.inactiveColor
                    }

                    // SSID and security
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            Layout.fillWidth: true
                            text: modelData.ssid
                            font.family: Config.fontFamily
                            font.pixelSize: 13
                            font.weight: modelData.connected ? Font.Medium : Font.Normal
                            color: modelData.connected ? Config.accentColor : Config.panelForeground
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.connected ? "Connected" : (modelData.security !== "--" && modelData.security !== "" ? "🔒 " + modelData.security : "Open")
                            font.family: Config.fontFamily
                            font.pixelSize: 10
                            color: Config.inactiveColor
                            elide: Text.ElideRight
                        }
                    }

                    // Connect indicator
                    Text {
                        visible: modelData.connected
                        text: "󰄬"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 16
                        color: Config.accentColor
                    }
                }

                MouseArea {
                    id: itemMa
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (!modelData.connected) {
                            connectToNetwork(modelData.ssid)
                        }
                    }
                }
            }
        }

        // Empty state
        Text {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            visible: networks.length === 0 && !scanning
            text: "No networks found"
            font.family: Config.fontFamily
            font.pixelSize: 13
            color: Config.inactiveColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        // Scanning indicator
        Text {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            visible: scanning && networks.length === 0
            text: "Scanning..."
            font.family: Config.fontFamily
            font.pixelSize: 13
            color: Config.inactiveColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
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
                    text: "Wi-Fi Settings..."
                    font.family: Config.fontFamily
                    font.pixelSize: 12
                    color: Config.panelForeground
                }
            }

            MouseArea {
                id: settingsMa
                anchors.fill: parent
                hoverEnabled: true
                onClicked: NetworkService.openSettings()
            }
        }
    }
}
