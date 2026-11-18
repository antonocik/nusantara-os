#!/usr/bin/env bash
set -euo pipefail

# NusantaraOS - build script (archiso)
# Usage: sudo ./build.sh [kde|xfce|gnome|sway]

PROFILE=${1:-kde}

if [[ $EUID -ne 0 ]]; then
  echo "Jalankan dengan sudo: sudo ./build.sh"
  exit 1
fi

cd "$(dirname "$0")"

# 1. Pilih profil
case "$PROFILE" in
  kde|xfce|gnome|sway) ;;
  *)
    echo "Profil tidak dikenal: $PROFILE (kde|xfce|gnome|sway)"
    exit 1
    ;;
esac

echo "[NusantaraOS] Build profil: $PROFILE"

# Kalau ada folder profiles/<nama>, pakai itu, else pakai root profile (kde default)
if [[ -d "profiles/$PROFILE" ]]; then
  PROFILE_DIR="profiles/$PROFILE"
else
  PROFILE_DIR="."
fi

# 2. Bersihkan work lama jika diminta
if [[ "${CLEAN:-0}" == "1" ]]; then
  rm -rf work out
fi

# 3. Build ISO
# archiso butuh profile dir yang berisi profiledef.sh, packages.x86_64, airootfs, dll
# Kita siapkan symlink/copy ke work_dir sesuai standar mkarchiso
mkdir -p out

# Jika profil terpisah, salin file umum
if [[ "$PROFILE_DIR" != "." ]]; then
  echo "Menggunakan $PROFILE_DIR ..."
  # packages & airootfs diambil dari profil spesifik jika ada
  if [[ -f "$PROFILE_DIR/packages.x86_64" ]]; then cp -v "$PROFILE_DIR/packages.x86_64" ./packages.x86_64; fi
  # airootfs di-merge (.overlay)
  # (untuk simplicity, build langsung dari folder profil)
  exec mkarchiso -v -w work -o out "$PROFILE_DIR"
else
  exec mkarchiso -v -w work -o out .
fi

echo "Selesai. ISO di out/"
ls -lh out/*.iso 2>/dev/null || true
