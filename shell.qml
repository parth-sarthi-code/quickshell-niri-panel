import QtQuick
import Quickshell
import Quickshell.Wayland
import Niri 0.1
import "components"
import "components/controlcenter"
import "services"

ShellRoot {
    id: root

    // Global reference to control center
    property alias controlCenter: ccLoader.item

    // Invisible overlay to catch clicks outside control center
    PanelWindow {
        id: clickCatcher
        visible: controlCenter && controlCenter.expanded
        screen: Quickshell.screens[0]
        
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        
        color: "transparent"
        WlrLayershell.namespace: "quickshell-clickcatcher"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        
        MouseArea {
            anchors.fill: parent
            onClicked: controlCenter.close()
        }
    }

    // Niri IPC connection
    Niri {
        id: niri
        Component.onCompleted: connect()

        onConnected: console.info("Connected to niri")
        onErrorOccurred: function(error) {
            console.error("Niri error:", error)
        }
    }

    // Limit workspaces to 10
    Component.onCompleted: {
        niri.workspaces.maxCount = 10
    }

    // Load the top panel
    LazyLoader {
        active: true
        component: TopPanel {}
    }

    // Load the control center
    LazyLoader {
        id: ccLoader
        active: true
        component: ControlCenter {
            id: controlCenterInstance
        }
    }
}
