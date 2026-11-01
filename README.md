# PocketTerm 3.5 Unleashed

Une couche de réglages et de petits scripts pour le
WaveShare PocketTerm 3.5, posée par-dessus
[PocketTerm35-OS](https://github.com/therezor/PocketTerm35-OS).

PocketTerm35-OS fournit le bureau (sway, launcher, barre, gestion des boutons).
Ce projet ne le remplace pas : il ajoute ses propres réglages dans `~/.config`,
que PocketTerm35-OS fusionne avec ses défauts. Retirer le projet rend le bureau
d'origine intact.

**État :** en démarrage. Le dépôt pose la structure, l'installation et la
charte graphique. Les réglages arrivent au fil des [specs](docs/specs.md).

## Prérequis

| quoi | détail |
|---|---|
| matériel | PocketTerm 3.5 avec Pi 5 (testé, 8 Go) ou Pi 4B |
| système | Raspberry Pi OS **Trixie 64 bits**, Lite conseillé (Bookworm n'est pas supporté par PocketTerm35-OS) |
| réseau | Wi-Fi ou Ethernet |

## Installation

Tout se fait sur le PocketTerm, dans un terminal ou en SSH. Si
PocketTerm35-OS est déjà installé dans la version de
[`PT35_VERSION`](PT35_VERSION), passer directement à l'étape 5.

### A. Socle : PocketTerm35-OS

**1. Vérifier le système**

```sh
grep VERSION_CODENAME /etc/os-release   # trixie
getconf LONG_BIT                        # 64
dpkg -s pt35-desktop | grep Version     # absent, ou la version de PT35_VERSION
```

Si ce n'est pas Trixie 64 bits, flasher Raspberry Pi OS Lite (Trixie, 64 bits)
avec Raspberry Pi Imager, puis recommencer.

**2. Neutraliser les anciens pilotes d'écran Waveshare** (si présents)

PocketTerm35-OS configure lui-même l'écran et le tactile. Une ancienne
installation Waveshare laisse ses propres overlays dans `config.txt`, qui
feraient doublon. Les commenter **avant** l'étape 3, sans redémarrer entre les
deux :

```sh
grep -n 'waveshare' /boot/firmware/config.txt          # rien : passer à l'étape 3
sudo sed -i.waveshare.bak 's/^dtoverlay=waveshare/#&/' /boot/firmware/config.txt
grep -n 'waveshare' /boot/firmware/config.txt          # chaque ligne commence par #
```

**3. Installer PocketTerm35-OS et flasher le clavier**

```sh
curl -fsSL https://raw.githubusercontent.com/therezor/PocketTerm35-OS/main/install.sh | sudo bash
sudo pt35-kbd flash
```

- Sur Raspberry Pi OS Desktop, l'installeur prévient qu'il remplace la session.
  C'est réversible (`--uninstall`).
- Il propose un agent IA local (darkwire). Optionnel : `n` pour s'en passer.
- Il ajoute son bloc à `config.txt` et en garde une copie dans
  `config.txt.pt35.bak`.
- Sans le firmware flashé, ABXY L R envoient des lettres.

**4. Redémarrer**

```sh
sudo reboot
```

Le PocketTerm démarre sur le bureau PocketTerm35-OS.

Si l'écran ou le tactile ne répond plus, restaurer l'ancienne config en SSH :

```sh
sudo cp /boot/firmware/config.txt.waveshare.bak /boot/firmware/config.txt && sudo reboot
```

### B. Ce projet

**5. Outils**

```sh
sudo apt update && sudo apt install -y git stow
```

**6. Dépôt**

```sh
git clone https://github.com/Kalacione/pocketterm35-unleashed.git ~/pocketterm35-unleashed
cd ~/pocketterm35-unleashed
```

**7. Installation**

```sh
./install.sh
```

Le script relie les fichiers de `home/` dans `~` (avec GNU stow). Un fichier
existant au même endroit est renommé en `.bak` et restauré à la désinstallation.
Si la version de PocketTerm35-OS ne correspond pas à `PT35_VERSION`, le script
s'arrête et indique quoi faire (voir plus bas).

**8. Rechargement**

`Super`+`Shift`+`c` recharge sway. Pour le menu, les apps et le thème,
redémarrer la session.

**9. Vérification**

```sh
ls -l ~/.config/sway/config   # lien vers ~/pocketterm35-unleashed/home/...
```

Logs : `/run/user/1000/pt35/sway.log`.

## Mise à jour

```sh
cd ~/pocketterm35-unleashed && git pull && ./install.sh
```

## Version de PocketTerm35-OS

Le projet est testé sur une seule version de PocketTerm35-OS, celle de
`PT35_VERSION`. La commande d'installation de PocketTerm35-OS prend toujours la
dernière version, ce qui peut casser ces réglages. Pour revenir à la version
testée :

```sh
./install.sh --pt35   # puis redémarrer
```

`./install.sh --force` installe quand même sur une autre version.

## Désinstallation

```sh
cd ~/pocketterm35-unleashed && ./install.sh --uninstall
```

Les liens sont retirés et les `.bak` restaurés. Recharger comme à l'étape 8.

## Contenu

| chemin | rôle |
|---|---|
| `home/` | fichiers reliés dans `~` par `install.sh` |
| `home/.config/sway/config` | inclut la config sway de PocketTerm35-OS |
| `install.sh` | installation, désinstallation, retour à la version testée |
| `PT35_VERSION` | version de PocketTerm35-OS testée |
| `tools/pin-pt35.sh` | archive une version de PocketTerm35-OS dans les releases |
| `docs/specs.md` | specs, priorités et TODO |
| `DESIGN.md` | charte graphique au format [DESIGN.md](https://github.com/google-labs-code/design.md) |
| `docs/design/` | aperçu de la charte (`charte.html`) et maquettes SVG 640x480 |
| `docs/briques.md` | logiciels retenus ou écartés, et pourquoi |
| `CLAUDE.md` | règles du projet, pour les contributeurs humains et IA |

## Remerciements

Ce projet repose sur [PocketTerm35-OS](https://github.com/therezor/PocketTerm35-OS)
de [therezor](https://github.com/therezor) : bureau, launcher, configuration
fusionnée, hooks et firmware clavier. Merci à therezor.

## Licence

MIT ([LICENSE](LICENSE)).

PocketTerm35-OS est sous licence MIT, Copyright (c) 2026 REZOR
([licence](https://github.com/therezor/PocketTerm35-OS/blob/main/LICENSE)).
Les `.deb` archivés dans les releases de ce dépôt sont ses binaires, non
modifiés, accompagnés de sa licence.
