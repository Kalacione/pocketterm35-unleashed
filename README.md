# PocketTerm 3.5 Unleashed

Nos réglages et petits scripts par-dessus
[PocketTerm35-OS](https://github.com/therezor/PocketTerm35-OS), pour le
WaveShare PocketTerm 3.5.

Ce dépôt ne remplace rien : PocketTerm35-OS garde ses défauts dans
`/usr/share/pt35-desktop/`, et on ne pose dans `~` que ce qu'on change.

## Prérequis

| quoi | détail |
|---|---|
| matériel | PocketTerm 3.5 avec Pi 4B (ou Pi 5) |
| système | Raspberry Pi OS **Trixie 64 bits** (Lite conseillé). Bookworm n'est pas supporté par upstream. |
| socle | PocketTerm35-OS installé, 0.4.2 ou plus récent ([install upstream](https://github.com/therezor/PocketTerm35-OS#install)) |
| firmware clavier | firmware pt35 flashé (`sudo pt35-kbd flash`) : sans lui, ABXY L R envoient des lettres et Start/Select ne sont pas fiables |
| réseau | Wi-Fi ou Ethernet, pour cloner le dépôt |
| paquets | `git` et `stow` (`install.sh` installe `stow` s'il manque) |

Vérifier le socle :

```sh
dpkg -s pt35-desktop | grep Version   # doit afficher 0.4.2 ou plus
```

## Getting started

Tout se fait sur le Pi, dans un terminal (foot) ou en SSH.

**1. Installer les outils.**

```sh
sudo apt update && sudo apt install -y git stow
```

**2. Cloner le dépôt.**

```sh
git clone https://github.com/Kalacione/pocketterm35-unleashed.git ~/pocketterm35-unleashed
cd ~/pocketterm35-unleashed
```

**3. Installer.**

```sh
./install.sh
```

Le script crée des liens de `~` vers `home/` du dépôt. Un vrai fichier déjà
présent à la place d'un des nôtres (par exemple `~/.config/sway/config` créé
par upstream) est renommé en `.bak`, puis remis en place à la désinstallation.

**4. Recharger.**

`Super`+`Shift`+`c` recharge sway. Pour menu, apps et thème, redémarrer la
session (ou le Pi) est le plus sûr.

**5. Vérifier.**

```sh
ls -l ~/.config/sway/config   # doit pointer vers ~/pocketterm35-unleashed/home/...
```

Le bureau doit se comporter comme avant, avec nos surcharges en plus. En cas de
souci, les logs sont dans `/run/user/1000/pt35/sway.log`.

## Mettre à jour

```sh
cd ~/pocketterm35-unleashed && git pull && ./install.sh
```

## Retirer, revenir en arrière

```sh
cd ~/pocketterm35-unleashed && ./install.sh --uninstall
```

Les liens sont retirés et les `.bak` remis en place : on retrouve le
PocketTerm35-OS d'origine. Recharger comme à l'étape 4.

Pour annuler un seul changement : `git log`, puis `git revert <commit>` et
`./install.sh`.

## Contenu

| chemin | rôle |
|---|---|
| `home/` | miroir de `~`, lié par `install.sh` |
| `home/.config/pt35/` | surcharges menu, apps, thème, et hooks |
| `home/.config/sway/config` | inclut la config upstream, puis nos surcharges |
| `home/.local/bin/` | nos petits scripts |
| `docs/briques.md` | briques retenues ou écartées, et pourquoi |
| `CLAUDE.md` | méthode et règles pour les agents |

## Licence

MIT, comme upstream.
