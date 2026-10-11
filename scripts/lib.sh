#!/usr/bin/env bash
# Shared helpers for the Eloisesearch meta-repo scripts.
# shellcheck disable=SC2034

set -euo pipefail

META_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Where sibling repositories live. Defaults to the meta-repo's parent directory
# (~/Development/eloisesearch-foundation locally, /workspaces in Codespaces).
WORKSPACE_ROOT="${WORKSPACE_ROOT:-$(cd "$META_DIR/.." && pwd)}"
MANIFEST="${MANIFEST:-$META_DIR/repos.txt}"

# Use HTTPS instead of SSH (set automatically in Codespaces, where the
# GITHUB_TOKEN credential helper only works over HTTPS).
if [[ -n "${CODESPACES:-}" ]]; then
  GIT_PROTOCOL="${GIT_PROTOCOL:-https}"
fi
GIT_PROTOCOL="${GIT_PROTOCOL:-ssh}"

if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'; C_DIM=$'\033[2m'; C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_RED=$'\033[31m'; C_BOLD=$'\033[1m'
else
  C_RESET=""; C_DIM=""; C_GREEN=""; C_YELLOW=""; C_RED=""; C_BOLD=""
fi

info()  { printf '%s\n' "${C_GREEN}==>${C_RESET} $*"; }
warn()  { printf '%s\n' "${C_YELLOW}warn:${C_RESET} $*" >&2; }
error() { printf '%s\n' "${C_RED}error:${C_RESET} $*" >&2; }

# The most useful line of a git error output, for compact messages: the first
# "fatal:"/"error:" line if there is one, otherwise the first non-empty line.
first_line() {
  local line
  line="$(printf '%s\n' "$1" | grep -m1 -E '^(fatal|error|ERROR|remote: ERROR)' || true)"
  [[ -n "$line" ]] || line="$(printf '%s\n' "$1" | sed -n '/[^[:space:]]/{p;q;}')"
  printf '%s' "$line"
}

# Convert git@github.com:owner/repo.git -> https://github.com/owner/repo.git when needed.
resolve_url() {
  local url="$1"
  if [[ "$GIT_PROTOCOL" == "https" && "$url" == git@github.com:* ]]; then
    url="https://github.com/${url#git@github.com:}"
  fi
  printf '%s' "$url"
}

# Print manifest entries as "dir url group", skipping comments and blank lines.
manifest_entries() {
  [[ -f "$MANIFEST" ]] || { error "manifest not found: $MANIFEST"; return 1; }
  awk '!/^[[:space:]]*(#|$)/ { print $1, $2, $3 }' "$MANIFEST"
}

# Directories of repositories currently cloned in WORKSPACE_ROOT (plus the meta-repo).
cloned_repos() {
  printf '%s\n' "$META_DIR"
  local dir url group
  while read -r dir url group; do
    [[ -d "$WORKSPACE_ROOT/$dir/.git" ]] && printf '%s\n' "$WORKSPACE_ROOT/$dir"
  done < <(manifest_entries)
  return 0
}
