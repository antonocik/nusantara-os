#!/usr/bin/env bash
# Nusantara OS — build ISO (archiso)
#
# Usage:
#   sudo ./build.sh [kde|xfce|gnome|sway]
#   ./build.sh kde              # otomatis pakai sudo bila bukan root
#   SKIP_PKG_CHECK=1 ./build.sh # lewati pengecekan paket
#   CLEAN=1 ./build.sh kde      # hapus work/ dan out/ dulu
#
# Harus dijalankan di Arch Linux / Garuda / CachyOS / Manjaro
# (atau container archlinux). Ubuntu/Debian tidak didukung.

set -euo pipefail

PROFILE="${1:-kde}"
case "$PROFILE" in
  kde|xfce|gnome|sway) ;;
  -h|--help)
    sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "Profil tidak dikenal: $PROFILE (pilihan: kde, xfce, gnome, sway)" >&2
    exit 1
    ;;
esac

cd "$(dirname "$0")"

# --- root / sudo ---
if [[ $EUID -eq 0 ]]; then
  SUDO=""
elif command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
  sudo -v
else
  echo "Butuh root. Jalankan sebagai root atau pasang sudo." >&2
  exit 1
fi

# --- cek toolchain ---
missing=()
command -v mkarchiso   >/dev/null 2>&1 || missing+=("archiso")
command -v mksquashfs  >/dev/null 2>&1 || missing+=("squashfs-tools")
if (( ${#missing[@]} )); then
  echo "Paket wajib belum ada: ${missing[*]}" >&2
  echo "Pasang dulu:  sudo pacman -S --needed archiso squashfs-tools" >&2
  exit 1
fi

[[ "${CLEAN:-0}" == "1" ]] && rm -rf work out build-profile
mkdir -p out

# --- susun profil gabungan ---
DEST="build-profile"
rm -rf "$DEST"
mkdir -p "$DEST"

cp -a airootfs "$DEST/airootfs"
cp -a syslinux "$DEST/syslinux"
[[ -d efiboot ]] && cp -a efiboot "$DEST/efiboot"
[[ -d grub ]]    && cp -a grub    "$DEST/grub"
cp profiledef.sh pacman.conf "$DEST/"

# paket: varian menimpa daftar dasar
if [[ -f "profiles/$PROFILE/packages.x86_64" ]]; then
  cp "profiles/$PROFILE/packages.x86_64" "$DEST/packages.x86_64"
  echo "[i] paket dari profiles/$PROFILE/packages.x86_64"
else
  cp packages.x86_64 "$DEST/packages.x86_64"
  echo "[i] paket dari packages.x86_64 (default)"
fi

# overlay tambahan per-varian (opsional)
if [[ -d "profiles/$PROFILE/airootfs" ]]; then
  cp -a "profiles/$PROFILE/airootfs/." "$DEST/airootfs/"
  echo "[i] overlay airootfs dari profiles/$PROFILE"
fi

# --- buang paket yang tidak ada di repo (biar build tidak gagal) ---
if [[ "${SKIP_PKG_CHECK:-0}" != "1" ]] && command -v pacman >/dev/null 2>&1; then
  if [[ -x scripts/filter-packages.sh ]]; then
    echo "[i] cek ketersediaan paket..."
    scripts/filter-packages.sh "$DEST/packages.x86_64" || \
      echo "[!] pengecekan paket gagal, lanjut dengan daftar apa adanya"
  fi
fi

# --- build ---
echo "[i] mkarchiso mulai: profil=$PROFILE"
mkarchiso -v -w work -o out "$DEST"

echo
echo "[✓] Selesai. Hasil:"
ls -lh out/*.iso 2>/dev/null || echo "  (tidak ada .iso, cek log di atas)"
