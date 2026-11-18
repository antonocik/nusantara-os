#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="NusantaraOS"
iso_label="NUSANTARAOS_2026"
iso_application="Nusantara OS Linux - Garuda-like Arch Distro"
iso_version="2026.11.07"
iso_publisher="Nusantara OS Project <dev@nusantaraos.local>"
install_dir="arch"
buildmodes=('iso')
work_dir="work"
out_dir="out"

bootmodes=(
  'bios.syslinux.mbr'
  'bios.syslinux.eltorito'
  'uefi-ia32.systemd-boot.eltorito'
  'uefi-x64.systemd-boot.eltorito'
  'uefi-x64.systemd-boot.esp'
)

arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M')

file_permissions=(
  ["/etc/sudoers.d/g_wheel"]="0:0:440"
  ["/usr/local/bin/nusantara-line-cpufreq"]="0:0:755"
  ["/usr/local/bin/nusantara-assistant"]="0:0:755"
  ["/usr/local/bin/nusantara-update"]="0:0:755"
  ["/usr/local/bin/nusantara-settings"]="0:0:755"
  ["/usr/bin/calamares"]="0:0:755"
)
