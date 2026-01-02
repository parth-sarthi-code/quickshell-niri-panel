import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."

// App launcher icon (like Apple logo in macOS)
Item {
    id: root
    
    implicitWidth: Config.panelHeight - 4
    implicitHeight: Config.panelHeight - 4

    Rectangle {
        id: background
        anchors.fill: parent
        anchors.margins: 2
        radius: Config.borderRadius
        color: mouseArea.containsMouse ? Config.hoverColor : "transparent"

        // Simple app grid icon (macOS Launchpad style)
        Grid {
            anchors.centerIn: parent
            columns: 2
            rows: 2
            spacing: 2

            Repeater {
                model: 4
                Rectangle {
                    width: 4
                    height: 4
                    radius: 1
                    color: Config.panelForeground
                    opacity: 0.9
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            // Launch app launcher (fuzzel, wofi, rofi, etc.)
            Qt.callLater(function() {
                launcherProcess.running = true
            })
        }
    }

    // Process to launch app launcher
    Process {
        id: launcherProcess
        command: ["sh", "-c", "fuzzel || wofi --show drun || rofi -show drun"]
    }
}
