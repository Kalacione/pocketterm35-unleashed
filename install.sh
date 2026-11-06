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
SPLASH_DIR=/usr/share/plymouth/themes/pocketterm
WIFI_CONF=/etc/modprobe.d/unleashed-wifi.conf
# Dans /usr/sbin, hors du PATH d'un utilisateur sur Debian.
PLY=/usr/sbin/plymouth-set-default-theme
# Paquets Debian dont nos réglages ont besoin, au-delà de ceux de PT35-OS.
# mpv n'est qu'une suggestion du .deb : Musique et Vidéo en dépendent ici.
# mpv-mpris et playerctl : le widget Lecture lit les lecteurs par MPRIS.
# python3-pil : tools/splash.py dessine l'écran de démarrage.
# tmux : la barre du bas du Terminal.
# python3-gi et les gir1.2-* : pt35-actions, le bandeau d'actions de l'éditeur.
# xdg-utils : xdg-mime, pour le navigateur par défaut.
DEPS="stow fonts-jetbrains-mono fontconfig mpv mpv-mpris playerctl curl unzip python3-pil tmux
  python3-gi gir1.2-gtk-3.0 gir1.2-gtklayershell-0.1 xdg-utils"
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
    # Retour au thème de Raspberry Pi OS (pix), sinon au défaut de Plymouth.
    if [ "$($PLY 2>/dev/null)" = pocketterm ]; then
      if [ -d /usr/share/plymouth/themes/pix ]; then sudo $PLY -R pix
      else sudo $PLY -R --reset; fi
    fi
    sudo rm -rf "$SPLASH_DIR"
    [ -e "$WIFI_CONF" ] && sudo rm -f "$WIFI_CONF" && echo "Wi-Fi : réglage retiré, actif au prochain redémarrage"
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

# Les médiathèques de Musique et Vidéo (profils de mpv.conf).
mkdir -p "$HOME/Music" "$HOME/Videos"

# Écran de démarrage : thème Plymouth dessiné depuis la charte. Les images sont
# refaites à chaque fois ; l'initramfs (une minute) seulement si elles changent.
if [ -x $PLY ]; then
  tmp=$(mktemp -d)
  cp plymouth/pocketterm/* "$tmp/"
  python3 tools/splash.py "$tmp"
  if ! diff -rq "$tmp" "$SPLASH_DIR" >/dev/null 2>&1 || [ "$($PLY)" != pocketterm ]; then
    sudo rm -rf "$SPLASH_DIR" && sudo cp -r "$tmp" "$SPLASH_DIR" && sudo chmod -R a+rX "$SPLASH_DIR"
    echo "écran de démarrage : reconstruction de l'initramfs, une minute"
    sudo $PLY -R pocketterm
  fi
  rm -rf "$tmp"
else
  echo "Plymouth absent : écran de démarrage non installé"
fi

# Options du pilote Wi-Fi, lues au chargement du module : effet au redémarrage.
if ! cmp -s "etc/modprobe.d/${WIFI_CONF##*/}" "$WIFI_CONF"; then
  sudo install -m644 "etc/modprobe.d/${WIFI_CONF##*/}" "$WIFI_CONF"
  echo "Wi-Fi : $WIFI_CONF posé, actif au prochain redémarrage"
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
# Les liens (xdg-open) s'ouvrent dans le Navigateur, posé une fois : un
# choix fait ensuite avec xdg-settings est écrit dans le même fichier et gardé.
MIME="${XDG_CONFIG_HOME:-$HOME/.config}/mimeapps.list"
if ! grep -qs '^x-scheme-handler/https=' "$MIME"; then
  xdg-mime default pt35-browser.desktop x-scheme-handler/http x-scheme-handler/https text/html
  echo "navigateur par défaut : pt35-browser.desktop"
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
seed_menu tile_opacity 55      # tuiles translucides à 55 %
seed_menu show_numbers false   # pas de numéro de ligne : le fil d'Ariane donne la position
# Éditeur : texte en JetBrains Mono 14 px, comme Files (foot). Posé une fois,
# tant que Mousepad garde sa police par défaut : ses Préférences la changent
# ensuite. 14 pt font 14 px car PT35-OS lance Mousepad avec GDK_DPI_SCALE=0.75.
MP=org.xfce.mousepad.preferences.view
if [ "$(gsettings get $MP use-default-monospace-font 2>/dev/null)" = true ]; then
  gsettings set $MP font-name 'JetBrains Mono 14'
  gsettings set $MP use-default-monospace-font false
  echo "éditeur : JetBrains Mono 14"
fi
# pt35d ne relit apps.toml et menu.toml qu'au démarrage ou sur reload.
pt35ctl reload 2>/dev/null && echo "pt35d rechargé"
echo "ok"
