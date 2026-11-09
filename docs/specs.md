# Specs & TODO

Source de vérité des specs du projet. Charte graphique : [`DESIGN.md`](../DESIGN.md), avec aperçu et maquettes dans [`design/`](design/).
Étude de faisabilité d'origine : [artifact](https://claude.ai/artifact/HaQP5Kn8hYigu6r1Lq8kTP).

## Principes et périmètre

[PocketTerm35-OS](https://github.com/therezor/PocketTerm35-OS) v0.4.2 fait déjà l'essentiel de ce qu'on voulait : Start ouvre un lanceur en grille utilisable au doigt, Select ouvre la bascule d'apps, chaque app a son workspace plein écran, et Paramètres couvre Wi-Fi, Bluetooth, Apparence et Système (lu dans sa [doc des touches](https://github.com/therezor/PocketTerm35-OS/blob/main/docs/KEYS.md), pas encore testé). Notre surcouche se réduit donc à trois choses : un thème, de la config TOML, et quelques écrans qui manquent.

- **Méthode** : avant toute brique, on cherche ce qui existe, dans cet ordre. (1) Ce que PT35-OS fait déjà. (2) Une app pensée pour le tactile sur petit écran, repérée sur [LinuxPhoneApps](https://linuxphoneapps.org), le catalogue des apps Linux testées sur téléphone avec une note « mobile fit ». (3) Un projet reconnu qui couvre plusieurs besoins à la fois. Puis on fait comme un humain : regarder, comprendre, copier, améliorer. L'amélioration « à notre sauce » passe par de la config, des petits scripts qui assemblent ou complètent une brique existante, et des PR upstream quand ça sert à tous. Un script se justifie par ce qu'il ajoute à l'existant, jamais pour le refaire. Si rien n'existe, on crée la brique nous-mêmes, en K.I.S.S. / D.R.Y. / Y.A.G.N.I., dans le cadre le plus adapté : config, script, PR upstream ou module à nous. Cette règle vaut pour tous les fils et tous les agents du projet.
- **K.I.S.S.** : tactile et boutons d'abord. Ergonomie : pas d'outil à la Vim. On déplace le curseur, on sélectionne, on copie, on coupe et on colle au doigt, au D-pad, avec A/B/X/Y, L/R et par des menus, jamais avec des combinaisons de touches à retenir. Valable pour toutes les apps, éditeur compris.
- **D.R.Y.** : un seul toolkit pour les apps graphiques (GTK4 / libadwaita), donc un seul thème : `theme.toml` pour le menu, `gtk.css` pour les apps.
- **Y.A.G.N.I.** : on teste l'app déjà en place avant d'en installer une autre.
- **Matériel** : Raspberry Pi 5, 8 Go de RAM. Les apps GTK4, un petit modèle IA local et la transcription vocale locale sont à sa portée. Le calcul lourd reste quand même sur le réseau (serveur IA local, Home Assistant) pour l'autonomie de la batterie.

| Version | Contenu | Critère de fin |
| --- | --- | --- |
| v1 Socle + admin | PT35-OS installé, thème Phosphore, fond d'écran image, écrans Paramètres manquants, menu Admin réseau, SSH, fichiers locaux et SSH, éditeur, musique et vidéo | Régler l'appareil et administrer le réseau sans taper de commande de config |
| v2 Usage | Wikipédia, assistant texte (Claude + serveur IA local), rétro-gaming minimal | Une semaine d'usage quotidien sans manque bloquant |
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

Le lanceur de PT35-OS est la racine du menu : écrans système, puis apps épinglées, puis les 5 dernières lancées, puis tout le reste. On le parcourt au doigt ou au D-pad. Notre fork le remplace par un écran d'accueil, décrit plus bas. Versions du fork : u1 fond d'écran, u2 grille + halo + scanlines, u3 première version de l'accueil (jamais publiée), u4 accueil final, u5 finitions, u6 balayage CRT, légende encadrée, tuiles translucides, u7 icône principale en obturateur, u8 widget Lecture, u9 écrans de réglages en liste encadrée, u12 pile de widgets et courbe de débit, u13 widgets STORAGE et HOSTS (épinglée dans `PT35_VERSION`). Toutes publiées par `tools/ship.sh`.

- **Manifeste d'app** : une entrée `[app.<id>]` dans `~/.config/pt35/apps.toml` (nom, icône ou 2 caractères, commande, workspace, une ou plusieurs instances). Un outil CLI/TUI se lance avec `foot -a <id> <commande>`. Les fichiers `.desktop` sont aussi lus. C'est le format qu'on utilise, pas besoin d'en inventer un.
- **Sous-menus** : `~/.config/pt35/menu.toml` (types d'entrée `goto`, `app`, `exec`, `action`, `builtin`). Nos ajouts (menu Admin, écrans Paramètres) passent par là.
- **Icône principale** (fork u7, PR #7 du fork) : obturateur à 8 lames en pixel art 15 × 15, clin d'œil à Aperture (Portal). Elle remplace la tête de mort dans la barre, la tuile du lanceur et le logo de `fastfetch` ; le libellé du réglage a été renommé. Dessin : [`design/icone-main/D-obturateur.txt`](design/icone-main/D-obturateur.txt), pistes comparées : [`pistes-v2.png`](design/icone-main/pistes-v2.png).
- **Icônes** : thème `Phosphore` ([PR #4](https://github.com/Kalacione/pocketterm35-unleashed/pull/4)) : icônes Tabler (MIT) au trait, recolorées en vert phosphore par `tools/icons.sh`, Papirus pour le reste. Sans icône, c'est le glyphe de 2 caractères qui s'affiche.
- **Scanlines** : effet CRT sur la barre, le menu et les apps, depuis le fork `0.4.2+u2` (`[effects] scanlines`, `pt35-bar --scanlines` dans la config sway), désactivé par défaut et activé par la surcouche. Une ligne sur deux à 15 % ne se voyait pas sur l'écran 3,5" : u5 ajoute `[effects] scanline_period`, et la surcouche passe à une ligne sur quatre à 25 %. Détails dans `DESIGN.md`.
- **Fond d'écran** : PT35-OS 0.4.2 met une couleur unie, et sans fenêtre ouverte le menu plein écran et opaque sert de bureau : une image posée par sway ne se verrait pas. Notre fork (`0.4.2+u1`) dessine `~/.config/pt35/wallpaper.svg` sous le lanceur, s'il existe. Le SVG est fait de formes (le moteur SVG du menu n'a pas de texte). Le SVG ne garde que la grille et les scanlines : la pluie (fork u20, u21) est dessinée par le menu, en VT323, têtes en glow, vitesse au curseur Pluie des Réglages rapides.
- **Accueil** (fork `0.4.2+u4` ; widgets à gauche, comme la maquette `01-accueil`). Aperçus : [`accueil-u6.png`](design/accueil-u6.png) (avant : [`accueil-u5.png`](design/accueil-u5.png), [`accueil-u4.png`](design/accueil-u4.png)), liste All apps [`toutes-les-apps-u2.png`](design/toutes-les-apps-u2.png) (version u3, même fonctionnement).
  - Réglages : `[menu] launcher_home = true`, `[menu] launcher_columns = 3`, `[icons] size_launcher = 64`, `[icons] glow = 4`. Tout est désactivé par défaut ; la surcouche les active (PR Unleashed #4).
  - Grille 3 × 3 des seules apps épinglées. Plus de colonne latérale ni de tuiles Toutes les apps, Paramètres ou Énergie ; Fenêtres reste sur Select. Défilement par lignes (D-pad, Bas / PageDown), L et R restent réservés. Tuile sélectionnée pleine en blanc léger.
  - *Widget column* à gauche (216 px, `widgets.rs` dans le fork), deux panneaux à onglet de même hauteur (u12). SYSTEM : grosse horloge, date, jauges segmentées CPU, RAM, TEMP. Une jauge sans valeur est masquée.
  - Pile de widgets (fork u12, [fork #12](https://github.com/Kalacione/PocketTerm35-OS/pull/12)) : le panneau du bas montre un widget épinglé à la fois, avec sa place écrite dans l'en-tête (`1/2`). L / R le changent sur l'accueil, un toucher sur l'en-tête aussi. Un lecteur qui démarre passe MEDIA devant. X ouvre All widgets (A montre, Y épingle ou désépingle). Sur l'accueil, L / R ne changent plus de mode : l'icône de mode de la barre le fait. Maquettes : [`widgets-nav-A-pile.png`](design/widgets-nav-A-pile.png) (retenue), [`widgets-nav-B-onglets.png`](design/widgets-nav-B-onglets.png) (écartée) ; rendus [`accueil-reseau-u12.png`](design/accueil-reseau-u12.png), [`accueil-media-u12.png`](design/accueil-media-u12.png), [`tous-les-widgets-u12.png`](design/tous-les-widgets-u12.png).
  - NETWORK : la connexion utilisée (LAN, WIFI + SSID, ou OFFLINE), l'IP, et une courbe des 3 dernières minutes en échelle log fixe de 1 kb/s à 1 Gb/s, lignes aux unités k, M, G ([`widget-reseau-echelles.png`](design/widget-reseau-echelles.png)). Descendant en aire pleine, montant en pointillés, débits en bits dessous. L'historique est tenu par `pt35d` (`pt35ctl traffic`) : le menu est relancé à chaque ouverture.
  - STORAGE et HOSTS (fork u13, [fork #13](https://github.com/Kalacione/PocketTerm35-OS/pull/13), maquette [`widgets-storage-hosts.png`](design/widgets-storage-hosts.png), rendus [`accueil-storage-u13.png`](design/accueil-storage-u13.png), [`accueil-hosts-u13.png`](design/accueil-hosts-u13.png), [`ssh-u13.png`](design/ssh-u13.png)). STORAGE : SD et clés USB, jauge verte, orange au-delà de 75 %, rouge et FULL au-delà de 90 % ; toucher = Fichiers. HOSTS : 3 hosts de `~/.ssh/config` épinglés depuis l'écran SSH (All apps, A connecte, Y épingle), UP / SLOW (> 150 ms) / DOWN, toujours écrit en plus de la couleur ; toucher une ligne = `foot ssh`. `pt35d` teste le port SSH toutes les 2 min ; DOWN seulement après deux tests muets à 30 s d'écart (fork 0.4.5+u2), sinon le premier test au démarrage, avant le réseau ou Tailscale, laissait un faux DOWN 2 min. Rien sur les hosts ne va dans le dépôt.
  - Réveil depuis HOSTS (fork 0.4.5+u2, [fork #25](https://github.com/Kalacione/PocketTerm35-OS/pull/25)) : avec un `~/.config/pt35/hooks/hook_wake` exécutable (mécanisme de hooks d'upstream), toucher une ligne DOWN (ou A sur un hôte épinglé DOWN de l'écran SSH, pour le D-pad) fait lancer `hook_wake <hôte>` par `pt35d`, en fond, coupé à 5 min. La ligne passe à `WAKE m:ss`, puis `UP`, `FAIL` avec la raison (`no answer` = sortie 1, `can't wake` = 2, `exit N`, `did not run`), ou `ON out of reach` : le hook dit la machine allumée mais le Pi ne la voit pas d'où il est (machine joignable en LAN seulement, Pi en déplacement). Ce résultat reste 10 min ou jusqu'à ce que l'hôte réponde. Le hook n'est pas dans ce dépôt : il connaît le réseau (relais, adresses), il vient de notre dépôt privé. Sans hook, un tap sur DOWN ouvre `foot ssh` comme avant. Le réglage par machine reste dans le hook (une commande, l'hôte en `$1`) : une machine de plus ne demande rien côté PocketTerm. Test sans écran : `pt35ctl wake <hôte>`, puis `pt35ctl hosts`.
  - All apps (liste) : Y sur l'accueil l'ouvre ; X ou une lettre l'ouvre en recherche ; en mode souris, clic droit sur une tuile. Dans la liste : A ouvre, B revient à l'accueil, X cherche, Y épingle ou désépingle. Paramètres (`screen:quick`) et Énergie (`page:power`) sont en fin de liste et s'épinglent comme une app.
  - Épingles par défaut, posées par `install.sh` si aucune n'existe : terminal, fichiers, éditeur, navigateur, musique, vidéo, DarkWire, Paramètres, Énergie.
  - SERVICES (fork u23) : `~/.local/state/pt35/services`, une ligne `UP nom` ou `DOWN nom` par service, écrite par n'importe quel script. DOWN d'abord en tag plein, trois lignes puis `+2 more`. Sans écriture depuis 5 minutes, toutes les lignes passent à `OLD`, pour qu'un UP périmé ne rassure pas. Le script et ses adresses restent hors du dépôt, comme les hosts. Maquette : aucune, même dessin de ligne que HOSTS.
  - u5 : plus de bandeau « PT35 // LAUNCHER », barre à 40 px ; horloges du widget et de la barre en VT323 (`[font] family_display`, `[bar] clock_size = 28`), halo sur l'horloge du widget (`[effects] glow = 3`). u22 : heure et date en bright avec halo (`[color] clock`), pour sortir du tout vert ([`horloge-avant-apres-u22.png`](design/horloge-avant-apres-u22.png)).
  - u6 : tuiles et widgets translucides sur le fond d'écran (`[menu] tile_opacity`, 55 % chez nous ; face `[color] tile` depuis u10) ; légende du bas comme la maquette, touche carrée colorée et action encadrée (`[menu] hint_frames = true`) ; balayage CRT, menu ouvert seulement (voir `DESIGN.md`).
  - Widget Lecture (fork u8, [PR #8 du fork](https://github.com/Kalacione/PocketTerm35-OS/pull/8), aperçu [`accueil-lecture-u8.png`](design/accueil-lecture-u8.png)) : panneau `MEDIA` à la place de NETWORK tant qu'un lecteur MPRIS joue ou est en pause, sinon NETWORK revient. Titre, artiste, barre de segments de la position, `1:23 / 4:56`, et l'état écrit en toutes lettres avec son icône (`▶ PLAYING`, `❚❚ PAUSED`, comme le reste du menu en anglais), jamais par la couleur seule. Un toucher sur le panneau fait lecture / pause. Depuis u12 : icône, et boutons précédent, lecture / pause, suivant ; sans lecteur, « Nothing playing ». Lu par `playerctl` hors du fil Wayland, comme le SSID. Paquets `playerctl` et `mpv-mpris`, posés par `install.sh`. Coût : `widgets.rs` et `draw_widgets` (environ 150 lignes), à reporter à chaque mise à jour d'upstream.

## App Paramètres

Paramètres existe déjà dans PT35-OS, en liste avec sous-vues. On complète ce qui manque d'abord par des entrées `exec` qui ouvrent un outil TUI existant (zéro code), puis par des écrans natifs en PR upstream si l'outil TUI est trop pénible.

| Réglage | Déjà dans PT35-OS | v1 (config seule) | Plus tard (PR `pt35-menu`) |
| --- | --- | --- | --- |
| Wi-Fi | oui (scan, connexion) | — | — |
| Bluetooth | oui | — | — |
| Son, luminosité | oui (réglages rapides ; u5 : curseurs à partir du tiers de l'écran, libellé 1/3, curseur 2/3 au plus, aperçu [`reglages-rapides-u5.png`](design/reglages-rapides-u5.png) ; u6 : curseur « Tiles », opacité des tuiles de 20 à 100 %, rangée dans `appearance.toml` posé par `install.sh`, pas dans `theme.toml` qui passerait devant le curseur) | — | — |
| Apparence (palette, police, taille) | oui | palette Phosphore | ligne Fond d'écran |
| Système (CPU, RAM, disque, température, IP) | oui | — | — |
| Réseau filaire / IP fixe, nom d'hôte | non | `nmtui` | écran natif si besoin |
| Date, heure, fuseau horaire | non | `dpkg-reconfigure tzdata` + interrupteur NTP (`timedatectl`) | écran natif avec liste filtrable |
| Langue et clavier | non | `dpkg-reconfigure locales` / `keyboard-configuration` | écran natif |
| Hôtes SSH | non | ouvrir `~/.ssh/config` dans l'éditeur | — |
| Mise à jour | à vérifier | `sudo apt full-upgrade` dans `foot` | — |

Les commandes root passent par une règle `sudoers` limitée à cette liste.

**Rendu des listes** (fork u9, `[menu] row_frames`, activé par la surcouche) : icône de chaque ligne dans un cadre carré, Réglages rapides en liste qui défile comme les autres, filets entre les lignes, pas de numéro de ligne (`show_numbers = false`, posé par `install.sh`). Interrupteurs : le mot ON ou OFF à côté du curseur, sur fond plein vert ou rouge ; le mot porte l'état, la couleur n'est qu'un appui. La pilule de sélection s'arrête avant la barre de défilement. Aperçus : [`reglages-rapides-u9.png`](design/reglages-rapides-u9.png), [`parametres-u9.png`](design/parametres-u9.png).

## Apps cibles

Pour chaque besoin : ce qui est déjà dans PT35-OS, à tester en premier, puis l'alternative pensée pour le tactile si celle-ci gêne. Les notes « mobile fit » viennent de LinuxPhoneApps : 5/5 veut dire que l'app tient sur un petit écran et se pilote au doigt. Les petits scripts viendront après les tests, là où une brique existante mérite d'être améliorée.

| Besoin | Déjà dans PT35-OS | Alternative tactile retenue | Priorité |
| --- | --- | --- | --- |
| Terminal | `foot` + `tmux` (barre du bas Phosphore) | — | v1 |
| SSH | Terminal | une entrée de menu par serveur dans `menu.toml` (`exec = "foot ssh nas"`) : config, pas de script | v1 |
| Admin réseau | Moniteur (`htop`), Disque (`ncdu`) | sous-menu « Admin » qui lance des outils standard : `mtr`, `nmap`, `iperf3`, `termshark` | v1 |
| Fichiers locaux + SSH | `yazi` (clavier) | `yazi` gardé, avec son SFTP natif (v25.12 et plus) et ses onglets : copier dans un onglet, coller dans un autre, local ou serveur. Thème Phosphore (`home/.config/yazi/`). A ouvre, B annule puis remonte, X ouvre Lieux (X encore = dossier perso, 1 à 9 = un hôte SSH dans un nouvel onglet), Y liste les onglets (Y encore = nouvel onglet ici, 1 à 9 = aller à un onglet). L et R gardent leur rôle partout. Ctrl+C / X / V copient, coupent, collent, Ctrl+T / W ouvrent et ferment un onglet. Hôtes lus dans `~/.ssh/config` par `pt35-yazi-vfs` à chaque ouverture | v1 |
| Éditeur de texte | `mousepad` (Y ouvre sa barre de menus), avec notre bandeau d'actions en bas (`pt35-actions`, maquette `05-editeur`) | [Éditeur de texte GNOME](https://linuxphoneapps.org/apps/org.gnome.texteditor/), mobile fit 5/5 : sélection au doigt, copier / coller par menu, boutons dans la barre. Il ouvre aussi les fichiers distants depuis Fichiers | v1 |
| Musique (mp3) | VLC | `mpv` + uosc, comme Vidéo (`home/.config/pt35/apps.toml`) : une seule interface, ouvre `~/Music`. Sans fichier, Musique et Vidéo affichent un accueil uosc (`scripts/pt35-home.lua`) : `Empty folder` (aucun fichier, sous-dossiers compris) ou `Nothing playing`, puis Play all, Browse (aussi les `.m3u`), Open URL au clavier. En anglais comme le reste. `install.sh` crée `~/Music` et `~/Videos`. Il revient tant que rien ne joue : B ne laisse jamais d'écran noir. VLC reste dans All apps | v1 (à tester) |
| Vidéo | `mpv` avec [uosc](https://github.com/tomasklaen/uosc) aux couleurs Phosphore (`home/.config/mpv/`) : toucher la vidéo = pause, A pause, X affiche les contrôles, Y et B (clic droit) ouvrent le menu | si besoin : Clapper (lecteur adaptatif GTK4). Le Pi 5 décode le HEVC en matériel et le H.264 1080p en logiciel : pas de limite pratique pour un écran 640 × 480 | v1 (à tester) |
| Wikipédia | Navigateur | [Wike](https://linuxphoneapps.org/apps/com.github.hugolabe.wike), mobile fit 5/5 : lecteur Wikipédia avec images, sommaire, favoris, 300 langues. Le côté « terminal » vient du thème Phosphore | v2 |
| Assistant texte (Claude + serveur IA local) | DarkWire (agent sur un petit modèle local, pensé pour le Pi 5 : secours hors réseau) | Newelle : assistant GTK4 qui gère l'API Claude, les modèles locaux via Ollama, la voix (transcription et synthèse) et peut lancer des commandes. À vérifier : rendu à 640 × 480, et si le serveur IA local parle le protocole Ollama | v2 |
| Assistant vocal + domotique | — | **Home Assistant** sur une machine du réseau. Il apporte Assist (la chaîne voix), l'intégration Anthropic (Claude), l'intégration Ollama (serveur IA local), Tuya en officiel et Alexa via un module communautaire. Sur le PocketTerm, on installe juste [linux-voice-assistant](https://github.com/OHF-Voice/linux-voice-assistant) (satellite vocal ARM64 avec mot de réveil local) et on affiche le tableau de bord HA | v3 |
| Rétro-gaming minimal | — | RetroArch. Start et Select restent au système : dans le jeu, Start = X et Select = Y. Il manque un mode où les boutons arrivent bruts au jeu : demander d'abord au mainteneur de PT35-OS, PR seulement s'il n'y a rien | v2 |
| Radio SDR | — | — | un jour peut-être |

Paquets Debian Trixie de Nautilus, Éditeur de texte, Wike et Amberol : pas encore vérifiés. Ils sont tous sur Flathub en secours. Newelle n'existe qu'en Flatpak.

**Micro** : la fiche produit annonce une « prise casque 3,5 mm » et deux haut-parleurs, sans micro ([The Pi Hut](https://thepihut.com/products/pocketterm35-handheld-linux-terminal-for-raspberry-pi)). Test : brancher le micro-casque, puis `arecord -l`. Si rien n'apparaît, un micro-casque USB, au format 16 kHz mono comme l'exige linux-voice-assistant.

## Tactile : défilement et gestes

Analyse du 1er novembre 2026. Étapes 1 et 2 retenues : fork u18 ([fork #18](https://github.com/Kalacione/PocketTerm35-OS/pull/18)).

**Constat.**

- Matériel : le GT911 est multitouch (5 doigts, pilote `goodix`). sway passe les doigts tels quels aux apps par `wl_touch`. libinput ne reconnaît aucun geste sur un écran tactile (ses gestes sont pour les pavés), donc le `bindgesture` de sway ne sert pas ici.
- Menu : `pt35-ui` (`layer.rs`) lit `wl_touch` lui-même. Chaque doigt posé appelle `App::touch` tout de suite : c'est le clic au toucher, et un deuxième doigt est un deuxième clic. Le glisser arrive déjà (`App::drag`) mais ne sert qu'à la barre de défilement.
- Listes : `ListState` défile par lignes entières (`offset` entier), pas au pixel. Six fonctions de dessin en dépendent (lignes, tuiles, accueil, apps, bascule, réglages rapides) et `Canvas` n'a pas de zone de découpe.
- Upstream : rien sur le tactile chez therezor jusqu'à 0.4.5 (novembre 2026), ni issue ni PR.

**Apps tierces : déjà couvertes, vérifié au doigt sur l'appareil.**

- foot (depuis 1.16, Trixie livre 1.21) : glisser = molette, ligne par ligne ; appui long (`[touch] long-press-delay`, 400 ms) puis glisser = sélection ; toucher bref = clic. La molette va à tmux (`mouse on` : historique), yazi, htop. Pas d'inertie.
- GTK3 / GTK4 (mousepad, Éditeur GNOME) et Firefox : défilement au doigt avec inertie, natif.
- mpv + uosc : toucher = clic, la barre de lecture se tire au doigt. Suffisant.
- VLC (Qt) : le doigt devient une souris, sans défilement cinétique. Reste dans All apps.

**Menu : étapes proposées** (fork, puis PR upstream ; chacune livrable seule, tailles estimées)

1. Toucher au relâcher, glisser = défiler (~120 lignes, `layer.rs` et `ListState`). Le doigt posé surligne la ligne. Au-delà d'environ 12 px c'est un glisser : la liste suit le doigt d'une ligne (ou d'une rangée de tuiles) par hauteur de ligne parcourue. Relevé sans bouger = toucher. Même modèle que foot. Le second doigt est ignoré. Barre de défilement, déplacement d'épingle (MOVE) et curseurs inchangés ; la bascule défile en horizontal. `pt35-bar` agit aussi au relâcher, comme à la souris.
2. Appui long = menu de la ligne (~30 lignes) : Open / Pin, Switch to / Close, ce que fait le clic droit. Évite un geste à deux doigts.
3. Inertie (~80 lignes) : vitesse des 100 dernières ms au relâcher, puis la liste continue par crans qui ralentissent, sur la boucle 60 fps existante (`App::animating`). Un doigt posé l'arrête.
4. Défilement au pixel (~300 lignes, les six dessins plus une découpe dans `Canvas`) : la liste colle au doigt comme sur un téléphone. Le plus lourd à reporter à chaque version d'upstream : seulement si 1 et 3 ne suffisent pas à l'usage.
5. Plus tard, si un usage le demande : balayage horizontal sur la pile de widgets et les pages d'épingles ; gestes à plusieurs doigts (voir lisgd dans `briques.md`).

Suite : 3 après essai de u18 sur l'appareil, 4 seulement si 1 et 3 ne suffisent pas.

## Limites connues d'upstream (PT35-OS 0.4.5)

Constatées sur l'appareil ou dans le code. Chacune se corrige dans le fork de PT35-OS, puis part en PR upstream.

| Limite | Effet | Contournement en attendant |
| --- | --- | --- |
| Pas de défilement au doigt dans le menu | Un toucher est un simple clic à l'endroit où il commence : glisser lance l'élément touché au lieu de faire défiler | Corrigé par u18 (fork #18) : voir Tactile |
| Pas de fond d'écran image | Couleur unie seulement, et le menu opaque couvre le bureau | Aucun |
| Une seule famille de police pour tout le menu | Pas de VT323 pour les titres | Fork u5 : VT323 pour les horloges (`[font] family_display`) ; les titres d'écran restent en JetBrains Mono |

## TODO

L'ordre suit les dépendances. Chaque tâche indique où elle se fait : « appareil » sur le PocketTerm, « agent » quand un agent prépare les fichiers dans ce dépôt.

**v1 Socle + admin**

- [x] Agent : relever les touches dans le code de PT35-OS (Start = F22, Select = F21, voir Navigation)
- [x] Créer le dépôt (surcouche dotfiles, pas de fork) et y verser specs et charte
- [ ] Appareil : installer Pi OS Trixie Lite + PocketTerm35-OS, puis `sudo pt35-kbd flash`
- [ ] Appareil : tester au doigt ce qui est déjà là (menu, bascule, Paramètres, mousepad, VLC, `mpv`) et noter ce qui gêne
- [ ] Appareil : Files (yazi), X puis un chiffre pour un hôte SSH, copier / coller entre deux onglets
- [ ] Appareil : brancher le micro-casque, `arecord -l`
- [x] Agent : thème Phosphore pour le menu et la barre (`theme.toml`)
- [ ] Appareil : appliquer le thème Phosphore, vérifier la sélection blanc léger et l'écran d'erreur
- [x] Agent : thème Phosphore pour les apps GTK4 (`gtk.css`) et `foot`
- [x] Agent : barre du bas du Terminal (tmux), police du terminal à 14 px
- [ ] Appareil : vérifier la barre du bas, la molette en mode souris et la copie au glisser
- [ ] Agent : `menu.toml` avec le sous-menu Admin, une entrée par serveur SSH, et les entrées Paramètres manquantes (`nmtui`, fuseau, langue)
- [x] Agent : fond d'écran 640 × 480 (`home/.config/pt35/wallpaper.svg`)
- [x] Agent : icônes Tabler recolorées, thème `Phosphore` (PR #4)
- [ ] Appareil : vérifier les icônes du lanceur
- [x] Agent : fond d'écran sous le lanceur, patch sur notre fork (`0.4.2+u1`)
- [x] Appareil : installer `0.4.2+u1`, vérifier le fond d'écran
- [x] Agent : JetBrains Mono dans le menu et la barre (lien posé par `install.sh`)
- [x] Agent : grille, halo des icônes et scanlines, fork `0.4.2+u2` (publiée)
- [x] Agent : accueil final (épingles 3 × 3, widget column, All apps), fork `0.4.2+u4`
- [x] Agent : épingler `0.4.2+u4` et tout activer dans la surcouche, épingles par défaut dans `install.sh`
- [x] Agent : finitions u5 (scanlines 1/4 à 25 %, horloges VT323, barre 40 px, réglages rapides)
- [x] Agent : u6 (balayage CRT, légende encadrée, tuiles translucides, curseur Tiles), fork #6 et unleashed #7
- [x] Agent : u7 (icône obturateur), fork #7, épinglé par `tools/ship.sh`
- [x] Agent : u8, widget Lecture (MPRIS via `playerctl`) sur l'accueil, fork #8
- [x] Agent : u9, listes encadrées, interrupteurs ON/OFF sur fond plein, pilule avant la barre de défilement, sans numéro de ligne (fork #9, unleashed #13)
- [x] Agent : `tools/ship.sh` remplace `release-fork.sh` et `pin-pt35.sh` (unleashed #12) ; `PT35_VERSION` = `0.4.2+u9`
- [x] Appareil : `git pull && ./install.sh --pt35 && ./install.sh`, puis vérifier d'un coup : accueil, jauges, All apps et épinglage (u4), balayage menu seul et curseur Tiles (u6), obturateur (u7), panneau MEDIA et pause au toucher (u8), état des interrupteurs lisible d'un coup d'œil (u9)
- [x] Agent : mpv + uosc aux couleurs Phosphore (`home/.config/mpv/`, uosc épinglé dans `install.sh`)
- [x] Agent : u12, pile de widgets, All widgets, courbe de débit log, MEDIA complet ([fork #12](https://github.com/Kalacione/PocketTerm35-OS/pull/12))
- [ ] Appareil : après `tools/ship.sh` pour u12 puis u13, vérifier L / R et le toucher sur l'en-tête, X → All widgets, la courbe pendant un téléchargement, les boutons MEDIA ; u13 : widgets STORAGE et HOSTS, écran SSH, `pt35ctl hosts`
- [ ] Appareil : `./install.sh`, ouvrir Vidéo puis Musique, tester uosc au doigt et aux boutons
- [x] Agent : écran de démarrage PocketTerm OS (thème Plymouth, images générées par `tools/splash.py`)
- [ ] Appareil : `./install.sh`, redémarrer, vérifier l'écran de démarrage et la barre
- [x] Appareil : Terminal, `seq 500` puis glisser vite vers le bas (l'historique remonte, `q` pour sortir) ; appui long puis glisser (sélection) ; Files, glisser dans la liste ; mousepad, glisser dans un long texte. Noter ce qui gêne
- [x] Trancher les étapes du menu (1 et 2, voir Tactile)
- [x] Agent : étapes 1 et 2 du tactile, fork u18 ([fork #18](https://github.com/Kalacione/PocketTerm35-OS/pull/18))
- [ ] Appareil : après `tools/ship.sh` pour u18, vérifier au doigt : glisser dans All apps et Paramètres fait défiler sans rien ouvrir ; toucher bref ouvre au relâcher ; appui long sur une app ouvre Open / Pin ; balayage sur la bascule ; barre de défilement ; tuiles de l'accueil, widgets et barre du haut au toucher
- [ ] Appareil : après `tools/ship.sh` pour 0.4.5+u2, réveil depuis HOSTS : `pt35ctl wake <hôte>`, puis un tap sur une ligne DOWN (WAKE, puis UP), A sur l'écran SSH, et plus de faux DOWN au démarrage
- [ ] Appareil : éditeur, barre de menus de 32 px en VT323, texte en JetBrains Mono 14 px, bandeau d'actions et barre tmux en anglais
- [x] Agent : Navigateur sur Firefox, profil `pt35-firefox` : pages mobiles (user-agent et viewport mobile), barre et menus Phosphore de 40 px, accueil seul au lancement
- [ ] Appareil : `./install.sh`, ouvrir Navigateur, vérifier la version mobile de Wikipédia, la taille, la barre d'adresse en VT323 et les menus
- [x] Agent : passage à upstream 0.4.5, fork `0.4.5+u1` ([fork #24](https://github.com/Kalacione/PocketTerm35-OS/pull/24)) ; Super+Entrée passe par upstream (`pt35ctl launch terminal`, donc notre `[app.terminal]`)
- [ ] Appareil : après `tools/ship.sh` pour `0.4.5+u1`, vérifier l'horloge VT323, la pluie et les halos, Super+Entrée (Terminal tmux devant), Paramètres > Barre et Menu

**Prochains chantiers** (pas commencés)

- [x] Fil d'Ariane : 46 → 32 px, prompt `PT35 ❯ SETTINGS ❯` et titre en VT323, 7 lignes de liste au lieu de 6 (fork u19, piste C3 de `design/fil-ariane/` du dossier partagé)
- [ ] Appareil : après `tools/ship.sh` pour u19, ouvrir Settings, vérifier le fil, la 7e ligne et le retour au doigt sur `PT35`
- [ ] Reskin des apps aux couleurs Phosphore, au-delà de GTK4, `foot` et mpv : liste des apps à cadrer
- Mis de côté : fond d'écran animé (pluie), il oblige à redessiner l'accueil en continu

**v2 Usage**

- [ ] Wike
- [ ] Newelle : tester à 640 × 480 avec Claude, puis le serveur IA local
- [ ] Rétro-gaming : RetroArch + demande au mainteneur pour le mode boutons bruts

**v3 Bonus**

- [ ] Home Assistant sur le réseau (Assist, Anthropic, Ollama, Tuya, Alexa), puis linux-voice-assistant sur le PocketTerm

## Questions ouvertes

- Le serveur IA local expose-t-il une API compatible Ollama ou OpenAI ? C'est ce qui permet de le brancher sans code dans Newelle et Home Assistant.
- Quelle machine du réseau peut héberger Home Assistant ?
- Tenda Beli : passe-t-il par l'app Tuya / Smart Life ? Si oui, l'intégration Tuya suffit.
