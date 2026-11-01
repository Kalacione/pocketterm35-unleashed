---
version: alpha
name: PocketTerm Phosphore
description: Charte cyberdeck rétro, vert phosphore doux sur fond gris-vert, pour l'écran couleur 640x480 tactile du PocketTerm 3.5.
colors:
  primary: "#63e6a4"
  on-primary: "#06110b"
  background: "#0b0f0d"
  surface: "#121a16"
  tile: "#1c2a23"
  line: "#24382e"
  muted: "#5e8f78"
  bright: "#d4ffe9"
  selection: "#e6fff2"
  teal: "#4fd1d9"
  danger: "#ffa94d"
  error: "#ff6e6e"
typography:
  display:
    fontFamily: VT323
    fontSize: 56px
  title:
    fontFamily: VT323
    fontSize: 28px
  body:
    fontFamily: JetBrains Mono
    fontSize: 17px
  label:
    fontFamily: JetBrains Mono
    fontSize: 12px
    letterSpacing: 0.1em
  terminal:
    fontFamily: JetBrains Mono
    fontSize: 14px
rounded:
  none: 0px
spacing:
  unit: 8px
  bar: 40px
  header: 46px
  row: 50px
  hint: 46px
  target-min: 48px
components:
  panel:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.primary}"
    rounded: "{rounded.none}"
  panel-label:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.label}"
  list-row:
    backgroundColor: "{colors.background}"
    textColor: "{colors.bright}"
    typography: "{typography.body}"
    height: "{spacing.row}"
  list-row-selected:
    backgroundColor: "{colors.selection}"
    textColor: "{colors.on-primary}"
    typography: "{typography.body}"
    height: "{spacing.row}"
  tile-selected:
    backgroundColor: "{colors.selection}"
    textColor: "{colors.on-primary}"
  button-danger:
    backgroundColor: "{colors.danger}"
    textColor: "{colors.on-primary}"
    height: "{spacing.target-min}"
  toggle-on:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.title}"
  toggle-off:
    backgroundColor: "{colors.error}"
    textColor: "{colors.on-primary}"
    typography: "{typography.title}"
  button-error:
    backgroundColor: "{colors.error}"
    textColor: "{colors.on-primary}"
    height: "{spacing.target-min}"
  action-bar-button:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.primary}"
    typography: "{typography.label}"
    height: "{spacing.target-min}"
  hint-bar:
    backgroundColor: "{colors.background}"
    textColor: "{colors.bright}"
    typography: "{typography.label}"
    height: "{spacing.hint}"
---

# PocketTerm Phosphore

Format : [DESIGN.md](https://github.com/google-labs-code/design.md) (Google Labs / Stitch, version alpha, Apache-2.0). Les tokens YAML en tête font foi, le texte explique comment les appliquer.

Pourquoi ce format : un seul fichier lisible par un humain et par un agent, avec les valeurs et le « pourquoi », pour 3 cibles écrites à la main (`theme.toml`, `gtk.css`, `foot.ini`). Écartés : [DTCG](https://www.designtokens.org/) (JSON stable depuis 2025.10, mais sans le texte qui explique) et [Style Dictionary](https://styledictionary.com/) (chaîne de build Node, YAGNI pour 3 fichiers). Le CLI de DESIGN.md sait exporter en DTCG si un jour on en a besoin.

Aperçu visuel, maquettes et `theme.toml` prêt à copier : [`docs/design/charte.html`](docs/design/charte.html) et les SVG de [`docs/design/`](docs/design/). Fonctionnement et périmètre : [`docs/specs.md`](docs/specs.md).

## Overview

Cyberdeck rétro sur un écran **couleur** 640 × 480 tactile (environ 9 px/mm), pas un terminal monochrome : on s'autorise des panneaux, des barres segmentées, des courbes et un léger halo, dans l'esprit d'eDEX-UI et des consoles des années 80. La charte habille [PocketTerm35-OS](https://github.com/therezor/PocketTerm35-OS) sans changer sa mise en page : surcharge de `~/.config/pt35/theme.toml` pour le menu et la barre, `gtk.css` pour les apps GTK4, couleurs `foot` pour le terminal.

v0.2 (31 oct. 2026) : vert adouci, sélection en blanc léger, danger et erreur en fond plein, deux polices, composants graphiques.

## Colors

- **primary** (phosphore doux) : texte, accent, étiquettes de panneau. Menthe désaturée, ≈ 12:1 sur le fond.
- **background** : gris-vert très sombre, pas un noir pur.
- **surface** et **line** : panneaux et leurs bordures de 1 px, grilles de graphiques.
- **muted** : valeurs et libellés secondaires (≈ 5,2:1).
- **bright** : titres, gros chiffres, texte des lignes (≈ 17:1).
- **selection** (blanc léger) : fond de l'élément sélectionné, texte on-primary (≈ 18:1).
- **teal** : uniquement une seconde série de données dans un graphique.
- **danger** (orange phosphore) et **error** (rouge phosphore) : voir la règle d'accessibilité ci-dessous.

**Accessibilité couleur (daltonisme).** Danger et erreur sont toujours en **fond plein** avec un texte on-primary (≈ 10:1 sur orange, ≈ 7:1 sur rouge), et toujours avec une icône ou un libellé (« ⚠ », « × », « SUPPRIMER »). Jamais un simple contour ni un texte coloré : la couleur seule ne porte jamais le sens.

Variantes dans Apparence : Ambre (`#f2b24e` sur `#0f0c08`) et Cyan (`#5fd8e8` sur `#0a0e10`), mêmes rôles.

Correspondance `theme.toml` ([`home/.config/pt35/theme.toml`](home/.config/pt35/theme.toml)) : `background`, `background_alt` = surface, `foreground` = primary, `muted`, `accent` = selection, `accent_fg` = on-primary, `warning` = danger, `critical` = error, `ok` = primary, `border` = line, `button_a` = primary, `button_b` = error, `button_x` = teal, `button_y` = danger, `button_neutral` = line. `pt35-menu` peint la ligne sélectionnée en `accent` : d'où `accent` = selection. Il s'en sert aussi pour le titre « PT35 », son soulignement et les curseurs, qui passent donc en blanc léger. Lanceur en grille (fork `0.4.2+u2`) puis accueil (`0.4.2+u4`, [PR #4](https://github.com/Kalacione/PocketTerm35-OS/pull/4)) : la tuile sélectionnée est pleine en `accent` (blanc léger), icône en `accent_fg`. Réglages : `[menu] launcher_home = true`, `[menu] launcher_columns = 3`, `[icons] size_launcher = 64`, `[icons] glow = 4` (halo des icônes, en px), `[effects] scanlines = 15` (voir Elevation & Depth). Tout est à 0 ou off par défaut ; la surcouche les active dans `theme.toml`. En `0.4.2+u1` et chez upstream, la tuile sélectionnée n'a qu'un halo de 2 px et des coins en `accent`.

## Typography

Deux polices TTF, lisibles par le moteur de texte du menu (`fontdue`) :

- **VT323** (pixel, OFL) : afficheur (horloges, gros chiffres). Livrée par le dépôt dans `~/.local/share/fonts`, où le fork la cherche depuis u5. `[font] family_display = "VT323"` sert aux horloges du widget SYSTEM et de la barre (`[bar] clock_size = 28`). Le menu n'a pas de police par rôle pour les titres : les titres d'écran restent en JetBrains Mono, le token `title` est une cible.
- **JetBrains Mono** (paquet Debian `fonts-jetbrains-mono`) : tout le texte courant, menu, barre et terminal. `install.sh` la lie dans `/usr/share/fonts/TTF`, seul dossier où PT35-OS peut la trouver (voir [`docs/briques.md`](docs/briques.md)).

| token | police | taille | usage |
|---|---|---|---|
| display | VT323 | 48-64 px | horloge, gros chiffres |
| title | VT323 | 28 px | titre d'écran |
| body | JetBrains Mono | 17 px | lignes de liste, tuiles |
| label | JetBrains Mono | 12 px, capitales espacées | étiquettes de panneau, méta |
| terminal | JetBrains Mono | 14 px | foot (`size=10.5`), barre du bas tmux |

## Layout

Mise en page de PT35-OS conservée : barre des tâches 40 px (u5, multiple de la période des scanlines), en-tête 46 px, lignes de 50 px, aide de boutons 46 px. Accueil (u4) : *widget column* de 216 px à gauche (deux panneaux à onglet de même hauteur depuis u12 : SYSTEM, puis la pile de widgets avec sa place `1/2` dans l'en-tête), grille 3 × 3 des épingles à droite, sans colonne latérale ni bandeau de titre (u5). Aperçu : [`docs/design/accueil-u6.png`](docs/design/accueil-u6.png). Réglages rapides : libellé sur le premier tiers, curseur sur 2/3 de la largeur au plus. Grille de 8 px pour tout ce qu'on ajoute. Cible tactile minimale 48 × 40.

## Elevation & Depth

Pas d'ombre portée. La profondeur vient de la surface plus claire des panneaux et d'un léger halo réservé aux titres, gros chiffres et courbes : 3 px sur l'horloge du widget (`[effects] glow = 3`, u5), 4 px sous les icônes de la grille (`[icons] glow`). **Scanlines CRT** : une ligne sur quatre assombrie de 25 % (motif de 4 px, comme la maquette), sur la barre, le menu et par-dessus les apps. Une ligne sur deux à 15 % ne se voyait pas sur l'écran 3,5". Le menu les dessine (`[effects] scanlines`, `[effects] scanline_period` depuis u5), et `pt35-bar --scanlines` pose une surface transparente sous la barre, qui couvre les apps et laisse passer les clics. La hauteur de la barre doit être un multiple de la période. Pas plus marquées : le texte doit rester net.

**Balayage CRT** (u6) : une bande lumineuse douce (8 %) descend tout l'écran en 1,6 s, toutes les 8 à 13 s au hasard (`[effects] sweep = 8`, `sweep_jitter = 5`, `sweep_strength = 8`). Seulement quand le menu est ouvert, jamais sur une app (pas sur une vidéo). Barre et menu se calent sur l'horloge système : une seule bande continue.

**Translucidité** (u6) : tuiles et widgets de l'accueil laissent voir le fond d'écran (`[menu] tile_opacity`, 55 % chez nous). Réglable de 20 à 100 % par le curseur « Tiles » des Réglages rapides ; la valeur vit dans `appearance.toml`, pas dans `theme.toml`. Leur face est `tile` (`#1c2a23`, fork u10), plus claire que `surface` : sur ce fond presque noir, une tuile en `surface` ne changeait pas à l'œil entre 20 et 100 %. Éclaircir `surface` partout aurait fait tomber le texte `muted` des listes sous 4,5:1.

## Shapes

**Icône principale** (fait partie de la charte) : obturateur à 8 lames, pixel art 15 × 15, en primary, clin d'œil à Aperture. C'est la seule icône pixel : elle signe le système dans la barre, la tuile du lanceur et le logo de `fastfetch` (fork u7). Source : [`docs/design/icone-main/D-obturateur.txt`](docs/design/icone-main/D-obturateur.txt) (`#` = pixel allumé), pistes écartées dans [`pistes-v2.png`](docs/design/icone-main/pistes-v2.png).

Angles droits partout (`menu.radius = 0`). Bordures de 1 px pour les panneaux, 2 px pour l'élément actif. Icônes [Tabler](https://tabler.io/icons) (MIT) au trait, en SVG net, recolorées en primary par `tools/icons.sh` dans le thème d'icônes `Phosphore`, qui hérite de Papirus pour les apps non couvertes. Pas de variante claire. Dans la grille du lanceur, le menu dessine sous chaque icône un halo flou de 4 px (`[icons] glow`).

## Components

- **panel / panel-label** : panneau en surface, étiquette pleine en haut à gauche (« SYSTÈME », « RÉSEAU »).
- **list-row** (u9, `[menu] row_frames`) : icône dans un cadre carré, filet entre les lignes, pas de numéro de ligne. Réglages rapides suivent le même rendu.
- **list-row-selected / tile-selected** : fond blanc léger, texte sombre. Dans une liste, la pilule de sélection s'arrête avant la barre de défilement (u9).
- **toggle-on / toggle-off** (u9) : bascule de 64 × 26, le mot ON ou OFF en VT323 dans la moitié libre, à côté du curseur. Fond plein `ok` (vert) si ON, `critical` (rouge) si OFF, texte sombre. Le mot porte l'état, la couleur n'est qu'un appui. Aperçu : [`docs/design/reglages-rapides-u9.png`](docs/design/reglages-rapides-u9.png).
- **button-danger / button-error** : fond plein orange ou rouge, texte sombre, icône obligatoire.
- **action-bar-button** : gros boutons en bas des écrans d'édition (Copier, Couper, Coller, Annuler, Chercher, Enregistrer). C'est la réponse au « pas de Vim ».
- **barre segmentée** : CPU, RAM, température, signal, volume. Masquée si la valeur n'existe pas.
- **courbe en aire** : débit réseau, charge, avec dégradé et halo.
- **app active dans la barre** (u5) : case pleine en `accent`, icône teintée sombre.
- **hint-bar** : touche carrée pleine aux couleurs des boutons physiques (A primary, B error, X teal, Y danger) et action encadrée, cliquables (`[menu] hint_frames = true`, u6).

## Do's and Don'ts

- Do : sélection en blanc léger, visible d'un coup d'œil au doigt comme au D-pad.
- Do : danger et erreur en fond plein, avec icône ou libellé.
- Do : tout faire au doigt, au D-pad, avec ABXY, L/R et par des menus.
- Don't : pas de contour seul ni de texte rouge ou orange pour porter un sens.
- Don't : pas de halo sur le texte courant, pas de fond animé (redessin continu). Seule animation ajoutée : le balayage CRT, rare et jamais sur une app. Les transitions courtes de PT35-OS (~0,1 s) sont gardées : le Pi 5 les tient sans peine.
- Don't : pas de jauge de batterie qui afficherait `--`.
