# AGENTS.md — eloisesearch-workspace guide

Canonical instructions for AI coding agents (and humans) working from the
Eloisesearch meta-repo. `CLAUDE.md` only imports this file. Each product
repository has its own `AGENTS.md` with its own rules; when you work inside one,
read that file too.

## What this repository is for

Eloisesearch gives application developers full-text search without operating a
search cluster: one binary, one data directory, and an API that is a documented
subset of the Elasticsearch 9.5.4 REST API and Query DSL (verified against
OpenSearch), so existing applications and tools can migrate by changing the
server address. SDKs for Rails and JavaScript are planned. The work is split across several repositories.
This meta-repo is where they are opened together, where cross-repository
planning lives, and where the shared documentation conventions and tooling are
kept. It contains no product code.

## Repositories

They are cloned as **siblings** of this directory (`../<name>`), locally and in
Codespaces (`/workspaces/<name>`), from the manifest in [`repos.txt`](repos.txt).

| Repository | Purpose | Status |
| --- | --- | --- |
| `eloisesearch` | Rust engine and HTTP/JSON server | Active |
| `eloisesearch-integration` | Demo apps (Rails + Nuxt movie search), shared fixtures, end-to-end and contract tests | Planned |
| `eloisesearch-ruby` | Ruby SDK and optional Rails integration | Planned |
| `eloisesearch-javascript` | JavaScript/TypeScript SDK | Planned |

## Commands

```bash
make setup             # clone missing core repositories as siblings
make setup-all         # also SDK / integration repositories
make status            # branch, ahead/behind, local changes for every repo
make pull              # fast-forward every cloned repo
make workspace         # open eloisesearch.code-workspace in VS Code

make docs-new-design NAME=<topic> [REPO=eloisesearch]   # new design doc from the template
make docs-check        # broken relative links in Markdown, all repos
make changelog-check   # CHANGELOG structure, every repo that has the check
make help              # everything
```

`scripts/each.sh <cmd>` runs any command in every cloned repository.

## Documentation conventions (all repositories)

**Source of truth.** Technical documentation lives in the repositories, in
Markdown, and changes in the same commit as the code it describes. Notion presents the Foundation and keeps
synced, read-only copies of the main documents (marked as such); it holds no task
lists, and changes are made here first, then copied.

**Tasks.** Open work is tracked only in [`docs/ROADMAP-MVP.md`](docs/ROADMAP-MVP.md),
as checkboxes under each phase. Other docs explain and specify; they do not hold
task lists. Tick an item in the commit that completes it.

**Where things go.**

| Content | Location |
| --- | --- |
| What the project is for, quick start, reference guides | `<repo>/README.md`, written use case first |
| Instructions for agents: layout, commands, invariants, docs map, rules | `<repo>/AGENTS.md` (+ `CLAUDE.md` = `@AGENTS.md`) |
| The gate a change passes | `<repo>/CONTRIBUTING.md` |
| User-visible changes | `<repo>/CHANGELOG.md` (Keep a Changelog) |
| Code map | `<repo>/docs/ARCHITECTURE.md` |
| Why it is built this way | `<repo>/docs/design-decisions.md` |
| Design of one feature, written before the code | `<repo>/docs/design-<topic>.md` |
| Plans and decisions that span repositories | this repo: `docs/ROADMAP-MVP.md`, `docs/decisions/` |
| Reusable prompts for agents | this repo: `docs/prompts/` |

**How to write.**

- Lead with the use case and the problem solved, then the behavior, then the
  implementation. "Phrase search with exclusions that never broadens results"
  before "parser built on X".
- Design docs and prompts use four parts: **Objective, Method, Constraints,
  Validation** ([template](docs/templates/design.md)).
- State what is verified and what is planned. A claim about current behavior
  points at the code or test that proves it.
- Third-party product names (Elasticsearch, OpenSearch) only where compatibility
  needs them: compatibility matrices, migration guides, compatibility tests and
  comments explaining a compatibility rule. Descriptive wording, trademark notice
  in user-facing docs, no logos, no marketing comparisons, no competitor research
  in the repositories. Never send identifiers that present Eloisesearch as
  another product.
- No emojis in docs, file names or editor configuration.

## Rules for agents

- Read the target repository's `AGENTS.md` before changing it, and run its
  gate (`make check` in `eloisesearch`) before saying a change is done.
- Keep changes inside one repository per commit. A change that spans
  repositories is a set of commits, one per repository, referenced from each
  other.
- Do not create GitHub repositories, push, tag or bump versions without the
  maintainer's explicit approval. Agents review, audit and draft; the maintainer
  decides.
- Adding a repository touches three places: `repos.txt`,
  `eloisesearch.code-workspace` and `customizations.codespaces.repositories` in
  `.devcontainer/devcontainer.json`.

## Documentation map

- [`README.md`](README.md): layout, getting started locally and in Codespaces.
- [`docs/README.md`](docs/README.md): index of every repository's docs.
- [`docs/ROADMAP-MVP.md`](docs/ROADMAP-MVP.md): MVP phases and gates, across
  repositories.
- [`docs/decisions/`](docs/decisions/): cross-repository decisions.
- [`docs/templates/design.md`](docs/templates/design.md): design doc template.
- [`docs/prompts/`](docs/prompts/): prompts for reviews, audits and new work.
