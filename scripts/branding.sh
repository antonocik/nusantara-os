#!/usr/bin/env bash
set -euo pipefail
# Ganti branding distro (nama, logo)
# Usage: ./scripts/branding.sh "NamaDistro" "publisher@email"
NAME=${1:-NusantaraOS}  # iso_name tanpa spasi
PUB=${2:-"Nusantara OS Project <dev@nusantaraos.local>"}

sed -i "s/iso_name=\"[^\"]*\"/iso_name=\"$NAME\"/" profiledef.sh
sed -i "s/iso_publisher=\"[^\"]*\"/iso_publisher=\"$PUB\"/" profiledef.sh
sed -i "s/productName: \"[^\"]*\"/productName: \"$NAME\"/" airootfs/etc/calamares/branding.conf

echo "Branding diganti ke $NAME. Rebuild ISO dengan sudo ./build.sh"
