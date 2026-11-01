# Briques

Une ligne par brique : ce qu'on prend, pourquoi, ou pourquoi on l'écarte.

| brique | statut | pourquoi |
|---|---|---|
| [PocketTerm35-OS](https://github.com/therezor/PocketTerm35-OS) | socle | bureau complet, config TOML fusionnée, hooks, MIT |
| GNU stow | retenu | lier `home/` dans `~` sans script maison |
| [DESIGN.md](https://github.com/google-labs-code/design.md) | retenu | format de charte lisible par les agents (tokens YAML + texte), plutôt qu'un format maison |
| [DTCG](https://www.designtokens.org/) (JSON W3C) | écarté | standard stable mais tokens seuls, sans le texte de charte ; DESIGN.md sait l'exporter |
| [Style Dictionary](https://styledictionary.com/) | écarté | chaîne de build Node pour générer nos 3 fichiers : YAGNI |
| [JetBrains Mono](https://www.jetbrains.com/lp/mono/) | retenu | police du texte courant, TTF, paquet Debian `fonts-jetbrains-mono` |
| [VT323](https://fonts.google.com/specimen/VT323) | retenu | police pixel des titres et gros chiffres, TTF, OFL |
| image SD maison (`build.sh`) | écarté | upstream ne produit pas d'image (un `.deb` + `install.sh` lancé sur le Pi) ; Raspberry Pi OS Lite + install upstream + `install.sh` suffit : YAGNI |
| [packer-builder-arm](https://github.com/mkaczanowski/packer-builder-arm) | en réserve | le jour où il faut une image : part d'une image existante (hash vérifié), Docker seul sur un PC x86, un fichier déclaratif ; on y rejouerait les mêmes étapes que sur le Pi |
| [sdm](https://github.com/gitbls/sdm) | écarté | personnalise aussi une image Raspberry Pi OS sur x86, mais plus lourd (plugins, nspawn) pour notre besoin |
| [pi-gen](https://github.com/RPi-Distro/pi-gen), [rpi-image-gen](https://github.com/raspberrypi/rpi-image-gen) | écarté | construisent l'OS de zéro (lent) ; rpi-image-gen ne supporte officiellement que les hôtes arm64 |
| `theme.toml` (couleurs + `menu.radius`) | retenu | le thème passe par la config de PT35-OS, aucune PR ; il passe devant les palettes d'Apparence |
| JetBrains Mono dans le menu et la barre | retenu | PT35-OS 0.4.2 cherche les polices dans quelques dossiers fixes, sans fontconfig, dont `/usr/share/fonts/TTF` (absent sur Debian) : `install.sh` y lie les TTF du paquet Debian. Ni patch ni compilation |
| fond d'écran via sway (`output * bg`) ou un hook | écarté | `pt35d` remet une couleur unie au démarrage et au rechargement, et le menu opaque couvre le bureau vide : image invisible |
| fork [Kalacione/PocketTerm35-OS](https://github.com/Kalacione/PocketTerm35-OS) | retenu | patch `pt35-menu` pour le fond d'écran (SVG via le `resvg` déjà présent). Le `.deb` est construit par la CI du fork, rien ne compile sur le Pi |
| patch + compilation sur le Pi | écarté | 1 à 2 Go d'outils Rust sur le Pi, patch à rejouer à chaque mise à jour |
| config Start / Select | inutile | le comportement voulu (menu, bascule d'apps, jamais transmis aux apps) est celui de PT35-OS par défaut |
| `stow --no-folding` | retenu | sans lui, stow lie tout `~/.config/pt35` vers le dépôt, et Apparence écrirait `appearance.toml` dans le dépôt |
| [Pixelitos](https://github.com/ItsZariep/pixelitos-icon-theme), [Star Pixel](https://github.com/starciad/star-pixel-icons-theme) | écarté | thèmes d'icônes pixel en PNG et en couleur ; `pt35-menu` ne lit que du SVG |
| teinte verte des icônes Papirus (patch fork) | écarté | choix de Djé : nos propres icônes pixel plutôt qu'une teinte automatique |
| icônes pixel maison (32x32) | écarté | dessinées puis remplacées : Djé préfère des SVG nets, le halo et les scanlines venant du rendu |
| [Tabler Icons](https://github.com/tabler/tabler-icons) (MIT) | retenu | SVG au trait, 5900 icônes, cône VLC compris ; `tools/icons.sh` en copie 12 en vert dans le thème `Phosphore`, qui hérite de Papirus |
| [Lucide](https://github.com/lucide-icons/lucide) (ISC) | écarté | même style et a toutes nos icônes, mais deux fois moins fourni que Tabler |
| halo et scanlines en SVG (`feGaussianBlur`, resvg le gère) | écarté | à refaire dans chaque fichier ; fait une fois au rendu dans notre fork (`0.4.2+u2`) |
| `screen_shader` CRT de Hyprland | écarté | il faudrait quitter sway, sur lequel PT35-OS repose ; une surface layer-shell transparente fait le même effet |
| `tools/release-fork.sh` (tag via `gh api`) | remplacé par `ship.sh` | la version vit déjà dans le `Cargo.toml` du fork (le `.deb` la porte) : le script la lit et pose le tag, la CI fait la release. Ni clone local, ni incrément de tag séparé qui contredirait le `.deb` |
| `tools/ship.sh` (remplace `release-fork.sh` et `pin-pt35.sh`) | retenu | une commande : tag, attente de la release CI, commit de `PT35_VERSION` par l'API. Aucun fichier local modifié, donc plus de conflit ni de modif oubliée sur le PC |
| installer la dernière release du fork sans `PT35_VERSION` | écarté | un `git revert` ne permettrait plus de revenir à la version d'avant, et le Pi prendrait une release avant que la surcouche soit prête |
| [uosc](https://github.com/tomasklaen/uosc) (LGPL-2.1) | retenu | interface de mpv faite pour le doigt (grosse barre de temps, menus), couleurs réglables dans `uosc.conf` : notre skin sans code. Pas dans Debian : `install.sh` prend l'archive de la release, version et sha256 épinglés |
| skin VLC (skins2, `.vlt`) | écarté | format ancien, X11 seulement, retiré de VLC 4 ; l'interface Qt reste trop dense pour 640x480 |
| réécrire un lecteur dans `pt35-menu` | écarté | mpv + uosc fait déjà lecture, playlist, pistes et sous-titres |
| MPRIS + [playerctl](https://github.com/altdesktop/playerctl) (Debian) | retenu pour le widget Lecture | un seul protocole pour VLC (natif) et mpv (paquet `mpv-mpris`), et pour tout lecteur futur ; `playerctl` en CLI, comme `nmcli` pour le widget réseau : aucune dépendance Rust en plus |
| IPC de mpv (`--input-ipc-server`), interfaces rc / http de VLC | écarté | une API par lecteur, à coder deux fois |
| client D-Bus en Rust (`zbus`) | écarté | nouvelle dépendance et plus de code pour ce que `playerctl` fait déjà |
| VLC pour Musique | remplacé | Musique passe sur mpv + uosc : une seule interface à habiller pour la musique et la vidéo |
| icône principale : Tabler `aperture`, `headset`, `radioactive` | écarté | floues à 16 px dans la barre, et la barre dessine le crâne en pixels : il aurait fallu y lire un SVG ; `radioactive` est un signal de danger |
| icône principale : obturateur 8 lames en pixel art (fork `0.4.2+u7`) | retenu | clin d'œil à Portal, net à 16 px car ses fentes suivent la grille ; remplace le dessin du crâne tel quel. Pistes : `design/icone-main-pistes-v2.png` du dossier partagé |
| interrupteurs `0` / `1` (premier jet u9) | remplacé | ON / OFF en toutes lettres sur fond plein vert ou rouge : l'état se lit sans distinguer les couleurs |
| numéros de ligne dans les listes | écarté | bruit à 640x480, le fil d'Ariane donne déjà la position ; `install.sh` pose `show_numbers = false` |
| accueil uosc à l'idle, `scripts/pt35-home.lua` (API de menus d'uosc) | retenu | écran noir sans fichier une fois « Drop files » masqué. Un menu uosc dit que la médiathèque est vide et propose Browse (navigateur d'uosc) et une URL tapée dans son champ de recherche : thème déjà fait, aucun patch du fork |
| liste de `~/Music` dans `pt35-menu` | écarté | patch Rust à reporter à chaque mise à jour d'upstream, refait le navigateur d'uosc |
| profils mpv `pt35-music` / `pt35-video` | retenu | chaque app a sa médiathèque (`uosc-default_directory`) ; les playlists sont déjà séparées, un processus mpv par app. Les `.m3u` s'ouvrent depuis Browse sans réglage |
