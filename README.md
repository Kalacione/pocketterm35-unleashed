# PocketTerm 3.5 Unleashed

Nos réglages et petits scripts par-dessus
[PocketTerm35-OS](https://github.com/therezor/PocketTerm35-OS), pour le
WaveShare PocketTerm 3.5.

## Prérequis

PocketTerm35-OS installé, firmware clavier pt35 flashé (`sudo pt35-kbd flash`).

## Installer

```sh
git clone https://github.com/Kalacione/pocketterm35-unleashed.git ~/pocketterm35-unleashed
cd ~/pocketterm35-unleashed
./install.sh
```

Un fichier déjà présent à la place d'un des nôtres est renommé en `.bak`.
Recharger : `Super`+`Shift`+`c` (sway) ou redémarrer la session.

## Mettre à jour

```sh
cd ~/pocketterm35-unleashed && git pull && ./install.sh
```

## Retirer

```sh
./install.sh --uninstall
```

Les liens sont retirés et les `.bak` remis en place.

## Contenu

Voir le tableau « Architecture » de [CLAUDE.md](CLAUDE.md) et
[docs/briques.md](docs/briques.md).

## Licence

MIT, comme upstream.
