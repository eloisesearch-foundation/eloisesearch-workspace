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
# Exit status: 0 when everything requested succeeded (repositories that do not
# exist on the remote yet are reported, not counted as failures); 1 when a pull,
# clone or remote check failed (authentication, network, diverged branch, ...).
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
    -h|--help)       awk 'NR > 1 && /^#/ { sub(/^# ?/, ""); print; next } NR > 1 { exit }' "$0"; exit 0 ;;
    *)               error "unknown option: $arg"; exit 2 ;;
  esac
done

info "workspace root: ${C_BOLD}$WORKSPACE_ROOT${C_RESET} (protocol: $GIT_PROTOCOL)"
$dry_run && info "dry run: nothing will be changed"

cloned=0; present=0; skipped=0; missing=0; failed=0

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
        if out="$(GIT_TERMINAL_PROMPT=0 git -C "$target" pull --ff-only --quiet 2>&1)"; then
          echo "${C_GREEN}updated${C_RESET}"
        else
          echo "${C_RED}pull failed:${C_RESET} $(first_line "$out")"
          failed=$((failed + 1))
        fi
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

  if ! out="$(GIT_TERMINAL_PROMPT=0 git ls-remote "$remote" 2>&1 >/dev/null)"; then
    if grep -qiE "repository not found|does not exist|not found" <<<"$out"; then
      printf '  %-26s %s\n' "$dir" "${C_YELLOW}not found on remote (not created yet?)${C_RESET}"
      missing=$((missing + 1))
    else
      # Authentication, network or permission problem: the repository may exist.
      printf '  %-26s %s\n' "$dir" "${C_RED}cannot reach remote:${C_RESET} $(first_line "$out")"
      failed=$((failed + 1))
    fi
    continue
  fi

  printf '  %-26s %s\n' "$dir" "cloning $remote"
  if out="$(GIT_TERMINAL_PROMPT=0 git clone --quiet "$remote" "$target" 2>&1)"; then
    cloned=$((cloned + 1))
  else
    printf '  %-26s %s\n' "" "${C_RED}clone failed:${C_RESET} $(first_line "$out")"
    failed=$((failed + 1))
  fi
done < <(manifest_entries)

info "done: $cloned cloned, $present already present, $missing not on remote, $skipped skipped, $failed failed"
if (( missing > 0 )); then
  warn "create the missing repositories on GitHub and run this script again"
fi
if (( failed > 0 )); then
  error "$failed operation(s) failed; see the messages above"
  exit 1
fi
