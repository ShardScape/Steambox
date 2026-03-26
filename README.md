# Steambox

Ubuntu 24.04 **Desktop** tuned as a **Steam-first PC**: automatic login, Steam at session start, and easy Bluetooth pairing for controllers and headsets.

## Requirements

- Ubuntu 24.04 LTS (Noble) with network access
- A normal user account (the one that should log in automatically)
- Run the installer from this repo with `sudo`

## Quick setup

1. Clone or copy this repository onto the machine.
2. Run (replace `youruser` with the Linux username that should auto-login):

   ```bash
   cd steambox
   chmod +x scripts/install-steambox.sh scripts/pair-bluetooth.sh
   sudo ./scripts/install-steambox.sh youruser
   ```

3. Reboot:

   ```bash
   sudo reboot
   ```

After reboot, GDM signs in that user without a password prompt, Steam starts with the desktop session, and Bluetooth is available through the standard GNOME UI.

## What gets configured

| Goal | How |
|------|-----|
| **Ubuntu 24 Desktop** | Installs the `ubuntu-desktop` metapackage (full GNOME desktop). |
| **Auto-login** | Sets `AutomaticLoginEnable` and `AutomaticLogin` in `/etc/gdm3/custom.conf` for the user you pass to the script. A timestamped backup of the previous file is kept next to it. |
| **Steam on login** | Installs `steam-installer` and drops a system-wide autostart file in `/etc/xdg/autostart/` so Steam launches for every graphical session. |
| **Bluetooth pairing** | Installs `bluez`, `gnome-bluetooth`, and `gnome-control-center`, enables the `bluetooth` service, adds a **Bluetooth Settings** shortcut on the user’s Desktop, and installs `/usr/local/bin/pair-bluetooth` (same as opening GNOME Bluetooth settings). |

## Pairing Bluetooth devices

- **GUI:** Open **Bluetooth Settings** on the desktop, or run `gnome-control-center bluetooth`, or run `pair-bluetooth` in a terminal.
- **CLI (optional):** For headless or scripting use, `bluetoothctl` is available (`scan on`, `pair`, `trust`, `connect`).

Ensure the machine has a working Bluetooth adapter (built-in or USB dongle). Some adapters need firmware from Ubuntu’s restricted or HWE stacks; install those if the adapter is not detected.

## Security note

Automatic login means anyone with physical access can use the session without entering a password. That matches a dedicated living-room Steam box; use disk encryption and/or firmware passwords if you need stronger protection.

## Files in this repo

- `scripts/install-steambox.sh` — main installer (APT packages + GDM + autostart + desktop shortcut)
- `scripts/pair-bluetooth.sh` — convenience launcher for Bluetooth settings
- `config/steam-autostart.desktop` — XDG autostart entry for Steam
- `config/bluetooth-settings.desktop` — desktop entry copied to the target user’s `Desktop/`
