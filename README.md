# Nusantara OS

**Distro Linux berbasis Arch — ala Garuda OS.** KDE Plasma, BTRFS + snapshot, live session siap pakai, dan tuning gaming.

<p align="center">
  <img src="assets/logo.png" alt="Logo Nusantara OS" width="180">
</p>

<p align="center">
  <a href="../../actions/workflows/build-iso.yml"><img alt="build-iso" src="../../actions/workflows/build-iso.yml/badge.svg"></a>
  <img alt="base" src="https://img.shields.io/badge/base-Arch%20Linux-1793D1">
  <img alt="desktop" src="https://img.shields.io/badge/desktop-KDE%20Plasma-1ABC9C">
  <img alt="filesystem" src="https://img.shields.io/badge/fs-BTRFS%20%2B%20Snapper-3ECF8E">
  <img alt="installer" src="https://img.shields.io/badge/installer-Calamares%20%7C%20archinstall-orange">
  <img alt="license" src="https://img.shields.io/badge/license-MIT-blue">
</p>

> Bukan produk resmi Garuda Linux dan tidak berafiliasi dengannya.

---

## Fitur

| Fitur | Detail |
|---|---|
| Basis | Arch Linux rolling release |
| Kernel | `linux-zen` + microcode AMD/Intel (`linux-lts`, `linux-cachyos` opsional) |
| Desktop | KDE Plasma (`plasma-meta`), SDDM; varian Xfce / GNOME / Sway |
| Filesystem | BTRFS subvolume `@`, `@home`, `@snapshots`, `@var_log`, `@var_cache` |
| Snapshot | Snapper + Timeshift + `grub-btrfs` (boot ke snapshot) |
| Installer | **Calamares 3.4** (dibangun dari AUR saat build) dengan fallback **archinstall** |
| Live session | Autologin user `nusantara` ke Plasma, sudo tanpa password, ikon "Pasang Nusantara OS" |
| Gaming | Steam, Lutris, GameMode, MangoHud, RetroArch, Winetricks |
| Grafis | Mesa + Vulkan (AMD/Intel), driver NVIDIA di `nusantara-assistant` |
| Audio | PipeWire + WirePlumber + SOF firmware |
| Jaringan | NetworkManager, BlueZ, firewall KDE |
| Performa | `earlyoom`, `tuned`, `thermald` |
| Tema | Merah-putih: SDDM `nusantara`, Plymouth, GRUB, Calamares, logo Garuda |
| Tool | `nusantara-assistant`, `nusantara-update`, `nusantara-settings`, `nusantara-install` |

## Build ISO

### Otomatis (GitHub Actions)

Workflow [`.github/workflows/build-iso.yml`](.github/workflows/build-iso.yml) membangun ISO di container `archlinux:latest` setiap push ke `main`, lalu mengunggahnya sebagai artefak.

- **Actions → build-iso → Run workflow** untuk build manual (pilih profil `kde`/`xfce`/`gnome`/`sway`, dan opsi Calamares/Chaotic-AUR)
- Setiap release baru otomatis melampirkan ISO ke halaman release
- Unduh hasil: tab **Actions** → run terakhir → **Artifacts → NusantaraOS-iso**

### Manual (di Arch / Garuda / CachyOS)

```bash
sudo pacman -Syu --needed archiso squashfs-tools libisoburn mtools dosfstools base-devel git zstd
git clone https://github.com/antonocik/nusantara-os && cd nusantara-os

sudo ./build.sh kde          # atau: xfce | gnome | sway
ls -lh out/*.iso             # NusantaraOS-<tanggal>-x86_64.iso
```

Variabel lingkungan yang berguna:

```bash
CLEAN=1 sudo ./build.sh kde                 # hapus work/, out/, localrepo/ dulu
SKIP_PKG_CHECK=1 sudo ./build.sh            # lewati pengecekan paket
WITH_CALAMARES=0 sudo ./build.sh            # tanpa installer grafis (pakai archinstall)
WITH_CHAOTIC=1 sudo ./build.sh              # tambah repo Chaotic-AUR + pamac
```

`WITH_CALAMARES` default **1**: Calamares tidak ada di repo resmi Arch, jadi `build.sh` membangun paketnya dari AUR (10–20 menit) dan memasukkannya ke repo lokal `localrepo/`. Kalau gagal, build tetap lanjut dan ISO memakai `archinstall`.

Build butuh ~20 GB disk kosong dan koneksi internet. Ubuntu/Debian **tidak bisa** — `mkarchiso` hanya ada di Arch.

### Uji di VM

```bash
make vm
# atau
qemu-system-x86_64 -m 8192 -smp 4 -enable-kvm -cdrom out/*.iso -boot d
```

### Tulis ke USB

```bash
sudo dd if=out/*.iso of=/dev/sdX bs=4M status=progress oflag=sync   # ganti sdX!
# atau salin ke Ventoy
```

## Status ISO

Tiga hal berbeda, jangan tertukar:

1. **ISO preview (rilis `v2026.11.07`)** — 18 MB, bootable, berisi kernel Arch + shell busybox. Dibuat di host Ubuntu tanpa `mkarchiso`, hanya untuk membuktikan boot chain berjalan.
2. **ISO penuh** — KDE + ±170 paket + Calamares, ±3–4 GB. Dibangun dengan `sudo ./build.sh kde` atau lewat GitHub Actions.
3. **Live session** — setelah boot: SDDM autologin `nusantara` → Plasma; ikon **Install Nusantara OS** menjalankan Calamares (`pkexec calamares`) atau `archinstall` bila Calamares tidak ikut.

## Struktur repo

```
.
├── profiledef.sh              # definisi ISO (nama, label, bootmode, izin file)
├── packages.x86_64            # paket repo resmi Arch
├── packages.aur.x86_64        # paket AUR opsional (tidak dipakai saat build)
├── pacman.conf                # konfigurasi pacman untuk mkarchiso
├── build.sh                   # build ISO + overlay profil + Calamares/Chaotic
├── Makefile                   # make iso / vm / clean / check
├── scripts/
│   ├── branding.sh            # ganti nama distro
│   ├── build-calamares.sh     # bangun Calamares dari AUR -> localrepo/
│   ├── enable-chaotic.sh      # pasang keyring + mirrorlist Chaotic-AUR
│   └── filter-packages.sh     # buang paket/grup yang tidak ada di repo
├── syslinux/syslinux.cfg      # boot BIOS
├── efiboot/                   # boot UEFI (systemd-boot)
├── grub/grub.cfg              # opsi boot GRUB
├── profiles/                  # varian: xfce, gnome, sway
├── airootfs/                  # isi rootfs live
│   ├── etc/calamares/         # settings, modul, branding nusantara
│   ├── etc/mkinitcpio.conf.d/ # hook archiso (live saja)
│   ├── etc/plymouth/          # splash
│   ├── etc/sddm.conf.d/       # tema + autologin live
│   ├── etc/sysusers.d/        # user live `nusantara`
│   ├── etc/tmpfiles.d/        # /home/nusantara saat boot
│   ├── usr/local/bin/         # nusantara-assistant, -update, -settings, -install
│   └── usr/share/             # tema SDDM/Plymouth, logo, pixmaps
├── assets/                    # logo.svg, logo.png
└── docs/                      # arsitektur, build, laporan, roadmap
```

## Tool bawaan

```bash
nusantara-install     # buka installer (Calamares, fallback archinstall)
nusantara-assistant   # menu: driver GPU, kernel, gaming, printer, snapshot, cleanup
nusantara-update      # snapshot → reflector → pacman -Syu → pamac → cache
nusantara-settings    # aktifkan NetworkManager/Bluetooth/CUPS/tuned
```

## Lisensi

MIT — lihat [LICENSE](LICENSE). "Garuda Linux" adalah merek pemiliknya masing-masing.
