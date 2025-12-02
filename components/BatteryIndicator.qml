import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."
import "../services"

// Battery indicator with icon and percentage
Item {
    id: root

    implicitWidth: row.implicitWidth
    implicitHeight: Config.panelHeight

    visible: BatteryService.available

    property real percentage: BatteryService.percentage
    property bool charging: BatteryService.charging
    property bool isLow: BatteryService.isLow
    property bool isCritical: BatteryService.isCritical

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 4

        // Battery icon
        Text {
            text: {
                let pct = Math.round(percentage * 100)
                if (charging) {
                    return "󰂄" // charging
                }
                if (pct >= 90) return "󰁹"
                if (pct >= 80) return "󰂂"
                if (pct >= 70) return "󰂁"
                if (pct >= 60) return "󰂀"
                if (pct >= 50) return "󰁿"
                if (pct >= 40) return "󰁾"
                if (pct >= 30) return "󰁽"
                if (pct >= 20) return "󰁼"
                if (pct >= 10) return "󰁻"
                return "󰁺" // empty
            }
            font.family: "Symbols Nerd Font, JetBrainsMono Nerd Font, Font Awesome 6 Free"
            font.pixelSize: Config.iconSize
            color: {
                if (charging) return Config.successColor
                if (isCritical) return Config.urgentColor
                if (isLow) return Config.warningColor
                return Config.panelForeground
            }
            Layout.alignment: Qt.AlignVCenter
        }

        // Percentage text
        Text {
            text: Math.round(percentage * 100) + "%"
            font.family: Config.fontFamily
            font.pixelSize: Config.fontSizeSmall
            color: {
                if (charging) return Config.successColor
                if (isCritical) return Config.urgentColor
                if (isLow) return Config.warningColor
                return Config.panelForeground
            }
            Layout.alignment: Qt.AlignVCenter
        }
    }

    Rectangle {
        id: hoverBg
        anchors.fill: parent
        anchors.margins: 2
        radius: Config.borderRadius
        color: Config.hoverColor
        opacity: mouseArea.containsMouse ? 1 : 0
        z: -1
        
        Behavior on opacity {
            NumberAnimation { duration: 100 }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            // Open power settings
            Qt.callLater(function() {
                powerSettingsProc.running = true
            })
        }
    }

    Process {
        id: powerSettingsProc
        command: ["sh", "-c", "gnome-control-center power || kde-open5 settings5://powerdevil || xfce4-power-manager-settings"]
    }

    // Tooltip
    ToolTip {
        visible: mouseArea.containsMouse
        text: BatteryService.getStatusText()
    }
}
