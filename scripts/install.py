#!/usr/bin/env python3
"""
Nirvana Shell Installer
A lightweight, macOS-inspired shell for Niri Wayland compositor
"""

import subprocess
import sys
import os
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

OPTIONAL = [
    ("wireplumber", "wireplumber", "Audio control (PipeWire)"),
    ("brightnessctl", "brightnessctl", "Brightness control"),
    ("networkmanager", "networkmanager", "Network management"),
    ("bluez", "bluez", "Bluetooth support"),
    ("tuned", "tuned", "Power profiles"),
    ("gammastep", "gammastep", "Night light"),
    ("playerctl", "playerctl", "Media controls"),
    ("fastfetch", "fastfetch", "System info fetch tool"),
]

FONTS = [
    ("ttf-sf-pro", "ttf-sf-pro", "SF Pro Display font"),
    ("ttf-nerd-fonts-symbols", "ttf-nerd-fonts-symbols", "Nerd Font icons"),
]


def run(cmd: list[str], check: bool = True) -> subprocess.CompletedProcess:
    """Run a command and return the result."""
    return subprocess.run(cmd, capture_output=True, text=True, check=check)


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

    # Check fonts
    print(f"\n{Colors.BOLD}Fonts:{Colors.RESET}")
    missing_fonts = []
    for check_name, pkg_name, desc in FONTS:
        installed = is_installed(check_name) or is_installed(pkg_name)
        print_status(check_name, installed, desc)
        if not installed:
            missing_fonts.append(pkg_name)

    # Installation prompt
    all_missing = missing_required + missing_optional + missing_fonts
    
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

    # Print run instructions
    prompt_continue("Press Enter to see run instructions...")
    
    print(f"""
{Colors.BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{Colors.RESET}

{Colors.GREEN}✓ Installation complete!{Colors.RESET}

{Colors.BOLD}To run Nirvana:{Colors.RESET}
  {Colors.CYAN}LD_LIBRARY_PATH=/usr/lib/qt6/qml/Niri:$LD_LIBRARY_PATH quickshell{Colors.RESET}

{Colors.BOLD}Add to your Niri config:{Colors.RESET}
  {Colors.CYAN}spawn-at-startup "sh" "-c" "LD_LIBRARY_PATH=/usr/lib/qt6/qml/Niri:$LD_LIBRARY_PATH quickshell"{Colors.RESET}

{Colors.MAGENTA}🧘 Enjoy your blissful workflow!{Colors.RESET}
""")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}Cancelled.{Colors.RESET}")
        sys.exit(1)
