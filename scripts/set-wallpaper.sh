#!/bin/bash
# Set wallpaper for Niri using swaybg
# Usage: set-wallpaper.sh /path/to/image.jpg

WALLPAPER_PATH="$1"
BG_FILE="$HOME/.config/background"

if [ -z "$WALLPAPER_PATH" ]; then
    echo "Usage: set-wallpaper.sh /path/to/image"
    exit 1
fi

if [ ! -f "$WALLPAPER_PATH" ]; then
    echo "Error: File not found: $WALLPAPER_PATH"
    exit 1
fi

# Copy to config directory
cp "$WALLPAPER_PATH" "$BG_FILE"

# Apply wallpaper instantly
pkill swaybg 2>/dev/null
swaybg -i "$BG_FILE" -m fill &
