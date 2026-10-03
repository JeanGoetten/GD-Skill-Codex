# Contributing

GD Skill Codex treats schemas, executors, skills, fixtures, and generated web
metadata as one versioned system.

## Before opening a pull request

1. Install dependencies with `npm ci`.
2. Run `npm run test:all` on Windows PowerShell.
3. Confirm `git diff --exit-code -- web/data.js` after validation.
4. Add a positive and a negative fixture for behavior changes.
5. State whether each new claim is formal, derived, heuristic, simulated, or empirical.

Changes to a `SKILL.md` that introduce executable requirements must update the
corresponding schema, executor, fixture, and entry in
`docs/spec-implementation-matrix.md`, or explicitly mark the requirement as
not implemented.

Do not present playtest, cognition, fairness, learning, or fun claims as proven
by structural calculations alone.
