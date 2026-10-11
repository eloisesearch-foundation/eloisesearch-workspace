#!/usr/bin/env bash
# Clone the Eloisesearch repositories listed in repos.txt as siblings of this meta-repo.
#
# Usage:
#   scripts/bootstrap.sh [--sdk | --all] [--dry-run] [--pull]
#
#   (default)       clone "core" repositories
#   --sdk, --all    also clone "sdk" repositories
#   --pull          fast-forward repositories that are already cloned
#   --dry-run       print what would happen, touch nothing (no network)
#
# Environment:
#   WORKSPACE_ROOT  where repositories are cloned (default: parent of the meta-repo)
#   GIT_PROTOCOL    ssh | https (default: ssh locally, https in Codespaces)

# shellcheck source=scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

with_sdk=false
dry_run=false
pull=false

for arg in "$@"; do
  case "$arg" in
    --sdk|--all)     with_sdk=true ;;
    --dry-run)       dry_run=true ;;
    --pull)          pull=true ;;
    -h|--help)       sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)               error "unknown option: $arg"; exit 2 ;;
  esac
done

info "workspace root: ${C_BOLD}$WORKSPACE_ROOT${C_RESET} (protocol: $GIT_PROTOCOL)"
$dry_run && info "dry run: nothing will be changed"

cloned=0; present=0; skipped=0; missing=0

while read -r dir url group; do
  case "$group" in
    core) ;;
    sdk)       $with_sdk || { skipped=$((skipped + 1)); continue; } ;;
    *)         warn "$dir: unknown group '$group', skipping"; skipped=$((skipped + 1)); continue ;;
  esac

  target="$WORKSPACE_ROOT/$dir"
  remote="$(resolve_url "$url")"

  if [[ -d "$target/.git" ]]; then
    present=$((present + 1))
    if $pull; then
      if $dry_run; then
        printf '  %-26s %s\n' "$dir" "${C_DIM}would pull --ff-only${C_RESET}"
      else
        printf '  %-26s ' "$dir"
        git -C "$target" pull --ff-only --quiet 2>/dev/null && echo "${C_GREEN}updated${C_RESET}" || echo "${C_YELLOW}pull failed (local changes or diverged)${C_RESET}"
      fi
    else
      printf '  %-26s %s\n' "$dir" "${C_DIM}already cloned${C_RESET}"
    fi
    continue
  fi

  if [[ -e "$target" ]]; then
    warn "$dir: $target exists but is not a git repository, skipping"
    skipped=$((skipped + 1))
    continue
  fi

  if $dry_run; then
    printf '  %-26s %s\n' "$dir" "would clone $remote ($group)"
    continue
  fi

  if ! GIT_TERMINAL_PROMPT=0 git ls-remote "$remote" >/dev/null 2>&1; then
    printf '  %-26s %s\n' "$dir" "${C_YELLOW}not found on remote (not created yet?)${C_RESET}"
    missing=$((missing + 1))
    continue
  fi

  printf '  %-26s %s\n' "$dir" "cloning $remote"
  git clone --quiet "$remote" "$target"
  cloned=$((cloned + 1))
done < <(manifest_entries)

info "done: $cloned cloned, $present already present, $missing not on remote, $skipped skipped"
if (( missing > 0 )); then
  warn "create the missing repositories on GitHub and run this script again"
fi
