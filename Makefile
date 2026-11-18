.PHONY: iso clean vm run check

iso:
	sudo ./build.sh kde

iso-xfce:
	sudo ./build.sh xfce

iso-gnome:
	sudo ./build.sh gnome

iso-sway:
	sudo ./build.sh sway

vm:
	qemu-system-x86_64 -m 8192 -smp 4 -cdrom out/*.iso -boot d -enable-kvm -vga virtio

run:
	@ls -lh out/*.iso

clean:
	sudo rm -rf work out

check:
	@echo "Cek paket..."
	@grep -v '^#' packages.x86_64 | grep -v '^$$' | wc -l
	@echo "Cek syntax..."
	bash -n build.sh && bash -n profiledef.sh
