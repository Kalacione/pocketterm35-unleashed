# Briques

Une ligne par brique : ce qu'on prend, pourquoi, ou pourquoi on l'écarte.

| brique | statut | pourquoi |
|---|---|---|
| [PocketTerm35-OS](https://github.com/therezor/PocketTerm35-OS) | socle | bureau complet, config TOML fusionnée, hooks, MIT |
| GNU stow | retenu | lier `home/` dans `~` sans script maison |
| [DESIGN.md](https://github.com/google-labs-code/design.md) | retenu | format de charte lisible par les agents (tokens YAML + texte), plutôt qu'un format maison |
| [DTCG](https://www.designtokens.org/) (JSON W3C) | écarté | standard stable mais tokens seuls, sans le texte de charte ; DESIGN.md sait l'exporter |
| [Style Dictionary](https://styledictionary.com/) | écarté | chaîne de build Node pour générer nos 3 fichiers : YAGNI |
