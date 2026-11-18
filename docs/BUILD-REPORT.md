# Status Proyek

Terakhir diperbarui: 2026-11-18

## Ringkasan

Repo berisi source lengkap distro archiso. Build ISO penuh dilakukan lewat
GitHub Actions (container Arch) atau lokal di Arch/Garuda.

| Komponen | Status |
|---|---|
| Profil archiso (`profiledef.sh`) | ✅ bootmode modern `bios.syslinux` + `uefi.systemd-boot` |
| Boot config | ✅ `syslinux/`, `efiboot/`, `grub/` — kernel `linux-zen` + placeholder archiso |
| Initramfs live | ✅ `airootfs/etc/mkinitcpio.conf.d/archiso.conf` + `mkinitcpio-archiso` |
| Daftar paket | ✅ 167 paket, semuanya terverifikasi ada di core/extra/multilib |
| Filter paket | ✅ mendukung nama paket, grup (`xfce4`), multilib, repo lokal |
| Build script | ✅ overlay profil, cek toolchain, Calamares (AUR), Chaotic-AUR opsional |
| CI | ✅ `.github/workflows/build-iso.yml` (input profil/calamares/chaotic) |
| Calamares | ✅ 3.4 — 21 modul, branding `nusantara`, QML slideshow |
| Live session | ✅ user `nusantara`, autologin SDDM, installer di desktop |
| Tema | ✅ SDDM `nusantara`, Plymouth, GRUB, logo SVG + PNG |
| Tool | ✅ assistant, update, settings, install, line-cpufreq |
| Dokumentasi | ✅ README, ARCHITECTURE, BUILD, BUILD-REPORT, ROADMAP |

## Sudah diverifikasi di repo ini

- `bash -n` untuk semua skrip: lolos
- 23 file YAML Calamares + workflow: lolos parser YAML
- 21 modul di `settings.conf` semuanya ada di sumber Calamares 3.4.2
- 167 paket `packages.x86_64`: 167/167 ditemukan di DB core/extra/multilib
- Semua path di `file_permissions` ada di `airootfs/`
- SVG logo: XML valid

## Belum diverifikasi (butuh host Arch / runner CI)

- `mkarchiso` end-to-end (ukuran ISO final, waktu build)
- Build Calamares dari AUR di container (durasi + modul python `localecfg`)
- Boot ISO hasil build: syslinux/UEFI, Plymouth, SDDM autologin
- Install Calamares sampai selesai, termasuk subvolume BTRFS + Snapper
- Tema SDDM/Plymouth tampil benar di layar

## ISO preview

`v2026.11.07` berisi ISO 18 MB: kernel Arch 7.2.14 + initramfs busybox + shell.
Hanya untuk membuktikan boot chain, **bukan** sistem yang bisa di-install.

## Langkah berikutnya

1. Jalankan workflow `build-iso` dan baca log `[filter]` / `[calamares]`.
2. Uji ISO penuh di QEMU: live session → Calamares → install ke disk.
3. Cek snapshot BTRFS (`snapper list`, boot menu `grub-btrfs`).
4. Rapikan ukuran ISO (< 4 GB) bila perlu.
5. Siapkan repo paket sendiri (`repo.nusantaraos.org`) bila ingin paket AUR ikut.
