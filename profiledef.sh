#!/usr/bin/env bash
# shellcheck disable=SC2034
# Nusantara OS — profil archiso

iso_name="NusantaraOS"
iso_label="NUSANTARAOS_$(date +%y%m)"
iso_application="Nusantara OS — Arch + KDE + BTRFS (Garuda-style)"
iso_version="$(date +%Y.%m.%d)"
iso_publisher="Nusantara OS Project <dev@nusantaraos.local>"
install_dir="arch"
buildmodes=('iso')
work_dir="work"
out_dir="out"

# Nama bootmode modern (archiso >= 70). Mode *.mbr / *.eltorito lama sudah
# deprecated dan hanya menghasilkan peringatan.
bootmodes=(
  'bios.syslinux'
  'uefi.systemd-boot'
)

arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
# zstd: jauh lebih cepat dari xz dengan rasio hampir sama
airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '15' '-b' '1M')

file_permissions=(
  ["/etc/sudoers.d/g_wheel"]="0:0:440"
  ["/etc/sudoers.d/99-nusantara-live"]="0:0:440"
  ["/usr/local/bin/nusantara-assistant"]="0:0:755"
  ["/usr/local/bin/nusantara-update"]="0:0:755"
  ["/usr/local/bin/nusantara-settings"]="0:0:755"
  ["/usr/local/bin/nusantara-line-cpufreq"]="0:0:755"
  ["/usr/local/bin/nusantara-install"]="0:0:755"
)
