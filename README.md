# Nirvana

> A blissful, minimal shell for Niri — peace in your workflow.

A lightweight top panel and control center for [Niri](https://github.com/YaLTeR/niri) Wayland compositor, built with [Quickshell](https://quickshell.outfoxxed.me/).

![Wayland](https://img.shields.io/badge/Wayland-Niri-blue?style=flat-square)
![Quickshell](https://img.shields.io/badge/Quickshell-0.2.1-green?style=flat-square)
![Qt](https://img.shields.io/badge/Qt-6.10-purple?style=flat-square)

## 📸 Screenshots

| Minimal Bar | Expanded Bar | Control Panel |
|:-----------:|:------------:|:-------------:|
| ![Minimal](minimal_bar.png) | ![Expanded](expanded_bar.png) | ![Control Panel](control_panel.png) |

## ✨ Features

### Top Panel
- **Workspace Indicator** — Visual pills showing active/inactive workspaces
- **Focused App** — Currently focused window title
- **Network Speed** — Toggle-able upload/download monitor
- **Status Icons** — WiFi, Bluetooth, Battery, Airplane mode, Night light
- **Clock** — Clean time display

### Control Center
- **Quick Toggles** — WiFi, Bluetooth, Airplane Mode, Night Light
- **Sliders** — Volume (PipeWire), Brightness
- **Power Profiles** — Power Saver / Balanced / Performance
- **System Stats** — CPU usage, temperature, RAM
- **Media Controls** — Now playing with artist/title
- **Quick Actions** — Lock screen

## 📋 TODO

- [ ] Notifications
- [ ] Power menu
- [ ] Calendar widget
- [ ] System tray

## 🚀 Installation

### Quick Install (Arch-based)

```bash
git clone https://github.com/parth-sarthi-code/quickshell-niri-panel.git ~/.config/quickshell
python3 ~/.config/quickshell/scripts/install.py
```

The installer will:
- Install dependencies (pacman/AUR)
- Set up Nirvana config + fastfetch theme
- Show run instructions

### Manual Install

```bash
git clone https://github.com/parth-sarthi-code/quickshell-niri-panel.git ~/.config/quickshell
LD_LIBRARY_PATH=/usr/lib/qt6/qml/Niri:$LD_LIBRARY_PATH quickshell
```

### Auto-start with Niri

Add to `~/.config/niri/config.kdl`:

```kdl
spawn-at-startup "sh" "-c" "LD_LIBRARY_PATH=/usr/lib/qt6/qml/Niri:$LD_LIBRARY_PATH quickshell"
```

## 🛠️ Dependencies

**Required:**
- Quickshell >= 0.2.1
- Niri Wayland compositor
- Qt 6.10+
- Nerd Fonts

**Optional:**
- `wireplumber` — Audio control
- `brightnessctl` — Brightness control
- `networkmanager` — Network management
- `bluez` — Bluetooth support
- `tuned` — Power profiles
- `gammastep` — Night light
- `playerctl` — Media controls
- `fastfetch` — System info (with Nirvana theme)

## 📁 Structure

```
~/.config/quickshell/
├── shell.qml           # Entry point
├── Config.qml          # Theme configuration
├── components/         # UI components
│   ├── TopPanel.qml
│   └── controlcenter/
└── services/           # System services
    └── scripts/        # Install script
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

MIT
