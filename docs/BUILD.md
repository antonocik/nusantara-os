# Panduan Build Lengkap NusantaraOS

## Syarat
- Arch/Garuda/CachyOS/Manjaro x86_64, 16GB RAM, 20GB disk kosong
- Koneksi internet stabil (download ~4-6GB paket)

## Langkah
```bash
sudo pacman -Syu archiso git base-devel
git clone <repo-nusantaraos> && cd nusantaraos
chmod +x build.sh
sudo ./build.sh kde
# atau
sudo ./build.sh xfce
```

## Cek ISO
```bash
ls -lh out/
qemu-system-x86_64 -m 8192 -cdrom out/*.iso -enable-kvm
```

## Burn ke USB
```bash
# Ventoy disarankan (copy iso langsung)
cp out/*.iso /run/media/$USER/Ventoy/
# atau dd
sudo dd if=out/*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

## Install
Boot USB > pilih UEFI > tunggu Calamares > Ikuti wizard > Reboot

## Troubleshooting
- Gagal mkarchiso: `sudo pacman -S --needed archiso`
- Calamares tidak jalan: cek `journalctl -b -u calamares`
- Boot hitam: coba Safe Mode entry di grub/syslinux
