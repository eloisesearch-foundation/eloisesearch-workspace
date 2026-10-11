# Prompt: clean-code audit after a long session

Run at the end of a long working session or before a release.

---

## Objective

Find what a long session leaves behind in `<repo>` so the maintainer can clean it
up before it hardens: dead code, duplication, missing tests and stale docs.

## Method

Audit the changes since `<base ref>` (default: the last tag or `origin/main`):

1. **Dead code:** unused functions, types, features, dependencies, config keys,
   commented-out blocks, stubs without a caller.
2. **Duplication:** the same logic or constant in more than one place; propose
   the single owner.
3. **Magic values:** literals that should be named constants or configuration.
4. **Missing tests:** guarantees stated in docs or code comments without a test
   that fails when they break.
5. **Stale docs:** README, `docs/`, `AGENTS.md`, `CHANGELOG.md` and code
   comments that no longer match the code.
6. **Invariants:** anything that violates the list in `<repo>/AGENTS.md`.

## Constraints

- Report only; do not change files unless the maintainer asks.
- Every finding cites file:line and is verifiable by reading the code.
- No style nitpicks that the formatter or linter already enforce.

## Validation

A table sorted by impact: finding, location, why it matters, proposed fix,
effort (S/M/L). End with the three changes you would make first.
