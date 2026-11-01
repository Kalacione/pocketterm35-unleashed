# Habiller une app

Comment donner à une app les couleurs du thème et la rendre utilisable au
doigt, comme l'éditeur de texte. La méthode vaut pour d'autres thèmes que
Phosphore et ne demande ni patch ni compilation : seulement des fichiers de
configuration, déposés dans `home/` et liés dans `~` par `install.sh`.

## 1. Identifier l'app

Ouvrir l'app, puis, dans un terminal :

```sh
swaymsg -t get_tree | grep -E '"(app_id|class)"'
```

L'`app_id` (Wayland) ou la `class` (X11) sert à trois endroits : la cible des
feuilles de style, la tuile du lanceur et le bandeau de boutons. Noter aussi le
toolkit de l'app (GTK 3, GTK 4, Qt, Firefox, terminal), qui décide de l'étape 2.

## 2. Les couleurs

Les valeurs viennent toutes de [`DESIGN.md`](../DESIGN.md) : aucune couleur
inventée dans un fichier d'app.

| toolkit | fichier | remarque |
|---|---|---|
| GTK 4 / libadwaita | `~/.config/gtk-4.0/gtk.css` | redéfinir les couleurs nommées (`@define-color window_bg_color ...`) suffit pour toutes les apps |
| GTK 3 | `~/.config/gtk-3.0/gtk.css` | préfixer chaque règle par la classe de la fenêtre (`window.mousepad menubar { ... }`) pour ne toucher qu'une app |
| Firefox | `chrome/userChrome.css` dans un profil dédié | activer `toolkit.legacyUserProfileCustomizations.stylesheets` dans le `user.js` du profil ; `!important` partout, sinon les règles de Firefox passent devant |
| app en terminal | le fichier de thème de l'app | elle hérite déjà des couleurs de `foot.ini` ; son propre thème (yazi, tmux) fait le reste |

Pour trouver le nom d'un élément GTK, lancer l'app avec l'inspecteur :
`GTK_DEBUG=interactive mousepad`.

Écrire les tailles en `px`. PocketTerm35-OS lance certaines apps avec
`GDK_DPI_SCALE=0.75`, qui réduit les tailles en `pt` mais pas celles en `px`.

## 3. Les préférences

Une préférence qui n'est pas du style (police du texte, thème sombre, échelle)
passe par l'outil de l'app, pas par un fichier copié par-dessus le sien :

- GTK : `gsettings set org.xfce.mousepad.preferences.view font-name 'JetBrains Mono 14'`.
  Dans `install.sh`, ne la poser que si l'utilisateur n'a rien changé, pour ne
  pas écraser son choix.
- Firefox : `user.js` dans le profil. Firefox le relit à chaque démarrage.

Un profil dédié (Firefox, ou tout programme qui accepte `--profile`) garde le
profil habituel de l'utilisateur intact.

## 4. La tuile du lanceur

Si l'app a besoin d'options ou d'un profil, la lancer depuis une entrée de
`~/.config/pt35/apps.toml`. On n'y écrit que les clés qui changent :

```toml
[app.mon-app]
exec  = "mon-app --profile \"$HOME/.local/share/mon-app\""
match = { app_id = "mon-app" }
```

`match` relie la fenêtre à sa tuile et à son icône dans la barre.
`pt35ctl reload` relit le fichier.

## 5. Les boutons au doigt

Une app sans barre d'outils utilisable au doigt peut recevoir un bandeau de
gros boutons en bas de l'écran : [`pt35-actions`](../home/.local/bin/pt35-actions).
Il apparaît quand l'app a le focus et envoie un raccourci Ctrl. Une app de
plus, c'est une entrée dans `ACTIONS` :

```python
ACTIONS = {"mousepad": EDIT, "org.xfce.mousepad": EDIT,
           "mon-app": [("SAVE", "s"), ("FIND", "f")]}
```

Le bandeau ne prend jamais le focus : le raccourci part vers l'app.

## 6. Vérifier

- Les états se lisent sans la couleur : un mot ou une icône en plus de la teinte.
- Une cible tactile fait au moins 40 px de haut.
- Rien n'est caché derrière la barre du haut (34 px) ou le bandeau.

Pour revenir en arrière, supprimer le fichier ou l'entrée ajoutée, puis
`pt35ctl reload` ou relancer l'app. `./install.sh --uninstall` retire tout.

## Exemples dans ce dépôt

- Navigateur (Firefox) : `home/.local/share/pt35-firefox/` (`user.js`,
  `chrome/userChrome.css`) et son entrée dans `home/.config/pt35/apps.toml`.
- Éditeur (Mousepad, GTK 3) : `home/.config/gtk-3.0/gtk.css`, la police dans
  `install.sh`, le bandeau dans `pt35-actions`.
- Fichiers (yazi, terminal) : `home/.config/yazi/theme.toml`.
- Lecteurs (mpv) : `home/.config/mpv/script-opts/uosc.conf`.
- Applications GTK 4 : `home/.config/gtk-4.0/gtk.css`.
