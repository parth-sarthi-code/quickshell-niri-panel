# Nirvana

> A blissful, minimal shell for Niri — peace in your workflow.

A lightweight top panel and control center for [Niri](https://github.com/YaLTeR/niri) Wayland compositor, built with [Quickshell](https://quickshell.outfoxxed.me/).

![Wayland](https://img.shields.io/badge/Wayland-Niri-blue?style=flat-square)
![Quickshell](https://img.shields.io/badge/Quickshell-0.2.1-green?style=flat-square)
![Qt](https://img.shields.io/badge/Qt-6.10-purple?style=flat-square)

## ✨ Features

**Panel**: Workspaces • Focused app • Network speed • WiFi/Bluetooth/Battery indicators • Clock

**Control Center**: Quick toggles • Volume/Brightness sliders • Power profiles • System stats • Media controls

## 📋 TODO

- [ ] Notifications
- [ ] Power menu
- [ ] Calendar widget
- [ ] System tray

## 🚀 Installation

```bash
git clone https://github.com/parth-sarthi-code/quickshell-niri-panel.git ~/.config/quickshell
python3 ~/.config/quickshell/scripts/install.py
```

The installer will:
- Install dependencies (pacman/AUR)
- Set up Nirvana config + fastfetch theme
- Show run instructions

### Manual

```bash
git clone https://github.com/parth-sarthi-code/quickshell-niri-panel.git ~/.config/quickshell
LD_LIBRARY_PATH=/usr/lib/qt6/qml/Niri:$LD_LIBRARY_PATH quickshell
```

### Auto-start

Add to `~/.config/niri/config.kdl`:

```kdl
spawn-at-startup "sh" "-c" "LD_LIBRARY_PATH=/usr/lib/qt6/qml/Niri:$LD_LIBRARY_PATH quickshell"
```

## 🛠️ Dependencies

**Required:** Quickshell, Niri, Qt 6.10+, Nerd Fonts

**Optional:** wireplumber, brightnessctl, networkmanager, bluez, tuned, gammastep, playerctl, fastfetch

## ⚙️ Config

Edit `Config.qml` for colors, fonts, panel height, opacity.

## 📝 License

MIT
