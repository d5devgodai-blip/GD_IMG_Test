#!/usr/bin/env bash
#
# Build command for the gd-img-cdn Cloudflare Pages project.
#
# WHY THIS EXISTS: Pages has no include/exclude setting -- it publishes whatever
# sits in the build output directory. But it builds from a FRESH CLONE, so a file
# deleted here is simply never uploaded while GitHub keeps it. That is the only
# way to have an image dir stay in the repo and off the CDN.
#
# The exclusion list is .cdnignore, not this script: adding or dropping a path is
# then a reviewable git change, and the dashboard holds one stable command.
#
# Pages settings that go with it:
#   Build command:           bash cdn_exclude.sh
#   Build output directory:  .          <- unchanged, so the published url path
#                                          still equals the repo path (pitfall 17)
#
# Failure mode is deliberately loud: any problem aborts the build, which leaves
# the PREVIOUS deployment live rather than publishing a wrong file set.
set -euo pipefail

LIST=".cdnignore"

if [ ! -f "$LIST" ]; then
  echo "cdn_exclude: $LIST not found in $(pwd) -- refusing to publish blind" >&2
  exit 1
fi

# Pass 1: validate every entry before deleting anything, so a bad list cannot
# leave the tree half-pruned.
paths=()
bad=0
while IFS= read -r raw || [ -n "$raw" ]; do
  path="${raw%$'\r'}"                    # tolerate a CRLF checkout
  path="${path#"${path%%[![:space:]]*}"}"
  path="${path%"${path##*[![:space:]]}"}"
  case "$path" in
    ''|'#'*)    continue ;;
    /*|*..*)    echo "cdn_exclude: unsafe path rejected: $path" >&2; bad=1; continue ;;
    .|./|'*')   echo "cdn_exclude: refusing to delete the repo root" >&2; bad=1; continue ;;
  esac
  if [ ! -e "$path" ]; then
    echo "cdn_exclude: listed path does not exist: $path" >&2
    bad=1
    continue
  fi
  paths+=("$path")
done < "$LIST"

if [ "$bad" -ne 0 ]; then
  echo "cdn_exclude: .cdnignore has errors -- aborting, nothing deployed" >&2
  exit 1
fi

# Pass 2: delete.
total=0
for path in "${paths[@]:-}"; do
  [ -n "$path" ] || continue
  n=$(find "$path" -type f | wc -l)
  rm -rf "$path"
  total=$((total + n))
  printf 'cdn_exclude: withheld %s (%s files)\n' "$path" "$n"
done

# The tooling itself must not be published either.
rm -f "$LIST" "$0"

printf 'cdn_exclude: %s files withheld from the CDN, %s remain\n' \
  "$total" "$(find . -path ./.git -prune -o -type f -print | wc -l)"
