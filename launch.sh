#!/bin/sh
# Launcher script for quickshell with Niri plugin
# This sets the library path so libNiri.so can be found

export LD_LIBRARY_PATH=/usr/lib/qt6/qml/Niri:$LD_LIBRARY_PATH
exec quickshell "$@"
