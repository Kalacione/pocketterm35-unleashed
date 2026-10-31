#!/usr/bin/env bash
# Archive le .deb d'une release PocketTerm35-OS dans une release de notre dépôt
# et l'épingle dans PT35_VERSION. À lancer sur un PC avec gh connecté.
#   tools/pin-pt35.sh 0.4.2
set -euo pipefail
cd "$(dirname "$0")/.."

v=${1:?usage: tools/pin-pt35.sh <version>}
up="https://github.com/therezor/PocketTerm35-OS/releases/download/v$v"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT

curl -fsSL -o "$tmp/pt35-desktop_arm64.deb" "$up/pt35-desktop_arm64.deb"
curl -fsSL -o "$tmp/SHA256SUMS" "$up/SHA256SUMS"
(cd "$tmp" && grep 'pt35-desktop_arm64.deb' SHA256SUMS | sha256sum -c -)

gh release create "pt35-$v" "$tmp/pt35-desktop_arm64.deb" "$tmp/SHA256SUMS" \
  --repo Kalacione/pocketterm35-unleashed --title "PocketTerm35-OS $v (archive)" \
  --notes "Copie de https://github.com/therezor/PocketTerm35-OS/releases/tag/v$v (MIT)."

echo "$v" > PT35_VERSION
echo "Épinglé sur $v. Teste sur le Pi, puis commit PT35_VERSION."
