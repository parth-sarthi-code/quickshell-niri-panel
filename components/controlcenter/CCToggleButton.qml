import QtQuick
import QtQuick.Layouts
import "../.."

// Toggle button with icon and labels (for connectivity grid)
Rectangle {
    id: toggle

    property string icon: ""
    property string iconOff: ""
    property string label: ""
    property string sublabel: ""
    property bool active: false

    signal clicked()
    signal longPressed()

    color: active ? Config.ccModuleActiveBackground : Config.ccSliderBackground
    radius: Config.ccModuleRadius - 6

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: 8
        }
        spacing: 2

        // Icon
        Rectangle {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            radius: 15
            color: active ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(1, 1, 1, 0.1)

            Text {
                anchors.centerIn: parent
                text: active ? toggle.icon : (toggle.iconOff || toggle.icon)
                font.family: "Symbols Nerd Font"
                font.pixelSize: 16
                color: active ? Config.panelForeground : Config.inactiveColor

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }
        }

        Item { Layout.fillHeight: true }

        // Label
        Text {
            Layout.fillWidth: true
            text: label
            font.family: Config.fontFamily
            font.pixelSize: 11
            font.weight: Font.Medium
            color: active ? Config.panelForeground : Config.activeColor
            elide: Text.ElideRight
        }

        // Sublabel
        Text {
            Layout.fillWidth: true
            text: sublabel
            font.family: Config.fontFamily
            font.pixelSize: 10
            color: active ? Qt.rgba(1, 1, 1, 0.7) : Config.inactiveColor
            elide: Text.ElideRight
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: toggle.clicked()
        onPressAndHold: toggle.longPressed()

        // Visual feedback
        Rectangle {
            anchors.fill: parent
            radius: toggle.radius
            color: parent.pressed ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
        }
    }
}
