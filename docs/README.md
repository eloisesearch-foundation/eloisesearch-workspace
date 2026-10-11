# Eloisesearch documentation index

Technical documentation lives in the repositories, in Markdown, and changes in the
same commit as the code. This page points to all of it. Notion presents the
Foundation and keeps synced, read-only copies of the main documents; tasks live
only in the roadmap.

## Start here

- [Roadmap (MVP)](ROADMAP-MVP.md): phases, current status and exit criteria.
- [`AGENTS.md`](../AGENTS.md): how the repositories fit together, commands, and
  the documentation conventions every repository follows.

## eloisesearch (engine and HTTP server)

- [README](https://github.com/eloisesearch-foundation/eloisesearch#readme): what it is for, quick start
- [Architecture](https://github.com/eloisesearch-foundation/eloisesearch/blob/main/docs/ARCHITECTURE.md)
- [API contract and compatibility matrix](https://github.com/eloisesearch-foundation/eloisesearch/blob/main/docs/api-contract.md)
- [Design decisions](https://github.com/eloisesearch-foundation/eloisesearch/blob/main/docs/design-decisions.md)
- [Quality, relevance and benchmark plan](https://github.com/eloisesearch-foundation/eloisesearch/blob/main/docs/quality-plan.md)
- [Configuration](https://github.com/eloisesearch-foundation/eloisesearch/blob/main/docs/configuration.md)
- [Changelog](https://github.com/eloisesearch-foundation/eloisesearch/blob/main/CHANGELOG.md)

`eloisesearch-integration`, `eloisesearch-ruby` and `eloisesearch-javascript`
are added here when they are created.

## Cross-repository decisions

| # | Title | Status |
| --- | --- | --- |
| [ADR-001](decisions/001-meta-repo-sibling-layout.md) | Meta-repo with sibling repositories | Accepted |

Decisions that belong to a single repository live in that repository's
`docs/design-decisions.md`.

## Writing docs

- [Design doc template](templates/design.md): Objective, Method, Constraints,
  Validation. Create one with `make docs-new-design NAME=<topic> [REPO=<repo>]`.
- Prompts for agents, in the same four parts:
  - [Review a pull request](prompts/review-pr.md)
  - [Implement one step of a design](prompts/implement-design.md)
  - [Clean-code audit after a long session](prompts/clean-code-audit.md)
- Checks: `make docs-check` (broken relative links in every cloned repository)
  and `make changelog-check`.
