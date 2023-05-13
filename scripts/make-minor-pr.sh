#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

cd "$(dirname $0)/.."

if [[ $# -ne 2 ]] || [[ "$1" == "--help" ]]; then
  echo "usage: $0 old-version new-version"
  exit 1
fi

old_version="$1"
new_version="$2"

minor_base=series/$(echo $new_version | sed -E 's/([0-9]+).([0-9]+).[0-9]+/\1.\2.x/')
branch="release/$new_version-minor"

cd "$(mktemp -d)"
git clone git@github.com:typelevel/cats-effect.git
cd 'cats-effect'

git checkout -b $branch origin/$minor_base
scripts/update-versions.sh $old_version $new_version
git commit -a -m "Update versions for $new_version"
git push origin $branch

gh pr create \
  --fill \
  --base $minor_base \
  --repo typelevel/cats-effect \
  --head typelevel:$branch \
  --label ':robot:'
