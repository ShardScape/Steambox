#!/usr/bin/env bash
# Opens GNOME Bluetooth settings for pairing. Usable from a terminal or keybinding.
set -euo pipefail
exec gnome-control-center bluetooth
