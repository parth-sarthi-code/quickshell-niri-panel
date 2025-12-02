import QtQuick
import QtQuick.Layouts
import ".."
import "../services"

// Network/WiFi indicator
Item {
    id: networkIndicator

    implicitWidth: row.implicitWidth
    implicitHeight: Config.panelHeight

    property bool connected: NetworkService.connected
    property string type: NetworkService.type
    property int strength: NetworkService.strength

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 4

        // Network icon
        Text {
            text: {
                if (!connected || type === "none") return "󰤭" // disconnected
                if (type === "ethernet") return "󰈀" // ethernet
                // WiFi with signal strength
                if (strength < 25) return "󰤟" // weak
                if (strength < 50) return "󰤢" // fair
                if (strength < 75) return "󰤥" // good
                return "󰤨" // excellent
            }
            font.family: "Symbols Nerd Font, JetBrainsMono Nerd Font, Font Awesome 6 Free"
            font.pixelSize: Config.iconSize
            color: connected ? Config.panelForeground : Config.inactiveColor
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
            // Open Control Center (root is ShellRoot from shell.qml)
            if (root.controlCenter) {
                root.controlCenter.toggle()
            }
        }
    }

    // Tooltip
    ToolTip {
        visible: mouseArea.containsMouse
        text: {
            if (!connected) return "Not connected"
            if (type === "ethernet") return "Ethernet: " + NetworkService.ssid
            return "WiFi: " + NetworkService.ssid + " (" + strength + "%)"
        }
    }
}
