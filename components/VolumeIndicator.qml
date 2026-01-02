import QtQuick
import QtQuick.Layouts
import ".."
import "../services"

// Volume indicator - click opens volume dropdown
Item {
    id: volumeIndicator

    implicitWidth: row.implicitWidth + 4
    implicitHeight: Config.panelHeight

    property int volume: AudioService.volume
    property bool muted: AudioService.muted

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: {
                if (muted || volume === 0) return "󰝟"
                if (volume < 33) return "󰕿"
                if (volume < 66) return "󰖀"
                return "󰕾"
            }
            font.family: "Symbols Nerd Font"
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
        opacity: mouseArea.containsMouse || (root.volumeDropdown && root.volumeDropdown.isOpen) ? 1 : 0
        
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
            if (mouse.button === Qt.RightButton) {
                AudioService.toggleMute()
            } else if (root.volumeDropdown) {
                // Close control center if open
                if (root.controlCenter && root.controlCenter.visible) {
                    root.controlCenter.visible = false
                }
                root.volumeDropdown.toggle()
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
}
