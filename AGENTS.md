# AGENTS.md

Instructions for AI agents working with or inside this repository.

## What this is

GD-Skill-Codex is a set of 15 game-design analysis skills. Each skill has a
protocol (`GD-Skill-Codex/<id>/SKILL.md`) and, for most of them, a deterministic
reference executor (`architecture/executors/<id>.ps1`) that checks structure.
Executors check consistency; they do not prove playtest outcomes.

## Before you answer a game-design question

Read `architecture/world-model-extraction.md` before building a world model from a
description. It covers how to separate stated from inferred facts and when to answer
`INSUFFICIENT_EVIDENCE`.

1. Route the request. Use `route_request` (MCP) or `node bin/gd-codex.js route "<request>"`.
   Treat the result as a baseline. Override it when the request clearly needs a
   different skill, and say so.
2. Read the chosen skill's `SKILL.md`, starting with its "How to Execute" section.
3. Check whether the world model declares the inputs the skill needs
   (`hidden_state.<key>`, see `get_skill`). If it does not, say which inputs are
   missing. Do not invent values.

## Rules that are not optional

- **Epistemic status.** Every claim is one of: `formal` (holds given the model and
  its assumptions), `derived` (computed from declared inputs), `heuristic` (a design
  judgment or threshold), or `empirical` (needs playtest data). Label heuristics as
  heuristics. Thresholds in executors are heuristics unless the world model declares them.
- **INSUFFICIENT_EVIDENCE is a valid answer.** Prefer it to a confident guess.
- **Structural check is not evidence of fun.** A passing executor means the
  declared model is internally consistent, nothing more.
- **Do not optimize for voluntary stopping.** Retention or pressure values
  describe a design; never use them to argue for keeping a player from leaving.
- **Do not use franchise references as validation.** Recognition references are
  anchors for intuition, not proof.

## Running things

| Task | Command |
|---|---|
| List skills | `node bin/gd-codex.js list` |
| Get a skill's contract | `node bin/gd-codex.js skill <id>` |
| Validate a world model | `node bin/gd-codex.js validate --world <file> --skill <id>` |
| Run one executor | `node bin/gd-codex.js execute <id> --world <file>` |
| Route + run chain | `node bin/gd-codex.js pipeline "<request>" --world <file>` |
| MCP server (stdio) | `node mcp/server.js` |
| Full gate | `npm run test:all` |
| Refresh SKILL.md sections | `node architecture/sync_skill_runtime.js` |

Executors and the router are PowerShell scripts. On Windows use `powershell.exe`;
elsewhere install PowerShell 7 (`pwsh`). Without a shell, `route`, `execute` and
`pipeline` fail with a clear message. `list`, `skill` and `validate` need only Node.

## Editing this repository

- Change a skill's contract in its `SKILL.md` and, if the hidden-state shape changes,
  in `architecture/schemas/` and the matching example. Then run `npm run test:all`.
- The "How to Execute" block between `<!-- gd-codex:how-to-execute:start/end -->`
  is generated. Edit `architecture/sync_skill_runtime.js`, not the block itself.
- `web/data.js` is generated. CI fails if it drifts from the committed version.
- `architecture/skill-registry.json` uses `domain_role` and `routing_role` only.
  The legacy `role` key is an error.
- New handoffs must have a `return_to` that is one of the two skills in the pair.
- Never add a franchise name to a skill `description`; the validator rejects it.

## Where things are

- `GD-Skill-Codex/` skill protocols
- `architecture/` schemas, executors, registry, handoffs, orchestrator
- `architecture/lib/runtime.js` shared runtime used by CLI and MCP
- `architecture/executor-manifest.json` skill → hidden-state key → schema → fixture
- `architecture/tests/` regression and smoke tests
- `bin/gd-codex.js` CLI, `mcp/server.js` MCP server
- `docs/` research-validity and implementation matrix
