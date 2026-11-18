# Status Proyek

Terakhir diperbarui: 2026-11-18 (build CI pertama yang berhasil)

## Ringkasan

Repo berisi source lengkap distro archiso. Build ISO penuh dilakukan lewat
GitHub Actions (container Arch) atau lokal di Arch/Garuda.

| Komponen | Status |
|---|---|
| Profil archiso (`profiledef.sh`) | ✅ bootmode modern `bios.syslinux` + `uefi.systemd-boot` |
| Boot config | ✅ `syslinux/`, `efiboot/`, `grub/` — kernel `linux-zen` + placeholder archiso |
| Initramfs live | ✅ `airootfs/etc/mkinitcpio.conf.d/archiso.conf` + `mkinitcpio-archiso` |
| Daftar paket | ✅ 173 paket, semuanya terverifikasi ada di core/extra/multilib |
| Filter paket | ✅ mendukung nama paket, grup (`xfce4`), multilib, repo lokal |
| Build script | ✅ overlay profil, cek toolchain, Calamares (PKGBUILD lokal), Chaotic-AUR opsional |
| CI | ✅ `.github/workflows/build-iso.yml` (input profil/calamares/chaotic) |
| Calamares | ✅ 3.4 — 21 modul, branding `nusantara`, QML slideshow |
| Live session | ✅ user `nusantara`, autologin SDDM, installer di desktop |
| Tema | ✅ SDDM `nusantara`, Plymouth, GRUB, logo SVG + PNG |
| Tool | ✅ assistant, update, settings, install, line-cpufreq (tanpa asumsi AUR/timeshift) |
| Dokumentasi | ✅ README, ARCHITECTURE, BUILD, BUILD-REPORT, ROADMAP |

## Sudah diverifikasi di repo ini

- `bash -n` untuk semua skrip: lolos
- 23 file YAML Calamares + workflow: lolos parser YAML
- 21 modul di `settings.conf` semuanya ada di sumber Calamares 3.4.2
- 173 paket `packages.x86_64`: 173/173 ditemukan di DB core/extra/multilib
- Config Calamares: semua key cocok dengan schema 3.4 (kecuali `swapPartitionName` yang dibaca runtime)
- Semua path di `file_permissions` ada di `airootfs/`
- SVG logo: XML valid
- Tema SDDM ditulis ulang untuk **SDDM 0.21 / Qt6**: hanya `SddmComponents 2.0`
  (TextBox, ComboBox, Button, Clock) — properti dicocokkan satu per satu dengan
  sumber upstream `components/2.0/*.qml`; `QtGraphicalEffects`, `Screen.width`,
  `userModel.currentUser` (tidak ada di SDDM) sudah dibuang
- Identitas distro: `airootfs/usr/lib/os-release`, `etc/lsb-release`, `etc/issue`
  (ID `nusantara`, `ID_LIKE=arch`)
- Tema Plymouth ditulis ulang memakai API asli modul script (diverifikasi ke
  `src/plugins/splash/script/script-lib-*.script` upstream): `Sprite(image)`,
  `SetX/SetY/SetOpacity`, `Image.Text(teks,r,g,b,alpha,font)`,
  `Plymouth.SetRefreshFunction/SetBootProgressFunction`. `Window.Hook(...)` dan
  `sprite.position` (yang dipakai versi lama) tidak ada di Plymouth.
  `nusantara.plymouth` sekarang punya `ScriptFile=` + `ImageDir=` — tanpa
  `ScriptFile`, plugin script Plymouth tidak memuat skrip apa pun

## Belum diverifikasi (butuh host Arch / runner CI)

- `mkarchiso` end-to-end (ukuran ISO final, waktu build)
- Build Calamares dari `packaging/calamares` di container (durasi + modul Python)
- Boot ISO hasil build: syslinux/UEFI, Plymouth, SDDM autologin
- Install Calamares sampai selesai, termasuk subvolume BTRFS + Snapper
- Tema SDDM/Plymouth tampil benar di layar (tema sudah lolos audit API Qt6,
  tapi belum pernah dirender di mesin nyata)

## Build CI pertama yang berhasil

Run [`44335794471`](https://github.com/antonocik/nusantara-os/actions/runs/44335794471)
(commit `5d1db49`, 18 Nov 2026):

| Item | Hasil |
|---|---|
| Waktu build | 14 menit 26 detik (termasuk Calamares 3.4.2 dari PKGBUILD lokal) |
| ISO | `NusantaraOS-2026.11.18-x86_64.iso` — **4.5 GB** |
| SHA256 | `939896cd5182749f4bd9a33b2e018eb3b5ce1495d628effe7cd9b468ebea92fd` |
| Paket | `[filter] tersedia: 174 paket` (173 + `calamares`) |
| Calamares | 48 modul terbangun, termasuk modul Python (`localecfg`, `unpackfs`, `displaymanager`, ...) |
| Kernel live | `vmlinuz-linux-zen` + `initramfs-linux-zen.img` |
| Kegagalan | Hanya langkah CI `Checksum`: `out/` milik root → `tee out/SHA256SUMS` permission denied. Sudah diperbaiki (`sudo chown -R`) |

## ISO preview

`v2026.11.07` berisi ISO 18 MB: kernel Arch 7.2.14 + initramfs busybox + shell.
Hanya untuk membuktikan boot chain, **bukan** sistem yang bisa di-install.

## Langkah berikutnya

1. Jalankan workflow `build-iso` dan baca log `[filter]` / `[calamares]`.
2. Uji ISO penuh di QEMU: live session → Calamares → install ke disk.
3. Cek snapshot BTRFS (`snapper list`, boot menu `grub-btrfs`).
4. Rapikan ukuran ISO (< 4 GB) bila perlu.
5. Siapkan repo paket sendiri (`repo.nusantaraos.org`) bila ingin paket AUR ikut.
