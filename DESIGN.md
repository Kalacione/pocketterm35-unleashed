---
version: alpha
name: PocketTerm Phosphore
description: Charte cyberdeck rétro, vert phosphore doux sur fond gris-vert, pour l'écran couleur 640x480 tactile du PocketTerm 3.5.
colors:
  primary: "#63e6a4"
  on-primary: "#06110b"
  background: "#0b0f0d"
  surface: "#121a16"
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
    fontSize: 13px
rounded:
  none: 0px
spacing:
  unit: 8px
  bar: 34px
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

Correspondance `theme.toml` : `background`, `background_alt` = surface, `foreground` = primary, `muted`, `accent` = primary, `accent_fg` = on-primary, `warning` = danger, `critical` = error, `ok` = primary, `border` = line, `button_a` = primary, `button_b` = error, `button_x` = teal, `button_y` = danger, `button_neutral` = line. À vérifier sur l'appareil : quelle couleur `pt35-menu` utilise pour la ligne sélectionnée. Si c'est `accent`, la sélection blanc léger demande `accent = selection`, ou une petite PR pour une clé dédiée.

## Typography

Deux polices TTF, lisibles par le moteur de texte du menu (`fontdue`) :

- **VT323** (pixel, OFL) : afficheur et titres (horloge, gros chiffres, titres d'écran). Livrée par le dépôt dans `~/.local/share/fonts`. `theme.toml` n'a qu'une famille pour tout le menu : VT323 sert donc là où on dessine nous-mêmes (widgets, fonds d'écran, icônes).
- **JetBrains Mono** (paquet Debian `fonts-jetbrains-mono`) : tout le texte courant, menu, terminal.

| token | police | taille | usage |
|---|---|---|---|
| display | VT323 | 48-64 px | horloge, gros chiffres |
| title | VT323 | 28 px | titre d'écran |
| body | JetBrains Mono | 17 px | lignes de liste, tuiles |
| label | JetBrains Mono | 12 px, capitales espacées | étiquettes de panneau, méta |
| terminal | JetBrains Mono | 13 px | foot |

## Layout

Mise en page de PT35-OS conservée : barre des tâches 34 px, en-tête 46 px, lignes de 50 px, aide de boutons 46 px. Grille de 8 px pour tout ce qu'on ajoute. Cible tactile minimale 48 × 40.

## Elevation & Depth

Pas d'ombre portée. La profondeur vient de la surface plus claire des panneaux et d'un léger halo (flou de 2 px) réservé aux titres, gros chiffres et courbes. Les scanlines n'existent que dans les fonds d'écran et les maquettes, pas dans l'interface.

## Shapes

Angles droits partout (`menu.radius = 0`). Bordures de 1 px pour les panneaux, 2 px pour l'élément actif. Icônes pixel-art 32 px.

## Components

- **panel / panel-label** : panneau en surface, étiquette pleine en haut à gauche (« SYSTÈME », « RÉSEAU »).
- **list-row-selected / tile-selected** : fond blanc léger, texte sombre.
- **button-danger / button-error** : fond plein orange ou rouge, texte sombre, icône obligatoire.
- **action-bar-button** : gros boutons en bas des écrans d'édition (Copier, Couper, Coller, Annuler, Chercher, Enregistrer). C'est la réponse au « pas de Vim ».
- **barre segmentée** : CPU, RAM, température, signal, volume.
- **courbe en aire** : débit réseau, charge, avec dégradé et halo.
- **hint-bar** : pastilles pleines aux couleurs des boutons physiques (A primary, B error, X teal, Y danger), cliquables.

## Do's and Don'ts

- Do : sélection en blanc léger, visible d'un coup d'œil au doigt comme au D-pad.
- Do : danger et erreur en fond plein, avec icône ou libellé.
- Do : tout faire au doigt, au D-pad, avec ABXY, L/R et par des menus.
- Don't : pas de contour seul ni de texte rouge ou orange pour porter un sens.
- Don't : pas de halo sur le texte courant, pas d'animation de transition, pas de fond animé.
- Don't : pas de jauge de batterie qui afficherait `--`.
