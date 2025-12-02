import QtQuick
import Quickshell
import Niri 0.1
import "components"
import "services"

ShellRoot {
    id: root

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
}
