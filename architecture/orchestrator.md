# Problem Orchestrator

GD Skill Codex control layer. It builds on existing skills; does not replace
none of them.

## Pipeline obrigatório

```text
user request
  -> problem decomposition
  -> world-model extraction
  -> assumptions and unknowns
  -> ontological projection
  -> skill routing
  -> formal model selection
  -> interface validation
  -> domain skill composition
  -> evidence sufficiency
  -> conflict and uncertainty report
  -> design options
  -> simulation/playtest plan
  -> recommendation
```

### 1. Decomposição

Extract entities, actors, actions, resources, objectives, constraints, scales
temporal, spatial relationships and available evidence. Record assumptions
absent as questions or hypotheses; do not invent values.

### 2. Classificação ontológica

Choose one or more projections on `architecture/world-model.schema.json`:

| Dominant signal | Primary model |
| --- | --- |
| sequential states, invariants, reachability | `discrete-state-machine-verification` |
| parallel processes, synchronization, shared resource | `concurrent-gameplay-processes` |
| domains, restrictions and generation | `procedural-level-constraint-solving` |
| timeline, startup/active/recovery, frames | `frame-based-combat-timing` |
| stocks, sources, sinks and rates | `resource-flow-economy` |
| multi-stage conversion | `macroeconomic-resource-conversion` |

Rule: Concurrency with sequential control uses a hybrid FSM + Petri model
Net; do not extend an FSM to represent complex concurrency.

### 3. Selection and composition

The central registry at `architecture/skill-registry.json` is migrating to
separate two dimensions:

- **domain role**: nature of the skill (`formal`, `design`, `hybrid`);
- **routing role**: contextual role (`primary_candidate`, `secondary`,
  `validator`).

Role migration is complete. `domain_role` and `routing_role` are the only valid dimensions for new contracts; any occurrence of `role` in the registry is an architectural error.
The router uses problem profiles before generic signals. The score matches
semantic profiles, `explicit`, `semantic` and `structural` signals, with penalty
by `anti_signals`. Nearby candidates are preserved as secondary instead
of being discarded by an arbitrary choice. The registry no longer has
`role` legacy; only `domain_role` and `routing_role` are valid.
Use `architecture/route_request.ps1` as a reference implementation.

Complementary skills work in parallel or in cycles; `downstream` indicates
data dependency, not just a reading suggestion. The runner materializes
input context, typed adapters and return packets. Each cycle has
`return_to`, `max_cycles` and a claims/adapters fingerprint for
detect stability; equality of status or route alone is no longer
considered convergence.

### 4. Estatuto epistemológico

Every conclusion must be classified:

- **formal**: guarantee conditional on the model and assumptions;
- **derived**: metric calculated from the data;
- **heuristic**: calibrable design parameter or judgment;
- **empirical**: statement that requires simulation, playtest or observation.

System constants, design parameters, derived metrics, and hypotheses
empirical data cannot be presented as the same thing. Work references
they are just semantic anchors: they do not authorize imitation of style or inference
of canon.

### 5. Cross validation

Before making the final recommendation, check:

1. **ontology**: entities, resources and states mean the same thing;
2. **time**: seconds, frames and cycles have explicit conversion;
3. **causality**: dependencies do not form contradictions;
4. **economy**: sources, sinks and conversions preserve units;
5. **agency**: a projection does not remove a choice created by another;
6. **solvency**: coverage, stability or entropy are not to be confused
   with quality or fun.
7. **evidence**: every recommendation points to claims, assumptions and
   limitations; without sufficient data, return `INSUFFICIENT_EVIDENCE`.

Conflicts must be reported as blocks or pending hypotheses, never
silently resolved.

## Calibração empírica

`architecture/calibration.schema.json` records the difference between the
system, design parameter, derived metric, heuristic, observation and value
validated. Defaults like `N_repetitions = 3` must be registered as
`heuristic`, with confidence and need for validation, never as a guarantee
universal.

## Validation and provenance

`architecture/validate_all.ps1` runs the structural validations,
cross-skill and web layer synchronization. The schema
`architecture/evidence.schema.json` sets the minimum provenance unit
for claims, including epistemological status, evidence, assumptions,
limitations, versions, input hash and seed when applicable.

`architecture/run_analysis.ps1` is the current reference runner: it runs the
routing and produces a versioned plan with provenance, but declares
`INSUFFICIENT_EVIDENCE` until there is a skill executor or simulation. This avoids
present an execution plan as if it were a completed diagnosis.
When it receives `-EvidenceStorePath`, it also persists the claims as JSONL
append-only, preserving input hash, versions, seed and timestamp.

`architecture/execute_skills.ps1` implements the initial execution bridge:
validates the world model, materializes a `SkillInput` per routed skill and generates a
`SkillOutput` `blocked` when there is no operational executor. Blocking is
intentional; the script does not interpret Markdown as code nor does it manufacture
results.

The first concrete executor is
`architecture/executors/discrete-state-machine-verification.ps1`. He applies
BFS to `hidden_state.state_system` and reports reachable, orphaned,
deadlocks and non-determinism. The corresponding limited simulation is in
`architecture/simulate_state_system.ps1`; it requires seed and step limit.

`architecture/generate_web_data.ps1` generates the visualization artifact from
registry, handoffs and front matter/skills content. The web layer
it is a projection of the system, not an independent source of relations.