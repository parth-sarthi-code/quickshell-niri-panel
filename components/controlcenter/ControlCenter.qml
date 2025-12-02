import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../.."
import "../../services"

// Optimized GNOME/macOS-style Control Center
PanelWindow {
    id: cc

    property bool expanded: false
    property string powerProfile: "balanced"
    property bool airplaneMode: false
    property bool nightLightActive: false
    property bool showStatsInPanel: false

    // System stats
    property int cpuUsage: 0
    property int cpuTemp: 0
    property int ramUsage: 0
    property int ramTotal: 0

    visible: expanded
    screen: Quickshell.screens[0]
    
    anchors {
        top: true
        right: true
    }
    margins {
        top: Config.panelHeight + 8
        right: 12
    }

    implicitWidth: Config.ccWidth
    implicitHeight: contentCol.implicitHeight + Config.ccPadding * 2
    color: "transparent"

    WlrLayershell.namespace: "quickshell-controlcenter"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Single process for power profile
    Process {
        id: powerProc
        property string action: "get"
        command: action === "get" 
            ? ["tuned-adm", "active"]
            : ["tuned-adm", "profile", action]
        stdout: SplitParser {
            onRead: function(line) {
                if (powerProc.action !== "get" || !line.includes("profile:")) return
                let p = line.split(":")[1].trim()
                cc.powerProfile = p.includes("powersave") || p.includes("battery") ? "power-saver"
                    : p.includes("performance") ? "performance" : "balanced"
            }
        }
    }

    function setPowerProfile(profile) {
        powerProfile = profile
        powerProc.action = profile === "power-saver" ? "laptop-battery-powersave"
            : profile === "performance" ? "throughput-performance" : "balanced"
        powerProc.running = true
    }

    function toggleAirplaneMode() {
        airplaneMode = !airplaneMode
        if (airplaneMode) {
            if (NetworkService.wifiEnabled) NetworkService.toggleWifi()
            if (BluetoothService.powered) BluetoothService.togglePower()
        } else if (!NetworkService.wifiEnabled) {
            NetworkService.toggleWifi()
        }
    }

    // CPU usage tracking (needs delta calculation)
    property real _prevCpuIdle: 0
    property real _prevCpuTotal: 0

    // Consolidated stats process - CPU needs proper delta calculation
    Process {
        id: statsProc
        command: ["sh", "-c", "head -1 /proc/stat; cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0; awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {printf \"%d %d\\n\", ((t-a)/t)*100, t/1024/1024}' /proc/meminfo"]
        property int lineNum: 0
        stdout: SplitParser {
            onRead: function(line) {
                let v = line.trim()
                if (statsProc.lineNum === 0) {
                    // Parse CPU line: cpu user nice system idle iowait irq softirq
                    let parts = v.split(/\s+/)
                    if (parts[0] === "cpu") {
                        let user = parseFloat(parts[1]) || 0
                        let nice = parseFloat(parts[2]) || 0
                        let system = parseFloat(parts[3]) || 0
                        let idle = parseFloat(parts[4]) || 0
                        let iowait = parseFloat(parts[5]) || 0
                        let irq = parseFloat(parts[6]) || 0
                        let softirq = parseFloat(parts[7]) || 0
                        
                        let total = user + nice + system + idle + iowait + irq + softirq
                        let idleTime = idle + iowait
                        
                        if (cc._prevCpuTotal > 0) {
                            let totalDelta = total - cc._prevCpuTotal
                            let idleDelta = idleTime - cc._prevCpuIdle
                            if (totalDelta > 0) {
                                cc.cpuUsage = Math.round(100 * (1 - idleDelta / totalDelta))
                            }
                        }
                        cc._prevCpuTotal = total
                        cc._prevCpuIdle = idleTime
                    }
                } else if (statsProc.lineNum === 1) {
                    cc.cpuTemp = Math.round(parseInt(v) / 1000) || 0
                } else {
                    let p = v.split(" ")
                    cc.ramUsage = parseInt(p[0]) || 0
                    cc.ramTotal = parseInt(p[1]) || 0
                }
                statsProc.lineNum++
            }
        }
        onStarted: lineNum = 0
    }

    Timer {
        interval: cc.expanded ? 3000 : 7000
        running: cc.expanded || cc.showStatsInPanel
        repeat: true
        triggeredOnStart: true
        onTriggered: statsProc.running = true
    }

    // Night light
    Process {
        id: nightProc
        property bool turnOn: false
        command: turnOn 
            ? ["sh", "-c", "pkill gammastep 2>/dev/null; sleep 0.2; gammastep -P -O 4500 &"]
            : ["sh", "-c", "pkill gammastep 2>/dev/null; sleep 0.2; gammastep -x 2>/dev/null"]
    }

    function toggleNightLight() {
        nightLightActive = !nightLightActive
        nightProc.turnOn = nightLightActive
        nightProc.running = true
    }

    Process {
        id: lockProc
        command: ["sh", "-c", "swaylock 2>/dev/null || hyprlock 2>/dev/null || loginctl lock-session"]
    }

    Component.onCompleted: {
        powerProc.action = "get"
        powerProc.running = true
    }

    // Background
    Rectangle {
        anchors.fill: parent
        color: Config.ccBackground
        opacity: Config.ccBackgroundOpacity
        radius: Config.ccModuleRadius + 4

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.08) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        radius: Config.ccModuleRadius + 4
        border.color: Qt.rgba(1, 1, 1, 0.15)
        border.width: 1
    }

    // Content
    ColumnLayout {
        id: contentCol
        anchors.fill: parent
        anchors.margins: Config.ccPadding
        spacing: Config.ccModuleSpacing

        // Quick Toggles
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            radius: Config.ccModuleRadius
            color: Config.ccModuleBackground

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                CCToggle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    icon: NetworkService.wifiEnabled ? (NetworkService.connected ? "󰤨" : "󰤯") : "󰤮"
                    label: "Wi-Fi"
                    subtitle: NetworkService.wifiEnabled && NetworkService.connected ? NetworkService.ssid : (NetworkService.wifiEnabled ? "On" : "Off")
                    active: NetworkService.wifiEnabled
                    onClicked: if (!airplaneMode) NetworkService.toggleWifi()
                }

                CCToggle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    icon: BluetoothService.powered ? (BluetoothService.connected ? "󰂱" : "󰂯") : "󰂲"
                    label: "Bluetooth"
                    subtitle: BluetoothService.powered ? (BluetoothService.connected ? BluetoothService.deviceName : "On") : "Off"
                    active: BluetoothService.powered
                    onClicked: if (!airplaneMode) BluetoothService.togglePower()
                }

                CCToggle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    icon: airplaneMode ? "󰀝" : "󰀞"
                    label: "Airplane"
                    subtitle: airplaneMode ? "On" : "Off"
                    active: airplaneMode
                    onClicked: toggleAirplaneMode()
                }
            }
        }

        // Stats + Sliders
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            spacing: Config.ccModuleSpacing

            // Stats Box
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: showStatsInPanel ? "#3a3a3c" : Config.ccModuleBackground
                radius: Config.ccModuleRadius
                Behavior on color { ColorAnimation { duration: 150 } }

                MouseArea {
                    anchors.fill: parent
                    onClicked: cc.showStatsInPanel = !cc.showStatsInPanel
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    // CPU Row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "󰻠"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 16
                            color: cpuUsage > 80 ? Config.urgentColor : Config.accentColor
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: "CPU"
                                font.family: Config.fontFamily
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                color: Config.inactiveColor
                            }

                            RowLayout {
                                spacing: 8

                                Text {
                                    text: cpuUsage + "%"
                                    font.family: Config.fontFamily
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                    color: cpuUsage > 80 ? Config.urgentColor : Config.panelForeground
                                }

                                Text {
                                    text: cpuTemp + "°C"
                                    font.family: Config.fontFamily
                                    font.pixelSize: 12
                                    color: cpuTemp > 80 ? Config.urgentColor : Config.inactiveColor
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Qt.rgba(1, 1, 1, 0.1)
                    }

                    // RAM Row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "󰍛"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 16
                            color: ramUsage > 80 ? Config.urgentColor : Config.accentColor
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: "RAM"
                                font.family: Config.fontFamily
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                color: Config.inactiveColor
                            }

                            RowLayout {
                                spacing: 4

                                Text {
                                    text: ramUsage + "%"
                                    font.family: Config.fontFamily
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                    color: ramUsage > 80 ? Config.urgentColor : Config.panelForeground
                                }

                                Text {
                                    text: "/ " + ramTotal + "GB"
                                    font.family: Config.fontFamily
                                    font.pixelSize: 11
                                    color: Config.inactiveColor
                                }
                            }
                        }
                    }
                }
            }

            CCSlider {
                Layout.preferredWidth: Config.ccSliderWidth
                Layout.fillHeight: true
                icon: BrightnessService.brightness > 70 ? "󰃠" : (BrightnessService.brightness > 30 ? "󰃟" : "󰃞")
                value: BrightnessService.brightness
                onSliderMoved: function(val) { BrightnessService.setBrightness(val) }
            }

            CCSlider {
                Layout.preferredWidth: Config.ccSliderWidth
                Layout.fillHeight: true
                icon: AudioService.muted ? "󰖁" : (AudioService.volume > 50 ? "󰕾" : (AudioService.volume > 0 ? "󰖀" : "󰕿"))
                value: AudioService.muted ? 0 : AudioService.volume
                onSliderMoved: function(val) { AudioService.setVolume(val) }
                onIconClicked: AudioService.toggleMute()
            }
        }

        // Power Profiles
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            radius: Config.ccModuleRadius
            color: Config.ccModuleBackground

            RowLayout {
                anchors.fill: parent
                anchors.margins: 6
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
                            color: powerProfile === "power-saver" ? Config.panelForeground : "#bbbbbb"
                        }

                        Text {
                            text: "Saver"
                            font.family: Config.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: powerProfile === "power-saver" ? Config.panelForeground : "#bbbbbb"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: cc.setPowerProfile("power-saver")
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
                            color: powerProfile === "balanced" ? Config.panelForeground : "#bbbbbb"
                        }

                        Text {
                            text: "Balanced"
                            font.family: Config.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: powerProfile === "balanced" ? Config.panelForeground : "#bbbbbb"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: cc.setPowerProfile("balanced")
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
                            color: powerProfile === "performance" ? Config.panelForeground : "#bbbbbb"
                        }

                        Text {
                            text: "Perf"
                            font.family: Config.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: powerProfile === "performance" ? Config.panelForeground : "#bbbbbb"
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: cc.setPowerProfile("performance")
                    }
                }
            }
        }

        // Bottom Row
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            spacing: Config.ccModuleSpacing

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Config.ccModuleRadius
                color: nightLightActive ? "#cc8800" : Config.ccModuleBackground  // Warm amber when active
                Behavior on color { ColorAnimation { duration: 150 } }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: "󰌶"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 18
                        color: nightLightActive ? "#fff5e0" : Config.inactiveColor  // Warm white when active
                    }

                    Text {
                        text: "Night Light"
                        font.family: Config.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: nightLightActive ? "#fff5e0" : Config.panelForeground  // Warm white when active
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: toggleNightLight()
                }
            }

            Rectangle {
                Layout.preferredWidth: 50
                Layout.fillHeight: true
                radius: Config.ccModuleRadius
                color: lockMa.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Config.ccModuleBackground
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text: "󰌾"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 20
                    color: Config.panelForeground
                }

                MouseArea {
                    id: lockMa
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        cc.close()
                        lockProc.running = true
                    }
                }
            }
        }
    }

    function toggle() {
        expanded = !expanded
        if (expanded) {
            powerProc.action = "get"
            powerProc.running = true
        }
    }

    function close() {
        expanded = false
    }
}
