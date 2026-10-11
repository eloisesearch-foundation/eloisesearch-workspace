# ADR-001: Meta-repo with Sibling Repositories

- **Status:** Accepted
- **Date:** 2026-10-11

## Context

Eloisesearch is split into several repositories (`eloisesearch`, `eloisesearch-ruby`,
`eloisesearch-javascript`, `eloisesearch-integration`). We want to open and search across all of them
in one VS Code window and reproduce the same setup in GitHub Codespaces, **without** merging
them into a monorepo (different toolchains, independent histories and release cycles).

Codespaces opens a single repository at `/workspaces/<repo>` and does not provide other
repositories automatically.

## Decision

- `eloisesearch-workspace` is a meta-repo containing only workspace config, docs and scripts.
- Project repositories are cloned as **siblings** of the meta-repo
  (`~/Development/eloisesearch-foundation/*` locally, `/workspaces/*` in Codespaces).
- [`repos.txt`](../../repos.txt) is the single manifest; `scripts/bootstrap.sh` clones what is
  missing and skips repositories that do not exist yet.
- `eloisesearch.code-workspace` references siblings with `../<repo>` paths, which resolve the
  same way locally and in Codespaces.
- `.devcontainer/devcontainer.json` grants the Codespace token access to the sibling
  repositories and runs the bootstrap on creation.

## Alternatives considered

| Option | Why not (for now) |
| --- | --- |
| Monorepo | Mixes Rust, Ruby and JS toolchains and histories; contradicts the repository plan. |
| Git submodules | Pin exact commits (useful later), but add command overhead, require remotes to exist before `git submodule add`, and nest repos inside the meta-repo. |
| Loose multi-repo | No shared onboarding, no reproducible Codespaces setup. |

## Consequences

- No cross-repo version pinning: each repository tracks its own default branch.
  If reproducible cross-repo snapshots become necessary (e.g. pinning an engine commit for a
  benchmark), add a lock step (`repos.lock` with SHAs) or migrate to submodules — the
  manifest makes either change small.
- Adding a repository means updating three places (manifest, code-workspace, devcontainer
  permissions); the README documents the checklist.
