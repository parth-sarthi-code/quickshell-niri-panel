# Quickshell Niri Panel

A lightweight, macOS-inspired top panel for the [niri](https://github.com/YaLTeR/niri) Wayland compositor using [Quickshell](https://quickshell.outfoxxed.me/).

## Features

- **Semi-transparent panel** (~45% opacity) with clean macOS-style aesthetics
- **Workspace indicator** - pill-style dots in the center, click or scroll to switch
- **System status indicators**:
  - Brightness (scroll to adjust)
  - Volume (click to mute, scroll to adjust, right-click for settings)
  - WiFi/Network (click to toggle, right-click for settings)
  - Bluetooth (click to toggle power, right-click for settings)
  - Battery (with percentage and status)
- **Clock** - macOS-style format (Day Mon DD h:mm AM/PM)
- **App launcher** - click the grid icon to launch fuzzel/wofi/rofi
- **Focused app name** - displays the currently focused application

## Requirements

- [Quickshell](https://quickshell.outfoxxed.me/) >= 0.2.1
- [niri](https://github.com/YaLTeR/niri) >= 25.08
- [qml-niri](https://github.com/imiric/qml-niri) plugin installed
- A Nerd Font for icons (e.g., JetBrainsMono Nerd Font, Symbols Nerd Font)

### Optional dependencies (for full functionality)

- `brightnessctl` - for brightness control
- `wpctl` or `pactl` - for volume control
- `nmcli` - for network status and control
- `bluetoothctl` - for Bluetooth status and control
- `fuzzel`, `wofi`, or `rofi` - for app launcher

## Installation

1. Install qml-niri following [its installation guide](https://github.com/imiric/qml-niri#installation)

2. The config is already in place at `~/.config/quickshell/`

3. Run quickshell:
   ```bash
   quickshell
   ```

4. To start automatically with niri, add to `~/.config/niri/config.kdl`:
   ```kdl
   spawn-at-startup "quickshell"
   ```

## Configuration

Edit `Config.qml` to customize:

- `panelHeight` - panel height in pixels (default: 28)
- `panelOpacity` - background opacity 0.0-1.0 (default: 0.45)
- `panelBackground` - background color
- `fontFamily` - font for text
- `fontSize` - base font size
- `accentColor`, `activeColor`, etc. - color scheme

## Interactions

| Component | Action | Effect |
|-----------|--------|--------|
| App Launcher | Click | Open app launcher (fuzzel/wofi/rofi) |
| Focused App | Right-click | Close focused window |
| Workspaces | Click dot | Switch to workspace |
| Workspaces | Scroll | Navigate workspaces |
| Brightness | Scroll | Adjust brightness |
| Volume | Click | Toggle mute |
| Volume | Scroll | Adjust volume |
| Volume | Right-click | Open sound settings |
| Network | Click | Toggle WiFi |
| Network | Right-click | Open network settings |
| Bluetooth | Click | Toggle Bluetooth power |
| Bluetooth | Right-click | Open Bluetooth settings |
| Battery | Click | Open power settings |
| Clock | Click | Open calendar |

## Structure

```
~/.config/quickshell/
├── shell.qml              # Main entry point
├── Config.qml             # Configuration singleton
├── qmldir                 # Module definition
├── components/
│   ├── TopPanel.qml       # Main panel layout
│   ├── WorkspaceIndicator.qml
│   ├── AppLauncher.qml
│   ├── FocusedApp.qml
│   ├── VolumeIndicator.qml
│   ├── BrightnessIndicator.qml
│   ├── NetworkIndicator.qml
│   ├── BluetoothIndicator.qml
│   ├── BatteryIndicator.qml
│   ├── Clock.qml
│   ├── ToolTip.qml
│   └── qmldir
└── services/
    ├── AudioService.qml
    ├── BrightnessService.qml
    ├── NetworkService.qml
    ├── BluetoothService.qml
    ├── BatteryService.qml
    └── qmldir
```

## License

MIT
