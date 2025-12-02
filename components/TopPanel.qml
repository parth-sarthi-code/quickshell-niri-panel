import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import ".."

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

    // Left section - App launcher / focused app
    RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        spacing: Config.itemSpacing

        AppLauncher {}
        FocusedApp {}
    }

    // Right section - Status icons and clock (clickable for Control Center)
    Rectangle {
        id: rightSection
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        width: statusRow.width + 12
        height: Config.panelHeight - 4
        radius: 8
        color: statusMa.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"

        Behavior on color {
            ColorAnimation { duration: 100 }
        }

        RowLayout {
            id: statusRow
            anchors.centerIn: parent
            spacing: Config.itemSpacing

            NetworkIndicator {}
            BluetoothIndicator {}
            BatteryIndicator {}
            
            // Separator
            Rectangle {
                width: 1
                height: Config.panelHeight - 12
                color: Qt.rgba(1, 1, 1, 0.2)
                Layout.alignment: Qt.AlignVCenter
            }

            Clock {}
        }

        MouseArea {
            id: statusMa
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                if (root.controlCenter) {
                    root.controlCenter.toggle()
                }
            }
        }
    }
}
