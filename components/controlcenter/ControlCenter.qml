import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../.."
import "../../services"

// iOS-style Control Center popup
PanelWindow {
    id: controlCenter

    property bool expanded: false

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

        // Top row: Connectivity module + Audio controls
        RowLayout {
            Layout.fillWidth: true
            spacing: Config.ccModuleSpacing

            // Connectivity module (WiFi, Bluetooth, etc.)
            ConnectivityModule {
                Layout.preferredWidth: (Config.ccWidth - Config.ccPadding * 2 - Config.ccModuleSpacing) / 2
                Layout.preferredHeight: 120
            }

            // Media/Quick controls
            ColumnLayout {
                Layout.preferredWidth: (Config.ccWidth - Config.ccPadding * 2 - Config.ccModuleSpacing) / 2
                Layout.preferredHeight: 120
                spacing: 8

                // Do Not Disturb
                CCToggleSmall {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    icon: "󰍶"
                    label: "Focus"
                    active: false
                    onClicked: active = !active
                }

                // Night Light / Dark Mode
                CCToggleSmall {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    icon: "󰌶"
                    label: "Night Light"
                    active: false
                    onClicked: {
                        active = !active
                        // Toggle redshift/gammastep
                    }
                }
            }
        }

        // Brightness and Volume sliders row
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 160
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

        // Expandable WiFi panel (when expanded)
        Loader {
            id: wifiPanelLoader
            Layout.fillWidth: true
            active: wifiExpanded
            visible: active
            sourceComponent: WifiPanel {
                onClose: wifiExpanded = false
            }
        }

        // Expandable Bluetooth panel (when expanded)
        Loader {
            id: btPanelLoader
            Layout.fillWidth: true
            active: btExpanded
            visible: active
            sourceComponent: BluetoothPanel {
                onClose: btExpanded = false
            }
        }
    }

    // State tracking for expandable panels
    property bool wifiExpanded: false
    property bool btExpanded: false

    function toggle() {
        expanded = !expanded
        if (!expanded) {
            wifiExpanded = false
            btExpanded = false
        }
    }

    function close() {
        expanded = false
        wifiExpanded = false
        btExpanded = false
    }
}
