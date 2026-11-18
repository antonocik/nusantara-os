# Status Proyek

Terakhir diperbarui: 2026-11-18

## Ringkasan

Repo berisi source lengkap distro archiso. Build ISO penuh dilakukan lewat
GitHub Actions (container Arch) atau lokal di Arch/Garuda.

| Komponen | Status |
|---|---|
| Profil archiso (`profiledef.sh`) | ✅ lengkap, bootmode BIOS + UEFI |
| Boot config | ✅ `syslinux/`, `efiboot/`, `grub/` dengan placeholder archiso |
| Daftar paket | ✅ `packages.x86_64` (repo resmi) + `packages.aur.x86_64` (opsional) |
| Filter paket | ✅ `scripts/filter-packages.sh` membuang paket tak tersedia |
| Build script | ✅ `build.sh` — overlay profil, deteksi sudo/root, cek toolchain |
| CI | ✅ `.github/workflows/build-iso.yml` (archlinux container, artefak + release) |
| Calamares | ✅ 23 modul conf, schema 3.3, BTRFS subvolume |
| Tema | ✅ SDDM `nusantara`, Plymouth, GRUB, logo SVG + PNG |
| Tool | ✅ assistant, update, settings, line-cpufreq |
| Dokumentasi | ✅ README, ARCHITECTURE, BUILD, ROADMAP |

## Sudah diverifikasi di repo ini

- `bash -n` untuk semua skrip: lolos
- Semua YAML Calamares + workflow: lolos parser YAML
- SVG logo: XML valid
- `profiledef.sh` menyebut path `file_permissions` yang semuanya ada di `airootfs/`

## Belum diverifikasi (butuh host Arch)

- `mkarchiso` end-to-end (nama paket & ukuran ISO final)
- Boot ISO hasil build di VM
- Install Calamares sampai selesai, termasuk pembuatan subvolume BTRFS
- Tema SDDM/Plymouth tampil benar di layar

## ISO preview

`v2026.11.07` berisi ISO 18 MB: kernel Arch 7.2.14 + initramfs busybox + shell.
Hanya untuk membuktikan boot chain, **bukan** sistem yang bisa di-install.

## Langkah berikutnya

1. Jalankan workflow `build-iso` dan perbaiki paket yang dilaporkan `filter-packages`.
2. Uji ISO penuh di QEMU, lalu install ke VM dan cek snapshot BTRFS.
3. Rapikan ukuran ISO (< 4 GB) bila perlu.
4. Siapkan repo paket sendiri (`repo.nusantaraos.org`) bila ingin paket AUR ikut.
