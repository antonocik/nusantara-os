# Panduan Build

## Syarat

| Item | Nilai |
|---|---|
| OS host | Arch Linux / Garuda / CachyOS / Manjaro (atau container `archlinux`) |
| Disk kosong | ±20 GB |
| RAM | 4 GB minimum, 8 GB disarankan |
| Internet | perlu (unduh paket) |

Ubuntu, Debian, Fedora, dan macOS **tidak didukung** — `mkarchiso` hanya ada di Arch.

## Build lokal

```bash
sudo pacman -Syu --needed archiso squashfs-tools base-devel git zstd
git clone https://github.com/antonocik/nusantara-os
cd nusantara-os
sudo ./build.sh kde
```

Urutan yang dilakukan `build.sh`:

1. Cek toolchain (`mkarchiso`, `mksquashfs`).
2. Susun profil gabungan di `build-profile/`:
   - `airootfs/`, `syslinux/`, `efiboot/`, `grub/`, `profiledef.sh`, `pacman.conf`
   - daftar paket dari `profiles/<varian>/packages.x86_64` bila ada, kalau tidak `packages.x86_64`
   - overlay `profiles/<varian>/airootfs/` bila ada
3. Jalankan `scripts/filter-packages.sh` untuk membuang paket yang tidak ada di repo (supaya build tidak gagal karena satu nama paket salah).
4. Jalankan `mkarchiso -v -w work -o out build-profile`.

Hasil: `out/NusantaraOS-<YYYY.MM.DD>-x86_64.iso`.

## Build lewat GitHub Actions

Workflow `.github/workflows/build-iso.yml`:

- Trigger: push ke `main`, `workflow_dispatch`, dan `release: published`.
- Berjalan di `ubuntu-latest`, mengeksekusi container `archlinux:latest` dengan `--privileged` (butuh akses loop device untuk `mkarchiso`).
- Artefak `NusantaraOS-iso` disimpan 14 hari.
- Saat release dipublikasikan, ISO otomatis dilampirkan ke release.

Menjalankan manual:

```bash
gh workflow run build-iso -f profile=kde
gh run watch
```

## Profil varian

| Profil | Desktop | Login manager |
|---|---|---|
| `kde` (default) | KDE Plasma | SDDM |
| `xfce` | Xfce | LightDM |
| `gnome` | GNOME | GDM |
| `sway` | Sway (tiling) | greetd/manual |

## Uji ISO

```bash
qemu-system-x86_64 -m 8192 -smp 4 -enable-kvm -cdrom out/*.iso -boot d
```

Cek boot: menu syslinux/UEFI → splash Plymouth → SDDM → desktop. Untuk install, jalankan Calamares dari menu aplikasi.

## Troubleshooting

| Gejala | Penyebab / solusi |
|---|---|
| `mkarchiso: command not found` | `sudo pacman -S archiso` |
| Build gagal `target not found: <paket>` | jalankan `scripts/filter-packages.sh`, atau hapus paket tersebut; paket AUR ada di `packages.aur.x86_64` dan tidak boleh masuk ISO |
| `failed to mount /dev/loop` | butuh hak root / container `--privileged` |
| ISO > 4 GB | kurangi paket dev (`gcc`, `clang`, `rust`, `go`, `docker`) dari `packages.x86_64` |
| Calamares tidak muncul | cek `journalctl -b -u calamares` di live session |
| Layar hitam saat boot | pilih entri **Safe Mode** di menu boot |

## Ganti nama distro

```bash
./scripts/branding.sh "NamaBaru" "dev@namabaru.id"
sudo ./build.sh kde
```
