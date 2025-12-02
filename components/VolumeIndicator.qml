import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."
import "../services"

// Volume indicator with icon
Item {
    id: root

    implicitWidth: row.implicitWidth
    implicitHeight: Config.panelHeight

    property int volume: AudioService.volume
    property bool muted: AudioService.muted

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 4

        // Volume icon (SF Symbols style)
        Text {
            text: {
                if (muted || volume === 0) return "󰝟" // muted
                if (volume < 33) return "󰕿" // low
                if (volume < 66) return "󰖀" // medium
                return "󰕾" // high
            }
            font.family: "Symbols Nerd Font, JetBrainsMono Nerd Font, Font Awesome 6 Free"
            font.pixelSize: Config.iconSize
            color: muted ? Config.inactiveColor : Config.panelForeground
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
                AudioService.toggleMute()
            } else {
                // Open pavucontrol or similar
                Qt.callLater(function() {
                    volumeSettingsProc.running = true
                })
            }
        }

        onWheel: function(wheel) {
            if (wheel.angleDelta.y > 0) {
                AudioService.increaseVolume(5)
            } else {
                AudioService.decreaseVolume(5)
            }
        }
    }

    Process {
        id: volumeSettingsProc
        command: ["sh", "-c", "pavucontrol || gnome-control-center sound || kde-open5 settings5://sound"]
    }

    // Tooltip
    ToolTip {
        visible: mouseArea.containsMouse
        text: muted ? "Muted" : "Volume: " + volume + "%"
    }
}
