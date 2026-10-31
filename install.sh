#!/usr/bin/env bash
# Lie home/ dans ~ avec GNU stow. --uninstall retire les liens.
set -euo pipefail
cd "$(dirname "$0")"

command -v stow >/dev/null || sudo apt-get install -y stow

if [ "${1:-}" = "--uninstall" ]; then
  stow -D -t "$HOME" home
  # On remet ce qu'on avait mis de côté.
  find home -type f -o -type l | while read -r f; do
    dst="$HOME/${f#home/}"
    if [ -e "$dst.bak" ] && [ ! -e "$dst" ]; then mv "$dst.bak" "$dst"; echo "restauré : $dst"; fi
  done
  exit 0
fi

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
