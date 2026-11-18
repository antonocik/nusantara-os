# Arsitektur NusantaraOS

## Prinsip (copied Garuda)
1. **Arch rolling** — selalu update, bukan LTS kaku
2. **BTRFS everywhere** — root/home/snapshot terpisah subvolume
3. **Gaming-first tuning** — kernel zen, gamemode, ananicy, earlyoom
4. **Installer grafis** — Calamares, bukan CLI manual
5. **Tool assistant** — satu pintu setup pasca-install

## Alur Build
```
profiledef.sh + packages.x86_64 + airootfs/
        |
   mkarchiso
        |
out/NusantaraOS-*.iso (squashfs + syslinux + systemd-boot)
```

## Filesystem Layout Installer (calamares/partition.conf)
- /boot/efi : FAT32 512MiB
- /boot      : BTRFS 1GiB (subvolume @boot)
- /          : BTRFS @
- /home      : BTRFS @home
- /.snapshots: BTRFS @snapshots
- /var/log   : BTRFS @var_log
- swap       : 2GiB partition (+ zram via systemd-zram)

## Desktop
- Default: KDE Plasma 6 + SDDM + Sweet/Nord theme
- Alt: Xfce (LightDM), GNOME (GDM), Sway (greetd)

## Kernel
- Default linux-zen, fallback linux-lts, opsional linux-cachyos
- Plymouth splash untuk boot cantik

## Repo
- core/extra/multilib dari Arch
- chaotic-aur untuk AUR mentah (seperti Garuda)
- Flatpak untuk app terisolasi
