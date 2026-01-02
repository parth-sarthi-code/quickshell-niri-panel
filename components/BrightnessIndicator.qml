import QtQuick
import QtQuick.Layouts
import ".."
import "../services"

// Brightness indicator
Item {
    id: root

    implicitWidth: row.implicitWidth
    implicitHeight: Config.panelHeight

    property int brightness: BrightnessService.brightness

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 4

        // Brightness icon (sun)
        Text {
            text: {
                if (brightness < 30) return "󰃞" // low brightness
                if (brightness < 70) return "󰃟" // medium
                return "󰃠" // high brightness
            }
            font.family: "Symbols Nerd Font, JetBrainsMono Nerd Font, Font Awesome 6 Free"
            font.pixelSize: Config.iconSize
            color: Config.panelForeground
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

        onWheel: function(wheel) {
            if (wheel.angleDelta.y > 0) {
                BrightnessService.increaseBrightness(5)
            } else {
                BrightnessService.decreaseBrightness(5)
            }
        }
    }

    // Tooltip
    ToolTip {
        visible: mouseArea.containsMouse
        text: "Brightness: " + brightness + "%"
    }
}
