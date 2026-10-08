# Changelog

## Unreleased

- Add an agent runtime: `bin/gd-codex.js` CLI, `mcp/server.js` MCP server (6 tools), and
  shared `architecture/lib/runtime.js`. See `AGENTS.md`.
- Add a generated "How to Execute" section to all 15 skills, kept in sync by
  `architecture/sync_skill_runtime.js --check`.
- Fix executor/spec divergences: intentional synchronization in nested loops, drought
  threshold (900 s per spec), open-loop retention pressure, punish windows and
  undeclared-input status in risk-reward. Thresholds are now declarable and labelled as heuristics.
- Fix PowerShell pitfalls that silenced checks: integer `[math]::Min/Max` truncation,
  `@($obj.missing).Count`, and `[double]$null` creating false completions.
- Type the `SkillOutput` `metrics`, `evidence` and `handoffs` items.
- Correct the `epistemic → cognitive-disruption` handoff `return_to`; the validator now
  requires `return_to` to be one of the two skills in the pair.
- Align `orchestrator.md` role taxonomy with the registry schema.
- CI runs on Windows and Linux (Linux installs PowerShell 7).
- Add `npm run test:all` as a single gate (`architecture/run_all.js`).
- Enforce the public `SkillOutput` contract through a shared executor wrapper.
- Validate registry, handoffs, adapters, evidence, calibration, and playtest artifacts.
- Add CI validation before GitHub Pages deployment.
- Harden the local execution server.
- Repair generated catalog concepts and world-model metadata.
- Extend FSM analysis with invariant, probability, and livelock checks.
- Add governance, research-validity, implementation-matrix, and benchmark docs.

### Known limitations

- Routing is keyword- and profile-based. A Portuguese request without the expected
  vocabulary can match no skill (`route` exits 1 with "Nenhuma skill foi ativada").
  Improving this needs a multilingual signal set, not a looser threshold.
- Executors are PowerShell. Node, Linux and macOS support depend on `pwsh` 7+ and are
  verified only by CI.
- Generated SKILL.md sections have not been verified on a clean clone outside CI.


## 1.0.0-reference — 2026-09

- Initial 15-skill catalog, schemas, executors, routing, adapters, evidence
  store, simulation runner, playtest contracts, and public catalog.
