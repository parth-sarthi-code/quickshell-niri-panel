import QtQuick
import QtQuick.Layouts
import ".."
import "../services"

// Bluetooth indicator
Item {
    id: root

    implicitWidth: row.implicitWidth
    implicitHeight: Config.panelHeight

    property bool powered: BluetoothService.powered
    property bool connected: BluetoothService.connected
    property int deviceCount: BluetoothService.connectedDevices

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 4

        // Bluetooth icon
        Text {
            text: {
                if (!powered) return "󰂲" // off
                if (connected) return "󰂱" // connected
                return "󰂯" // on but not connected
            }
            font.family: "Symbols Nerd Font, JetBrainsMono Nerd Font, Font Awesome 6 Free"
            font.pixelSize: Config.iconSize
            color: {
                if (!powered) return Config.inactiveColor
                if (connected) return Config.accentColor
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
        
        Behavior on opacity {
            NumberAnimation { duration: 100 }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                BluetoothService.togglePower()
            } else {
                BluetoothService.openSettings()
            }
        }
    }

    // Tooltip
    ToolTip {
        visible: mouseArea.containsMouse
        text: {
            if (!powered) return "Bluetooth Off"
            if (connected) return "Connected: " + BluetoothService.deviceName + 
                (deviceCount > 1 ? " (+" + (deviceCount - 1) + " more)" : "")
            return "Bluetooth On"
        }
    }
}
