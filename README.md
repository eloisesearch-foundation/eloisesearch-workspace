# eloisesearch-workspace

Meta-repo for the [Eloisesearch Foundation](https://github.com/eloisesearch-foundation) projects.

It holds **shared workspace configuration, documentation and scripts** — not product code.
Every project keeps its own repository and Git history; this repo only makes it easy to open
and work on them together in one VS Code window, locally or in GitHub Codespaces.

> Not a monorepo. Repositories are cloned as **siblings** of this one, driven by
> [`repos.txt`](repos.txt). See [ADR-001](docs/decisions/001-meta-repo-sibling-layout.md).

## Layout

```
~/Development/eloisesearch-foundation/      # /workspaces/ in Codespaces
├── .github/                    # org profile repo (eloisesearch-foundation/.github)
├── eloisesearch-workspace/     # ← this meta-repo
│   ├── .devcontainer/          # Codespaces / Dev Containers
│   ├── AGENTS.md               # instructions for agents (CLAUDE.md imports it)
│   ├── docs/                   # roadmap, cross-repo decisions, templates, prompts
│   ├── scripts/                # bootstrap, status, each, docs checks
│   ├── Makefile                # setup, pull, status, workspace, docs-*
│   ├── repos.txt               # repository manifest
│   └── eloisesearch.code-workspace
├── eloisesearch/               # core: Rust + Tantivy engine and HTTP API
├── eloisesearch-integration/   # reference harness, contract fixtures, demos, E2E
├── eloisesearch-ruby/          # Ruby SDK + optional Rails integration        (planned)
└── eloisesearch-javascript/    # JavaScript / TypeScript SDK                  (planned)
```

| Repository | Group | Responsibility |
| --- | --- | --- |
| `eloisesearch-workspace` | — | Workspace, Codespaces, shared docs and scripts. |
| `eloisesearch` | core | Rust engine (Tantivy), HTTP/JSON server, OpenAPI. |
| `eloisesearch-integration` | core | Reference harness and contract fixtures (run against Elasticsearch, OpenSearch and Eloisesearch); later the demo apps and end-to-end tests. |
| `eloisesearch-ruby` | sdk | Ruby HTTP client and optional Rails integration. |
| `eloisesearch-javascript` | sdk | JavaScript/TypeScript client. |

## Getting started (local)

```bash
cd ~/Development/eloisesearch-foundation
git clone git@github.com:eloisesearch-foundation/eloisesearch-workspace.git   # once it exists
cd eloisesearch-workspace

make setup                       # core repositories (scripts/bootstrap.sh)
make setup-all                   # + SDK repositories
make workspace                   # code eloisesearch.code-workspace
```

Repositories that do not exist on GitHub yet are skipped with a warning, so the script
is safe to run at any time.

## Getting started (Codespaces)

1. Open this repository in a Codespace (4-core / 8 GB machine).
2. Accept the extra repository permissions requested by `devcontainer.json`.
3. `postCreateCommand` runs `scripts/bootstrap.sh --all` and clones the siblings into `/workspaces/`.
   It exits with an error if a clone fails for a reason other than the repository not existing yet.
4. **File → Open Workspace from File… →** `eloisesearch.code-workspace`.

Codespaces does not make sibling repositories available on its own; the bootstrap script
and the `customizations.codespaces.repositories` permissions are what make it work.

## Scripts

`make help` lists the shortcuts; the underlying scripts are:

| Command | What it does |
| --- | --- |
| `scripts/bootstrap.sh [--all] [--pull] [--dry-run]` | Clone missing repositories (optionally fast-forward existing ones). |
| `scripts/status.sh [--fetch]` | Branch, ahead/behind and uncommitted changes for every repo. |
| `scripts/each.sh <cmd…>` | Run a command in every cloned repository, e.g. `scripts/each.sh git pull --ff-only`. |
| `scripts/new-design.sh <topic> [repo]` | Create `<repo>/docs/design-<topic>.md` from the template (`make docs-new-design`). |
| `scripts/check-docs.py` | Report broken relative links in Markdown across all cloned repositories (`make docs-check`). |
| `scripts/check-manifest.py` | Check that `repos.txt`, the `.code-workspace` and the dev container permissions list the same repositories (`make check`, also in CI). |

Environment overrides: `WORKSPACE_ROOT` (where siblings live, default `..`) and
`GIT_PROTOCOL` (`ssh` locally, `https` automatically in Codespaces).

## Adding a repository

1. Create it under `eloisesearch-foundation` on GitHub.
2. Add a line to [`repos.txt`](repos.txt).
3. Add it to `eloisesearch.code-workspace` and to `customizations.codespaces.repositories`
   in [`.devcontainer/devcontainer.json`](.devcontainer/devcontainer.json).
4. Run `make check` (CI runs it too) and `scripts/bootstrap.sh`.

## Documentation

Technical documentation lives in the repositories and changes with the code.
Start at [`docs/README.md`](docs/README.md); the conventions every repository
follows are in [`AGENTS.md`](AGENTS.md#documentation-conventions-all-repositories).

```bash
make docs-new-design NAME=persistence            # eloisesearch/docs/design-persistence.md
make docs-new-design NAME=client REPO=eloisesearch-ruby
make docs-check                                  # broken relative links, all repos
make changelog-check                             # CHANGELOG structure, all repos
```
