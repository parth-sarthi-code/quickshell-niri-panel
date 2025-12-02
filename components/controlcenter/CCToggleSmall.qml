import QtQuick
import QtQuick.Layouts
import "../.."

// Small toggle button (Focus, Night Light, etc.)
Rectangle {
    id: toggle

    property string icon: ""
    property string label: ""
    property bool active: false

    signal clicked()

    color: active ? Config.ccModuleActiveBackground : Config.ccModuleBackground
    radius: Config.ccModuleRadius - 4

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    RowLayout {
        anchors {
            fill: parent
            margins: 10
        }
        spacing: 10

        // Icon
        Rectangle {
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            radius: 14
            color: active ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(1, 1, 1, 0.1)

            Text {
                anchors.centerIn: parent
                text: toggle.icon
                font.family: "Symbols Nerd Font"
                font.pixelSize: 14
                color: active ? Config.panelForeground : Config.inactiveColor
            }
        }

        // Label
        Text {
            Layout.fillWidth: true
            text: label
            font.family: Config.fontFamily
            font.pixelSize: 12
            font.weight: Font.Medium
            color: active ? Config.panelForeground : Config.activeColor
            elide: Text.ElideRight
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: toggle.clicked()

        Rectangle {
            anchors.fill: parent
            radius: toggle.radius
            color: parent.pressed ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
        }
    }
}
