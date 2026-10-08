# ADR 0001: Where the player model lives

Status: **proposed. Awaiting a design decision from the framework owner.**

## Context

Every skill models the system and treats the player as a declared parameter. The skills
cover the MDA mechanics and dynamics layers well and say little about the aesthetics layer.
Concepts such as challenge-skill balance (flow), motivation, cognitive load, accessibility and
differences in expertise have no place in any `hidden_state` slice, so they are either ignored
or silently folded into a skill's heuristics.

## Options

1. **Transversal parameter in the world model.** Add an optional `player` block to
   `world-model.schema.json` (expertise, input latency tolerance, accessibility settings,
   declared motivation model). Skills read it when they need it and state the assumption
   they used.
   - Pro: one place to declare the player; no new executors.
   - Con: the schema grows; skills must be audited for which fields they read.

2. **A dedicated skill.** Create a sixteenth skill, for example `player-model-and-flow`,
   with its own `hidden_state` slice and executor.
   - Pro: the concept gets the same rigour as the other skills.
   - Con: a new skill needs its own research basis, and the external evaluation (see
     `docs/evaluation-status.md`) would have to cover it too.

3. **Out of scope.** State explicitly in the README that the framework does not model the
   player, and that aesthetic and experiential claims are outside its validity.
   - Pro: honest and cheap.
   - Con: leaves the largest known gap in place.

## Recommendation

Option 1 now, with option 3's disclaimer kept until the transversal block is validated. A
dedicated skill (option 2) should wait until there are external cases that show the block is
not enough. This keeps the commitment small and makes the gap visible to users.

## Decision needed

Confirm option 1, 2 or 3. Until then, no schema or executor changes are made for the player model.
