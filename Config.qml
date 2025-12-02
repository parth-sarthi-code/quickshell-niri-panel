pragma Singleton
import QtQuick
import Quickshell

Singleton {
    // Panel settings
    readonly property int panelHeight: 32
    readonly property real panelOpacity: 0.45
    readonly property color panelBackground: "#1a1a1a"
    readonly property color panelForeground: "#ffffff"
    
    // Font settings (SF Pro style, fallback to system sans)
    readonly property string fontFamily: "SF Pro Display, Inter, Cantarell, sans-serif"
    readonly property int fontSize: 13
    readonly property int fontSizeSmall: 11
    
    // Colors
    readonly property color accentColor: "#007AFF"
    readonly property color activeColor: "#ffffff"
    readonly property color inactiveColor: "#666666"
    readonly property color hoverColor: Qt.rgba(1, 1, 1, 0.1)
    readonly property color urgentColor: "#FF453A"
    readonly property color warningColor: "#FF9F0A"
    readonly property color successColor: "#30D158"
    
    // Spacing
    readonly property int itemSpacing: 12
    readonly property int iconSize: 18
    readonly property int borderRadius: 6
}
