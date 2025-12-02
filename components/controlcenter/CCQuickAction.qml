import QtQuick
import QtQuick.Layouts
import "../.."

// Quick action button (Screenshot, Lock, etc.)
Rectangle {
    id: action

    property string icon: ""
    property string label: ""
    property bool active: false

    signal clicked()

    color: active ? Config.ccModuleActiveBackground : Config.ccModuleBackground
    radius: Config.ccModuleRadius

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 6

        // Icon
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 36
            height: 36
            radius: 18
            color: active ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(1, 1, 1, 0.1)

            Text {
                anchors.centerIn: parent
                text: action.icon
                font.family: "Symbols Nerd Font"
                font.pixelSize: 18
                color: active ? Config.panelForeground : Config.inactiveColor
            }
        }

        // Label
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: label
            font.family: Config.fontFamily
            font.pixelSize: 10
            font.weight: Font.Medium
            color: active ? Config.panelForeground : Config.activeColor
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: action.clicked()

        Rectangle {
            anchors.fill: parent
            radius: action.radius
            color: parent.pressed ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
        }
    }
}
