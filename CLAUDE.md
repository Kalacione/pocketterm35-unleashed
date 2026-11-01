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
| `docs/briques.md` | briques retenues ou écartées, et pourquoi |

Si une surcharge ne suffit pas : PR sur un fork d'upstream, pas de patch local.

## Version d'upstream

- Upstream est épinglé dans `PT35_VERSION`. Ne jamais conseiller la commande
  d'install d'upstream : elle prend la dernière version.
- Changer de version est un choix volontaire : sur un PC avec `gh` connecté,
  `tools/pin-pt35.sh <version>` archive le `.deb` (et la licence) en release et
  met à jour `PT35_VERSION`. On teste sur le Pi, puis on commit.
- Pas de fork tant qu'on n'en a pas besoin. On forke seulement pour porter une
  PR upstream, ou si upstream casse et qu'il faut patcher. La CI d'upstream
  (`release.yml`) construit alors le `.deb` ARM sur le fork à chaque tag.

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
