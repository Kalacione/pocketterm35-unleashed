#!/usr/bin/env bash
# Publie la version du fork : tag v<version> sur son main, la CI du fork
# (release.yml, sur push de tag v*) construit le .deb et crée la release.
# La version est celle du Cargo.toml du fork, montée dans la PR du patch
# avec sa section du CHANGELOG. À lancer sur un PC avec gh connecté.
#   tools/release-fork.sh
set -euo pipefail
cd "$(dirname "$0")/.."

repo=Kalacione/PocketTerm35-OS
sha=$(gh api "repos/$repo/commits/main" --jq .sha)
raw() { gh api "repos/$repo/contents/$1?ref=$sha" -H 'Accept: application/vnd.github.raw'; }

v=$(raw Cargo.toml | sed -n 's/^version = "\(.*\)"/\1/p' | head -1)
[ -n "$v" ] || { echo "Version introuvable dans Cargo.toml." >&2; exit 1; }
raw CHANGELOG.md | grep -q "^## $v " || { echo "Pas de section « ## $v » dans le CHANGELOG du fork." >&2; exit 1; }
if gh api "repos/$repo/git/ref/tags/v$v" >/dev/null 2>&1; then
  echo "v$v existe déjà sur $repo : monte la version dans Cargo.toml et le CHANGELOG." >&2; exit 1
fi

gh api "repos/$repo/git/refs" -f ref="refs/tags/v$v" -f sha="$sha" >/dev/null
echo "$v" > PT35_VERSION
echo "Tag v$v posé sur ${sha:0:7}. Build : https://github.com/$repo/actions"
echo "Release : https://github.com/$repo/releases/tag/v$v"
echo "Puis sur le Pi : ./install.sh --pt35, et commit PT35_VERSION."
