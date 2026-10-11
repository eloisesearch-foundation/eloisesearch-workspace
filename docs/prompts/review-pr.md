# Prompt: review a pull request

Use with any coding agent. Replace `<repo>` and `<PR or branch>`.

---

## Objective

Review `<PR or branch>` in `<repo>` and tell the maintainer whether it is safe to
merge, what must change before it is, and what can wait. You are the reviewer,
not the decision maker: the maintainer merges.

## Method

1. Read `<repo>/AGENTS.md` and the design doc the PR references, if any.
2. Ignore the PR description until you have read the diff. Describe what the
   code actually does, then compare it with what the description claims.
3. For each changed behavior, find the test that would fail without it. Run the
   repository gate (`make check`) and report the result verbatim.
4. Look for regressions in callers of the changed code, not only in the diff.
5. Check that docs (`docs/`, README) and `CHANGELOG.md` changed when behavior,
   API, configuration or deployment changed.

## Constraints

- Do not edit code, push, approve or merge.
- Do not accept "tests pass" as proof of a guarantee that has no test.
- Do not suggest unrelated refactors; list them separately as optional.
- Flag third-party product names used outside compatibility contexts, and any
  change to a compatible route or query feature without a matching update to
  `api-contract.md` and a test against the reference.

## Validation

Report in this shape:

- **Verdict:** merge / merge after fixes / do not merge.
- **Blocking:** numbered, each with file:line, the problem and the fix.
- **Non-blocking:** improvements that can be follow-ups.
- **Evidence:** commands run and their output summary; what you could not run.
