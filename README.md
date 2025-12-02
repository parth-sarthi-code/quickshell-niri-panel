# Quickshell Niri Panel

A lightweight, macOS-inspired top panel and control center for the [Niri](https://github.com/YaLTeR/niri) Wayland compositor, built with [Quickshell](https://quickshell.outfoxxed.me/).

![Wayland](https://img.shields.io/badge/Wayland-Niri-blue?style=flat-square)
![Quickshell](https://img.shields.io/badge/Quickshell-0.2.1-green?style=flat-square)
![Qt](https://img.shields.io/badge/Qt-6.10-purple?style=flat-square)

## ✨ Features

### Top Panel
- **Workspace Indicator** - Visual workspace pills with active/inactive states
- **Focused App Name** - Shows currently focused window title
- **Network Speed Monitor** - Toggle-able upload/download speed display
- **System Tray Icons**:
  - Network status (WiFi/Ethernet with signal strength)
  - Bluetooth status
  - Battery with percentage and charging state
  - Airplane mode indicator
  - Night light indicator
- **Control Center Trigger** - macOS-style pill button
- **Clock** - Clean time display

### Control Center (GNOME/macOS Style)
- **Quick Toggles**: WiFi, Bluetooth, Airplane Mode, Night Light
- **Sliders**: Volume (PipeWire), Brightness
- **Power Profiles** - Power Saver / Balanced / Performance
- **System Stats** - CPU usage, temperature, RAM
- **Media Controls** - Now playing with artist/title
- **Quick Actions** - Lock screen, Settings

## 📊 Performance

| Service | Method | Interval | Notes |
|---------|--------|----------|-------|
| **Battery** | Native D-Bus | Real-time | Zero polling |
| **Bluetooth** | Native D-Bus | Real-time | Zero polling |
| **Audio** | wpctl | 5s | Optimistic UI |
| **Brightness** | sysfs | 5s | Direct file read |
| **Network** | busctl | 5-15s | Adaptive polling |
| **Network Speed** | /proc/net/dev | 3s | On-demand only |
| **System Stats** | /proc + sysfs | 3-7s | Faster when CC open |

**Resource Usage**: ~0.1-0.3% CPU idle, ~25-35 MB memory

## 📁 Structure

```
~/.config/quickshell/
├── shell.qml              # Entry point
├── Config.qml             # Theme configuration
├── components/
│   ├── TopPanel.qml       # Main panel bar
│   ├── Clock.qml, FocusedApp.qml, WorkspaceIndicator.qml
│   ├── NetworkIndicator.qml, BluetoothIndicator.qml, BatteryIndicator.qml
│   └── controlcenter/
│       ├── ControlCenter.qml
│       ├── CCToggle.qml, CCSlider.qml, CCQuickAction.qml
└── services/
    ├── AudioService.qml, BatteryService.qml, BluetoothService.qml
    ├── BrightnessService.qml, NetworkService.qml, NetworkSpeedService.qml
```

## 🛠️ Dependencies

**Required:**
- Quickshell >= 0.2.1
- Niri Wayland compositor
- Qt 6.10+
- Nerd Fonts

**Optional:**
- `wireplumber` - Audio
- `brightnessctl` - Brightness
- `networkmanager` - Network
- `bluez` - Bluetooth
- `tuned` - Power profiles
- `gammastep` - Night light
- `playerctl` - Media controls

## 🚀 Installation

```bash
git clone https://github.com/parth-sarthi-code/quickshell-niri-panel.git ~/.config/quickshell
LD_LIBRARY_PATH=/usr/lib/qt6/qml/Niri:$LD_LIBRARY_PATH quickshell
```

## ⚙️ Configuration

Edit `Config.qml`:

```qml
readonly property int panelHeight: 32
readonly property real panelOpacity: 0.45
readonly property color accentColor: "#007AFF"
readonly property string fontFamily: "SF Pro Display, Inter, sans-serif"
```

## 📝 License

MIT License
