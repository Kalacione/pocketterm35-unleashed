#!/usr/bin/env bash
# Lie home/ dans ~ avec GNU stow, après avoir vérifié la version de PocketTerm35-OS.
#   ./install.sh              installe nos réglages
#   ./install.sh --uninstall  retire les liens, remet les .bak
#   ./install.sh --pt35       (ré)installe la version épinglée de PocketTerm35-OS
#   ./install.sh --force      installe même si la version diffère
set -euo pipefail
cd "$(dirname "$0")"

PIN=$(cat PT35_VERSION)
# Notre archive d'abord, upstream en secours.
DEB_URLS="https://github.com/Kalacione/pocketterm35-unleashed/releases/download/pt35-$PIN/pt35-desktop_arm64.deb
https://github.com/therezor/PocketTerm35-OS/releases/download/v$PIN/pt35-desktop_arm64.deb"

case "${1:-}" in
  --pt35)
    tmp=$(mktemp -d)
    for u in $DEB_URLS; do curl -fsSL -o "$tmp/pt35-desktop_arm64.deb" "$u" && break; done
    [ -s "$tmp/pt35-desktop_arm64.deb" ] || { echo "Téléchargement impossible." >&2; exit 1; }
    sudo apt-get install -y --allow-downgrades "$tmp/pt35-desktop_arm64.deb"
    rm -rf "$tmp"
    echo "PocketTerm35-OS $PIN installé. Redémarre."
    exit 0 ;;
  --uninstall)
    command -v stow >/dev/null || sudo apt-get install -y stow
    stow -D -t "$HOME" home
    # On remet ce qu'on avait mis de côté.
    find home -type f -o -type l | while read -r f; do
      dst="$HOME/${f#home/}"
      if [ -e "$dst.bak" ] && [ ! -e "$dst" ]; then mv "$dst.bak" "$dst"; echo "restauré : $dst"; fi
    done
    exit 0 ;;
esac

# Nos surcharges sont testées sur une seule version d'upstream.
have=$(dpkg-query -W -f='${Version}' pt35-desktop 2>/dev/null || echo absent)
# cargo-deb ajoute une révision Debian (0.4.2-1) : on la retire.
if [ "${have%%-*}" != "$PIN" ] && [ "${1:-}" != "--force" ]; then
  echo "PocketTerm35-OS installé : $have, version testée : $PIN." >&2
  echo "Remettre la version testée : ./install.sh --pt35   Passer outre : ./install.sh --force" >&2
  exit 1
fi

command -v stow >/dev/null || sudo apt-get install -y stow

# Un vrai fichier à la place d'un des nôtres bloque stow : on le met de côté.
find home -type f -o -type l | while read -r f; do
  dst="$HOME/${f#home/}"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.bak"
    echo "sauvegardé : $dst.bak"
  fi
done

stow -R -t "$HOME" home
echo "ok"
