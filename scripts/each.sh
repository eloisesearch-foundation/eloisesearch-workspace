#!/usr/bin/env bash
# Run a command in every cloned repository (the meta-repo is excluded).
#
# Usage:
#   scripts/each.sh git pull --ff-only
#   scripts/each.sh git switch main

# shellcheck source=scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

if (( $# == 0 )); then
  error "usage: scripts/each.sh <command> [args...]"
  exit 2
fi

status=0
while read -r repo; do
  [[ "$repo" == "$META_DIR" ]] && continue
  info "$(basename "$repo")"
  ( cd "$repo" && "$@" ) || { warn "failed in $(basename "$repo")"; status=1; }
done < <(cloned_repos)
exit "$status"
