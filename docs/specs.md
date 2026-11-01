# Specs & TODO

Source de vérité des specs du projet. Charte graphique : [`DESIGN.md`](../DESIGN.md), avec aperçu et maquettes dans [`design/`](design/).
Étude de faisabilité d'origine : [artifact](https://claude.ai/artifact/HaQP5Kn8hYigu6r1Lq8kTP).

## Principes et périmètre

[PocketTerm35-OS](https://github.com/therezor/PocketTerm35-OS) v0.4.2 fait déjà l'essentiel de ce qu'on voulait : Start ouvre un lanceur en grille utilisable au doigt, Select ouvre la bascule d'apps, chaque app a son workspace plein écran, et Paramètres couvre Wi-Fi, Bluetooth, Apparence et Système (lu dans sa [doc des touches](https://github.com/therezor/PocketTerm35-OS/blob/main/docs/KEYS.md), pas encore testé). Notre surcouche se réduit donc à trois choses : un thème, de la config TOML, et quelques écrans qui manquent.

- **Méthode** : avant toute brique, on cherche ce qui existe, dans cet ordre. (1) Ce que PT35-OS fait déjà. (2) Une app pensée pour le tactile sur petit écran, repérée sur [LinuxPhoneApps](https://linuxphoneapps.org), le catalogue des apps Linux testées sur téléphone avec une note « mobile fit ». (3) Un projet reconnu qui couvre plusieurs besoins à la fois. Puis on fait comme un humain : regarder, comprendre, copier, améliorer. L'amélioration « à notre sauce » passe par de la config, des petits scripts qui assemblent ou complètent une brique existante, et des PR upstream quand ça sert à tous. Un script se justifie par ce qu'il ajoute à l'existant, jamais pour le refaire. Si rien n'existe, on crée la brique nous-mêmes, en K.I.S.S. / D.R.Y. / Y.A.G.N.I., dans le cadre le plus adapté : config, script, PR upstream ou module à nous. Cette règle vaut pour tous les fils et tous les agents du projet.
- **K.I.S.S.** : tactile et boutons d'abord. Ergonomie : pas d'outil à la Vim. On déplace le curseur, on sélectionne, on copie, on coupe et on colle au doigt, au D-pad, avec A/B/X/Y, L/R et par des menus, jamais avec des combinaisons de touches à retenir. Valable pour toutes les apps, éditeur compris.
- **D.R.Y.** : un seul toolkit pour les apps graphiques (GTK4 / libadwaita), donc un seul thème : `theme.toml` pour le menu, `gtk.css` pour les apps.
- **Y.A.G.N.I.** : on teste l'app déjà en place avant d'en installer une autre.
- **Matériel** : Raspberry Pi 5, 8 Go de RAM. Les apps GTK4, un petit modèle IA local et la transcription vocale locale sont à sa portée. Le calcul lourd reste quand même sur le réseau (Jean-Michel, Home Assistant) pour l'autonomie de la batterie.

| Version | Contenu | Critère de fin |
| --- | --- | --- |
| v1 Socle + admin | PT35-OS installé, thème Phosphore, fond d'écran image, écrans Paramètres manquants, menu Admin réseau, SSH, fichiers locaux et SSH, éditeur, musique et vidéo | Régler l'appareil et administrer le réseau sans taper de commande de config |
| v2 Usage | Wikipédia, assistant texte (Claude + Jean-Michel), rétro-gaming minimal | Une semaine d'usage quotidien sans manque bloquant |
| v3 Bonus | Assistant vocal, domotique | À cadrer après v2 |
| Un jour peut-être | Radio SDR | — |

## Navigation

On garde le mapping de PT35-OS tel quel : il correspond déjà à l'idée « mobile ». Les touches sont définies par `pt35d` (pas par sway), qui les relâche quand le menu est ouvert.

| Bouton | Firmware patché | Mode Boutons (défaut) | Dans le menu |
| --- | --- | --- | --- |
| Start | F22 | Ouvre / ferme le menu principal | Ferme le menu |
| Select | F21 | Bascule d'apps (cartes avec aperçu) | Ferme la bascule |
| D-pad | flèches | Flèches | Déplacer |
| A | F18 | Entrée | Ouvrir |
| B | F17 | Échap | Retour |
| X | F15 | Tab | Rechercher |
| Y | F16 | F10 (menu de l'app) | Épingler une app |
| L | F13 | Fermer la fenêtre | Fermer (dans la bascule) |
| R | F14 | Passer en mode Souris | idem |

Raccourcis clavier utiles : Super+Espace (menu), Super+W (bascule), Super+Entrée (terminal), Super+Q (fermer). La barre du haut (34 px) sert de barre des tâches tactile : une icône par app ouverte, puis mode, volume, réseau et heure, chacun cliquable. Pas de batterie, le matériel ne l'expose pas.

**Règle Start / Select** : ces deux boutons appartiennent toujours au système, aucune app ne les reçoit. Une app qui en a besoin (émulateur) utilise d'autres touches (voir Rétro-gaming).

Pas de gestes de bord en v1 : la barre des tâches et les boutons couvrent tout. `lisgd` reste possible en v2 si le besoin apparaît à l'usage.

## Lanceur et fond d'écran

Le lanceur de PT35-OS est la racine du menu : écrans système, puis apps épinglées, puis les 5 dernières lancées, puis tout le reste. On le parcourt au doigt ou au D-pad. Notre fork le remplace par un écran d'accueil (`0.4.2+u4`), décrit plus bas. Versions du fork : u1 fond d'écran, u2 grille + halo + scanlines (publiée), u3 première version de l'accueil (fusionnée, pas publiée), u4 accueil final (en cours).

- **Manifeste d'app** : une entrée `[app.<id>]` dans `~/.config/pt35/apps.toml` (nom, icône ou 2 caractères, commande, workspace, une ou plusieurs instances). Un outil CLI/TUI se lance avec `foot -a <id> <commande>`. Les fichiers `.desktop` sont aussi lus. C'est le format qu'on utilise, pas besoin d'en inventer un.
- **Sous-menus** : `~/.config/pt35/menu.toml` (types d'entrée `goto`, `app`, `exec`, `action`, `builtin`). Nos ajouts (menu Admin, écrans Paramètres) passent par là.
- **Icônes** : thème `Phosphore` ([PR #4](https://github.com/Kalacione/pocketterm35-unleashed/pull/4)) : icônes Tabler (MIT) au trait, recolorées en vert phosphore par `tools/icons.sh`, Papirus pour le reste. Sans icône, c'est le glyphe de 2 caractères qui s'affiche.
- **Scanlines** : effet CRT discret sur la barre, le menu et les apps, depuis le fork `0.4.2+u2` (`[effects] scanlines = 15`, `pt35-bar --scanlines` dans la config sway), désactivé par défaut et activé par la surcouche. Détails dans `DESIGN.md`.
- **Fond d'écran** : PT35-OS 0.4.2 met une couleur unie, et sans fenêtre ouverte le menu plein écran et opaque sert de bureau : une image posée par sway ne se verrait pas. Notre fork (`0.4.2+u1`) dessine `~/.config/pt35/wallpaper.svg` sous le lanceur, s'il existe. Le SVG est fait de formes (le moteur SVG du menu n'a pas de texte). Image fixe, pas d'animation.
- **Accueil** (fork `0.4.2+u4`, [PR #4](https://github.com/Kalacione/PocketTerm35-OS/pull/4) en cours ; choix de Djé : widgets à gauche, comme la maquette `01-accueil`). Aperçus de la première version (u3, remplacée) : [`accueil-u2.png`](design/accueil-u2.png), [`toutes-les-apps-u2.png`](design/toutes-les-apps-u2.png).
  - Réglages : `[menu] launcher_home = true`, `[menu] launcher_columns = 3`, `[icons] size_launcher = 64`, `[icons] glow = 4`. Tout est désactivé par défaut ; la surcouche les active (PR Unleashed #4).
  - Grille 3 × 3 des seules apps épinglées. Plus de colonne latérale ni de tuiles Toutes les apps, Paramètres ou Énergie ; Fenêtres reste sur Select. Défilement par lignes (D-pad, Bas / PageDown), L et R restent réservés. Tuile sélectionnée pleine en blanc léger.
  - *Widget column* à gauche (216 px, `widgets.rs` dans le fork), deux panneaux à onglet. SYSTEM : grosse horloge, date, jauges segmentées CPU, RAM, TEMP. NETWORK : nom (SSID, Ethernet ou Offline), IP, signal Wi-Fi en segments, débits ↓/↑. Une jauge sans valeur est masquée.
  - All apps (liste) : Y sur l'accueil l'ouvre ; X ou une lettre l'ouvre en recherche ; en mode souris, clic droit sur une tuile. Dans la liste : A ouvre, B revient à l'accueil, X cherche, Y épingle ou désépingle. Paramètres (`screen:quick`) et Énergie (`page:power`) sont en fin de liste et s'épinglent comme une app.
  - Épingles par défaut, posées par `install.sh` si aucune n'existe : terminal, fichiers, éditeur, navigateur, musique, vidéo, DarkWire, Paramètres, Énergie.
  - Pas fait : courbe de débit (il faudrait un historique tenu par `pt35d`) et widget Lecture (MPRIS).

## App Paramètres

Paramètres existe déjà dans PT35-OS, en liste avec sous-vues. On complète ce qui manque d'abord par des entrées `exec` qui ouvrent un outil TUI existant (zéro code), puis par des écrans natifs en PR upstream si l'outil TUI est trop pénible.

| Réglage | Déjà dans PT35-OS | v1 (config seule) | Plus tard (PR `pt35-menu`) |
| --- | --- | --- | --- |
| Wi-Fi | oui (scan, connexion) | — | — |
| Bluetooth | oui | — | — |
| Son, luminosité | oui (réglages rapides) | — | — |
| Apparence (palette, police, taille) | oui | palette Phosphore | ligne Fond d'écran |
| Système (CPU, RAM, disque, température, IP) | oui | — | — |
| Réseau filaire / IP fixe, nom d'hôte | non | `nmtui` | écran natif si besoin |
| Date, heure, fuseau horaire | non | `dpkg-reconfigure tzdata` + interrupteur NTP (`timedatectl`) | écran natif avec liste filtrable |
| Langue et clavier | non | `dpkg-reconfigure locales` / `keyboard-configuration` | écran natif |
| Hôtes SSH | non | ouvrir `~/.ssh/config` dans l'éditeur | — |
| Mise à jour | à vérifier | `sudo apt full-upgrade` dans `foot` | — |

Les commandes root passent par une règle `sudoers` limitée à cette liste.

## Apps cibles

Pour chaque besoin : ce qui est déjà dans PT35-OS, à tester en premier, puis l'alternative pensée pour le tactile si celle-ci gêne. Les notes « mobile fit » viennent de LinuxPhoneApps : 5/5 veut dire que l'app tient sur un petit écran et se pilote au doigt. Les petits scripts viendront après les tests, là où une brique existante mérite d'être améliorée.

| Besoin | Déjà dans PT35-OS | Alternative tactile retenue | Priorité |
| --- | --- | --- | --- |
| Terminal | `foot` | — | v1 |
| SSH | Terminal | une entrée de menu par serveur dans `menu.toml` (`exec = "foot ssh nas"`) : config, pas de script | v1 |
| Admin réseau | Moniteur (`htop`), Disque (`ncdu`) | sous-menu « Admin » qui lance des outils standard : `mtr`, `nmap`, `iperf3`, `termshark` | v1 |
| Fichiers locaux + SSH | `yazi` (clavier) | [Fichiers GNOME (Nautilus)](https://linuxphoneapps.org/apps/org.gnome.nautilus/), mobile fit 5/5, GTK4. Un serveur SSH s'ouvre comme un dossier (`sftp://nas`, via `gvfs-backends`) et reste en favori. Copier / coller au doigt entre local et distant, et entre deux serveurs | v1 |
| Éditeur de texte | `mousepad` (Y ouvre sa barre de menus) | [Éditeur de texte GNOME](https://linuxphoneapps.org/apps/org.gnome.texteditor/), mobile fit 5/5 : sélection au doigt, copier / coller par menu, boutons dans la barre. Il ouvre aussi les fichiers distants depuis Fichiers | v1 |
| Musique (mp3) | VLC | si VLC est pénible au doigt : Amberol (lecteur adaptatif GTK4) | v1 (à tester) |
| Vidéo | `mpv` | si besoin : Clapper (lecteur adaptatif GTK4). Le Pi 5 décode le HEVC en matériel et le H.264 1080p en logiciel : pas de limite pratique pour un écran 640 × 480 | v1 (à tester) |
| Wikipédia | Navigateur | [Wike](https://linuxphoneapps.org/apps/com.github.hugolabe.wike), mobile fit 5/5 : lecteur Wikipédia avec images, sommaire, favoris, 300 langues. Le côté « terminal » vient du thème Phosphore | v2 |
| Assistant texte (Claude + Jean-Michel) | DarkWire (agent sur un petit modèle local, pensé pour le Pi 5 : secours hors réseau) | Newelle : assistant GTK4 qui gère l'API Claude, les modèles locaux via Ollama, la voix (transcription et synthèse) et peut lancer des commandes. À vérifier : rendu à 640 × 480, et si Jean-Michel parle le protocole Ollama | v2 |
| Assistant vocal + domotique | — | **Home Assistant** sur une machine du réseau. Il apporte Assist (la chaîne voix), l'intégration Anthropic (Claude), l'intégration Ollama (Jean-Michel), Tuya en officiel et Alexa via un module communautaire. Sur le PocketTerm, on installe juste [linux-voice-assistant](https://github.com/OHF-Voice/linux-voice-assistant) (satellite vocal ARM64 avec mot de réveil local) et on affiche le tableau de bord HA | v3 |
| Rétro-gaming minimal | — | RetroArch. Start et Select restent au système : dans le jeu, Start = X et Select = Y. Il manque un mode où les boutons arrivent bruts au jeu : demander d'abord au mainteneur de PT35-OS, PR seulement s'il n'y a rien | v2 |
| Radio SDR | — | — | un jour peut-être |

Paquets Debian Trixie de Nautilus, Éditeur de texte, Wike et Amberol : pas encore vérifiés. Ils sont tous sur Flathub en secours. Newelle n'existe qu'en Flatpak.

**Micro** : la fiche produit annonce une « prise casque 3,5 mm » et deux haut-parleurs, sans micro ([The Pi Hut](https://thepihut.com/products/pocketterm35-handheld-linux-terminal-for-raspberry-pi)). Test : brancher le micro-casque, puis `arecord -l`. Si rien n'apparaît, un micro-casque USB, au format 16 kHz mono comme l'exige linux-voice-assistant.

## Limites connues d'upstream (PT35-OS 0.4.2)

Constatées sur l'appareil ou dans le code. Chacune se corrige dans le fork de PT35-OS, puis part en PR upstream.

| Limite | Effet | Contournement en attendant |
| --- | --- | --- |
| Pas de défilement au doigt dans le menu | Un toucher est un simple clic à l'endroit où il commence : glisser lance l'élément touché au lieu de faire défiler | D-pad, ou la barre de défilement (cliquer la piste, tirer le curseur) |
| Pas de fond d'écran image | Couleur unie seulement, et le menu opaque couvre le bureau | Aucun |
| Une seule famille de police pour tout le menu | Pas de VT323 pour les titres, JetBrains Mono à vérifier | Police par défaut |

## TODO

L'ordre suit les dépendances. Chaque tâche indique où elle se fait : « appareil » chez Djé sur le PocketTerm, « agent » quand un agent prépare les fichiers dans ce dépôt.

**v1 Socle + admin**

- [x] Agent : relever les touches dans le code de PT35-OS (Start = F22, Select = F21, voir Navigation)
- [x] Créer le dépôt (surcouche dotfiles, pas de fork) et y verser specs et charte
- [ ] Appareil : installer Pi OS Trixie Lite + PocketTerm35-OS, puis `sudo pt35-kbd flash`
- [ ] Appareil : tester au doigt ce qui est déjà là (menu, bascule, Paramètres, mousepad, VLC, `mpv`) et noter ce qui gêne
- [ ] Appareil : `apt install nautilus gvfs-backends gnome-text-editor`, ouvrir `sftp://<serveur>` et tester copier / coller
- [ ] Appareil : brancher le micro-casque, `arecord -l`
- [x] Agent : thème Phosphore pour le menu et la barre (`theme.toml`)
- [ ] Appareil : appliquer le thème Phosphore, vérifier la sélection blanc léger et l'écran d'erreur
- [x] Agent : thème Phosphore pour les apps GTK4 (`gtk.css`) et `foot`
- [ ] Agent : `menu.toml` avec le sous-menu Admin, une entrée par serveur SSH, et les entrées Paramètres manquantes (`nmtui`, fuseau, langue)
- [x] Agent : fond d'écran 640 × 480 (`home/.config/pt35/wallpaper.svg`)
- [x] Agent : icônes Tabler recolorées, thème `Phosphore` (PR #4)
- [ ] Appareil : vérifier les icônes du lanceur
- [x] Agent : fond d'écran sous le lanceur, patch sur notre fork (`0.4.2+u1`)
- [x] Appareil : installer `0.4.2+u1`, vérifier le fond d'écran
- [x] Agent : JetBrains Mono dans le menu et la barre (lien posé par `install.sh`)
- [x] Agent : grille, halo des icônes et scanlines, fork `0.4.2+u2` (publiée)
- [ ] Agent : accueil final (épingles 3 × 3, widget column, All apps), fork `0.4.2+u4` (PR #4 du fork)
- [ ] Agent : épingler `0.4.2+u4` et tout activer dans la surcouche, épingles par défaut dans `install.sh` (PR Unleashed #4)
- [ ] Appareil : installer `0.4.2+u4`, vérifier l'accueil, les jauges, All apps et l'épinglage
- [ ] Agent : défilement au doigt dans `pt35-menu` (glisser = défiler, toucher bref = ouvrir), dans le fork de PT35-OS, puis PR upstream

**v2 Usage**

- [ ] Wike
- [ ] Newelle : tester à 640 × 480 avec Claude, puis Jean-Michel
- [ ] Rétro-gaming : RetroArch + demande au mainteneur pour le mode boutons bruts

**v3 Bonus**

- [ ] Home Assistant sur le réseau (Assist, Anthropic, Ollama, Tuya, Alexa), puis linux-voice-assistant sur le PocketTerm

## Questions ouvertes

- Jean-Michel expose-t-il une API compatible Ollama ou OpenAI ? C'est ce qui permet de le brancher sans code dans Newelle et Home Assistant.
- As-tu déjà un Home Assistant, ou une machine qui pourrait l'héberger (celle de Jean-Michel ?) ?
- Tenda Beli : passe-t-il par l'app Tuya / Smart Life ? Si oui, l'intégration Tuya suffit.
