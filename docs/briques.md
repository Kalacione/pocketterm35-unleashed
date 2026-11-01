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
| thème Plymouth `script` (`plymouth/pocketterm/`) | retenu | remplace l'écran « Raspberry Pi Desktop » (thème `pix` de `rpd-plym-splash`) sans fork : une image par état de la barre, échangées par le script |
| images de démarrage générées à l'install (`tools/splash.py`, Pillow) | retenu | aucune image dans le dépôt : couleurs, obturateur et police viennent de la charte, un changement suit au prochain `install.sh`. Pistes : `design/boot/` du dossier partagé |
| texte dessiné par Plymouth (`Image.Text`) | écarté | il faudrait mettre la police dans l'initramfs ; l'image figée suffit |
| numéros de ligne dans les listes | écarté | bruit à 640x480, le fil d'Ariane donne déjà la position ; `install.sh` pose `show_numbers = false` |
| accueil uosc à l'idle, `scripts/pt35-home.lua` (API de menus d'uosc) | retenu | écran noir sans fichier une fois « Drop files » masqué. Un menu uosc dit que la médiathèque est vide et propose Browse (navigateur d'uosc) et une URL tapée dans son champ de recherche : thème déjà fait, aucun patch du fork |
| liste de `~/Music` dans `pt35-menu` | écarté | patch Rust à reporter à chaque mise à jour d'upstream, refait le navigateur d'uosc |
| profils mpv `pt35-music` / `pt35-video` | retenu | chaque app a sa médiathèque (`uosc-default_directory`) ; les playlists sont déjà séparées, un processus mpv par app. Les `.m3u` s'ouvrent depuis Browse sans réglage |
| vnstat pour la courbe de débit | écarté | historique par tranches de 5 min au mieux, il faut un point toutes les 2 s : `pt35d` lit déjà les compteurs de `/sys/class/net` à chaque tour |
| courbe de débit en échelle log fixe 1k → 1G (fork u12) | retenu | repos et téléchargement lisibles sur le même graphe, aucun saut d'échelle ; les lignes sont les unités. Le linéaire auto écrasait le repos 3 min après chaque rafale |
| widgets en pile, L / R et toucher sur l'en-tête (fork u12) | retenu | pas de glisser possible ; les onglets ne tiennent pas plus de 2 widgets dans 216 px. L / R ne servaient sur l'accueil qu'à changer de mode, que l'icône de la barre fait déjà |
| un widget par connexion (LAN, Wi-Fi) | écarté | afficher un périphérique inutilisé n'apporte rien : NETWORK suit la route que `pt35d` connaît déjà |
| [tmux](https://github.com/tmux/tmux) (ISC, Debian) pour la barre du bas du Terminal | retenu | barre de statut native, couleurs en config ; donne aussi la molette sur l'historique et la copie OSC 52 vers foot. Lancé par la tuile Terminal et Super+Entrée seulement : `foot ssh …` et les apps en `foot -a` restent sans |
| [Zellij](https://zellij.dev/) | écarté | barre plus riche mais binaire hors Debian, plus lourd, raccourcis qui prennent beaucoup de touches : YAGNI |
| barre de prompt ([Starship](https://starship.rs/)) | écarté | habille le prompt, pas le bas de l'écran ; à reconsidérer à part |
| bandeau d'actions `pt35-actions` (Python, GTK3 + [gtk-layer-shell](https://github.com/wmww/gtk-layer-shell), wtype) | retenu | maquette `05-editeur` : Copier, Couper, Coller, Annuler, Chercher, Enregistrer en bas de l'éditeur. Surface layer-shell sans clavier, montrée quand l'app a le focus (`swaymsg subscribe`), raccourcis Ctrl envoyés par wtype (déjà dépendance de PT35-OS). Une app de plus = une entrée dans `ACTIONS` |
| barre d'outils native de mousepad | écarté | toujours en haut, en anglais, quinze icônes : ni la maquette ni le pouce |
| Waybar (modules custom + `on-click`) | écarté | pas de moyen fiable de l'afficher seulement sur l'éditeur (SIGUSR1 bascule à l'aveugle) |
| barre d'actions par app dans `pt35-bar` (fork) | en réserve | la bonne place à terme, et proposable à upstream ; patch Rust à reporter à chaque version, pour six boutons |
| hosts du widget HOSTS lus dans `~/.ssh/config` (fork u13) | retenu | déjà la source de vérité, reste sur l'appareil, rien dans le dépôt ; `ssh -G` résout comme ssh. Pin / unpin sur l'écran SSH |
| ping (ICMP) pour HOSTS | écarté | une connexion TCP au port SSH dit si on peut s'y connecter, et passe quand l'ICMP est filtré ; un test toutes les 2 min par `pt35d` |
| VPN OpenVPN dans NETWORK | à cadrer | NetworkManager importe les `.ovpn` (`network-manager-openvpn`) ; le widget ferait `nmcli con up/down` |
| redémarrer `pt35d` et la barre dans le `postinst` (fork u14) | retenu | les boucles de respawn du sway config relancent les nouveaux binaires ; sinon l'ancien démon reste jusqu'au prochain login et les widgets HOSTS et NETWORK restent vides |
| réordonner les épingles de l'accueil avec B (fork u15) | retenu | B ne fait rien sur l'accueil ; L/R tournent déjà les widgets et il n'y a pas d'autre bouton au dos. Croix = échange avec la voisine, A ou B pose, ordre écrit dans le fichier `pinned` à chaque pas. Tuile saisie : cadre épais + étiquette MOVE |
| captures du README : sway headless (`WLR_BACKENDS=headless`, 640x480) + `grim`, binaires du fork compilés sur PC | retenu | rendu réel du menu, de la barre et des apps sans l'appareil ; seules les icônes système et les valeurs (IP, disques) diffèrent du Pi |
| [yazi](https://github.com/sxyazi/yazi) (MIT) avec son VFS SFTP et ses onglets | retenu | déjà l'explorateur de PT35-OS ; copier / coller local ↔ SSH ↔ SSH entre onglets sans paquet ni patch. Thème, touches et deux petits plugins Lua dans `home/.config/yazi/`. Limite : yazi ne vérifie pas la clé d'hôte du serveur et ignore ProxyJump |
| `pt35-yazi-vfs` (`ssh -G` → `vfs.toml`) | retenu | yazi ne lit pas `~/.ssh/config` : on le traduit à chaque ouverture de Files, la liste d'hôtes reste hors du git |
| [smart-enter](https://github.com/yazi-rs/plugins) (MIT) | copié | A doit entrer dans un dossier, pas l'ouvrir avec une autre app ; trois lignes reprises dans `pt35-nav` plutôt qu'un `ya pkg` de plus |
| Nautilus + GVFS, Thunar | écarté | lit `~/.ssh/config` et va au doigt, mais ~100 Mo de dépendances et une interface serrée à 640x480, pour refaire ce que yazi fait |
| mc (double panneau, sftpfs) | écarté | 40 colonnes par panneau à 640x480, touches F |
| bandeau `pt35-actions` pour Files | écarté | le clavier physique fait Ctrl+C / Ctrl+V : pas d'interface en plus |
| [sshfs.yazi](https://github.com/uhs-robert/sshfs.yazi) | écarté | monte par sshfs (FUSE, paquet en plus) ce que le SFTP natif de yazi fait déjà |
| L / R pour les onglets de Files (patch `pt35d`) | écarté pour l'instant | L ferme et R change de mode partout : un sens par bouton. Y (F10, libre dans yazi) liste les onglets comme X liste les lieux, et un hôte choisi par X s'ouvre dans son propre onglet : deux onglets suffisent pour copier |
| défilement tactile de [foot](https://codeberg.org/dnkl/foot) (depuis 1.16) | retenu | glisser = molette, appui long = sélection, sans config ; tmux, yazi et htop défilent déjà au doigt |
| gestes libinput / `bindgesture` de sway | écarté | pavés tactiles seulement, rien pour un écran tactile |
| [Touchégg](https://github.com/JoseExposito/touchegg) | écarté | X11, ou GNOME / KDE par extension : rien pour sway |
| [lisgd](https://git.sr.ht/~mil/lisgd) (sxmo) | en réserve | gestes multi-doigts → commande (ex. 3 doigts = Start), lit evdev sans config sway ; mais l'app sous les doigts reçoit le même geste, donc il agit deux fois. Seulement si un geste système est demandé |
| défilement tactile dans `pt35-ui` (fork u18) | retenu | rien d'existant pour une surface layer-shell en Rust ; on copie le modèle de foot : rien au toucher, 12 px puis glisser = défiler par lignes, 500 ms = appui long (clic droit), second doigt ignoré. Voir `specs.md`, Tactile |
| fil d'Ariane en prompt, `❯` et titre en VT323 sur 32 px (fork u19) | retenu | piste C3 parmi un onglet plein et deux autres séparateurs (`>`, chemin bash). À 32 px la liste montre 7 lignes ; 64 px dans la maquette de la charte, 46 chez upstream |
| Firefox dans un profil à nous (`home/.local/share/pt35-firefox/` : `user.js`, `chrome/userChrome.css`) | retenu | user-agent Android et 1,5 pixel par pixel CSS : 427 px de large, les sites servent leur version mobile, au doigt. Seul des deux navigateurs dont l'interface se skinne (police, tailles, couleurs). Profil à chemin fixe (`--profile`), lié par stow ; ton profil Firefox habituel n'est pas touché |
| Chromium (`--user-agent`, `--force-device-scale-factor`, `--touch-events`) | écarté comme Navigateur | fait aussi les pages mobiles, mais son interface ne change que par un thème d'extension : couleurs seules, pas de police, tailles liées à l'échelle de la page. Reste dans All apps tel qu'upstream le lance (échelle 0,75) |
| [mobile-config-firefox](https://gitlab.postmarketos.org/postmarketOS/mobile-config-firefox) (postmarketOS, Debian `firefox-esr-mobile-config`, GPL-3.0) | écarté, idée reprise | fait pour un téléphone en portrait (revient à l'interface de bureau en paysage), installé pour tout le système et pour `firefox-esr` seulement ; on reprend l'idée : user-agent mobile et `userChrome.css` |
| `dom.meta-viewport.enabled` (viewport mobile de Firefox) | écarté | une page sans balise viewport serait rendue sur 980 px puis réduite : illisible à 640x480. La largeur de 427 px suffit aux sites adaptatifs |
| `policies.json` de Firefox | écarté | demande root (`/etc/firefox/policies`) et vaut pour tous les profils : `user.js` suffit |
| mode kiosque (`--kiosk`, `--app`) | écarté | plus de barre d'adresse ni de menus |
