#!/usr/bin/env bash
# Steambox: Ubuntu 24.04 Desktop — Steam-focused setup (auto-login, Steam autostart, Bluetooth).
# Run as root: sudo ./install-steambox.sh <username>
set -euo pipefail

STEAMBOX_USER="${1:-${STEAMBOX_USER:-}}"
if [[ -z "${STEAMBOX_USER}" ]]; then
  echo "Usage: sudo $0 <linux-username>" >&2
  echo "Or set STEAMBOX_USER and run: sudo -E $0" >&2
  exit 1
fi

if [[ "${EUID}" -ne 0 ]]; then
  echo "This script must run as root (use sudo)." >&2
  exit 1
fi

if ! id "${STEAMBOX_USER}" &>/dev/null; then
  echo "User '${STEAMBOX_USER}' does not exist. Create the account first." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y software-properties-common

# Steam lives in multiverse
add-apt-repository -y multiverse || true
apt-get update -y

apt-get install -y \
  ubuntu-desktop \
  steam-installer \
  bluez \
  gnome-bluetooth \
  gnome-control-center \
  curl

# GDM automatic login (handles default commented lines on Ubuntu)
GDM_CONF="/etc/gdm3/custom.conf"
if [[ ! -f "${GDM_CONF}" ]]; then
  echo "Expected ${GDM_CONF} missing; is GDM installed?" >&2
  exit 1
fi

cp -a "${GDM_CONF}" "${GDM_CONF}.bak-steambox-$(date +%Y%m%d%H%M%S)"

# Replace commented or active AutomaticLogin* under [daemon]
sed -i \
  -e 's/^[#[:space:]]*AutomaticLoginEnable[[:space:]]*=.*/AutomaticLoginEnable=true/' \
  -e "s/^[#[:space:]]*AutomaticLogin[[:space:]]*=.*/AutomaticLogin=${STEAMBOX_USER}/" \
  "${GDM_CONF}"

# If keys were absent (unusual), append them after [daemon]
if ! grep -qE '^AutomaticLoginEnable[[:space:]]*=' "${GDM_CONF}"; then
  sed -i "/^\[daemon\]/a AutomaticLoginEnable=true" "${GDM_CONF}"
fi
if ! grep -qE '^AutomaticLogin[[:space:]]*=' "${GDM_CONF}"; then
  sed -i "/^\[daemon\]/a AutomaticLogin=${STEAMBOX_USER}" "${GDM_CONF}"
fi

# System-wide autostart: Steam + Bluetooth settings shortcut
install -d -m 0755 /etc/xdg/autostart
install -m 0644 "${REPO_ROOT}/config/steam-autostart.desktop" /etc/xdg/autostart/steam-autostart.desktop

DESKTOP_DIR="/home/${STEAMBOX_USER}/Desktop"
install -d -o "${STEAMBOX_USER}" -g "${STEAMBOX_USER}" -m 0755 "${DESKTOP_DIR}"
install -m 0755 "${REPO_ROOT}/scripts/pair-bluetooth.sh" /usr/local/bin/pair-bluetooth
install -m 0644 "${REPO_ROOT}/config/bluetooth-settings.desktop" "${DESKTOP_DIR}/Bluetooth Settings.desktop"
chown "${STEAMBOX_USER}:${STEAMBOX_USER}" "${DESKTOP_DIR}/Bluetooth Settings.desktop"

systemctl enable bluetooth
systemctl start bluetooth || true

echo "Steambox setup finished for user '${STEAMBOX_USER}'."
echo "Reboot to apply GDM auto-login: sudo reboot"
