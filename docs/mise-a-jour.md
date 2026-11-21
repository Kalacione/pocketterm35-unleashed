# Mettre à jour

Les commandes se tapent sur le PocketTerm, une par ligne. Chaque bloc se colle
tel quel.

## Mettre à jour

```sh
cd ~/pocketterm35-unleashed
git pull
./install.sh --pt35
./install.sh
sudo reboot
```

`./install.sh --pt35` installe la version de PocketTerm35-OS écrite dans
[`PT35_VERSION`](../PT35_VERSION), et ne fait rien d'autre. `./install.sh`
relie les réglages. Le redémarrage n'est utile que si `PT35_VERSION` a changé.

## Vérifier la version installée

```sh
cat ~/pocketterm35-unleashed/PT35_VERSION
dpkg -s pt35-desktop | grep Version
```

Les deux doivent donner la même version. Sinon, relancer `./install.sh --pt35`.

## Revenir à une version précédente

Lister les versions passées, la plus récente en haut :

```sh
cd ~/pocketterm35-unleashed
git log --oneline -- PT35_VERSION
```

Installer celle du commit choisi, à la place de `<commit>` :

```sh
git checkout <commit>
./install.sh --pt35
./install.sh
sudo reboot
```

Pour revenir à la dernière version ensuite :

```sh
git checkout main
git pull
./install.sh --pt35
./install.sh
sudo reboot
```

## Réveiller une machine depuis le widget Hosts (optionnel)

Un toucher sur une machine DOWN du widget Hosts peut la réveiller (Wake-on-LAN)
au lieu d'ouvrir SSH. Rien n'est réglé par défaut : il faut un script à vous,
`~/.config/pt35/hooks/hook_wake`. Il reçoit le nom de la machine (celui de
`~/.ssh/config`) en `$1`, et doit sortir avec :

- `0` quand la machine répond ;
- `1` si elle ne répond pas ;
- `2` s'il ne sait pas réveiller cette machine.

Pendant le réveil, la ligne affiche `WAKE` et le temps écoulé, puis `UP`, ou
`FAIL` avec la raison. Sans script, rien ne change.

Exemple pour des machines sur le même réseau que le PocketTerm. Remplacer le
nom, l'adresse MAC et l'adresse IP par les vôtres :

```sh
sudo apt install -y wakeonlan netcat-openbsd
mkdir -p ~/.config/pt35/hooks
cat > ~/.config/pt35/hooks/hook_wake <<'EOF'
#!/bin/sh
case "$1" in
  nas) mac=00:11:22:33:44:55 addr=192.0.2.20 ;;
  *) exit 2 ;;
esac
wakeonlan "$mac" >/dev/null
for i in $(seq 36); do
  nc -z -w 2 "$addr" 22 && exit 0
  sleep 5
done
exit 1
EOF
chmod 755 ~/.config/pt35/hooks/hook_wake
```

Le paquet Wake-on-LAN ne traverse pas un VPN. Hors de chez vous, le script
peut demander à une machine toujours allumée du réseau d'envoyer le paquet,
par exemple avec `ssh`.

Tester sans l'écran, sur une machine épinglée dans Hosts, puis lire le résultat :

```sh
pt35ctl wake nas
pt35ctl hosts
grep wake /run/user/1000/pt35/sway.log
```

Pour couper le réveil :

```sh
chmod -x ~/.config/pt35/hooks/hook_wake
```
