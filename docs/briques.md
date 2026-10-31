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
