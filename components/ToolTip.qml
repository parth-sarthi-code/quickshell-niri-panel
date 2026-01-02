import QtQuick
import QtQuick.Controls
import ".."

// Simple tooltip component
ToolTip {
    id: root
    
    delay: 500
    timeout: 5000
    
    contentItem: Text {
        text: root.text
        font.family: Config.fontFamily
        font.pixelSize: Config.fontSizeSmall
        color: Config.panelForeground
    }
    
    background: Rectangle {
        color: Qt.rgba(0, 0, 0, 0.85)
        radius: 4
        border.color: Qt.rgba(1, 1, 1, 0.1)
        border.width: 1
    }
}
