# PocketTerm 3.5 Unleashed

Surcouche personnelle de [PocketTerm35-OS](https://github.com/therezor/PocketTerm35-OS)
(MIT) pour le WaveShare PocketTerm 3.5. Ce fichier s'applique à tout agent qui
intervient sur le projet.

## Méthode

1. **Regarder, comprendre, copier, améliorer.** Comme un humain.
2. **Chercher l'existant d'abord** : apps, modules, drivers, retours d'expérience
   (GitHub, forums, dépôts PocketTerm35). On assemble des briques de lego.
3. **Améliorer « à notre sauce »** par de la config, de petits scripts ou une PR
   upstream. Le « maison » se justifie par ce qu'il ajoute, pas pour refaire
   l'existant.
4. **Si rien n'existe, on crée la brique**, dans le cadre le plus adapté
   (config, hook, script, PR upstream), en restant KISS, DRY, YAGNI.
5. Noter chaque brique retenue (ou écartée) dans `docs/briques.md`, une ligne.

## Principes

- K.I.S.S., D.R.Y., Y.A.G.N.I. Le plus petit changement qui marche.
- Ne pas dupliquer upstream : on ne surcharge que les clés qu'on modifie.
- Tout ce qui sert à tout le monde part en PR upstream, pas ici.

## Communication

Tutoiement. Explications brèves. Pas de flatterie. Mettre chaque demande en
perspective (coût, alternative existante, impact sur le reste).

## Matériel

Référence détaillée : `CLAUDE.md` et `docs/hardware-facts.md` d'upstream. Ne pas
recopier ici, résumer seulement :

- Pi 5, 8 Go de RAM (upstream supporte aussi le Pi 4B), écran HDMI 640x480,
  tactile GT911.
- Clavier RP2040. Firmware patché pt35 : ABXY L R = F13-F18, Select = F21,
  Start = F22. Firmware stock : lettres `a b x y l r`, d'où le flash requis.
- Pas de jauge batterie côté Linux (`/sys/class/power_supply` absent) : jamais
  d'indicateur qui afficherait `--`.
- Pas de micro intégré.
- Luminosité via la console série du firmware pt35 (`/dev/ttyACM0`).

## Architecture

PocketTerm35-OS installe ses défauts dans `/usr/share/pt35-desktop/` et fusionne
`~/.config/pt35/*.toml` par-dessus, table par table (les tableaux sont remplacés,
pas concaténés). Ce dépôt ne contient que nos surcharges. Convention des chemins (un dossier
n'est créé qu'au premier fichier qui en a besoin) :

| chemin | rôle |
|---|---|
| `home/` | miroir de `~`, lié par `install.sh` (GNU stow) |
| `home/.config/pt35/*.toml` | surcharges menu, apps, thème |
| `home/.config/pt35/hooks/hook_*` | scripts sur `startup`, `launch`, `shutdown`, `screenshot`, `reload`, `lowbattery` |
| `home/.config/sway/config` | `include` upstream puis nos surcharges sway |
| `home/.local/bin/` | nos petits scripts |
| `plymouth/<thème>/` | thème Plymouth, images générées par `tools/splash.py` à l'install |
| `docs/briques.md` | briques retenues ou écartées, et pourquoi |
| `docs/captures/` | captures du README, rendues depuis le code de la version épinglée |

Si une surcharge ne suffit pas : PR sur un fork d'upstream, pas de patch local.

## Version d'upstream

- La version installée sur le Pi est épinglée dans `PT35_VERSION` : un commit de
  la surcouche = une version du `.deb` testée avec. `install.sh --pt35` installe
  celle-là ; revenir en arrière = `git revert`. Ne jamais conseiller la commande
  d'install d'upstream : elle prend la dernière version.
- Fork : [Kalacione/PocketTerm35-OS](https://github.com/Kalacione/PocketTerm35-OS),
  seulement pour ce qu'aucune config ne permet. Une version patchée s'appelle
  `<version upstream>+u<n>` (ex. `0.4.2+u1`), montée dans le `Cargo.toml` du fork
  avec son entrée dans le CHANGELOG, dans la PR du patch. Une nouvelle version
  d'upstream passe aussi par le fork (rebase, puis `+u1`).
- Flux d'une version, dans cet ordre :
  1. merger la PR du fork ;
  2. lancer `tools/ship.sh` (PC avec `gh`, depuis n'importe où) : il vérifie le
     CHANGELOG et la CI du main du fork, pose le tag, attend la release faite
     par la CI (`release.yml`), puis commite `PT35_VERSION` sur le main de la
     surcouche. Relançable s'il s'arrête en route ;
  3. merger la PR de la surcouche qui va avec ;
  4. sur le Pi : `git pull && ./install.sh --pt35 && ./install.sh`.
- `PT35_VERSION` ne change que par `tools/ship.sh` : jamais à la main, jamais
  dans une PR (c'est ce qui créait des conflits et des modifs locales). Jamais
  de tag à la main ni de `gh release create`.
- Pas de compilation sur le Pi. Un patch qui sert à tous part ensuite en PR chez
  therezor.
- Dans les messages, toujours nommer une PR avec son dépôt : « fork #7 »,
  « unleashed #9 », jamais « PR #7 » seul.

## Documentation

- `README.md` présente le projet à quelqu'un d'extérieur : ce que c'est,
  comment l'installer, le retirer, le contenu réel du dépôt. Pas de règles
  internes ni de notes pour nous-mêmes.
- Les règles du projet vont ici, les décisions et briques dans `docs/`.
- Le README ne décrit que ce qui existe dans le dépôt.

## Tests

Djé teste sur l'appareil lui-même, sans accès distant pour l'agent. Chaque
changement livre donc :

- les commandes exactes à lancer sur le Pi ;
- ce qu'on doit voir si ça marche ;
- comment revenir en arrière.

Logs utiles : `/run/user/1000/pt35/sway.log`.

## Environnement

Jean-Michel : harness IA local (gemma4 / qwen3.8) sur le réseau de Djé. À
considérer comme brique disponible avant d'ajouter un autre service IA.
