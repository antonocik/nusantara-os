# Nusantara OS - Distro Linux Ala Garuda OS (Lengkap)

Distro Linux berbasis **Arch Linux** terinspirasi Garuda OS.
Dibangun dengan `archiso` + `Calamares`, filesystem **BTRFS + Snapper/Timeshift**, desktop **KDE Plasma**, optimasi gaming & performa.

![Nusantara OS](https://img.shields.io/badge/OS-Nusantara_OS-blue?style=flat-square) ![Arch](https://img.shields.io/badge/Base-Arch%20Linux-1793D1?style=flat-square) ![KDE](https://img.shields.io/badge/DE-KDE%20Plasma-1ABC9C?style=flat-square)

## ✨ Fitur Seperti Garuda OS

| Fitur | Status |
|-------|--------|
| Arch Linux rolling release | ✅ |
| KDE Plasma (default) + pilihan Xfce/GNOME | ✅ profil terpisah |
| Kernel `linux-zen` + fallback `linux-lts` | ✅ |
| BTRFS + Snapper/Timeshift snapshots | ✅ |
| Installer Calamares (grafis) | ✅ |
| Gaming: Steam, Lutris, Proton, GameMode, MangoHud, VkBasalt, RetroArch | ✅ |
| Chaotic-AUR repository | ✅ |
| Performance: `ananicy-cpp`, `systemd-oomd`, `preload`, `tuned`, `earlyoom` | ✅ |
| Audio Pipewire + WirePlumber | ✅ |
| NetworkManager + Firewall (UFW/firewalld) | ✅ |
| App: Firefox, LibreOffice, VLC, GIMP, OBS, Konsole, Kate, Okular, Elisa | ✅ |
| `nusantara-assistant` — tool setup ala Garuda Assistant | ✅ |
| Plymouth splash + SDDM theme | ✅ |
| NVIDIA + AMD + Intel driver otomatis | ✅ |
| Flatpak + Garuda-settings | ✅ |
| Auto-update (garuda-update setara `nusantara-update`) | ✅ |

## 🚀 Cara Build ISO (dari Arch / Garuda / CachyOS)

### 1. Install deps (hanya di Arch-based)
```bash
sudo pacman -Syu archiso git base-devel calamares mkisofs xorriso squashfs-tools dosfstools
git clone https://github.com/archlinux/archiso.git /tmp/archiso
sudo make -C /tmp/archiso install
```

### 2. Build
```bash
chmod +x build.sh
sudo ./build.sh
# hasil: out/NusantaraOS-*.iso
```

Atau make:
```bash
make iso
```

### 3. Test di VM
```bash
make vm
# atau: qemu-system-x86_64 -m 4096 -cdrom out/*.iso -boot d
```

### 4. Install ke Laptop
- Boot ISO > Calamares akan terbuka otomatis (atau dari menu aplikasi)
- Pilih disk > layout BTRFS (default) > Timeshift aktif > Install
- Reboot tanpa USB

## 📁 Struktur Repo
```
.
├── README.md
├── build.sh                 # build ISO
├── profiledef.sh            # definisi profil archiso
├── packages.x86_64          # daftar paket (120+ paket)
├── packages.aur.x86_64      # paket AUR opsional
├── airootfs/                # rootfs live environment
│   ├── etc/
│   │   ├── pacman.conf      # + Chaotic-AUR
│   │   ├── calamares/       # config installer: partition, modules, branding
│   │   ├── skel/            # template /home user baru
│   │   ├── sddm.conf
│   │   └── systemd/system/  # services: NetworkManager, etc
│   └── usr/
│       ├── bin/             # nusantara-assistant, nusantara-update, dll
│       ├── share/
│       │   ├── calamares/
│       │   ├── plymouth/themes/
│       │   └── sddm/themes/
│       └── lib/systemd/
├── syslinux/                # bootloader ISO
├── grub/                    # grub theme + config
├── profiles/                # varian: kde (default), xfce, gnome, sway
├── scripts/                 # util build, branding, chroot
└── docs/
    ├── ARCHITECTURE.md
    ├── BUILD.md
    └── ROADMAP.md
```

## 🖥️ Varian Profil
```bash
# KDE (Garuda dr460nized look) — default
sudo ./build.sh kde

# Xfce ringan
sudo ./build.sh xfce

# GNOME
sudo ./build.sh gnome

# Sway tiling minimal
sudo ./build.sh sway
```
Lihat `profiles/` untuk detail.

## 🛠️ Tool Bawaan
```bash
nusantara-assistant   # menu grafis/terminal: driver, kernel, gaming, snapshot, update
nusantara-update      # update sistem + snapper snapshot otomatis
nusantara-settings    # optimasi: power, wifi, printer, bluetooth
```

## ⚠️ Disclaimer
Proyek ini adalah referensi edukasi untuk membangun distro Arch ala Garuda.
Bukan produk resmi Garuda Linux. Butuh keahlian Linux untuk maintenance & build.
Test di VM dulu sebelum install ke hardware utama.

## 📄 Lisensi
MIT — bebas fork / rename (ganti nama di `profiledef.sh` & `branding.conf`).

---
Dibuat untuk: Ammar — 2026. Mau ganti nama/b branding? edit `profiledef.sh` baris `iso_publisher` & `iso_name` lalu rebuild.
