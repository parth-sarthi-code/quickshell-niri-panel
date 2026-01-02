import QtQuick
import QtQuick.Layouts
import ".."

// Workspace indicator - macOS style dots/pills
Item {
    id: root

    implicitWidth: workspaceContainer.width
    implicitHeight: Config.panelHeight - 8

    Rectangle {
        id: workspaceContainer
        anchors.centerIn: parent
        width: workspaceRow.implicitWidth + 16
        height: parent.height
        color: Qt.rgba(1, 1, 1, 0.08)
        radius: height / 2

        Row {
            id: workspaceRow
            anchors.centerIn: parent
            spacing: 8

            Repeater {
                model: niri.workspaces

                Rectangle {
                    id: workspaceDot
                    width: model.isFocused ? 20 : 10
                    height: 10
                    radius: 5
                    color: model.isFocused ? Config.activeColor :
                           model.isActive ? Qt.rgba(1, 1, 1, 0.6) :
                           model.isUrgent ? Config.urgentColor : Qt.rgba(1, 1, 1, 0.3)
                    
                    Behavior on width {
                        NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                    }
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }

                    MouseArea {
                        id: dotMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        // Click to focus workspace
                        onClicked: niri.focusWorkspaceById(model.id)
                    }

                    // Tooltip
                    ToolTip {
                        visible: dotMouseArea.containsMouse
                        text: model.name || ("Workspace " + (model.index + 1))
                    }
                }
            }
        }

        // Scroll anywhere on the workspace indicator to switch
        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            
            onWheel: function(wheel) {
                // Find current focused workspace index
                let currentIdx = -1
                for (let i = 0; i < niri.workspaces.count; i++) {
                    let ws = niri.workspaces.get(i)
                    if (ws && ws.isFocused) {
                        currentIdx = i
                        break
                    }
                }
                
                if (wheel.angleDelta.y > 0 && currentIdx > 0) {
                    // Scroll up - previous workspace
                    niri.focusWorkspace(currentIdx - 1)
                } else if (wheel.angleDelta.y < 0 && currentIdx < niri.workspaces.count - 1) {
                    // Scroll down - next workspace
                    niri.focusWorkspace(currentIdx + 1)
                }
            }
            
            onClicked: function(mouse) { mouse.accepted = false }
        }
    }
}
