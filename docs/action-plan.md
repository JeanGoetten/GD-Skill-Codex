# GD Skill Codex Historical Action Plan

> This document preserves the implementation record started on 2026-09-14.
> It is not the current backlog. Use [`../ROADMAP.md`](../ROADMAP.md) for live
> release gates and [`spec-implementation-matrix.md`](spec-implementation-matrix.md)
> for current executable coverage.

## Objetivo

Transform the GD Skill Codex from a well-organized architectural specification
in an operational game design analysis framework, without expanding the catalog
15 skills before consolidating:

1. a semantic and versioned world model;
2. truly typed interfaces between skills;
3. separate routing, execution and iteration;
4. semantic validation and consistency between sources;
5. traceable evidence, uncertainty and reproducibility;
6. an explicit bridge between analysis, simulation and playtest.

This document is an implementation roadmap. It does not replace
[`architecture/orchestrator.md`](../architecture/orchestrator.md), which describes
the current architectural behavior.

## Startup diagnostics

### Already exists

- 15 skills with front matter and own protocols;
- registration, handoffs, calibration and structural validations;
- a shared world model, still superficial;
- deterministic heuristic router;
- static web dashboard for catalog and visualization;
- conceptual distinction between `formal`, `derived`, `heuristic` and `empirical`.

### Does not exist yet

- an ontology verifiable by entity, relation, unit and version;
- schema compatibility between output and input handoffs;
- an executor of skills and feedback cycles;
- an evidence store or universal claims format;
- validation of units, semantics and dependencies;
- reproducible execution of simulations and procedural generation;
- a connection between orchestrator and dashboard;
- a single derived source for registry, graph and web data.

### Decision principles

1. **Evidence before recommendation:** lack of data can produce
   `INSUFFICIENT_EVIDENCE`, not an invented conclusion.
2. **Model before metric:** every metric must declare domain, unit,
   assumptions, method and limitations.
3. **Projections, not forced ontology:** an entity can be projected as
   actor, resource, state or capacity according to the analysis.
4. **Hard constraint separated from preference:** invariants, constraints,
   Heuristics and empirical hypotheses should not share the same status.
5. **One source of truth:** Derived artifacts should not be edited
   manually.
6. **Stated approximations:** continuous, probabilistic or physical models
   simplified ones need to state when they are approximations.
7. **No global score not defined:** the system should prefer a vector of
   results and uncertainties to a single note of “health”.

## Execution log

### 2026-09-14 — start of Phase 0

**Status:** in progress, with baseline and governance decisions recorded.

**Verified evidence**

| Area | Observed status | Current source | Job decision |
| --- | --- | --- | --- |
| Skills | 15 directories with `SKILL.md` | `GD-Skill-Codex/` | Do not add skills until completing Phases 1–5 |
| Registry | `role` mixes nature and routing | `architecture/skill-registry.json` | Separate `domain_role` and `routing_role` in Phase 2 |
| Handoffs | 7 contracts with field names, without schemas | `architecture/handoffs.json` | Migrate to `input_schema`/`output_schema` in Phase 2 |
| World model | Main fields are permissive arrays/objects | `architecture/world-model.schema.json` | Decompose into sub-schemes in Phase 1 |
| Routing | Deterministic heuristic ranking | `architecture/route_request.ps1` | Keep as fallback until Phase 3 |
| Validation | Predominantly structural | `architecture/validate_*.ps1` | Create semantic validation and entrypoint in Phase 4 |
| Web | Static catalog based on `web/data.js` | `web/` | Do not present as an engine; derive data in Phase 4 |
| Evidence | Statuses exist, but there is no evidence store | `architecture/` and front matter | Create universal model in Phase 5 |

**Recorded decisions**

- The current state will be described as **architectural specification +
  reference implementation**, not as an operational engine.
- `web/data.js` is a presentation artifact and not a source of truth.
- `INSUFFICIENT_EVIDENCE` will be a valid and explicit result.
- An overall health/confidence score will not be created without function,
  defined data and method.
- The first vertical slice will be
  `world model -> state system -> validated handoff -> traceable claim`.

**Phase 0 pending issues**

- complete the traceability matrix between public claims, status
  epistemological and evidence;
- label demonstrative numbers existing in the web layer;
- register the versioning policy in executable schemas;
- convert this baseline into automatic validations in Phase 4.

### 2026-09-14 — first slice of Phases 1–5

**Status:** fundamentals implemented; operational integration and calibration
continue in progress.

**Deliveries completed**

- created `architecture/schemas/` with 22 composable schemas for world model,
  interfaces, metrics, assumptions, evidence, recommendations and tests;
- `world-model.schema.json` now references entities, actors, resources,
  actions, rules, objectives, space, time, knowledge, progression and economy;
- `handoffs.json` received `schema_version`, `input_schema` and `output_schema`;
- created `validate_schema_interfaces.ps1` to check presence and
  chaining of contracts;
- created `evidence.schema.json` and `evidence.example.json`;
- `validate_all.ps1` now runs architecture, cross-skill, web and
  interfaces;
- `validate_web_data.ps1` detects missing skills/downstreams in the presentation;
- `route_request.ps1` now differentiates signal weights, applies blocking by
  anti-signal without positive evidence, chooses secondaries by relative threshold
  and exposes the routing policy in the result;
- corrected state system formalizations, randomness, invariants,
  risk-reward vector, physical range of CSP and discrete equations of
  economy.

**Validation performed**
```text
OK: todas as skills passaram na validação
OK: world model e handoffs passaram na validação
OK: registry e consistência cross-skill verificados
OK: web/data.js sincronizado com skills/downstreams
OK: schemas composáveis/interfaces e contratos compatíveis
```

**Immediate issues**

- link `validate_all.ps1` to the documented acceptance criteria;
- replace remaining permissive objects with semantic properties
  versioned in progression/economy;
- complete automatic generation of `web/data.js`;
- implement skills executor, persistent evidence store and simulation;
- continue the mathematical correction of the remaining skills and add limit cases.

### 2026-09-14 — reference runner and current status

[`architecture/run_analysis.ps1`](../architecture/run_analysis.ps1) was created.
It accepts a request, performs weighted routing, records order of
execution, seed, world model version and a derived claim. As there is not yet
skill runner or simulation runner, the report returns
`INSUFFICIENT_EVIDENCE` explicitly. This is the first reproducible run
of the pipeline without transforming a plan into a diagnosis.

**Phase status**

| Phase | Status | Evidence |
| --- | --- | --- |
| 0 — baseline/governance | completed with labeling issues | registration and decisions above |
| 1 — world model/units/versioning | core implemented; progression/economy semantics still partial | `architecture/schemas/`, `world-model.schema.json` |
| 2 — interfaces/handoffs | contracts and schemes implemented; skill-specific compatibility still pending | `handoffs.json`, `validate_schema_interfaces.ps1` |
| 3 — orchestrator | reference runner implemented; royal executor still pending | `run_analysis.ps1`, `route_request.ps1` |
| 4 — validation/artifacts | implemented aggregate validation; automatic web generation still pending | `validate_all.ps1`, `validate_web_data.ps1` |
| 5 — evidence/reproducibility | implemented schema, example and append-only JSONL store; pending trust propagation | `evidence.schema.json`, `evidence.example.json`, `run_analysis.ps1` |
| 6 — mathematical models | partial priority fixes | state, risk, CSP and economics skills |
| 7 — simulation/operational web | textual accessibility and catalog label added; simulation bridge pending | `web/index.html`, `web/app.js` |

**Final checks of this run**

- `architecture/validate_all.ps1`: passed;
- `validate_skills.ps1`: passed;
- `node --check web/app.js`: passed;
- `run_analysis.ps1` with `-Seed 42`: produced deterministic plan and
  `INSUFFICIENT_EVIDENCE`;
- JSONL persistence of claims: tested with hash, version and seed;
- no skill runner or simulation runner was pretended to be completed.

### 2026-09-14 — derived generation and minimum trust

**Deliveries for this stage**

- created `architecture/generate_web_data.ps1`;
- `web/data.js` is now generated from `skill-registry.json`,
  `handoffs.json` and `SKILL.md`, with downstreams derived from the handoffs;
- `validate_all.ps1` runs generation before validations, reducing drift
  between architecture and dashboard;
- the runner calculates and records minimum propagated confidence:
  `low` without world model, `medium` with partial context and `high` only with
  multiple evidence and strong signal;
- README and orchestrator now declare the generator and derived nature
  of the web artifact.

**Verification**

- generation completed for 15 skills;
- `node --check web/app.js` passed;
- generated downstreams passed `validate_web_data.ps1`;
- the runner's confidence was tested with and without the world model;
- the limitation remains explicit: trust is an initial policy, not
  empirical validation.
- after the first run of the generator, the web validator was adjusted to
  accept the produced JavaScript/JSON syntax; the regression was reproduced and
  corrected before final validation.

### 2026-09-14 — skill execution bridge

[`architecture/execute_skills.ps1`](../architecture/execute_skills.ps1) was created.
This first implementation:

- requires and validates the mandatory fields of the world model;
- executes existing routing;
- materializes an output per skill in the execution order;
- records `skill_id`, version, input hash, seed and version of the world model;
- returns `status: blocked` and `INSUFFICIENT_EVIDENCE` when it does not exist
  operational executor for the skill;
- you can persist a claim per skill in the JSONL evidence store.

This closes the execution interface without masking the absence of implementations
of skills. The backlog was reduced from “there is no execution bridge” to
“add versioned executors for skills and a simulation runner”.

### 2026-09-14 — first executor and simulation runner

**Deliveries**

- created `architecture/schemas/state-system.schema.json`;
- created `architecture/executors/discrete-state-machine-verification.ps1`;
- the executor applies BFS to the declared system, reporting achievable states,
  reachable endpoints, orphans, deadlocks, non-determinism and metrics
  derivatives;
- `execute_skills.ps1` started dispatching to versioned executors when
  they exist, keeping `blocked` for skills without implementation;
- created `architecture/simulate_state_system.ps1`, with seed, step limit,
  deterministic/weighted selection and reproducible trace;
- created the example
  `architecture/examples/state-system.example.json`.

**Verification**

- example system produced `partial`, reached `start, victory` and detected
  `orphan`;
- simulation runner reached the `victory` terminal in limited trace;
- execution without an executor remains explicitly blocked;
- the limitation remains: this executor proves properties of the declared graph,
  not the runtime implementation nor the player experience.

### 2026-09-14 — cobertura formal ampliada

**Deliveries**

- created `csp-system.schema.json` and integrated with the interface validator;
- created `executors/procedural-level-constraint-solving.ps1`, with validation
  of references, AC-3 propagation and empty domain detection;
- created `examples/csp-system.example.json`;
- created `executors/resource-flow-economy.ps1` by specialized executor,
  with its own schema and fixture;
- feature runner calculates discrete equation
  `Q(t+1) = Q(t) + sources - sinks`, classifies resources as
  `inflationary`, `deficit` or `balanced` and records derived evidence;
- `execute_skills.ps1` can now dispatch three formal skills:
  states, CSP and resource flow.

**Verification**

- CSP fixture: `success`, `locally_consistent`, no empty domains;
- resource fixture: `success`, `mixed` state, with inflation and deficit
  detected separately;
- both were executed by the pipeline, not just called directly;
- AC-3 continues to be explicitly limited to local consistency;
- the economic balance remains conditional on the discrete model provided.

### 2026-09-14 — executor of competing processes

**Deliveries**

- created `petri-net.schema.json` and registered in `hidden-state.schema.json`;
- created `executors/concurrent-gameplay-processes.ps1`;
- created `examples/petri-net.example.json`;
- the executor validates places, tokens and arcs, executes a limited trajectory,
  records markings, triggered transitions, observed progress and deadlock;
- `execute_skills.ps1` now dispatches four formal executors:
  states, CSP, resource flow and concurrent processes.

**Verification**

- Petri Net fixture fired `craft` deterministically;
- the final marking was `raw_material=0, product=1`;
- the deadlock was explicitly reported after the single token was consumed;
- execution through the pipeline routed to `concurrent-gameplay-processes`;
- limitation is registered: a limited trajectory does not prove liveliness
  global nor absence of deadlocks in all states.

### 2026-09-14 — frame-based timing executor

**Deliveries**

- created `frame-timing.schema.json` and integrated with `hidden-state` and
  interface validation;
- created `executors/frame-based-combat-timing.ps1`;
- created `examples/frame-timing.example.json`;
- the executor calculates total duration, seconds per tick, hit advantage and block
  advantage for actions with startup/active/recovery declared;
- loop candidates simultaneously require sufficient advantage, repeatability,
  contact, recourse and declared absence of escape;
- limitations of geometry, spacing, input buffer and escape states are
  included in the result, rather than being inferred.

**Verification**

- fixture produced `success`, 33 total frames, `+3` hit advantage and `-7`
  block advantage;
- no loops were classified as guaranteed;
- execution through the pipeline routed to `frame-based-combat-timing`;
- validation remains conditional on the declared parameters.

### 2026-09-14 — ERA executor and validator coverage

**Deliveries**

- created `procedural-expressive-range-analysis.schema.json` and integrated into
  `hidden_state` and the interface validator;
- created `executors/procedural-expressive-range-analysis.ps1`;
- created `examples/procedural-expressive-range-analysis.example.json`;
- executor requires `solvability_status` and non-empty samples;
- calculates sample count, classified samples, occupied bins,
  `bin_occupancy_coverage` and `distribution_bias`;
- explicitly separates occupation of bins from geometric coverage/area;
- `execute_skills.ps1` can now dispatch the ERA validator when routed.

**Verification**

- fixture produced `success` with 4 samples;
- 3 out of 9 bins were occupied (`0.3333`);
- the bin with the highest concentration represented `0.5` of the classified samples;
- execution through the pipeline routed to ERA;
- no quality, geometric diversity or overall solvency was inferred.

## Phase sequencing

The phases are ordered by dependency. A phase can start in parallel
when your prerequisites are complete, but you must not declare
stability before the acceptance criteria of the previous phase.

### Phase 0 — Baseline and governance

**Objective:** freeze the evolution contract and make the current state
observable before the changes.

**Deliveries**

- inventory of sources of truth and duplicate fields;
- traceability matrix between audit item, file, decision and test;
- versioning policy for schemas, skills and analyses;
- definition of canonical epistemological statuses:
  `formal`, `derived`, `heuristic`, `empirical`, `observed`, `assumed`,
  `unknown`, `contradicted`, `validated`;
- explicit registration of `INSUFFICIENT_EVIDENCE`;
- documented decision that the current dashboard is a static catalog.

**Acceptance criteria**

- each relevant public claim has an epistemological classification;
- no demonstrative dashboard number is presented as actual execution;
- the README describes the project as specification + reference implementation.

**Prioridade:** P0.

### Phase 1 — World model, units and versioning

**Objective:** replace the permissive schema with a composite ontology,
without imposing a single classification for all entities.

**Deliveries**

- decomposition of `world-model.schema.json` into sub-schemas for entities,
  actors, resources, actions, rules, objectives, space, time, knowledge and
  hidden state;
- stable identifiers, `type`, `source`, `version`, `timestamp`,
  ownership, relationships and epistemological status;
- unit vocabulary and explicit conversions between seconds, frames,
  ticks, cycles, distance, speed, damage and rates;
- separation between entity, resource, state variable, currency, capacity,
  knowledge and population;
- `world_model_version`, `analysis_version`, `skill_version` and `input_hash`;
- validation of internal references and relationships between objects.

**Acceptance criteria**

- valid and invalid examples cover each sub-schema;
- references to non-existent entities fail;
- incompatible units fail before any calculation;
- two different projections can point to the same entity without duplicating it.

**Priority:** P0. **Dependency:** Phase 0.

### Phase 2 — Interface contracts and handoffs

**Objective:** transform field names into verifiable contracts.

**Deliveries**

- schemas for `SkillInput`, `SkillOutput`, `HandoffContract`, `Metric`,
  `Assumption`, `Evidence`, `Recommendation` and `TestPlan`;
- `input_schema`, `output_schema`, `version`, required fields, units and
  compatibility in `handoffs.json`;
- distinction between `model`, `assumptions`, `analysis`, `results`, `evidence`,
  `uncertainty`, `recommendation` and `test`;
- iteration contract with return payload, merge strategy, state
  preserved,stop condition and computable metric;
- separate taxonomy for `domain_role` (`formal`, `design`, `hybrid`) and
  `routing_role` (`primary_candidate`, `secondary`, `validator`);
- validation that each target input exists in the source's compatible output.

**Acceptance criteria**

- an incompatible handoff fails with a localized error;
- `return_to` only accepts existing skills and steps;
- `max_cycles` is positive integer;
- every `convergence_metric` has a definition, threshold and evaluation method;
- registry, handoffs and front matter can be compared automatically.

**Priority:** P0. **Dependency:** Phase 1.

### Phase 3 — Executable Orchestrator

**Objective:** separate routing, execution, validation and iteration.

**Deliveries**

- pipeline: request, decomposition, world model extraction,
  assumptions/unknowns, ontological projection, routing, minimum selection,
  execution, validation and reporting;
- `route_request.ps1` explicitly kept as heuristic fallback;
- different weights for explicit, semantic and structural signals;
- real blocks for anti-signals and conflicts;
- selection of secondary skills based on dependencies, not on `First 3`;
- selection of validators by contract and type of risk;
- dependency graph and execution order;
- `evidence sufficiency` before any recommendation;
- execution logs, explicit failures and partial results identified.

**Acceptance criteria**

- the same input produces the same execution plan when the seed is fixed;
- an anti-signal blocks or requires review according to the declared policy;
- no skill is executed without compatible inputs;
- cycles close due to convergence, limit or reported error;
- `UNKNOWN` and `INSUFFICIENT_EVIDENCE` are valid results.

**Priority:** P0. **Dependency:** Phases 1 and 2.

### Phase 4 — Semantic validation and artifact generation

**Objective:** replace presence validations with coherence validations.

**Deliveries**

- `validate_schema.ps1`;
- `validate_registry.ps1`;
- `validate_handoffs.ps1`;
- `validate_interfaces.ps1`;
- `validate_units.ps1`;
- `validate_routing.ps1`;
- `validate_examples.ps1`;
- `validate_web_data.ps1`;
- `validate_all.ps1` as entrypoint;
- generator of `web/data.js`, document tables and graph from the registry and
  of handoffs;
- checking graph coverage, legitimate cycles, references and drift.

**Acceptance criteria**

- `validate_all.ps1` covers all validators and returns actionable errors;
- the web graph is derived from `handoffs.json`;
- changes to the registry are detected in the generated artifacts;
- no demonstrative data contains timestamp or confidence that appears to be execution
  real without the label `DEMO`, `EXAMPLE` or `SIMULATED`.

**Priority:** P1. **Dependency:** Phases 1–3.

### Phase 5 — Evidence engine and reproducibility

**Objective:** to make the epistemological layer imposed by architecture.

**Deliveries**

- evidence store with `claim`, `status`, `source`, `calculation`,
  `assumptions`, `confidence`, `validation` and limitations;
- link between claim, input hash, world model version, skill and execution;
- registration of seed, parameters, sample, timestamp and environment;
- confidence propagation and uncertainty budget;
- distinction between model, observed data, derived result and recommendation;
- report of conflicts and dependence on hypotheses;
- system state vector in place of undefined `health score`.

**Acceptance criteria**

- every recommendation points to at least one claim;
- every derived claim points to reproducible data and calculation;
- results without sufficient evidence are marked without silent fallback;
- a PCG/simulation run can be repeated with the same seed and parameters.

**Priority:** P0. **Dependency:** Phases 1–3.

### 2026-09-14 — progression executors and macroeconomics

**Status:** expanded formal coverage; the two executable models were
integrated into `hidden_state` and the execution pipeline.

**Deliveries completed**

- created `progression-analysis.schema.json` with versioned parameters for
  discrete growth, regime classification, prestige and limits of
  overflow;
- created the exponential-progression-and-prestige.ps1` executor, which validates
  parameters, calculates finite growth and prestige points/multipliers
  and blocks missing inputs or unrepresentable blow-up;
- created `macroeconomic-conversion.schema.json` for resources, products,
  conversions, efficiency and monetary flow;
- created the executor `macroeconomic-resource-conversion.ps1`, with matrix
  discrete input-output, consumption adjusted by efficiency, balance of sources and
  monetary sinks and explicitly approximate price projection;
- added reproducible fixtures in `architecture/examples/`;
- both schemas were registered in `hidden-state.schema.json` and in
  `validate_schema_interfaces.ps1`.

**Limites preservados**

- calculated growth is not a prediction of retention or behavior;
- monetary balance does not prove inflation/deflation without time series, demand,
  speed and observation;
- the price projection is a bounded approximation, not a market forecast;
- results remain conditional on coefficients, efficiency and hypotheses
  declared in the world model.

**Validation performed**
```text
progression-analysis.example.json: executor concluído
macroeconomic-conversion.example.json: executor concluído
macro pelo execute_skills.ps1: primary roteada e executor despachado
casos ausentes/blow-up de progressão: bloqueio/guard validados pelo executor
```

### 2026-09-14 — selective risk-reward performer

**Status:** a design lens with observable inputs has been integrated into
pipeline, without promoting structural heuristics to playtest evidence.

**Deliveries completed**

- created `risk-reward-action.schema.json` for action contracts, cost of
  stamina, recovery, damage, reaction, hitbox/hurtbox areas and evasion cost;
- created `committed-risk-reward-actions.ps1`, with checks for:
  `RISKLESS_DOMINANCE`, `STAMINA_LOCK_TRAP` and
  `REACH_EXPOSURE_INCOHERENCE`;
- added playable fixture in
  `architecture/examples/risk-reward-actions.example.json`;
- integrated `hidden_state.risk_reward_actions` into the shared schema;
- registered the new schema in interface validation;
- included explicit handoffs for timing and composition of actions.

**Limites preservados**

- alerts are derived from declared parameters, not observations of
  players;
- geometric areas are proxies and do not replace hitboxes, spacing or
  exhaust simulation;
- no flag alone asserts dominance, injustice or frustration.

**Validation performed**
```text
risk-reward-actions.example.json: executor success, 2 flags estruturais
execute_skills.ps1: roteamento para committed-risk-reward-actions e dispatch concluídos
validate_schema_interfaces.ps1: 31 schemas compatíveis
validate_all.ps1: validação agregada concluída
```

### 2026-09-14 — selective epistemic progression executor

**Status:** second design lens with observable data integrated into the
pipeline, maintaining the distinction between knowledge topology and evidence
empirical understanding.

**Deliveries completed**

- created `epistemic-progression.schema.json` for holons, clues, terminals,
  declared physical accessibility and known body of knowledge;
- created `epistemic-holarchic-progression.ps1`, with checks for:
  `INFORMATIONAL_ISLAND`, `PSEUDO_HOLON` and `FALSE_HOLARCHY`;
- calculated the coverage of mandatory predecessors of each terminal holon;
- added playable fixture in
  `architecture/examples/epistemic-progression.example.json`;
- integrated `hidden_state.epistemic_progression` into the shared schema and
  interface validation;
- included explicit handoffs for cognition and spatial pacing.

**Limites preservados**

- graph coverage is not inference probability or reachability
  cognitive;
- declared physical accessibility still requires trajectory validation,
  hazards and interaction rules;
- the performer does not infer fun, clarity or frustration.

**Validation performed**
```text
epistemic-progression.example.json: executor success, capacidade terminal 0,5
execute_skills.ps1: roteamento para epistemic-holarchic-progression e dispatch concluídos
validate_schema_interfaces.ps1: 32 schemas compatíveis
validate_all.ps1: validação agregada concluída
```

### 2026-09-14 — selective cognitive schema disruption executor

**Status:** Integrated third observable design lens, with hypotheses
structural effects separated from cognitive effects that require playtesting.

**Deliveries completed**

- created `cognitive-schema-disruption.schema.json` for conventions,
  repetitions, salience, ruptures, thresholds and hidden coherence;
- created `cognitive-schema-disruption.ps1`, with checks for:
  `PREMATURE_DISRUPTION`, `ARBITRARY_DISSONANCE`,
  `PUNITIVE_DISRUPTION` and `NON_STRATEGIC_BREAK`;
- added playable fixture in
  `architecture/examples/cognitive-schema-disruption.example.json`;
- integrated `hidden_state.cognitive_schema_disruption` into shared schema
  and interface validation;
- included explicit handoffs for epistemic progression and range analysis.

**Limites preservados**

- magnitude and threshold are proxies declared in feature space;
- hidden coherence does not prove discovery or acceptance by the player;
- surprise, confusion and accommodation require observation or playtest.

**Validation performed**
```text
cognitive-schema-disruption.example.json: executor success, 0 flags
execute_skills.ps1: roteamento e dispatch concluídos
validate_schema_interfaces.ps1: 33 schemas compatíveis
validate_all.ps1: validação agregada concluída
```

### 2026-09-14 — selective competitive feedback performer

**Status:** integrated fourth observable design lens, with separation between
mathematical properties of feedback and fairness/behavior hypotheses.

**Deliveries completed**

- created `competitive-feedback.schema.json` for positions, scores, drag
  leader, compensation effect, history and expected value per ranking;
- created `competitive-negative-feedback.ps1`, with checks for:
  `EXTREME_RUBBER_BANDING`, `DESTRUCTIVE_ELASTIC_OSCILLATION` and
  `SANDBAGGING_INCENTIVE`;
- added playable fixture in
  `architecture/examples/competitive-feedback.example.json`;
- integrated `hidden_state.competitive_feedback` into shared schema and
  interface validation;
- included explicit handoffs to save resources and progression.

**Limites preservados**

- mathematical stability does not prove perceived fairness or fun;
- sandbagging requires strategic agents, simulation or telemetry;
- a specific sample of positions does not demonstrate temporal dynamics.

**Validation performed**
```text
competitive-feedback.example.json: executor success, 2 hipóteses estruturais
execute_skills.ps1: roteamento e dispatch concluídos
validate_schema_interfaces.ps1: 34 schemas compatíveis
validate_all.ps1: validação agregada concluída
```

### 2026-09-14 — selective executor of spatial topology and pacing

**Status:** Fifth observable design lens integrated into the pipeline.

**Deliveries completed**

- created `spatial-pacing.schema.json` for nodes, edges, mechanics, phases,
  tension, risk of death and decompression rooms;
- created `spatial-topology-and-learning-pacing.ps1`, with checks for:
  `COGNITIVE_LOAD_SPIKE`, `TENSION_PLATEAU`,
  `TOPOLOGICAL_PREREQUISITE_BREAK` and `UNREACHABLE_SPACE`;
- added playable fixture in
  `architecture/examples/spatial-pacing.example.json`;
- integrated `hidden_state.spatial_pacing` into shared schema and
  interface validation;
- included explicit handoffs for procedural solvency and progression
  epistemic.

**Limites preservados**

- reachability of the graph does not prove physical solvability or accessibility;
- voltage and phases are declared proxies;
- pedagogical quality requires route tracing, testing with novices and review of
  accessibility.

**Validation performed**
```text
spatial-pacing.example.json: executor success, reachable ratio 1
execute_skills.ps1: roteamento e dispatch concluídos
validate_schema_interfaces.ps1: 35 schemas compatíveis
validate_all.ps1: validação agregada concluída
```

### 2026-09-14 — execution of to-do block 1–7

**Status:** Expanded coverage of executors and transversal infrastructure;
contracts and results continue to distinguish calculation derived from evidence
empirical.

**Deliveries completed**

- implemented `emergent-agency-composition` executors and
  `nested-gameplay-loop-architecture`, with schemas, fixtures, metrics,
  diagnostics and handoffs;
- created `validate_handoff_compatibility.ps1`, checking origin, destination,
  declared fields, version and adapters required;
- created `regression_tests.ps1`, which runs the fixtures of all
  executors and rejects invalid statuses;
- created `simulation_runner.ps1`, with repetition, seed, world model hash,
  status by run and classification `derived_from_simulation` or
  `INSUFFICIENT_EVIDENCE`;
- created `playtest-hypothesis.schema.json` and fixture to separate hypothesis,
  population, metrics, protocol, sample and success criteria;
- fixed `execute_skills.ps1` to register derived claims when there is
  real output, maintain low/medium confidence and use `partial` correctly;
- dashboard now accepts local JSON reports and displays status, skills,
  seed and hash, keeping `not executed` by default;
- `validate_all.ps1` now includes handoff compatibility.

**Pending issues still open**

- JSON Schema validation with complete engine;
- propagation of trust through dependencies and conflicts in multiple claims;
- executable adapters between handoffs, in addition to need detection;
- simulation runner with strategic agents and specific time series;
- automatic integration of the evidence store and loading of executions via
  dashboard;
- definitive separation between `domain_role` and `routing_role`;
- complete ontology of the world model and empirical calibration.

**Validation performed**
```text
2 novos executors: fixtures e dispatch validados
16 fixtures executadas sem status inválido
validate_handoff_compatibility.ps1: concluído com warnings de adapters explícitos
validate_all.ps1: validação agregada concluída
node --check web/app.js: concluído
```

### 2026-09-14 — explicit closure of issues 1–7

**Status:** the first seven backlog items have been executed in their form
reference; adapters and empirical calibration remain limitations
declared.

**Additional deliveries**

- created persistent migration from `skill-registry.json` to
  `domain_role`/`routing_role`, with updated router and validation;
- created `iterate_handoffs.ps1` and convergence/cycle limit criteria;
- created `provenance.schema.json` with source type, dependencies, conflicts,
  hashes and versions;
- strengthened `knowledge`, `progression`, `economy` and `spatial` schemas
  with IDs, relations, units, stock, gates and epistemological status;
- dispatcher's evidence store started recording derived claims when there are
  real output, keeping `INSUFFICIENT_EVIDENCE` for locks only;
- handoff compatibility now differentiates valid contracts from fields that
  still require explicit adapters.

**Final block validation**
```text
39 schemas composáveis/interfaces compatíveis
7 handoffs verificados; 5 adapters explicitamente advertidos
16 fixtures executadas sem status inválido
iteration contract: 2 ciclos, convergência detectada
registry: 15 skills com domain_role/routing_role
validate_all.ps1: concluído
```

### 2026-09-14 — handoff executable adapters

**Status:** the five field compatibility warnings have been converted to
declarative contracts and an adapter executor, preserving external data
as an explicit requirement.

**Deliveries completed**

- created `handoff-adapters.json` with mappings, derived fields and
  `external_required`;
- created `execute_handoff_adapter.ps1`, which materializes mapped fields,
  records outstanding derived expressions and does not fabricate missing data;
- `validate_handoff_compatibility.ps1` now requires adapter for fields not
  compatible and validates that each field has mapping, derivation or requirement
  external;
- Petri Net fixture was adapted for resource flow and produced fields
  `places` and `transition_rates`, with explicit warning for `resource_list`
  missing in the output.

**Validation**
```text
7 handoffs verificados com adapters declarados
adapter concurrent-gameplay-processes -> resource-flow-economy executado
Node disponível; a engine AJV foi instalada e integrada à validação agregada
```

### 2026-09-14 — AJV installation and integration

**Status:** Full JSON Schema validation integrated with aggregate validation.

**Deliveries completed**

- installed `ajv` 8.20.0 and `ajv-formats` 3.0.1 as dependencies
  development;
- created `architecture/validate_json_schema.js`, with schema loading
  composable, `$ref` resolution, format support and BOM tolerance;
- `validate_all.ps1` started to perform AJV validation;
- `package.json` received `test` and `validate:schema`;
- 15 world models and 16 fixtures were validated by AJV.

**Validation**
```text
npm run validate:schema: passou
validate_all.ps1: passou
AJV: 15 world models válidos; 16 fixtures inspecionadas
```

### 2026-09-14 — adapters integrados ao dispatcher

**Status:** the execution flow now automatically materializes adapters
declared between consecutive skills.

**Deliveries completed**

- `execute_skills.ps1` now identifies consecutive pairs with contracts in
  `handoff-adapters.json`;
- each adapter is executed via `execute_handoff_adapter.ps1` and its result
  is included in the `handoff_adapters` field of the report;
- derived fields, warnings and external requirements remain traceable;
- adapter failures stop execution explicitly, without fallback
  silent.

**Validation**
```text
request Petri Net + resource flow: 1 adapter automático executado
execution_status: blocked por skill downstream sem executor, não por adapter
adapter warnings: 1 campo externo ausente, preservado explicitamente
validate_all.ps1: passou
```

### Phase 6 — Model correction and calibration

**Objective:** correct formalizations that could contaminate diagnoses.

**Ordem recomendada**

1. discrete transition system, distinguishing finite set, system
   discrete, non-determinism and probabilistic distribution;
2. invariants like `Valid = {q | Phi(q)}` and reachability as a subset;
3. timing with contact conditions, repetition, resources, escape and geometry;
4. risk-reward actions with separate state, damage, position and speed;
5. competitive feedback on performance differences, not just ranking;
6. savings with discrete equations when the system is event-driven,
   bounded prices and explicit assumptions for sources, sinks and demand;
7. progression as positive-feedback growth, including exponential cases,
   sublinear and blow-up;
8. Configurable canonical temporal bands for loops;
9. epistemic progression with `pure_epistemic`, `hybrid` and `physical` modes;
10. cognitive divergence as `design-space divergence` until it exists
    empirical observation;
11. ERA with adaptive sample size and distinct occupancy metrics,
    density and valid-space coverage;
12. CSP with `Reachability(agent_model)` and separation between generator,
    verifier and quality evaluator.

**Acceptance criteria**

- each formula declares domain, unity, hypothesis and epistemological status;
- examples do not conclude more than the data allow;
- arbitrary defaults are marked as calibratable heuristics;
- regression tests cover limit cases: zero, negative, infinity,
  empty domain, insufficient cycles and data.

**Priority:** P1. **Dependency:** Phases 1, 2 and 5.

### Phase 7 — Simulation, playtest and web bridge

**Objective:** connect executable analysis, evidence and presentation.

**Deliveries**

- simulation runner interface;
- hypothesis playtest interface and observation collection;
- storage of runs and time series;
- dashboard powered by real results when available;
- explicit “not executed” state;
- accessible textual representation for the graph;
- visualization of claims, evidence, uncertainties and conflicts;
- future flow `request -> router -> execution -> result -> dashboard`.

**Acceptance criteria**

- the UI differentiates catalog, performed analysis and demonstration;
- the graph and displayed numbers derive from versioned artifacts;
- users of assistive technologies can consult relationships without
  depend only on SVG;
- an execution can be opened from the dashboard with its provenance.

**Priority:** P2. **Dependency:** Phases 4 and 5.

### 2026-09-14 — operational closure of block 1–7

**Status:** completed and validated.

- the ontology received cross-skill semantic validation for IDs, references,
  units, dependencies, cycles and deadlocks;
- `role` was removed from the registry; `domain_role` and `routing_role` are the
  official dimensions;
- adapters now declare version, source/destination schemas and units;
- `iterate_handoffs.ps1` records `return_to`, conflicts and convergence;
- claims and evidence records now carry `skill_id`, propagated trust,
  provenance, dependencies and conflicts;
- the JSONL evidence store generates a queryable index `.index.json`;
- simulation runner records snapshots, events, time series and agents
  declared, without transforming the executor's repetition into empirical evidence;
- regressions cover missing, duplicate IDs, invalid references, zero,
  negatives, overflow, cycles, deadlocks, partial and incomplete adapters;
- the dashboard displays claims, trust, epistemological status and adapters alongside
  upload a report.

**Validation run:** `npm test`, `npm run validate:schema`,
`architecture/regression_tests.ps1` and `architecture/validate_all.ps1`.

**Limitations preserved:** time series are still executor snapshots,
agents only use strategies declared in the world model and trust is not
empirically calibrated. No recommendations are released when the claim is
in `INSUFFICIENT_EVIDENCE`.

### 2026-09-14 — quatro tarefas operacionais selecionadas

Four backlog tasks were performed:

1. **Dimensional compatibility of adapters:** created
   `validate_adapter_dimensions.ps1`, with version check, schemas,
   dimensional units and fields.
2. **Queryable evidence store:** created `query_evidence_store.ps1`, with
   filters by `skill_id`, `status` and `confidence`.
3. **Traceable Recommendations:** created `generate_recommendations.ps1` and
   integrated the `recommendations` field into the report; insufficient claims or
   Low-confidence results in `blocked` recommendations.
4. **Aggregated simulation:** `simulation_runner.ps1` started recording count
   of successes/partials/failures and metric names, maintaining snapshots,
   events, seeds and the distinction between derivation and empirical evidence.

Additional validation: four valid dimensional adapters, evidence query
returning filtered records, recommendation blocked for insufficient claim,
AJV, regressions and `validate_all.ps1` approved.

### 2026-09-14 — integration of simulation evidence and dashboard

- `simulation_runner.ps1` accepts `EvidenceStorePath` and persists a claim
  simulation with seed, hash, epistemological status, limitations and provenance;
- `validate_recommendations.ps1` checks that each recommendation points to a
  existing claim, has evidence and remains blocked when necessary;
- the dashboard allows you to filter claims loaded by blocking, low trust
  or conditional state;
- flow continues to distinguish `derived_from_simulation` from evidence
  observational and does not promote partial conclusions.

### 2026-09-14 — report validation and incremental index

- created `validate_report.ps1`, which checks claims, provenance hashes and
  recommendations trackable in a comprehensive report;
- created `refresh_evidence_index.ps1`; the index is now regenerated after each
  dispatcher execution or simulation persistence;
- regression suite gained valid and invalid reporting cases including
  orphan recommendation, unblocked recommendation and divergent hash;
- final validations: AJV, `validate_all.ps1`, `regression_tests.ps1` and flow
  end to end with two records in the evidence store.

### 2026-09-14 — simulation and operational presentation contract

- created `simulation-report.schema.json`, covering runs, snapshots, events,
  agents, epistemological state and aggregates;
- created `validate_simulation_report.js` and integrated the schema with AJV inspection;
- the dashboard now identifies simulation reports and displays runs,
  successes, partials and failures, keeping explicit that derived simulation does not
  equivalent to telemetry or playtest;
- a report generated with two runs was validated by the dedicated contract,
  in addition to `npm test`, `validate_all.ps1` and `regression_tests.ps1`.

### 2026-09-14 — automatic validation of simulation and playtest

- `validate_all.ps1` now generates a reference run and validates its
  report with `validate_simulation_report.js`;
- created `validate_playtest_hypothesis.js`/`.ps1`, which validates the fixture
  hypothesis, requires sample/protocol/criterion and rejects stated observations
  as if they were hypotheses;
- `regression_tests.ps1` received invalid playtest case;
- validations executed successfully: AJV, `validate_all.ps1`,
  `regression_tests.ps1` is the official playtest fixture.

### 2026-09-14 — record of playtest observations

- created `playtest-observation.schema.json` with contract for metric, sample,
  timestamp, status and limitations;
- created `validate_playtest_observation.js` and
  `record_playtest_observation.ps1`, which link the observation to the hypothesis,
  check metrics/sample and persist an empirical claim in the evidence store;
- `validate_all.ps1` runs the observation fixture and checks for update
  of the index; regressions cover invalid structural observation.

### 2026-09-14 — evidence store AJV validation

- created `validate_evidence_store.js`, which validates each JSONL record against
  `evidence.schema.json` and identifies invalid JSON, status or trust out
  of the contract and incomplete provenance;
- `validate_all.ps1` validates stores generated by playtest and simulation before
  remove them as temporary artifacts;
- regressions cover an invalid evidence record.

## Trackable backlog

| ID | Theme | Phase | Priority | Expected result |
| --- | --- | --- | --- | --- |
| B-01 | Ontology and sub-schemes | 1 | P0 | Semantic and validable world model |
| B-02 | Units and domains | 1 | P0 | Verifiable dimensional compatibility |
| B-03 | Versioning and hashes | 1 | P0 | Old analyzes reproducible |
| B-04 | Input/output contracts | 2 | P0 | Schema-typed handoffs |
| B-05 | Role taxonomy | 2 | P0 | Separate nature and role of routing |
| B-06 | Iteration contract | 2 | P0 | Computable returns and convergence |
| B-07 | Orchestrator pipeline | 3 | P0 | Separate routing, execution and validation |
| B-08 | Evidence sufficiency | 3/5 | P0 | Recommendations blocked without evidence |
| B-09 | Semantic validators | 4 | P1 | Coherence between interfaces and sources |
| B-10 | Single source and web generation | 4 | P1 | Drift elimination |
| B-11 | Evidence store | 5 | P0 | Traceable claims |
| B-12 | Uncertainty and confidence | 5 | P0 | Propagated and explicit uncertainty |
| B-13 | Reproducibility | 5 | P0 | Registered seed, parameters and hashes |
| B-14 | FSM/timing/economy correction | 6 | P1 | Dimensionally coherent formalizations |
| B-15 | ERA/CSP/cognition correction | 6 | P1 | Correctly limited metrics and reach |
| B-16 | Simulation/playtest bridge | 7 | P2 | Executable evidence |
| B-17 | Operational dashboard | 7 | P2 | Execution-connected UI |

## Historical framework-ready criteria (snapshot from 2026-09-14)

This checklist is preserved as an audit snapshot; it is not automatically
updated. Current status is maintained in `ROADMAP.md`.

- [ ] world model and interface schemas have executable validation;
- [ ] handoffs have verifiable input, output and unit compatibility;
- [ ] routing, execution, iteration and validation are distinct components;
- [ ] there is a valid result for insufficient evidence;
- [ ] claims have provenance, assumptions and epistemological status;
- [ ] executions are reproducible by version, hash, seed and parameters;
- [ ] semantic validation and structural validation are separate;
- [ ] registry, handoffs, README and web are synchronized by generation;
- [ ] corrected mathematical models have limit cases covered;
- [ ] dashboard does not present simulated data as facts;
- [ ] at least one formal skill, one design skill and one validator skill go through
  the complete pipeline;
- [ ] there is a simulation or reference experiment with results
  traceable to recommendation.

## Out of immediate scope

- add new skills;
- create a global “quality” or “health” score;
- replace all models with complete physical simulations;
- treat retention heuristics as a universal objective;
- infer cognitive impact, fun or fairness without observational data;
- transform the dashboard into a production product before the evidence layer.

## Recommended execution sequence

1. Phase 0 and drift inventory.
2. Phase 1, starting with IDs, units and versions.
3. Phase 2 and migration of a pilot handoff.
4. Phase 3 with a reference end-to-end execution.
5. Phase 4 to prevent regressions and generate artifacts.
6. Phase 5 to make claims and evidence persistent.
7. Phase 6, prioritizing models that already participate in the pilot handoff.
8. Phase 7 only after real data can feed the presentation.

The first recommended vertical slice is:
```text
world model versionado
  -> discrete state system
  -> interface validada
  -> cross-skill validator
  -> claim com evidência e incerteza
  -> relatório reproduzível
```

This slice tests the foundation of the framework without requiring implementation
simultaneous use of the 15 skills.
