.PHONY: iso iso-xfce iso-gnome iso-sway vm run check verify-iso clean

PROFILE ?= kde
ISO     ?= $(firstword $(wildcard out/*.iso))

iso:
	sudo ./build.sh $(PROFILE)

iso-xfce:
	sudo ./build.sh xfce

iso-gnome:
	sudo ./build.sh gnome

iso-sway:
	sudo ./build.sh sway

vm:
	qemu-system-x86_64 -m 8192 -smp 4 -cdrom $(ISO) -boot d -enable-kvm -vga virtio

run:
	@ls -lh out/*.iso

# Cek source tanpa build: syntax skrip, YAML, jumlah paket
check:
	@echo "== syntax skrip =="
	@for f in build.sh profiledef.sh scripts/*.sh airootfs/usr/local/bin/nusantara-*; do \
	  bash -n "$$f" && echo "  OK  $$f"; done
	@echo "== YAML =="
	@python3 -c "import yaml,glob; fs=sorted(glob.glob('airootfs/etc/calamares/**/*.conf',recursive=True))+sorted(glob.glob('airootfs/etc/calamares/**/*.desc',recursive=True))+['.github/workflows/build-iso.yml']; [list(yaml.safe_load_all(open(f))) for f in fs]; print('  %d file OK' % len(fs))"
	@echo "== paket =="
	@printf '  %s paket di packages.x86_64\n' "$$(grep -vE '^[[:space:]]*#|^[[:space:]]*$$' packages.x86_64 | wc -l)"

# Cek isi ISO hasil build (kernel, rootfs, Calamares, tema, live user)
verify-iso:
	scripts/check-iso.sh $(ISO)

clean:
	sudo rm -rf work out build-profile localrepo
