#!/usr/bin/env bash
# Show branch, sync state and uncommitted changes for the meta-repo and every cloned repository.
#
# Usage: scripts/status.sh [--fetch]

# shellcheck source=scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

fetch=false
[[ "${1:-}" == "--fetch" ]] && fetch=true

printf '%s\n' "${C_BOLD}$(printf '%-26s %-22s %-14s %s' REPOSITORY BRANCH UPSTREAM CHANGES)${C_RESET}"

while read -r repo; do
  name="$(basename "$repo")"
  if ! git -C "$repo" rev-parse --git-dir >/dev/null 2>&1; then
    printf '%-26s %s\n' "$name" "${C_DIM}not a git repository yet${C_RESET}"
    continue
  fi
  $fetch && git -C "$repo" fetch --quiet 2>/dev/null || true

  branch="$(git -C "$repo" symbolic-ref --short -q HEAD || echo '(detached)')"
  if git -C "$repo" rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
    read -r behind ahead < <(git -C "$repo" rev-list --left-right --count '@{u}...HEAD')
    upstream="↑$ahead ↓$behind"
  else
    upstream="no upstream"
  fi
  changes="$(git -C "$repo" status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
  [[ "$changes" == 0 ]] && changes="${C_GREEN}clean${C_RESET}" || changes="${C_YELLOW}$changes changed${C_RESET}"

  printf '%-26s %-22s %-14s %s\n' "$name" "$branch" "$upstream" "$changes"
done < <(cloned_repos)
