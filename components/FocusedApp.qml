import QtQuick
import QtQuick.Layouts
import ".."

// Display currently focused application name (macOS style)
Item {
    id: root

    implicitWidth: appText.implicitWidth
    implicitHeight: Config.panelHeight

    Text {
        id: appText
        anchors.verticalCenter: parent.verticalCenter
        
        text: niri.focusedWindow?.appId ?? "Desktop"
        color: Config.panelForeground
        font.family: Config.fontFamily
        font.pixelSize: Config.fontSize
        font.weight: Font.DemiBold
        
        // Capitalize first letter
        Component.onCompleted: updateText()
        
        Connections {
            target: niri
            function onFocusedWindowChanged() {
                appText.updateText()
            }
        }
        
        function updateText() {
            let appId = niri.focusedWindow?.appId ?? "Desktop"
            // Clean up app name - capitalize first letter
            if (appId.length > 0) {
                appId = appId.charAt(0).toUpperCase() + appId.slice(1)
            }
            // Remove common suffixes
            appId = appId.replace(/-bin$/, "").replace(/\.desktop$/, "")
            text = appId
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        // Click to show app info or close window
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        
        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton && niri.focusedWindow) {
                niri.closeWindowOrFocused()
            }
        }
    }
}
