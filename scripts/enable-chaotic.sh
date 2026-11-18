#!/usr/bin/env bash
# Aktifkan Chaotic-AUR (repo yang dipakai Garuda OS) di host build.
# Hanya mengubah keyring + mirrorlist sistem, bukan pacman.conf.
#
# Usage: sudo scripts/enable-chaotic.sh

set -euo pipefail

if [[ $EUID -eq 0 ]]; then SUDO=""; else SUDO="sudo"; fi

KEY="3056513887B78AEB"
KEYRING="https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst"
MIRRORLIST="https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst"

echo "[chaotic] init keyring"
$SUDO pacman-key --init

echo "[chaotic] ambil kunci $KEY"
ok=0
for ks in keyserver.ubuntu.com hkps://keys.openpgp.org keys.gnupg.net; do
  if $SUDO pacman-key --recv-key "$KEY" --keyserver "$ks"; then ok=1; break; fi
done
(( ok )) || { echo "[chaotic] gagal mengunduh kunci" >&2; exit 1; }

$SUDO pacman-key --lsign-key "$KEY"

echo "[chaotic] pasang keyring & mirrorlist"
$SUDO pacman -U --noconfirm --needed "$KEYRING"
$SUDO pacman -U --noconfirm --needed "$MIRRORLIST"

[[ -f /etc/pacman.d/chaotic-mirrorlist ]] || {
  echo "[chaotic] mirrorlist tidak terpasang" >&2
  exit 1
}

echo "[chaotic] selesai"
