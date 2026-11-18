#!/usr/bin/env bash
# Hapus paket yang tidak tersedia di repo aktif, supaya mkarchiso tidak gagal.
# Usage: scripts/filter-packages.sh <file-paket> [file-output]
#
# Menulis ulang <file-paket> (in-place) minus paket yang tidak ditemukan,
# dan mencetak ringkasan paket yang dibuang ke stderr.

set -euo pipefail

FILE="${1:?paket: butuh path file packages.x86_64}"
OUT="${2:-$FILE}"

if ! command -v pacman >/dev/null 2>&1; then
  echo "[filter] pacman tidak ada, skip" >&2
  exit 0
fi

# pastikan database sinkron (butuh root)
SUDO=""
if [[ $EUID -ne 0 ]] && command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
fi
$SUDO pacman -Sy --noconfirm >/dev/null 2>&1 || true

tmp="$(mktemp)"
removed=()
kept=0

while IFS= read -r line; do
  # pertahankan komentar & baris kosong
  if [[ -z "${line// }" || "$line" == \#* ]]; then
    printf '%s\n' "$line" >> "$tmp"
    continue
  fi
  pkg="${line%%#*}"
  pkg="$(echo "$pkg" | xargs)"
  [[ -z "$pkg" ]] && continue

  if pacman -Si "$pkg" >/dev/null 2>&1; then
    printf '%s\n' "$pkg" >> "$tmp"
    kept=$((kept + 1))
  else
    removed+=("$pkg")
  fi
done < "$FILE"

mv "$tmp" "$OUT"

echo "[filter] tersedia: $kept paket" >&2
if (( ${#removed[@]} )); then
  echo "[filter] dibuang ${#removed[@]} paket tidak tersedia:" >&2
  printf '  - %s\n' "${removed[@]}" >&2
fi
