#!/usr/bin/env bash
# Publie la version du fork et l'épingle dans la surcouche, en une commande.
# Ne touche à aucun fichier local : tout passe par l'API GitHub (gh connecté).
#   1. lit la version du Cargo.toml sur le main du fork (montée dans la PR du patch)
#   2. vérifie : section du CHANGELOG, CI verte sur ce commit
#   3. pose le tag v<version> : la CI du fork construit le .deb et crée la release
#   4. attend la release, puis commite PT35_VERSION sur le main de la surcouche
# Relançable : une étape déjà faite est sautée.
#   tools/ship.sh
set -euo pipefail

fork=Kalacione/PocketTerm35-OS
self=Kalacione/pocketterm35-unleashed
die() { echo "$*" >&2; exit 1; }

sha=$(gh api "repos/$fork/commits/main" --jq .sha)
raw() { gh api "repos/$1/contents/$2?ref=$3" -H 'Accept: application/vnd.github.raw'; }
v=$(raw "$fork" Cargo.toml "$sha" | sed -n 's/^version = "\(.*\)"/\1/p' | head -1)
[ -n "$v" ] || die "Version introuvable dans le Cargo.toml du fork."
pin=$(raw "$self" PT35_VERSION main)
[ "$pin" != "$v" ] || die "Déjà épinglé sur $v. Pour publier, monte la version dans le Cargo.toml du fork."
echo "fork main ${sha:0:7} : $v (épinglé : $pin)"

# Sur une erreur 404, gh api écrit quand même le JSON de l'erreur : on teste son code de sortie.
if ! gh api "repos/$fork/git/ref/tags/v$v" >/dev/null 2>&1; then
  raw "$fork" CHANGELOG.md "$sha" | grep -q "^## $v " || die "Pas de section « ## $v » dans le CHANGELOG du fork."
  ci=$(gh run list -R "$fork" -w ci.yml -c "$sha" -L 1 --json conclusion --jq '.[0].conclusion // "absente"')
  [ "$ci" = success ] || die "CI du fork sur ${sha:0:7} : $ci. Attends qu'elle passe (https://github.com/$fork/actions)."
  gh api "repos/$fork/git/refs" -f ref="refs/tags/v$v" -f sha="$sha" >/dev/null
  echo "tag v$v posé sur ${sha:0:7}"
fi

# La release porte le .deb : on attend son build, lancé par le tag.
deb() { gh release view "v$v" -R "$fork" --json assets --jq '.assets[].name' 2>/dev/null | grep -qx pt35-desktop_arm64.deb; }
if ! deb; then
  run=
  for _ in $(seq 30); do
    run=$(gh run list -R "$fork" -w release.yml -b "v$v" -L 1 --json databaseId --jq '.[0].databaseId // empty')
    [ -n "$run" ] && break; sleep 2
  done
  [ -n "$run" ] || die "Build de v$v introuvable : https://github.com/$fork/actions"
  gh run watch "$run" -R "$fork" --exit-status >/dev/null || die "Build de v$v en échec : https://github.com/$fork/actions/runs/$run"
  deb || die "Release v$v sans .deb : https://github.com/$fork/releases/tag/v$v"
fi
echo "release : https://github.com/$fork/releases/tag/v$v"

# Commit direct sur main : PT35_VERSION ne change que par ici, jamais dans une PR.
blob=$(gh api "repos/$self/contents/PT35_VERSION?ref=main" --jq .sha)
gh api -X PUT "repos/$self/contents/PT35_VERSION" -f branch=main -f sha="$blob" \
  -f message="PT35_VERSION $v" -f content="$(echo "$v" | base64)" >/dev/null
echo "PT35_VERSION $v commité sur $self main."
echo "Sur le Pi : cd ~/pocketterm35-unleashed && git pull && ./install.sh --pt35 && ./install.sh && sudo reboot"
echo "Retour arrière : git revert du commit « PT35_VERSION $v » sur main, puis les mêmes commandes."
