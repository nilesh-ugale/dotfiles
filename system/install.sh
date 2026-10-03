#!/usr/bin/env bash
# Install the system files under etc/ into /etc. Not a stow package:
# NetworkManager only runs dispatcher scripts owned by root, so these are
# copied with root ownership instead of symlinked.
set -euo pipefail
cd "$(dirname "$0")"

sudo install -Dm644 -o root -g root etc/nftables.conf /etc/nftables.conf
sudo install -Dm755 -o root -g root etc/NetworkManager/dispatcher.d/70-wifi-wired-exclusive \
    /etc/NetworkManager/dispatcher.d/70-wifi-wired-exclusive
sudo install -Dm644 -o root -g root etc/sysctl.d/90-arp.conf /etc/sysctl.d/90-arp.conf
sudo install -Dm644 -o root -g root etc/mkinitcpio.conf /etc/mkinitcpio.conf
sudo install -Dm644 -o root -g root etc/mkinitcpio.d/linux.preset /etc/mkinitcpio.d/linux.preset

sudo nft -c -f /etc/nftables.conf
sudo systemctl enable --now nftables
sudo sysctl --system >/dev/null
sudo mkinitcpio -P
