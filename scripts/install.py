#!/usr/bin/env python3
"""
Nirvana Shell Installer
A lightweight, macOS-inspired shell for Niri Wayland compositor
"""

import subprocess
import sys
import os
import shutil
import tempfile
from pathlib import Path


# ANSI Colors
class Colors:
    MAGENTA = "\033[35m"
    CYAN = "\033[36m"
    GREEN = "\033[32m"
    YELLOW = "\033[33m"
    RED = "\033[31m"
    BOLD = "\033[1m"
    RESET = "\033[0m"


BANNER = f"""
{Colors.MAGENTA}  ███╗   ██╗██╗██████╗ ██╗   ██╗ █████╗ ███╗   ██╗ █████╗ {Colors.RESET}
{Colors.MAGENTA}  ████╗  ██║██║██╔══██╗██║   ██║██╔══██╗████╗  ██║██╔══██╗{Colors.RESET}
{Colors.CYAN}  ██╔██╗ ██║██║██████╔╝██║   ██║███████║██╔██╗ ██║███████║{Colors.RESET}
{Colors.CYAN}  ██║╚██╗██║██║██╔══██╗╚██╗ ██╔╝██╔══██║██║╚██╗██║██╔══██║{Colors.RESET}
{Colors.MAGENTA}  ██║ ╚████║██║██║  ██║ ╚████╔╝ ██║  ██║██║ ╚████║██║  ██║{Colors.RESET}
{Colors.MAGENTA}  ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝  ╚═══╝  ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝{Colors.RESET}

       {Colors.CYAN}A blissful, minimal shell for Niri{Colors.RESET}
"""

# Dependencies
REQUIRED = [
    ("quickshell", "quickshell-git", "Core shell framework"),
    ("niri", "niri", "Wayland compositor"),
]

# Tested on Arch Linux with these packages
OPTIONAL = [
    # Audio/Media
    ("wireplumber", "wireplumber", "Audio control (PipeWire)"),
    ("playerctl", "playerctl", "Media controls"),
    # Hardware
    ("brightnessctl", "brightnessctl", "Brightness control"),
    ("bluez", "bluez", "Bluetooth support"),
    # Network
    ("networkmanager", "networkmanager", "Network management"),
    # Power
    ("tuned", "tuned", "Power profiles daemon"),
    # Display
    ("gammastep", "gammastep", "Night light"),
    ("swaybg", "swaybg", "Wallpaper manager"),
    # Utilities
    ("fuzzel", "fuzzel", "App launcher"),
    ("swaylock", "swaylock", "Screen locker"),
    ("mate-polkit", "mate-polkit", "Polkit authentication agent"),
    ("fastfetch", "fastfetch", "System info fetch tool"),
]

# Recommended apps (used in default keybindings)
APPS = [
    ("ghostty", "ghostty", "Terminal (Mod+T)"),
    ("google-chrome", "google-chrome", "Browser (Mod+B)"),
    ("nautilus", "nautilus", "File manager (Mod+E)"),
]

FONTS = [
    ("ttf-sf-pro", "ttf-sf-pro", "SF Pro Display font"),
    ("otf-font-awesome", "otf-font-awesome", "Font Awesome icons"),
    ("ttf-nerd-fonts-symbols", "ttf-nerd-fonts-symbols", "Nerd Font icons"),
]

BUILD_DEPS = [
  "cmake",
  "git",
  "base-devel",
  "qt6-base",
  "qt6-declarative",
]

QML_PATH_CANDIDATES = [
  Path(p)
  for p in (os.environ.get("QML_IMPORT_PATH", "").split(":") if os.environ.get("QML_IMPORT_PATH") else [])
  if p
]
QML_PATH_CANDIDATES += [Path("/usr/lib/qt6/qml"), Path("/usr/lib64/qt6/qml")]


def run(cmd: list[str], check: bool = True, cwd: Path | None = None) -> subprocess.CompletedProcess:
    """Run a command and return the result."""
    return subprocess.run(cmd, capture_output=True, text=True, check=check, cwd=cwd)


def is_installed(package: str) -> bool:
    """Check if a package is installed."""
    result = run(["pacman", "-Qi", package], check=False)
    return result.returncode == 0


def has_aur_helper() -> str | None:
    """Check for available AUR helper."""
    for helper in ["paru", "yay", "pikaur"]:
        if run(["which", helper], check=False).returncode == 0:
            return helper
    return None


def install_packages(packages: list[str], aur_helper: str | None = None):
    """Install packages using pacman or AUR helper."""
    if not packages:
        return

    # Separate official and AUR packages
    official = []
    aur = []
    
    for pkg in packages:
        result = run(["pacman", "-Si", pkg], check=False)
        if result.returncode == 0:
            official.append(pkg)
        else:
            aur.append(pkg)

    # Install official packages
    if official:
        print(f"\n{Colors.CYAN}Installing from official repos:{Colors.RESET} {', '.join(official)}")
        subprocess.run(["sudo", "pacman", "-S", "--needed", "--noconfirm"] + official)

    # Install AUR packages
    if aur:
        if aur_helper:
            print(f"\n{Colors.CYAN}Installing from AUR:{Colors.RESET} {', '.join(aur)}")
            subprocess.run([aur_helper, "-S", "--needed", "--noconfirm"] + aur)
        else:
            print(f"\n{Colors.YELLOW}⚠ AUR packages need manual install:{Colors.RESET} {', '.join(aur)}")
            print(f"  Install an AUR helper: paru, yay, or pikaur")


def print_status(name: str, installed: bool, description: str):
    """Print package status."""
    status = f"{Colors.GREEN}✓{Colors.RESET}" if installed else f"{Colors.RED}✗{Colors.RESET}"
    print(f"  {status} {Colors.BOLD}{name:<20}{Colors.RESET} {description}")


def prompt_yes_no(message: str, default_yes: bool = True) -> bool:
    """Prompt user for yes/no input with clear formatting."""
    if default_yes:
        hint = f"{Colors.GREEN}y{Colors.RESET} / n"
        default_text = "yes"
    else:
        hint = f"y / {Colors.GREEN}n{Colors.RESET}"
        default_text = "no"
    
    print(f"\n  {message}")
    print(f"  [{hint}] (Enter = {default_text})")
    response = input(f"  {Colors.CYAN}>{Colors.RESET} ").strip().lower()
    
    if response == '':
        return default_yes
    return response in ('y', 'yes')


def prompt_continue(message: str = "Press Enter to continue..."):
    """Prompt user to press Enter to continue."""
    input(f"\n  {Colors.CYAN}{message}{Colors.RESET}")


def install_fastfetch_config():
    """Install Nirvana-themed fastfetch configuration."""
    fastfetch_dir = Path.home() / ".config" / "fastfetch"
    config_file = fastfetch_dir / "config.jsonc"
    
    # Create directory if needed
    fastfetch_dir.mkdir(parents=True, exist_ok=True)
    
    # Backup existing config
    if config_file.exists():
        backup = config_file.with_suffix('.jsonc.backup')
        print(f"  {Colors.YELLOW}Backing up existing config to {backup.name}{Colors.RESET}")
        config_file.rename(backup)
    
    # Write Nirvana fastfetch config
    fastfetch_config = '''{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  
  "logo": {
    "type": "none"
  },

  "display": {
    "separator": "  ",
    "color": {
      "keys": "cyan",
      "title": "magenta"
    }
  },

  "modules": [
    "break",
    "break",
    {
      "type": "custom",
      "format": "{#magenta}    ███╗   ██╗██╗██████╗ ██╗   ██╗ █████╗ ███╗   ██╗ █████╗ {#}"
    },
    {
      "type": "custom",
      "format": "{#magenta}    ████╗  ██║██║██╔══██╗██║   ██║██╔══██╗████╗  ██║██╔══██╗{#}"
    },
    {
      "type": "custom",
      "format": "{#cyan}    ██╔██╗ ██║██║██████╔╝██║   ██║███████║██╔██╗ ██║███████║{#}"
    },
    {
      "type": "custom",
      "format": "{#cyan}    ██║╚██╗██║██║██╔══██╗╚██╗ ██╔╝██╔══██║██║╚██╗██║██╔══██║{#}"
    },
    {
      "type": "custom",
      "format": "{#magenta}    ██║ ╚████║██║██║  ██║ ╚████╔╝ ██║  ██║██║ ╚████║██║  ██║{#}"
    },
    {
      "type": "custom",
      "format": "{#magenta}    ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝  ╚═══╝  ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝{#}"
    },
    "break",
    {
      "type": "title",
      "key": "                        "
    },
    {
      "type": "custom",
      "format": "      ───────────────────────────────────────────────────"
    },
    "break",
    {
      "type": "os",
      "key": "                      OS"
    },
    {
      "type": "kernel",
      "key": "                  Kernel"
    },
    {
      "type": "packages",
      "key": "                    Pkgs"
    },
    {
      "type": "shell",
      "key": "                   Shell"
    },
    {
      "type": "wm",
      "key": "                      WM"
    },
    {
      "type": "terminal",
      "key": "                    Term"
    },
    "break",
    {
      "type": "cpu",
      "key": "                     CPU"
    },
    {
      "type": "gpu",
      "key": "                     GPU"
    },
    {
      "type": "memory",
      "key": "                     RAM"
    },
    {
      "type": "disk",
      "key": "                    Disk",
      "folders": "/"
    },
    {
      "type": "battery",
      "key": "                     Bat"
    },
    "break",
    {
      "type": "uptime",
      "key": "                      Up"
    },
    "break",
    {
      "type": "colors",
      "paddingLeft": 24,
      "symbol": "circle"
    },
    "break",
    "break"
  ]
}
'''
    
    config_file.write_text(fastfetch_config)
    print(f"  {Colors.GREEN}✓{Colors.RESET} Installed Nirvana fastfetch config")


def install_niri_config():
    """Install optimized Niri configuration."""
    niri_dir = Path.home() / ".config" / "niri"
    nirvana_niri = Path.home() / ".config" / "quickshell" / "niri"
    
    # Check if Nirvana niri configs exist
    if not nirvana_niri.exists():
        print(f"  {Colors.RED}✗{Colors.RESET} Nirvana niri configs not found at {nirvana_niri}")
        return False
    
    # Create niri config directory
    niri_dir.mkdir(parents=True, exist_ok=True)
    
    # Backup existing configs
    for config_name in ["config.kdl", "animations.kdl"]:
        src = nirvana_niri / config_name
        dest = niri_dir / config_name
        
        if not src.exists():
            continue
            
        if dest.exists():
            backup = dest.with_suffix('.kdl.backup')
            print(f"  {Colors.YELLOW}Backing up {config_name} to {backup.name}{Colors.RESET}")
            dest.rename(backup)
        
        # Copy config
        dest.write_text(src.read_text())
        print(f"  {Colors.GREEN}✓{Colors.RESET} Installed {config_name}")
    
    return True

def find_qml_path() -> Path:
    for path in QML_PATH_CANDIDATES:
        if path.exists():
            return path
    # fallback to first candidate even if missing
    return QML_PATH_CANDIDATES[0]


def qml_niri_installed(qml_path: Path) -> bool:
    niri_dir = qml_path / "Niri"
    return niri_dir.is_dir() and (niri_dir / "libNiri.so").exists() and (niri_dir / "libNiriplugin.so").exists()


def verify_qml_niri(qml_path: Path) -> bool:
    qml_bin = shutil.which("qml6") or shutil.which("qml")
    if not qml_bin:
        print(f"{Colors.YELLOW}⚠{Colors.RESET} qml/qml6 not found; skipping plugin verify")
        return False
    snippet = "import QtQuick\nimport Niri 0.1\nItem {}\n"
    env = os.environ.copy()
    current = env.get("QML_IMPORT_PATH", "")
    env["QML_IMPORT_PATH"] = f"{qml_path}:{current}" if current else str(qml_path)
    with tempfile.NamedTemporaryFile("w", suffix=".qml", delete=False) as tf:
        tf.write(snippet)
        tmp_path = Path(tf.name)
    try:
        proc = subprocess.run([qml_bin, str(tmp_path)], text=True, capture_output=True, env=env)
        if proc.returncode == 0:
            print(f"{Colors.GREEN}✓{Colors.RESET} qml-niri import OK")
            return True
        print(f"{Colors.RED}✗{Colors.RESET} qml-niri import failed:\n{proc.stderr}")
        return False
    finally:
        tmp_path.unlink(missing_ok=True)


def install_qml_niri(qml_path: Path, aur_helper: str | None):
    print(f"\n{Colors.BOLD}qml-niri plugin:{Colors.RESET}")
    # ensure build deps
    missing_build = [p for p in BUILD_DEPS if not is_installed(p)]
    if missing_build:
        print(f"  Missing build deps: {', '.join(missing_build)}")
        if prompt_yes_no("Install build deps?", default_yes=True):
            install_packages(missing_build, aur_helper)
        else:
            print("  Skipping qml-niri install.")
            return

    with tempfile.TemporaryDirectory(prefix="qml-niri-") as tmp:
        repo_dir = Path(tmp) / "qml-niri"
        build_dir = Path(tmp) / "build"
        print("  Cloning qml-niri...")
        run(["git", "clone", "https://github.com/imiric/qml-niri.git", str(repo_dir)])
        print("  Configuring...")
        run(["cmake", "-S", str(repo_dir), "-B", str(build_dir), "-DCMAKE_BUILD_TYPE=Release"])
        print("  Building...")
        run(["cmake", "--build", str(build_dir)])

        src = build_dir / "Niri"
        if not src.exists():
            print(f"{Colors.RED}✗ build output not found at {src}{Colors.RESET}")
            return

        dest = qml_path / "Niri"
        print(f"  Installing to {dest} ...")
        if dest.exists():
            run(["sudo", "rm", "-rf", str(dest)])
        run(["sudo", "mkdir", "-p", str(qml_path)])
        run(["sudo", "cp", "-r", str(src), str(dest)])

    # Fix library loading by creating symlink for libNiri.so
    print("  Setting up library symlink...")
    run(["sudo", "ln", "-sf", str(qml_path / "Niri" / "libNiri.so"), "/usr/lib/libNiri.so"])

    verify_qml_niri(qml_path)


def main():
    print(BANNER)
    
    # Check for AUR helper
    aur_helper = has_aur_helper()
    if aur_helper:
        print(f"{Colors.GREEN}✓{Colors.RESET} Found AUR helper: {Colors.CYAN}{aur_helper}{Colors.RESET}")
    else:
        print(f"{Colors.YELLOW}⚠{Colors.RESET} No AUR helper found. Some packages may need manual installation.")
    
    # Check required dependencies
    print(f"\n{Colors.BOLD}Required Dependencies:{Colors.RESET}")
    missing_required = []
    for check_name, pkg_name, desc in REQUIRED:
        installed = is_installed(check_name) or is_installed(pkg_name)
        print_status(check_name, installed, desc)
        if not installed:
            missing_required.append(pkg_name)

    # Check optional dependencies
    print(f"\n{Colors.BOLD}Optional Dependencies:{Colors.RESET}")
    missing_optional = []
    for check_name, pkg_name, desc in OPTIONAL:
        installed = is_installed(check_name) or is_installed(pkg_name)
        print_status(check_name, installed, desc)
        if not installed:
            missing_optional.append(pkg_name)

    # Check recommended apps
    print(f"\n{Colors.BOLD}Recommended Apps:{Colors.RESET}")
    missing_apps = []
    for check_name, pkg_name, desc in APPS:
        installed = is_installed(check_name) or is_installed(pkg_name)
        print_status(check_name, installed, desc)
        if not installed:
            missing_apps.append(pkg_name)

    # Check fonts
    print(f"\n{Colors.BOLD}Fonts:{Colors.RESET}")
    missing_fonts = []
    for check_name, pkg_name, desc in FONTS:
        installed = is_installed(check_name) or is_installed(pkg_name)
        print_status(check_name, installed, desc)
        if not installed:
            missing_fonts.append(pkg_name)

    # Installation prompt
    all_missing = missing_required + missing_optional + missing_apps + missing_fonts
    
    if not all_missing:
        print(f"\n{Colors.GREEN}✓ All dependencies installed!{Colors.RESET}")
    else:
        print(f"\n{Colors.YELLOW}Missing packages:{Colors.RESET} {len(all_missing)}")
        
        # Required packages
        if missing_required:
            print(f"\n{Colors.RED}Required packages must be installed:{Colors.RESET}")
            for pkg in missing_required:
                print(f"    • {pkg}")
            if prompt_yes_no("Install required packages?", default_yes=True):
                install_packages(missing_required, aur_helper)

        # Optional packages
        if missing_optional:
            print(f"\n{Colors.CYAN}Optional packages for full functionality:{Colors.RESET}")
            for pkg in missing_optional:
                print(f"    • {pkg}")
            if prompt_yes_no("Install optional packages?", default_yes=True):
                install_packages(missing_optional, aur_helper)

        # Recommended apps
        if missing_apps:
            print(f"\n{Colors.CYAN}Recommended apps (used in keybindings):{Colors.RESET}")
            for pkg in missing_apps:
                print(f"    • {pkg}")
            if prompt_yes_no("Install recommended apps?", default_yes=False):
                install_packages(missing_apps, aur_helper)

        # Fonts
        if missing_fonts:
            print(f"\n{Colors.CYAN}Recommended fonts:{Colors.RESET}")
            for pkg in missing_fonts:
                print(f"    • {pkg}")
            if prompt_yes_no("Install fonts?", default_yes=True):
                install_packages(missing_fonts, aur_helper)

    # Clone/update config
    config_dir = Path.home() / ".config" / "quickshell"
    repo_url = "https://github.com/parth-sarthi-code/quickshell-niri-panel.git"
    
    print(f"\n{Colors.BOLD}Configuration:{Colors.RESET}")
    
    if config_dir.exists() and (config_dir / ".git").exists():
        print(f"  {Colors.GREEN}✓{Colors.RESET} Config exists at {config_dir}")
        if prompt_yes_no("Update from git?", default_yes=False):
            subprocess.run(["git", "-C", str(config_dir), "pull"])
    else:
        print(f"  Config will be cloned to: {Colors.CYAN}{config_dir}{Colors.RESET}")
        if prompt_yes_no("Clone Nirvana config?", default_yes=True):
            if config_dir.exists():
                backup = config_dir.with_suffix('.backup')
                print(f"  {Colors.YELLOW}Backing up existing config to {backup}{Colors.RESET}")
                config_dir.rename(backup)
            subprocess.run(["git", "clone", repo_url, str(config_dir)])

    # Install fastfetch config
    print(f"\n{Colors.BOLD}Fastfetch:{Colors.RESET}")
    if is_installed("fastfetch"):
        if prompt_yes_no("Install Nirvana fastfetch theme?", default_yes=True):
            install_fastfetch_config()
    else:
        print(f"  {Colors.YELLOW}⚠{Colors.RESET} Fastfetch not installed, skipping theme")

    # Install Niri config
    print(f"\n{Colors.BOLD}Niri Configuration:{Colors.RESET}")
    if is_installed("niri"):
        niri_config = Path.home() / ".config" / "niri" / "config.kdl"
        if niri_config.exists():
            print(f"  {Colors.CYAN}ℹ{Colors.RESET} Existing Niri config found at {niri_config}")
        if prompt_yes_no("Install Nirvana Niri config? (optimized for Niri 25.11)", default_yes=True):
            install_niri_config()
    else:
        print(f"  {Colors.YELLOW}⚠{Colors.RESET} Niri not installed, skipping config")

    # qml-niri plugin
    qml_path = find_qml_path()
    if qml_niri_installed(qml_path):
        print(f"\n{Colors.GREEN}✓{Colors.RESET} qml-niri already present at {qml_path / 'Niri'}")
        if prompt_yes_no("Reinstall qml-niri?", default_yes=False):
            install_qml_niri(qml_path, aur_helper)
        else:
            verify_qml_niri(qml_path)
    else:
        if prompt_yes_no("Install qml-niri plugin now?", default_yes=True):
            install_qml_niri(qml_path, aur_helper)
        else:
            print(f"{Colors.YELLOW}⚠{Colors.RESET} qml-niri plugin not installed; Quickshell will fail to load this config.")

    # Print run instructions
    prompt_continue("Press Enter to see run instructions...")
    
    print(f"""
{Colors.BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{Colors.RESET}

{Colors.GREEN}✓ Installation complete!{Colors.RESET}

{Colors.BOLD}Start Niri session:{Colors.RESET}
  Log out and select Niri from your display manager, or run:
  {Colors.CYAN}niri-session{Colors.RESET}

{Colors.BOLD}Key bindings (Niri 25.11):{Colors.RESET}
  {Colors.CYAN}Alt+Tab{Colors.RESET}      Recent windows switcher
  {Colors.CYAN}Mod+A{Colors.RESET}        Overview
  {Colors.CYAN}Mod+Space{Colors.RESET}    App launcher (fuzzel)
  {Colors.CYAN}Mod+T{Colors.RESET}        Terminal (ghostty)
  {Colors.CYAN}Mod+M{Colors.RESET}        Maximize to edges

{Colors.MAGENTA}🧘 Enjoy your blissful workflow!{Colors.RESET}
""")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}Cancelled.{Colors.RESET}")
        sys.exit(1)
