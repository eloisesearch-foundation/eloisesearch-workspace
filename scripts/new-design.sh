#!/usr/bin/env bash
# Create <repo>/docs/design-<topic>.md from docs/templates/design.md.
#
# Usage: scripts/new-design.sh <topic> [repo]
#   topic  lowercase words separated by '-', e.g. persistence or query-syntax
#   repo   sibling repository (default: eloisesearch); use eloisesearch-workspace
#          for cross-repository designs

# shellcheck source=scripts/lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

topic="${1:-}"
repo="${2:-eloisesearch}"

if [[ -z "$topic" ]]; then
  error "usage: make docs-new-design NAME=<topic> [REPO=<repo>]"
  exit 2
fi
if [[ ! "$topic" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  error "topic must be lowercase words separated by '-' (got '$topic')"
  exit 2
fi

if [[ "$repo" == "$(basename "$META_DIR")" ]]; then
  repo_dir="$META_DIR"
else
  repo_dir="$WORKSPACE_ROOT/$repo"
fi
if [[ ! -d "$repo_dir" ]]; then
  error "repository '$repo' not found at $repo_dir (run make setup-all?)"
  exit 1
fi

target="$repo_dir/docs/design-$topic.md"
if [[ -e "$target" ]]; then
  error "$target already exists"
  exit 1
fi

title="$(printf '%s' "${topic//-/ }" | awk '{ $1 = toupper(substr($1,1,1)) substr($1,2); print }')"
today="$(date +%Y-%m-%d)"

mkdir -p "$repo_dir/docs"
sed -e "s/{{TITLE}}/$title/" -e "s/{{DATE}}/$today/" "$META_DIR/docs/templates/design.md" > "$target"
info "created ${target#"$WORKSPACE_ROOT"/}"
echo "   Fill in Objective, Method, Constraints and Validation, then link it from"
echo "   $repo/AGENTS.md (documentation map) and the roadmap item it serves."
