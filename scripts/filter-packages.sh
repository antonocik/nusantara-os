#!/usr/bin/env bash
# Hapus paket yang tidak tersedia di repo aktif, supaya mkarchiso tidak gagal.
#
# Usage: scripts/filter-packages.sh <file-paket> [pacman.conf]
#
# Bila pacman.conf diberikan, pengecekan memakai konfigurasi repo tsb
# (penting agar multilib, chaotic-aur, dan repo lokal ikut terhitung).

set -euo pipefail

FILE="${1:?paket: butuh path file packages.x86_64}"
CONF="${2:-}"

if ! command -v pacman >/dev/null 2>&1; then
  echo "[filter] pacman tidak ada, skip" >&2
  exit 0
fi

PACMAN=(pacman)
if [[ -n "$CONF" && -f "$CONF" ]]; then
  PACMAN=(pacman --config "$CONF")
fi

if [[ $EUID -ne 0 ]]; then
  if command -v sudo >/dev/null 2>&1; then
    PACMAN=(sudo "${PACMAN[@]}")
  else
    echo "[filter] butuh root untuk pacman -Sy, skip" >&2
    exit 0
  fi
fi

"${PACMAN[@]}" -Sy --noconfirm >/dev/null 2>&1 || true

tmp="$(mktemp)"
removed=()
kept=0

while IFS= read -r line; do
  if [[ -z "${line// }" || "$line" == \#* ]]; then
    printf '%s\n' "$line" >> "$tmp"
    continue
  fi
  pkg="${line%%#*}"
  pkg="$(echo "$pkg" | xargs)"
  [[ -z "$pkg" ]] && continue

  # -Si = paket tunggal, -Sg = nama grup (mis. xfce4, gnome)
  if "${PACMAN[@]}" -Si "$pkg" >/dev/null 2>&1 || \
     "${PACMAN[@]}" -Sg "$pkg" >/dev/null 2>&1; then
    printf '%s\n' "$pkg" >> "$tmp"
    kept=$((kept + 1))
  else
    removed+=("$pkg")
  fi
done < "$FILE"

mv "$tmp" "$FILE"

echo "[filter] tersedia: $kept paket" >&2
if (( ${#removed[@]} )); then
  echo "[filter] dibuang ${#removed[@]} paket tidak tersedia:" >&2
  printf '  - %s\n' "${removed[@]}" >&2
fi
