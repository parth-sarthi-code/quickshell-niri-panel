import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../.."
import "../../services"

// iOS-style Control Center popup
PanelWindow {
    id: controlCenter

    property bool expanded: false
    property string powerProfile: "balanced" // power-saver, balanced, performance

    visible: expanded
    screen: Quickshell.screens[0]
    
    // Positioning: top-right corner, below panel
    anchors {
        top: true
        right: true
    }
    margins {
        top: Config.panelHeight + 8
        right: 12
    }

    implicitWidth: Config.ccWidth
    implicitHeight: contentColumn.implicitHeight + Config.ccPadding * 2

    color: "transparent"

    // Click outside to close
    WlrLayershell.namespace: "quickshell-controlcenter"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: expanded ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // Power profile management using tuned-adm
    Process {
        id: getPowerProfile
        command: ["tuned-adm", "active"]
        stdout: SplitParser {
            onRead: function(line) {
                // Output: "Current active profile: balanced"
                if (line.includes("profile:")) {
                    let profile = line.split(":")[1].trim()
                    // Map tuned profiles to our 3 modes
                    if (profile.includes("powersave") || profile.includes("battery") || profile === "laptop-battery-powersave") {
                        controlCenter.powerProfile = "power-saver"
                    } else if (profile.includes("performance") || profile === "throughput-performance" || profile === "latency-performance") {
                        controlCenter.powerProfile = "performance"
                    } else {
                        controlCenter.powerProfile = "balanced"
                    }
                }
            }
        }
    }

    // Separate processes for each power profile using tuned-adm
    Process {
        id: setPowerSaver
        command: ["tuned-adm", "profile", "laptop-battery-powersave"]
        onExited: getPowerProfile.running = true
    }

    Process {
        id: setBalanced
        command: ["tuned-adm", "profile", "balanced"]
        onExited: getPowerProfile.running = true
    }

    Process {
        id: setPerformance
        command: ["tuned-adm", "profile", "throughput-performance"]
        onExited: getPowerProfile.running = true
    }

    function setPowerProfile(profile) {
        if (profile === "power-saver") {
            setPowerSaver.running = true
        } else if (profile === "performance") {
            setPerformance.running = true
        } else {
            setBalanced.running = true
        }
    }

    // Screenshot process
    Process {
        id: screenshotProc
        command: ["sh", "-c", "grimblast copy area 2>/dev/null || grim -g \"$(slurp)\" - | wl-copy 2>/dev/null || gnome-screenshot -a"]
    }

    // Screen lock process
    Process {
        id: lockProc
        command: ["sh", "-c", "swaylock 2>/dev/null || hyprlock 2>/dev/null || loginctl lock-session"]
    }

    Component.onCompleted: getPowerProfile.running = true

    // Main background
    Rectangle {
        id: background
        anchors.fill: parent
        color: Config.ccBackground
        opacity: Config.ccBackgroundOpacity
        radius: Config.ccModuleRadius + 4

        // Blur effect simulation with gradient
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.08) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
    }

    // Border for glassmorphism
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        radius: Config.ccModuleRadius + 4
        border.color: Qt.rgba(1, 1, 1, 0.15)
        border.width: 1
    }

    // Content
    ColumnLayout {
        id: contentColumn
        anchors {
            fill: parent
            margins: Config.ccPadding
        }
        spacing: Config.ccModuleSpacing

        // Top row: Brightness/Volume sliders (half width each)
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            spacing: Config.ccModuleSpacing

            // Brightness slider
            CCSlider {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: BrightnessService.brightness > 70 ? "󰃠" : (BrightnessService.brightness > 30 ? "󰃟" : "󰃞")
                value: BrightnessService.brightness
                onSliderMoved: function(val) {
                    BrightnessService.setBrightness(val)
                }
            }

            // Volume slider
            CCSlider {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: AudioService.muted ? "󰖁" : (AudioService.volume > 50 ? "󰕾" : (AudioService.volume > 0 ? "󰖀" : "󰕿"))
                value: AudioService.muted ? 0 : AudioService.volume
                onSliderMoved: function(val) {
                    AudioService.setVolume(val)
                }
                onIconClicked: AudioService.toggleMute()
            }
        }

        // Power Profile Selector (3 options)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            radius: Config.ccModuleRadius
            color: Config.ccModuleBackground

            RowLayout {
                anchors {
                    fill: parent
                    margins: 6
                }
                spacing: 6

                // Power Saver
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Config.ccModuleRadius - 4
                    color: powerProfile === "power-saver" ? Config.ccModuleActiveBackground : "transparent"

                    Behavior on color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: "󰌪"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 14
                            color: powerProfile === "power-saver" ? Config.panelForeground : Config.inactiveColor
                        }

                        Text {
                            text: "Saver"
                            font.family: Config.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: powerProfile === "power-saver" ? Config.panelForeground : Config.inactiveColor
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            controlCenter.setPowerProfile("power-saver")
                        }
                    }
                }

                // Balanced
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Config.ccModuleRadius - 4
                    color: powerProfile === "balanced" ? Config.ccModuleActiveBackground : "transparent"

                    Behavior on color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: "󰗑"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 14
                            color: powerProfile === "balanced" ? Config.panelForeground : Config.inactiveColor
                        }

                        Text {
                            text: "Balanced"
                            font.family: Config.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: powerProfile === "balanced" ? Config.panelForeground : Config.inactiveColor
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            controlCenter.setPowerProfile("balanced")
                        }
                    }
                }

                // Performance
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Config.ccModuleRadius - 4
                    color: powerProfile === "performance" ? Config.ccModuleActiveBackground : "transparent"

                    Behavior on color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: "󱐋"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 14
                            color: powerProfile === "performance" ? Config.panelForeground : Config.inactiveColor
                        }

                        Text {
                            text: "Perf"
                            font.family: Config.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: powerProfile === "performance" ? Config.panelForeground : Config.inactiveColor
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            controlCenter.setPowerProfile("performance")
                        }
                    }
                }
            }
        }

        // Quick Actions Row (Screenshot, Screen Lock, Focus, Night Light)
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            spacing: Config.ccModuleSpacing

            // Screenshot
            CCQuickAction {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: "󰹑"
                label: "Screenshot"
                onClicked: {
                    controlCenter.close()
                    Qt.callLater(function() { screenshotProc.running = true })
                }
            }

            // Screen Lock
            CCQuickAction {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: "󰌾"
                label: "Lock"
                onClicked: {
                    controlCenter.close()
                    lockProc.running = true
                }
            }

            // Focus / DND
            CCQuickAction {
                id: focusBtn
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: "󰍶"
                label: "Focus"
                active: false
                onClicked: active = !active
            }

            // Night Light
            CCQuickAction {
                id: nightLightBtn
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: "󰌶"
                label: "Night"
                active: false
                onClicked: active = !active
            }
        }
    }

    function toggle() {
        expanded = !expanded
        if (expanded) {
            getPowerProfile.running = true
        }
    }

    function close() {
        expanded = false
    }
}
