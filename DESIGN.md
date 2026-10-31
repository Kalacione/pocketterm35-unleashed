---
version: alpha
name: PocketTerm Matrix
description: Charte cyberdeck rétro-pixel, phosphore sur noir, pour l'écran 640x480 tactile du PocketTerm 3.5.
colors:
  primary: "#33ff66"
  on-primary: "#050805"
  background: "#050805"
  surface: "#0d2a16"
  muted: "#1d7a3a"
  bright: "#c8ffd6"
  warning: "#ffb000"
  critical: "#ff3b4e"
  button-x: "#33e6ff"
typography:
  title:
    fontFamily: VT323
    fontSize: 28px
  menu:
    fontFamily: VT323
    fontSize: 24px
  meta:
    fontFamily: VT323
    fontSize: 18px
  terminal:
    fontFamily: VT323
    fontSize: 16px
rounded:
  none: 0px
spacing:
  unit: 8px
  bar: 34px
  header: 46px
  row: 50px
  hint: 46px
  tile: 86px
  target-min: 48px
components:
  taskbar:
    backgroundColor: "{colors.background}"
    textColor: "{colors.primary}"
    typography: "{typography.meta}"
    height: "{spacing.bar}"
  list-row:
    backgroundColor: "{colors.background}"
    textColor: "{colors.primary}"
    typography: "{typography.menu}"
    height: "{spacing.row}"
    rounded: "{rounded.none}"
  list-row-selected:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.menu}"
    height: "{spacing.row}"
  tile:
    backgroundColor: "{colors.background}"
    textColor: "{colors.primary}"
    typography: "{typography.menu}"
    height: "{spacing.tile}"
    rounded: "{rounded.none}"
  tile-selected:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.bright}"
    height: "{spacing.tile}"
  button-destructive:
    backgroundColor: "{colors.background}"
    textColor: "{colors.critical}"
    height: "{spacing.target-min}"
    rounded: "{rounded.none}"
  hint-bar:
    backgroundColor: "{colors.background}"
    textColor: "{colors.bright}"
    typography: "{typography.meta}"
    height: "{spacing.hint}"
---

# PocketTerm Matrix

Format : [DESIGN.md](https://github.com/google-labs-code/design.md) (Google Labs / Stitch, version alpha, Apache-2.0). Les tokens YAML en tête font foi, le texte explique comment les appliquer.

Pourquoi ce format : un seul fichier lisible par un humain et par un agent, avec les valeurs et le « pourquoi », pour 3 cibles écrites à la main (`theme.toml`, `gtk.css`, `foot.ini`). Écartés : [DTCG](https://www.designtokens.org/) (JSON stable depuis 2025.10, mais sans le texte qui explique) et [Style Dictionary](https://styledictionary.com/) (chaîne de build Node, YAGNI pour 3 fichiers). Le CLI de DESIGN.md sait exporter en DTCG si un jour on en a besoin. Aperçu visuel et maquettes : [`docs/design/charte.html`](docs/design/charte.html) et les SVG de [`docs/design/`](docs/design/). Fonctionnement et périmètre : [`docs/specs.md`](docs/specs.md).

## Overview

Un écran de terminal vert, façon cyberdeck rétro-pixel et ambiance Matrix, sur un écran 640 × 480 tactile d'environ 9 px/mm. La charte habille [PocketTerm35-OS](https://github.com/therezor/PocketTerm35-OS) sans changer sa mise en page : elle se traduit en surcharge de `~/.config/pt35/theme.toml` pour le menu et la barre, en `gtk.css` pour les apps GTK4, et en couleurs `foot`.

## Colors

- **primary** (phosphore) : texte principal, sélection, accent. Contraste ≈ 15:1 sur le fond.
- **background** : tout l'écran, fond de terminal. Quasi noir avec une pointe de vert.
- **surface** : panneaux, tuile sélectionnée.
- **muted** : bordures, valeurs secondaires, libellés de 16 px et plus seulement (≈ 3,8:1).
- **bright** : texte sur surface, titres, emphase (≈ 17:1).
- **warning** (ambre) et **critical** (rouge) : états seulement, jamais décoratifs. Le rouge marque une action destructive (fermer, supprimer).
- **button-x** : pastille du bouton X dans l'aide de boutons, pour coller aux couleurs physiques.

Variantes de palette proposées dans Apparence : Ambre (`#ffb000` sur `#0a0702`) et Cyan (`#33e6ff` sur `#03080a`), même rôles.

Correspondance `theme.toml` : `background`, `background_alt` = surface, `foreground` = primary, `muted`, `accent` = primary, `accent_fg` = on-primary, `warning`, `critical`, `ok` = primary, `border` = muted, `button_a` = primary, `button_b` = critical, `button_x`, `button_y` = warning, `button_neutral` = surface.

## Typography

Une seule famille, pixel, en TTF : VT323 (OFL). Le menu et la barre de PT35-OS dessinent le texte avec `fontdue`, qui ne lit pas les polices bitmap (PCF, OTB). Si VT323 bave à 16 px dans `foot`, repli sur Terminus TTF pour le terminal seulement. À valider à l'œil sur l'appareil.

| token | taille | clé `theme.toml` | usage |
|---|---|---|---|
| title | 28 px | `size_title` | en-tête d'écran |
| menu | 24 px | `size_menu` | lignes de liste, libellés de tuiles |
| meta | 18 px | `size_bar`, `size_hint` | barre des tâches, aide de boutons |
| terminal | 16 px | `foot.ini` | terminal |

## Layout

On garde la mise en page de PT35-OS, déjà réglée pour cet écran. Seule la grille du lanceur change : 4 colonnes au lieu de 3 (`menu.columns = 4`). Grille de 8 px pour tout ce qu'on ajoute.

| élément | dimension | clé `theme.toml` |
|---|---|---|
| barre des tâches | 640 × 34 | `bar.height` |
| en-tête | 46 | `menu.header_height` |
| ligne de liste | 50, 7 lignes visibles | `menu.row_height` |
| tuile du lanceur | 86 de haut, 4 colonnes | `menu.tile_height`, `menu.columns` |
| aide de boutons | 640 × 46 | `menu.hint_height` |
| cible tactile minimale | 48 × 40 | — |

## Elevation & Depth

Aucune. Pas d'ombre, pas de flou, pas de dégradé. La profondeur passe par l'assombrissement de ce qui est derrière : fond d'écran à 55 % sous le lanceur, app courante à 90 % sous la bascule d'apps.

## Shapes

Angles droits partout (`menu.radius = 0`). Bordures pleines de 2 px. Icônes pixel-art 32 px, deux couleurs plus transparence, agrandies au plus proche voisin.

## Components

- **list-row / list-row-selected** : la sélection est une inversion vidéo (fond phosphore, texte noir) avec un curseur `>`. Valeur actuelle à droite en muted, chevron vers la sous-vue.
- **tile / tile-selected** : tuile active en surface avec bordure phosphore.
- **button-destructive** : bordure et texte critical, jamais plus petit que la cible minimale.
- **hint-bar** : pastilles colorées comme les boutons physiques, cliquables.
- **taskbar** : celle de PT35-OS. Pas d'indicateur de batterie, le matériel ne l'expose pas.

## Do's and Don'ts

- Do : sélection visible d'un coup d'œil, au doigt comme au D-pad.
- Do : tout faire au doigt, au D-pad, avec ABXY, L/R et par des menus.
- Do : le curseur est la seule chose qui clignote (`menu.animations = false`).
- Don't : pas d'arrondi, d'ombre, de dégradé ni de fond animé (le Pi 4 garde ses cycles pour les apps).
- Don't : pas de deuxième police.
- Don't : pas d'ambre ni de rouge décoratifs.
- Don't : pas de jauge de batterie qui afficherait `--`.
