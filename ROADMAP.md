# Roadmap

This is the live roadmap. Historical implementation notes remain in
`docs/action-plan.md`.

## Agent runtime and framework hardening

- [x] Agent entry point (`AGENTS.md`), CLI (`bin/gd-codex.js`), MCP server (`mcp/server.js`).
- [x] Generated "How to Execute" section in all 15 skills, with drift check.
- [x] Executor/spec divergences fixed for nested loops and risk-reward, with regression tests.
- [x] Threshold provenance in `architecture/threshold-provenance.json`, checked by
  `architecture/tests/threshold_sync.test.js`.
- [x] World-model extraction protocol (`architecture/world-model-extraction.md`), with its skeleton validated.
- [x] Typed `SkillOutput` items for `claims`, `metrics`, `evidence`, `handoffs`, `anomalies`,
  `assumptions`, `limitations`.
- [x] Role taxonomy in `orchestrator.md` aligned with the registry schema.
- [ ] Node ports of the executors. The executors are still PowerShell; CI on Linux is configured but unverified.
- [ ] Routing for Portuguese requests that use none of the expected terms.
- [ ] Per-skill `results` contracts. `results` stays an open object by decision.
- [ ] External evaluation: 0 of 45 cases recorded (see `docs/evaluation-status.md`).
- [ ] Player-model decision (see `docs/decisions/0001-player-model.md`, proposed).
- [ ] Skill `references/` split. Not done: SKILL.md files are 207–237 lines, under the recommended limit.

## Current release gate

- [x] All public executor results pass `SkillOutput` validation.
- [x] Registry, handoffs, adapters, fixtures, evidence examples, and playtest
  contracts are validated by AJV or their semantic validators.
- [x] Pull requests and Pages deployment run the complete validation suite.
- [x] The local server uses allowlists, bounded requests, and loopback binding.
- [x] Generated catalog metadata contains roles and searchable concepts.
- [x] A routing benchmark is executable and versioned.
- [ ] Independent designers have evaluated recommendation usefulness.
- [ ] Confidence labels are calibrated against observational or playtest data.
- [ ] At least three external game projects reproduce the end-to-end workflow.

## Next research milestones

1. Collect the first external benchmark corpus under `benchmarks/cases/`.
2. Measure routing accuracy, inter-rater agreement, and recommendation utility.
3. Replace ordinal confidence where possible with calibrated probabilities and
   documented uncertainty intervals.
4. Publish a tagged release after external replication, without adding new
   skills until the current 15 have evidence-backed calibration.
