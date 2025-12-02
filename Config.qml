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
    readonly property color inactiveColor: "#999999"
    readonly property color hoverColor: Qt.rgba(1, 1, 1, 0.1)
    readonly property color urgentColor: "#FF453A"
    readonly property color warningColor: "#FF9F0A"
    readonly property color successColor: "#30D158"
    
    // Spacing
    readonly property int itemSpacing: 12
    readonly property int iconSize: 18
    readonly property int borderRadius: 8
    
    // Control Center settings
    readonly property int ccWidth: 320
    readonly property int ccPadding: 16
    readonly property int ccModuleRadius: 20
    readonly property int ccModuleSpacing: 12
    readonly property int ccSliderWidth: 55
    readonly property real ccBackgroundOpacity: 0.85
    readonly property color ccBackground: "#1c1c1e"
    readonly property color ccModuleBackground: "#2c2c2e"
    readonly property color ccModuleActiveBackground: "#007AFF"
    readonly property color ccSliderBackground: "#3a3a3c"
    readonly property color ccSliderFillColor: "#ffffff"
}
