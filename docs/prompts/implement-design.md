# Prompt: implement one step of a design doc

Use when a `docs/design-<topic>.md` is Accepted and work starts on its plan.

---

## Objective

Implement step `<n>` of `<repo>/docs/design-<topic>.md`, and only that step, so it
can be reviewed and merged on its own.

## Method

1. Read `<repo>/AGENTS.md`, the design doc and the code it cites under
   "Current state". If the code no longer matches the doc, stop and report the
   difference before writing anything.
2. Write the tests from the step's validation first and watch them fail.
3. Implement the smallest change that makes them pass.
4. Update `docs/` and `CHANGELOG.md` (`[Unreleased]`) in the same change when the
   step alters user-visible behavior, the API or configuration.
5. Run the repository gate (`make check`).

## Constraints

- Do not start the next step, add public surface without a caller, or refactor
  unrelated code.
- Do not weaken an existing test to make a new one pass.
- Respect the invariants in `AGENTS.md`; if the step requires breaking one,
  stop and ask.
- Do not commit, push or bump versions unless asked.

## Validation

Report: files changed, tests added (and that they failed before), gate output,
docs updated, and anything from the design that turned out wrong or unclear.
