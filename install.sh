#!/usr/bin/env bash
# Lie home/ dans ~ avec GNU stow, après avoir vérifié la version de PocketTerm35-OS.
#   ./install.sh              installe nos réglages
#   ./install.sh --uninstall  retire les liens, remet les .bak
#   ./install.sh --pt35       (ré)installe la version épinglée de PocketTerm35-OS
#   ./install.sh --force      installe même si la version diffère
set -euo pipefail
cd "$(dirname "$0")"

PIN=$(cat PT35_VERSION)
FONT_DIR=/usr/share/fonts/TTF
ICON_LINK=/usr/share/icons/Phosphore
# uosc, l'interface tactile de mpv : version et empreinte épinglées.
UOSC_VERSION=5.9.2
UOSC_SHA256=81d1d0c896cb8b2c3d3d218e3ed91a33b3f16c6ff420e11f3179130984266375
MPV_DIR=$HOME/.config/mpv
# Paquets Debian dont nos réglages ont besoin, au-delà de ceux de PT35-OS.
# mpv n'est qu'une suggestion du .deb : Musique et Vidéo en dépendent ici.
# mpv-mpris et playerctl : le widget Lecture lit les lecteurs par MPRIS.
DEPS="stow fonts-jetbrains-mono fontconfig mpv mpv-mpris playerctl curl unzip"
# Notre archive d'upstream, puis notre fork (versions +u<n>), puis upstream.
DEB_URLS="https://github.com/Kalacione/pocketterm35-unleashed/releases/download/pt35-$PIN/pt35-desktop_arm64.deb
https://github.com/Kalacione/PocketTerm35-OS/releases/download/v$PIN/pt35-desktop_arm64.deb
https://github.com/therezor/PocketTerm35-OS/releases/download/v$PIN/pt35-desktop_arm64.deb"

# N'installe que les paquets absents, sans rien toucher s'ils sont tous là.
need() {
  local missing=() p
  for p in "$@"; do
    dpkg-query -W -f='${Status}' "$p" 2>/dev/null | grep -q 'ok installed' || missing+=("$p")
  done
  [ ${#missing[@]} -eq 0 ] && return
  sudo apt-get update -qq
  sudo apt-get install -y "${missing[@]}"
}

case "${1:-}" in
  --pt35)
    # Lisible par _apt, sinon apt prévient qu'il télécharge en root.
    tmp=$(mktemp -d) && chmod 755 "$tmp"
    # Sans -S : une source absente (404) n'est pas une erreur, on essaie la suivante.
    for u in $DEB_URLS; do curl -fsL -o "$tmp/pt35-desktop_arm64.deb" "$u" && echo "source : $u" && break; done
    [ -s "$tmp/pt35-desktop_arm64.deb" ] || { echo "Téléchargement impossible." >&2; exit 1; }
    sudo apt-get install -y --allow-downgrades "$tmp/pt35-desktop_arm64.deb"
    rm -rf "$tmp"
    echo "PocketTerm35-OS $PIN installé. Puis : ./install.sh && sudo reboot"
    exit 0 ;;
  --uninstall)
    need stow
    stow -D --no-folding -t "$HOME" home
    sudo rm -f "$FONT_DIR"/JetBrainsMono-Regular.ttf "$FONT_DIR"/JetBrainsMono-Bold.ttf "$ICON_LINK"
    rm -rf "$MPV_DIR/scripts/uosc" "$MPV_DIR"/fonts/uosc_*
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

# shellcheck disable=SC2086 # une liste de paquets, à découper
need $DEPS

# PT35-OS cherche ses polices dans quelques dossiers fixes, sans fontconfig.
# /usr/share/fonts/TTF en fait partie et n'existe pas sur Debian : on y lie
# JetBrains Mono. Sans elle, theme.toml empêcherait la barre de démarrer.
for style in Regular Bold; do
  [ -e "$FONT_DIR/JetBrainsMono-$style.ttf" ] && continue
  src=$(fc-match -f '%{file}' "JetBrains Mono:style=$style")
  case "$src" in
    *JetBrainsMono-$style.ttf) sudo mkdir -p "$FONT_DIR" && sudo ln -sf "$src" "$FONT_DIR/JetBrainsMono-$style.ttf" ;;
    *) echo "JetBrains Mono $style introuvable ($src), arrêt avant stow." >&2; exit 1 ;;
  esac
done

# Un vrai fichier à la place d'un des nôtres bloque stow : on le met de côté.
find home -type f -o -type l | while read -r f; do
  dst="$HOME/${f#home/}"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.bak"
    echo "sauvegardé : $dst.bak"
  fi
done

# --no-folding : de vrais dossiers dans ~, sinon PT35-OS écrirait dans le dépôt.
stow -R --no-folding -t "$HOME" home

# PT35-OS ne lit pas ~/.local/share/icons, et cherche /usr/share/icons en premier :
# dans /usr/local, Papirus passerait devant.
[ -L "$ICON_LINK" ] || sudo ln -sfn "$HOME/.local/share/icons/Phosphore" "$ICON_LINK"

# uosc n'est pas dans Debian : on prend l'archive de sa release, vérifiée.
if [ "$(cat "$MPV_DIR/scripts/uosc/.version" 2>/dev/null)" != "$UOSC_VERSION" ]; then
  tmp=$(mktemp -d)
  curl -fsSL -o "$tmp/uosc.zip" "https://github.com/tomasklaen/uosc/releases/download/$UOSC_VERSION/uosc.zip"
  echo "$UOSC_SHA256  $tmp/uosc.zip" | sha256sum -c --quiet
  rm -rf "$MPV_DIR/scripts/uosc" && mkdir -p "$MPV_DIR"
  unzip -qo "$tmp/uosc.zip" -d "$MPV_DIR" -x 'scripts/uosc/bin/ziggy-darwin' 'scripts/uosc/bin/ziggy-windows.exe'
  echo "$UOSC_VERSION" > "$MPV_DIR/scripts/uosc/.version"
  rm -rf "$tmp"
  echo "uosc $UOSC_VERSION installé"
fi

# L'accueil n'affiche que les épingles : on en pose par défaut, sans toucher
# à celles qui existent. Y sur l'accueil ouvre Toutes les apps pour en changer.
PINS="${XDG_STATE_HOME:-$HOME/.local/state}/pt35/pinned"
if [ ! -s "$PINS" ]; then
  mkdir -p "$(dirname "$PINS")"
  printf '%s\n' app:terminal app:files app:editor app:browser app:music app:video \
    app:darkwire screen:quick page:power > "$PINS"
  echo "épingles par défaut : $PINS"
fi
# Défauts posés une fois dans appearance.toml, que Paramètres > Apparence et
# les Réglages rapides réécrivent (theme.toml passerait devant eux).
LOOK="${XDG_CONFIG_HOME:-$HOME/.config}/pt35/appearance.toml"
seed_menu() {
  grep -qs "^$1[ =]" "$LOOK" && return
  mkdir -p "$(dirname "$LOOK")"
  if grep -qs '^\[menu\]' "$LOOK"; then
    sed -i "/^\[menu\]/a $1 = $2" "$LOOK"
  else
    printf '\n[menu]\n%s = %s\n' "$1" "$2" >> "$LOOK"
  fi
  echo "$1 = $2 : $LOOK"
}
seed_menu tile_opacity 85      # tuiles translucides à 85 %
seed_menu show_numbers false   # pas de numéro de ligne : le fil d'Ariane donne la position
echo "ok"
