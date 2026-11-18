# Panduan Build

## Syarat

| Item | Nilai |
|---|---|
| OS host | Arch Linux / Garuda / CachyOS / Manjaro (atau container `archlinux`) |
| Disk kosong | ±20 GB |
| RAM | 4 GB minimum, 8 GB disarankan |
| Internet | perlu (unduh paket + sumber Calamares) |

Ubuntu, Debian, Fedora, dan macOS **tidak didukung** — `mkarchiso` hanya ada di Arch.

## Build lokal

```bash
sudo pacman -Syu --needed archiso squashfs-tools libisoburn mtools dosfstools base-devel git zstd
git clone https://github.com/antonocik/nusantara-os
cd nusantara-os
sudo ./build.sh kde
```

Urutan yang dilakukan `build.sh`:

1. Cek toolchain (`mkarchiso`, `mksquashfs`, `xorriso`, `mkfs.vfat`, `mcopy`).
2. Susun profil gabungan di `build-profile/`:
   - `airootfs/`, `syslinux/`, `efiboot/`, `grub/`, `profiledef.sh`, `pacman.conf`
   - daftar paket dari `profiles/<varian>/packages.x86_64` bila ada, kalau tidak `packages.x86_64`
   - overlay `profiles/<varian>/airootfs/` bila ada
3. **Calamares** (default aktif): `scripts/build-calamares.sh` membangun paket dari AUR,
   menaruhnya di `localrepo/`, lalu menambahkan repo `[nusantara-local]` ke pacman.conf.
4. **Chaotic-AUR** (opsional, `WITH_CHAOTIC=1`): `scripts/enable-chaotic.sh` memasang keyring
   + mirrorlist, lalu repo `[chaotic-aur]` diaktifkan dan `pamac` ditambahkan.
5. `scripts/filter-packages.sh <paket> <pacman.conf>` membuang paket/grup yang tidak ada
   di repo mana pun (memakai konfigurasi pacman profil, jadi multilib & repo lokal ikut dicek).
6. Jalankan `mkarchiso -v -w work -o out build-profile`.

Hasil: `out/NusantaraOS-<YYYY.MM.DD>-x86_64.iso`.

### Variabel lingkungan

| Variabel | Default | Arti |
|---|---|---|
| `WITH_CALAMARES` | `1` | Bangun Calamares 3.4 dari AUR (best-effort) |
| `WITH_CHAOTIC` | `0` | Aktifkan Chaotic-AUR + `pamac` |
| `SKIP_PKG_CHECK` | `0` | Lewati filter paket |
| `CLEAN` | `0` | Hapus `work/`, `out/`, `build-profile/`, `localrepo/` |

Bila Calamares gagal dibangun, build **tidak** berhenti: paket `calamares` otomatis
dibuang oleh filter, dan ISO memakai `archinstall` (TUI, ada di repo resmi).

## Build lewat GitHub Actions

Workflow `.github/workflows/build-iso.yml`:

- Trigger: push ke `main`, `workflow_dispatch`, dan `release: published`.
- Berjalan di `ubuntu-latest`, mengeksekusi container `archlinux:latest` dengan `--privileged`
  (butuh akses loop device untuk `mkarchiso`).
- Input manual: `profile`, `calamares` (1/0), `chaotic` (0/1).
- Artefak `NusantaraOS-iso` disimpan 14 hari.
- Saat release dipublikasikan, ISO otomatis dilampirkan ke release.

Menjalankan manual:

```bash
gh workflow run build-iso -f profile=kde -f calamares=1 -f chaotic=0
gh run watch
```

## Profil varian

| Profil | Desktop | Login manager |
|---|---|---|
| `kde` (default) | KDE Plasma | SDDM |
| `xfce` | Xfce | LightDM |
| `gnome` | GNOME | GDM |
| `sway` | Sway (tiling) | greetd/manual |

## Live session

| Komponen | Nilai |
|---|---|
| User | `nusantara` (dibuat `systemd-sysusers` saat boot) |
| Home | `/home/nusantara` (dibuat `systemd-tmpfiles`) |
| Login | SDDM autologin `99-nusantara-autologin.conf` |
| Sudo | NOPASSWD (`/etc/sudoers.d/99-nusantara-live`) |
| Installer | `/home/nusantara/Desktop/nusantara-install.desktop` → `nusantara-install` |

Calamares menghapus semua sisa live session saat install (`modules/shellprocess.conf`):
autologin, user live, sudoers, sysusers, tmpfiles, hook `archiso`, lalu menjalankan
`mkinitcpio -P`, membuat config Snapper, dan `grub-mkconfig`.

## Uji ISO

```bash
qemu-system-x86_64 -m 8192 -smp 4 -enable-kvm -cdrom out/*.iso -boot d
```

Cek boot: menu syslinux/UEFI → splash Plymouth → SDDM autologin → desktop Plasma.
Untuk install, klik ikon **Install Nusantara OS**.

## Troubleshooting

| Gejala | Penyebab / solusi |
|---|---|
| `mkarchiso: command not found` | `sudo pacman -S archiso` |
| `The 'syslinux' package is missing from the package list!` | `syslinux` wajib ada di `packages.x86_64` |
| `xorriso`/`mcopy` tidak ditemukan | `sudo pacman -S libisoburn mtools dosfstools` |
| Build gagal `target not found: <paket>` | jalankan `scripts/filter-packages.sh`, atau hapus paket tersebut; paket AUR ada di `packages.aur.x86_64` |
| Calamares gagal dibangun | build lanjut dengan `archinstall`; cek log `[calamares]` (butuh `kpmcore`, `qt6-*`) |
| `failed to mount /dev/loop` | butuh hak root / container `--privileged` |
| ISO > 4 GB | kurangi paket berat (`gimp`, `krita`, `obs-studio`, `libreoffice-still`) |
| Layar hitam saat boot | pilih entri **Safe Mode** di menu boot |
| Live session tidak autologin | cek `journalctl -b -u sddm`, `systemd-sysusers` (user `nusantara`) |

## Ganti nama distro

```bash
./scripts/branding.sh "NamaBaru" "dev@namabaru.id"
sudo ./build.sh kde
```
