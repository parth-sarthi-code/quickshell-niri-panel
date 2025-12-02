import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import ".."
import "../services"

PanelWindow {
    id: panel

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Config.panelHeight
    color: "transparent"

    // Semi-transparent background with blur effect feel
    Rectangle {
        id: panelBackground
        anchors.fill: parent
        color: Config.panelBackground
        opacity: Config.panelOpacity

        // Subtle bottom border
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: Qt.rgba(1, 1, 1, 0.1)
        }
    }

    // Center section - Workspaces (absolutely centered)
    WorkspaceIndicator {
        anchors.centerIn: parent
    }

    // Left section - Focused app + Network speed toggle + Network speeds
    RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        spacing: Config.itemSpacing

        FocusedApp {}

        // Network Speed Toggle Icon (clickable) - hidden when speeds are shown
        Rectangle {
            visible: !NetworkSpeedService.enabled
            width: 24
            height: 24
            radius: 4
            color: netSpeedMa.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

            Text {
                anchors.centerIn: parent
                text: "󰒍"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 16
                color: Config.inactiveColor
            }

            MouseArea {
                id: netSpeedMa
                anchors.fill: parent
                hoverEnabled: true
                onClicked: NetworkSpeedService.enabled = true
            }
        }

        // Network Speed Display (when enabled) - clickable to disable
        RowLayout {
            visible: NetworkSpeedService.enabled
            spacing: 6

            // Separator before speeds
            Rectangle {
                width: 1
                height: Config.panelHeight - 14
                color: Qt.rgba(1, 1, 1, 0.15)
            }

            // Clickable speed display area
            Rectangle {
                color: netSpeedAreaMa.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                radius: 4
                implicitWidth: speedRow.implicitWidth + 8
                implicitHeight: speedRow.implicitHeight + 4

                Row {
                    id: speedRow
                    anchors.centerIn: parent
                    spacing: 10

                    // Download
                    Row {
                        spacing: 3
                        Text {
                            text: "↓"
                            font.family: Config.fontFamily
                            font.pixelSize: 14
                            color: Config.panelForeground
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: NetworkSpeedService.downloadText
                            font.family: Config.fontFamily
                            font.pixelSize: Config.fontSize
                            font.weight: Font.Medium
                            color: Config.panelForeground
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // Upload
                    Row {
                        spacing: 3
                        Text {
                            text: "↑"
                            font.family: Config.fontFamily
                            font.pixelSize: 14
                            color: Config.panelForeground
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: NetworkSpeedService.uploadText
                            font.family: Config.fontFamily
                            font.pixelSize: Config.fontSize
                            font.weight: Font.Medium
                            color: Config.panelForeground
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                MouseArea {
                    id: netSpeedAreaMa
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: NetworkSpeedService.enabled = false
                }
            }
        }
    }

    // Right section - Status icons, CC trigger, and clock
    RowLayout {
        id: rightSection
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        // Status indicators (conditional visibility)
        RowLayout {
            spacing: Config.itemSpacing

            // System stats (when enabled)
            RowLayout {
                visible: root.controlCenter && root.controlCenter.showStatsInPanel
                spacing: 8

                // CPU
                Row {
                    spacing: 4
                    Text {
                        text: "󰻠"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 16
                        color: root.controlCenter && root.controlCenter.cpuUsage > 80 ? Config.urgentColor : Config.accentColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: (root.controlCenter ? root.controlCenter.cpuUsage : 0) + "%"
                        font.family: Config.fontFamily
                        font.pixelSize: Config.fontSize
                        font.weight: Font.Medium
                        color: Config.panelForeground
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Temp (more visible)
                Row {
                    spacing: 3
                    Text {
                        text: "󰔏"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 14
                        color: root.controlCenter && root.controlCenter.cpuTemp > 80 ? Config.urgentColor : Config.warningColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: (root.controlCenter ? root.controlCenter.cpuTemp : 0) + "°"
                        font.family: Config.fontFamily
                        font.pixelSize: Config.fontSize
                        font.weight: Font.Medium
                        color: root.controlCenter && root.controlCenter.cpuTemp > 80 ? Config.urgentColor : Config.panelForeground
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // RAM
                Row {
                    spacing: 4
                    Text {
                        text: "󰍛"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 16
                        color: root.controlCenter && root.controlCenter.ramUsage > 80 ? Config.urgentColor : Config.accentColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: (root.controlCenter ? root.controlCenter.ramUsage : 0) + "%"
                        font.family: Config.fontFamily
                        font.pixelSize: Config.fontSize
                        font.weight: Font.Medium
                        color: Config.panelForeground
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Separator after stats
                Rectangle {
                    width: 1
                    height: Config.panelHeight - 14
                    color: Qt.rgba(1, 1, 1, 0.15)
                }
            }

            // Airplane mode indicator
            Text {
                visible: root.controlCenter && root.controlCenter.airplaneMode
                text: "󰀝"
                font.family: "Symbols Nerd Font"
                font.pixelSize: Config.iconSize
                color: Config.warningColor
            }

            // Night light indicator
            Text {
                visible: root.controlCenter && root.controlCenter.nightLightActive
                text: "󰌶"
                font.family: "Symbols Nerd Font"
                font.pixelSize: Config.iconSize
                color: "#FFB347" // Warm orange color
            }

            NetworkIndicator {
                visible: networkService.connected
            }
            BluetoothIndicator {
                visible: bluetoothService.powered
            }
            BatteryIndicator {}
        }

        // CC Trigger button (macOS-style)
        Rectangle {
            id: ccTrigger
            width: 36
            height: Config.panelHeight - 6
            radius: height / 2
            color: ccTriggerMa.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.08)

            Behavior on color {
                ColorAnimation { duration: 100 }
            }

            Text {
                anchors.centerIn: parent
                text: "󰍜"  // hamburger menu / settings icon
                font.family: "Symbols Nerd Font"
                font.pixelSize: 16
                color: Config.panelForeground
            }

            MouseArea {
                id: ccTriggerMa
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    if (root.controlCenter) {
                        root.controlCenter.toggle()
                    }
                }
            }
        }

        // Separator
        Rectangle {
            width: 1
            height: Config.panelHeight - 12
            color: Qt.rgba(1, 1, 1, 0.2)
            Layout.alignment: Qt.AlignVCenter
        }

        // Clock
        Clock {}
    }

    // Service references for conditional visibility
    property var networkService: NetworkService
    property var bluetoothService: BluetoothService
}
