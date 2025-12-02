import QtQuick
import QtQuick.Layouts
import "../.."

// iOS-style vertical slider for brightness/volume
Rectangle {
    id: slider

    property string icon: "󰃟"
    property real value: 50 // 0-100
    property bool dragging: false

    signal sliderMoved(real val)
    signal iconClicked()

    color: Config.ccModuleBackground
    radius: Config.ccModuleRadius

    // Fill indicator (from bottom)
    Rectangle {
        id: fill
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: (value / 100) * parent.height
        radius: Config.ccModuleRadius
        color: Config.ccSliderFillColor
        opacity: 0.95

        Behavior on height {
            enabled: !dragging
            NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
        }
    }

    // Icon at bottom
    Text {
        id: iconText
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 14
        }
        text: icon
        font.family: "Symbols Nerd Font"
        font.pixelSize: 26
        color: value > 20 ? Config.ccModuleBackground : Config.panelForeground
        
        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        MouseArea {
            anchors.fill: parent
            anchors.margins: -8
            onClicked: slider.iconClicked()
        }
    }

    // Value display (shows while dragging)
    Text {
        anchors.centerIn: parent
        visible: dragging
        text: Math.round(value) + "%"
        font.family: Config.fontFamily
        font.pixelSize: 18
        font.weight: Font.Bold
        color: value > 60 ? Config.ccModuleBackground : Config.panelForeground
    }

    // Drag handling
    MouseArea {
        id: dragArea
        anchors.fill: parent
        
        onPressed: function(mouse) {
            dragging = true
            updateValue(mouse)
        }
        
        onReleased: dragging = false
        
        onPositionChanged: function(mouse) {
            if (pressed) {
                updateValue(mouse)
            }
        }

        function updateValue(mouse) {
            // Calculate value from position (inverted: top = 100, bottom = 0)
            let newValue = Math.round((1 - mouse.y / slider.height) * 100)
            newValue = Math.max(0, Math.min(100, newValue))
            if (newValue !== slider.value) {
                slider.value = newValue
                slider.sliderMoved(newValue)
            }
        }
    }

    // Scroll wheel support
    WheelHandler {
        onWheel: function(event) {
            let delta = event.angleDelta.y > 0 ? 5 : -5
            let newValue = Math.max(0, Math.min(100, slider.value + delta))
            if (newValue !== slider.value) {
                slider.value = newValue
                slider.sliderMoved(newValue)
            }
        }
    }
}
