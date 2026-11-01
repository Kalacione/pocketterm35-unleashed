#!/bin/sh
# Icônes du lanceur : Tabler Icons (MIT), au trait, en vert phosphore.
# Le halo et la sélection sont dessinés par pt35-menu, pas dans les SVG.
#   tools/icons.sh [couleur]   # regénère home/.local/share/icons/Phosphore
set -eu
cd "$(dirname "$0")/.."

VERSION=3.24.0
COLOR=${1:-#63e6a4}
OUT=home/.local/share/icons/Phosphore
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

curl -fsSL "https://registry.npmjs.org/@tabler/icons/-/icons-$VERSION.tgz" | tar xz -C "$TMP"
mkdir -p "$OUT/scalable/apps"
cp "$TMP/package/LICENSE" "$OUT/LICENSE"

# nom d'icône de l'app (apps.toml de PT35-OS) et icône Tabler
while read -r app tabler; do
  sed "s/currentColor/$COLOR/" "$TMP/package/icons/outline/$tabler.svg" > "$OUT/scalable/apps/$app.svg"
done <<'MAP'
foot terminal-2
system-file-manager folder
mousepad file-pencil
vlc traffic-cone
mpv movie
chromium world
darkwire message-chatbot
preferences-system settings
utilities-system-monitor device-desktop-analytics
baobab chart-pie
multimedia-photo-viewer photo
galculator calculator
view-app-grid layout-grid
system-shutdown power
MAP
echo "$(ls "$OUT/scalable/apps" | wc -l) icônes dans $OUT"
