import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."

// Clock display - macOS style (Day Mon DD h:mm AM/PM)
Item {
    id: root

    implicitWidth: timeText.implicitWidth + 8
    implicitHeight: Config.panelHeight

    property string timeFormat: "ddd MMM d  h:mm AP"

    Text {
        id: timeText
        anchors.centerIn: parent
        
        text: Qt.formatDateTime(new Date(), timeFormat)
        color: Config.panelForeground
        font.family: Config.fontFamily
        font.pixelSize: Config.fontSize
        font.weight: Font.Medium
    }

    // Update every second
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            timeText.text = Qt.formatDateTime(new Date(), timeFormat)
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
            // Open calendar or notification center
            Qt.callLater(function() {
                calendarProc.running = true
            })
        }
    }

    Process {
        id: calendarProc
        command: ["sh", "-c", "gnome-calendar || kde-open5 calendar || notify-send 'Calendar' \"$(date '+%A, %B %d, %Y')\""]
    }

    // Tooltip with full date
    ToolTip {
        visible: mouseArea.containsMouse
        text: Qt.formatDateTime(new Date(), "dddd, MMMM d, yyyy")
    }
}
