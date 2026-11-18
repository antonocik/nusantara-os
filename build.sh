#!/usr/bin/env bash
# Nusantara OS — build ISO (archiso)
#
# Usage:
#   sudo ./build.sh [kde|xfce|gnome|sway]
#   ./build.sh kde                  # otomatis pakai sudo bila bukan root
#   SKIP_PKG_CHECK=1 ./build.sh     # lewati pengecekan paket
#   CLEAN=1 ./build.sh kde          # hapus work/ dan out/ dulu
#   WITH_CHAOTIC=1 ./build.sh kde   # aktifkan repo Chaotic-AUR (+ pamac)
#   WITH_CALAMARES=0 ./build.sh kde # jangan bangun installer Calamares dari AUR
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

WITH_CHAOTIC="${WITH_CHAOTIC:-0}"
WITH_CALAMARES="${WITH_CALAMARES:-1}"
SKIP_PKG_CHECK="${SKIP_PKG_CHECK:-0}"
CLEAN="${CLEAN:-0}"

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
command -v xorriso     >/dev/null 2>&1 || missing+=("libisoburn")
command -v mkfs.vfat   >/dev/null 2>&1 || missing+=("dosfstools")
command -v mcopy       >/dev/null 2>&1 || missing+=("mtools")
if (( ${#missing[@]} )); then
  echo "Paket wajib belum ada: ${missing[*]}" >&2
  echo "Pasang dulu:  sudo pacman -S --needed archiso squashfs-tools libisoburn dosfstools mtools" >&2
  exit 1
fi

[[ "$CLEAN" == "1" ]] && rm -rf work out build-profile localrepo
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

PKG_LIST="$DEST/packages.x86_64"
if [[ -f "profiles/$PROFILE/packages.x86_64" ]]; then
  cp "profiles/$PROFILE/packages.x86_64" "$PKG_LIST"
  echo "[i] paket dari profiles/$PROFILE/packages.x86_64"
else
  cp packages.x86_64 "$PKG_LIST"
  echo "[i] paket dari packages.x86_64 (default)"
fi

# overlay tambahan per-varian (opsional)
if [[ -d "profiles/$PROFILE/airootfs" ]]; then
  cp -a "profiles/$PROFILE/airootfs/." "$DEST/airootfs/"
  echo "[i] overlay airootfs dari profiles/$PROFILE"
fi

add_pkg() {
  local pkg="$1" file="$2"
  grep -qxF -- "$pkg" "$file" || printf '%s\n' "$pkg" >> "$file"
}

# --- Chaotic-AUR (opsional, best-effort) ---
if [[ "$WITH_CHAOTIC" == "1" ]]; then
  echo "[i] menyiapkan Chaotic-AUR..."
  if scripts/enable-chaotic.sh && [[ -f /etc/pacman.d/chaotic-mirrorlist ]]; then
    sed -i \
      -e 's|^# \[chaotic-aur\]|[chaotic-aur]|' \
      -e 's|^# Include = /etc/pacman.d/chaotic-mirrorlist|Include = /etc/pacman.d/chaotic-mirrorlist|' \
      "$DEST/pacman.conf"
    add_pkg pamac "$PKG_LIST"
    echo "[i] Chaotic-AUR aktif (pamac ditambahkan)"
  else
    echo "[!] Chaotic-AUR gagal disiapkan — build lanjut tanpa repo itu" >&2
  fi
fi

# --- Calamares dari AUR (opsional, best-effort) ---
if [[ "$WITH_CALAMARES" == "1" ]]; then
  echo "[i] membangun Calamares dari AUR (bisa 10-20 menit)..."
  if scripts/build-calamares.sh "$PWD/localrepo"; then
    cat >> "$DEST/pacman.conf" <<EOF

[nusantara-local]
SigLevel = Optional TrustAll
Server = file://$PWD/localrepo
EOF
    add_pkg calamares "$PKG_LIST"

    # Modul python (localecfg) hanya ada bila binding Python ikut dibangun.
    if [[ -f localrepo/calamares-modules.txt ]] && \
       ! grep -qx "localecfg" localrepo/calamares-modules.txt; then
      echo "[!] modul localecfg tidak ada — locale tidak akan ditulis otomatis" >&2
      sed -i '/^[[:space:]]*- localecfg$/d' "$DEST/airootfs/etc/calamares/settings.conf"
    fi
    echo "[i] Calamares siap dipakai di ISO"
  else
    echo "[!] Calamares gagal dibangun — ISO tetap dibuat (installer: archinstall)" >&2
  fi
fi

# --- buang paket yang tidak ada di repo (biar build tidak gagal) ---
if [[ "$SKIP_PKG_CHECK" != "1" ]] && command -v pacman >/dev/null 2>&1; then
  if [[ -x scripts/filter-packages.sh ]]; then
    echo "[i] cek ketersediaan paket..."
    scripts/filter-packages.sh "$PKG_LIST" "$DEST/pacman.conf" || \
      echo "[!] pengecekan paket gagal, lanjut dengan daftar apa adanya" >&2
  fi
fi

# --- build ---
echo "[i] mkarchiso mulai: profil=$PROFILE"
mkarchiso -v -w work -o out "$DEST"

echo
echo "[✓] Selesai. Hasil:"
ls -lh out/*.iso 2>/dev/null || echo "  (tidak ada .iso, cek log di atas)"
