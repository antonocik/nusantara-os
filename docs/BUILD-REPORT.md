# Nusantara OS — Build Report
Tanggal: 2026-11-07

Status: BUILD-READY (source lengkap, validasi lolos)

## Validasi
- build.sh: bash -n OK
- profiledef.sh: OK (NusantaraOS / NUSANTARAOS_2026 / 2026.11.07)
- packages.x86_64: 232 paket, 0 duplikat
- Calamares YAML: branding.conf, settings.conf, partition.conf, shell_process.conf OK
- SDDM theme: metadata.desktop + Main.qml + README ✓
- Plymouth: nusantara.plymouth + nusantara.script + logo.png 36KB ✓
- GRUB theme: nusantara/theme.txt ✓
- Logo final: nusantaraos.svg 4.8KB valid XML ✓ + png 512px ✓
- Tools: nusantara-assistant / nusantara-update / nusantara-settings executable ✓

## Build ISO (harus di Arch/Garuda/CachyOS)
```bash
sudo pacman -Syu archiso git base-devel
sudo ./build.sh kde
# hasil: out/NusantaraOS-2026.11.07-x86_64.iso
qemu-system-x86_64 -m 8192 -cdrom out/*.iso -enable-kvm
```

Host saat ini: Zorin OS 18.1 (Ubuntu-based) → mkarchiso tidak tersedia.
Solusi: pindah repo ke VM Arch, atau build via Docker archlinux.

## Berikutnya
- [ ] Build ISO di Arch VM
- [ ] Test VM Plymouth → SDDM → Calamares → BTRFS install
- [ ] Publish repo (git init)
