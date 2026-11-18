#!/usr/bin/env bash
# Bangun paket Calamares dari PKGBUILD lokal (packaging/calamares), lalu
# masukkan ke repo lokal untuk mkarchiso.
#
# Calamares tidak ada di repo resmi Arch (hanya AUR). Supaya build tidak
# bergantung pada ketersediaan AUR, PKGBUILD-nya disimpan di repo ini.
# Skrip ini dipanggil otomatis oleh build.sh (WITH_CALAMARES=1) dan aman
# gagal: build.sh akan lanjut memakai archinstall.
#
# Usage: sudo scripts/build-calamares.sh [dir-repo-lokal]

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTDIR="${1:-$ROOT_DIR/localrepo}"
BUILDER="nusantara-builder"
PKGBUILD_DIR="$ROOT_DIR/packaging/calamares"
AUR_SNAPSHOT="https://aur.archlinux.org/cgit/aur.git/snapshot/calamares.tar.gz"

info() { echo "[calamares] $*" >&2; }
die()  { echo "[calamares] GAGAL: $*" >&2; exit 1; }

[[ $EUID -eq 0 ]] || die "jalankan sebagai root (sudo)"
command -v pacman   >/dev/null 2>&1 || die "pacman tidak ada"
command -v makepkg  >/dev/null 2>&1 || die "makepkg tidak ada (pasang base-devel)"
command -v curl     >/dev/null 2>&1 || die "curl tidak ada"
command -v repo-add >/dev/null 2>&1 || die "repo-add tidak ada (pasang pacman-contrib)"

info "memasang dependensi build..."
pacman -S --needed --noconfirm --asdeps \
  base-devel git curl pacman-contrib \
  python python-yaml \
  kcoreaddons kpmcore libpwquality \
  qt6-declarative qt6-svg yaml-cpp \
  extra-cmake-modules libglvnd ninja qt6-tools qt6-translations

# makepkg menolak berjalan sebagai root
if ! id -u "$BUILDER" >/dev/null 2>&1; then
  info "membuat user build '$BUILDER'"
  useradd -m -s /bin/bash "$BUILDER"
fi
printf '%s ALL=(ALL) NOPASSWD: ALL\n' "$BUILDER" > "/etc/sudoers.d/99-$BUILDER"
chmod 0440 "/etc/sudoers.d/99-$BUILDER"

WORK="$(mktemp -d)"
chmod 0755 "$WORK"
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

mkdir -p "$WORK/calamares"
if [[ -f "$PKGBUILD_DIR/PKGBUILD" ]]; then
  info "memakai PKGBUILD lokal ($PKGBUILD_DIR/PKGBUILD)"
  install -m 0644 "$PKGBUILD_DIR/PKGBUILD" "$WORK/calamares/PKGBUILD"
  [[ -f "$PKGBUILD_DIR/calamares.install" ]] && \
    install -m 0644 "$PKGBUILD_DIR/calamares.install" "$WORK/calamares/"
else
  info "PKGBUILD lokal tidak ada, mengunduh snapshot AUR..."
  curl -fsSL --retry 3 --max-time 120 -o "$WORK/calamares.tar.gz" "$AUR_SNAPSHOT"
  tar -xzf "$WORK/calamares.tar.gz" -C "$WORK"
  [[ -f "$WORK/calamares/PKGBUILD" ]] || die "PKGBUILD tidak ditemukan di snapshot"
fi

chown -R "$BUILDER":"$BUILDER" "$WORK"

info "makepkg (Qt6, ninja) — bisa 10-20 menit..."
su - "$BUILDER" -c "cd '$WORK/calamares' && makepkg -s --noconfirm --needed --noprogressbar" \
  || die "makepkg gagal"

PKG="$(ls "$WORK"/calamares/calamares-*.pkg.tar.zst 2>/dev/null | head -n1 || true)"
[[ -n "$PKG" && -f "$PKG" ]] || die "paket hasil build tidak ditemukan"

mkdir -p "$OUTDIR"
cp -f "$PKG" "$OUTDIR"/
info "paket: $(basename "$PKG")"

# Catat modul yang benar-benar dibangun. Modul Python (mount, unpackfs,
# displaymanager, ...) hanya ada bila binding Python ikut terbangun, jadi
# daftar ini dipakai untuk memastikan installer tidak setengah jadi.
tar --zstd -tf "$PKG" \
  | sed -n 's#^usr/lib/calamares/modules/\([^/]*\)/.*#\1#p' \
  | sort -u > "$OUTDIR/calamares-modules.txt"
info "modul terbangun: $(wc -l < "$OUTDIR/calamares-modules.txt") buah"

REQUIRED=(
  welcome locale keyboard partition users summary
  mount unpackfs machineid fstab displaymanager networkcfg hwclock
  services-systemd plymouthcfg shellprocess grubcfg bootloader
  umount finished
)
missing=()
for m in "${REQUIRED[@]}"; do
  grep -qx "$m" "$OUTDIR/calamares-modules.txt" || missing+=("$m")
done
if (( ${#missing[@]} )); then
  die "modul wajib tidak terbangun: ${missing[*]} (binding Python gagal?)"
fi

repo-add --quiet "$OUTDIR/nusantara-local.db.tar.gz" "$OUTDIR/$(basename "$PKG")"
info "repo lokal siap di $OUTDIR"
