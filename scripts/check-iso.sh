#!/usr/bin/env bash
# Periksa ISO Nusantara OS tanpa perlu booting.
#
# Usage: scripts/check-iso.sh [file.iso]
#
# Yang dicek:
#   1. kernel + initramfs di /arch/boot/x86_64
#   2. rootfs live (/arch/x86_64/airootfs.sfs) bisa dibaca
#   3. file kunci ada di dalam rootfs: Calamares + branding, tema SDDM,
#      autologin live, user live, sudoers, hook archiso, installer desktop
#   4. ukuran + SHA256

set -euo pipefail

ISO="${1:-$(ls out/*.iso 2>/dev/null | head -n1 || true)}"
[[ -n "${ISO:-}" && -f "$ISO" ]] || {
  echo "ISO tidak ditemukan. Pakai: scripts/check-iso.sh path/ke/file.iso" >&2
  exit 1
}

for t in xorriso unsquashfs sha256sum; do
  command -v "$t" >/dev/null 2>&1 || { echo "butuh '$t' (libisoburn / squashfs-tools)" >&2; exit 1; }
done

echo "== ISO =="
printf '  file   : %s\n' "$ISO"
printf '  ukuran : %s\n' "$(du -h "$ISO" | cut -f1)"
printf '  sha256 : %s\n\n' "$(sha256sum "$ISO" | cut -d' ' -f1)"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "== Boot =="
xorriso -indev "$ISO" -find /arch/boot/x86_64 -type f -exec lsdl 2>/dev/null | sed 's/^/  /'
xorriso -indev "$ISO" -find /arch/boot/syslinux -type f -exec lsdl 2>/dev/null | sed 's/^/  /' | head -n 5

echo
echo "== Rootfs live =="
xorriso -osirrox on -indev "$ISO" \
  -extract /arch/x86_64/airootfs.sfs "$tmp/airootfs.sfs" >/dev/null 2>&1 || {
  echo "  GAGAL mengekstrak /arch/x86_64/airootfs.sfs" >&2
  exit 1
}
printf '  airootfs.sfs: %s\n' "$(du -h "$tmp/airootfs.sfs" | cut -f1)"

unsquashfs -l "$tmp/airootfs.sfs" | sed 's|^squashfs-root/||' > "$tmp/list.txt"

key_files=(
  etc/calamares/settings.conf
  etc/calamares/branding/nusantara/branding.desc
  etc/calamares/branding/nusantara/show.qml
  etc/calamares/modules/partition.conf
  etc/calamares/modules/unpackfs.conf
  etc/calamares/modules/shellprocess.conf
  etc/mkinitcpio.conf.d/archiso.conf
  etc/sddm.conf.d/99-nusantara-autologin.conf
  etc/sddm.conf.d/99-nusantara.conf
  etc/sysusers.d/nusantara-live.conf
  etc/tmpfiles.d/nusantara-live.conf
  etc/sudoers.d/99-nusantara-live
  etc/systemd/system/multi-user.target.wants/sddm.service
  etc/systemd/system/multi-user.target.wants/NetworkManager.service
  etc/hostname
  usr/bin/calamares
  usr/bin/sddm
  usr/local/bin/nusantara-install
  usr/share/sddm/themes/nusantara/Main.qml
  usr/share/plymouth/themes/nusantara/nusantara.plymouth
  home/nusantara/Desktop/nusantara-install.desktop
)

fail=0
for f in "${key_files[@]}"; do
  if grep -qx -- "$f" "$tmp/list.txt"; then
    printf '  ✓ %s\n' "$f"
  else
    printf '  ✗ %s (HILANG)\n' "$f"
    fail=$((fail + 1))
  fi
done

echo
if (( fail )); then
  echo "HASIL: $fail file kunci hilang — ISO kemungkinan tidak bisa dipakai."
  exit 1
fi
echo "HASIL: semua file kunci ada. ISO siap diuji di QEMU/Ventoy."
