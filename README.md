# GD Skill Codex

Catalog of conceptual skills for analysis and design of game systems.

## Catalog

| Directory | Focus |
| --- | --- |
| `frame-based-combat-timing` | discrete timing, frames and cancellations |
| `concurrent-gameplay-processes` | concurrency, resources and Petri nets |
| `procedural-level-constraint-solving` | CSP, solvency and procedural generation |
| `resource-flow-economy` | resource flows, stocks and balance |
| `procedural-expressive-range-analysis` | procedural content diversity and bias |
| `spatial-topology-and-learning-pacing` | topology, implicit teaching and rhythm |
| `epistemic-holarchic-progression` | information graphs and epistemic progression |
| `competitive-negative-feedback` | compensation and competitive stabilization |
| `macroeconomic-resource-conversion` | production matrices and virtual economy |
| `emergent-agency-composition` | verb composition and emergent agency |
| `cognitive-schema-disruption` | subversion of expectations and cognition |
| `committed-risk-reward-actions` | action contracts, commitment and spatial risk |
| `exponential-progression-and-prestige` | curve families, progression and prestige |
| `nested-gameplay-loop-architecture` | nested time loops |
| `discrete-state-machine-verification` | automata, transitions and reachability |

## Conventions

Each skill is in `DIRECTORY/SKILL.md` and starts with portable YAML front matter. The standard keys are `name`, `description` and `metadata`; project-specific fields live below `metadata` as `domain.primary`, `activation_signals.concepts`, `activation_signals.recognition_references`, `outputs`, `handoffs.downstream` and `exclusions`. `name` uses exactly the name of the official directory. They all include `Domain`, `Purpose`, `Activation Signals`, `Scope`, `Exclusions`, `Handoff Conditions`, `Handoff Candidates` and `Recognition References`, in addition to the specific mathematical protocol.

### Mathematical status and handoffs

`Mathematical Status` separates formal guarantees, derived metrics, heuristics/design judgments, and mandatory simulation or playtesting. Guarantees are conditional on the model: for example, AC-3 provides arc consistency, not global solvability; entropy describes distribution, not quality; KL requires the same event space; stability does not imply justice; and expected value does not determine player choice.

`Handoff Candidates` lists official destinations and forwarding trigger. The front matter is the tool-readable interface; narrative sections preserve context, limitations, and evidence for designers.

## Routing architecture

Use `discrete-state-machine-verification` as an interface for states, invariants and reachability. Forward timing to `frame-based-combat-timing`, concurrency to `concurrent-gameplay-processes`, space and teaching to `spatial-topology-and-learning-pacing`, generation to `procedural-level-constraint-solving` or `procedural-expressive-range-analysis`, economics to `resource-flow-economy` or `macroeconomic-resource-conversion`, and progression to `exponential-progression-and-prestige`. Epistemic narrative and cognition use `epistemic-holarchic-progression` and `cognitive-schema-disruption`; agency, risk and competition use `emergent-agency-composition`, `committed-risk-reward-actions` and `competitive-negative-feedback`. Temporal loops are handled by `nested-gameplay-loop-architecture`.

## Official interfaces

Every skill receives a problem and context from the system; returns model, assumptions, metrics, anomalies and recommendations. The interfaces between skills are: state (`Q, Σ, δ, q0, F`), spatial graph (`V, E`), flow (`stocks, flows, rates`), curve (`f(t), marginal cost, reset`) and epistemic evidence (`holons, clues, knowledge state`). The handoff must cite the official destination directory and preserve units, domains and invariants.

Formulas are working models: units, domains, states, error contracts and acceptance criteria must be made explicit in the project that applies them. AC-3 is just local consistency; Global checks of trajectories, reachability, and solvability remain necessary. For heterogeneous states, normalize to a common representation before applying KL norm or divergence.

## Limitations

Thresholds and diagnoses are conditional risks, not universal guarantees. Results depend on the model, data, implementation, latency, accessibility, player behavior and playtests. Textual validation does not replace execution tests, simulation or design review.

## Validation

In PowerShell, run:
```powershell
.\validate_skills.ps1
```

The script checks front matter, `name == directory` and required headings without installing dependencies.

For the complete suite, install dependencies and run:

```powershell
npm ci
npm run test:all
```

The live release gates are in [`ROADMAP.md`](ROADMAP.md). Historical implementation
notes remain in [`docs/action-plan.md`](docs/action-plan.md), executable coverage
is tracked in [`docs/spec-implementation-matrix.md`](docs/spec-implementation-matrix.md),
and empirical-validity requirements are in
[`docs/research-validity.md`](docs/research-validity.md).

## End-to-end example

Plan routing without executing a skill:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\architecture\run_analysis.ps1 `
  -Request "verify state reachability and invariant violations" `
  -WorldModelPath .\architecture\examples\state-system.example.json
```

Execute the routed skills and produce validated outputs, claims, provenance,
confidence propagation, and conditional recommendations:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\architecture\execute_skills.ps1 `
  -Request "verify state reachability and invariant violations" `
  -WorldModelPath .\architecture\examples\state-system.example.json `
  -OutputPath .\analysis-report.json
```

For the local catalog and bounded fixture runner, use `npm run serve`. The
server binds to `127.0.0.1`; do not expose it to an untrusted network.

## Integrated feedback architecture

The recommendations from the feedback document are now implemented in
[`architecture/`](architecture/):

- [`world-model.schema.json`](architecture/world-model.schema.json) defines the
  shared ontology (`entities`, `resources`, `spatial`, `temporal`,
  `rules`, `knowledge`, `progression`, `economy`, `actors`, `actions`, `goals`
  and `hidden_state`);
- [`orchestrator.md`](architecture/orchestrator.md) defines the
  decomposition, model selection, composition, epistemological status and
  cross-validation;
- [`handoffs.json`](architecture/handoffs.json) turns forwards into
  contracts with trigger, entry, exit, return and iteration limit;
- [`skill-registry.json`](architecture/skill-registry.json) centralizes
  `domain_role` (nature) and `routing_role` (role in routing), in addition to semantic signals,
  structural and anti-signals;
- [`route_request.ps1`](architecture/route_request.ps1) implements a router
  reference deterministic;
- [`calibration.schema.json`](architecture/calibration.schema.json) records
  confidence, sample and epistemological status of parameters;
- [`calibration.defaults.json`](architecture/calibration.defaults.json) tag
  repetition and duration defaults as low confidence heuristics;
- [`validate_cross_skill.ps1`](architecture/validate_cross_skill.ps1) checks
  registry, add-ons, skill files and handoff cycles;
- [`validate_architecture.ps1`](architecture/validate_architecture.ps1) checks
  that the schema, registry and contracts are complete.

Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\architecture\validate_architecture.ps1`
to validate this layer.

`architecture\validate_all.ps1` also performs cross-skill validation and
web data synchronization check. The minimum provenance contract
it's in [`architecture/evidence.schema.json`](architecture/evidence.schema.json)
and an example is in
[`architecture/evidence.example.json`](architecture/evidence.example.json).
The planning-only reference runner
[`architecture/run_analysis.ps1`](architecture/run_analysis.ps1) generates a plan
of reproducible analysis and explicitly marks the insufficiency of evidence. Use
it when only routing is desired; it intentionally does not execute skills.
[`architecture/execute_skills.ps1`](architecture/execute_skills.ps1) is the operational dispatcher: it validates the world model, executes the skills in the routing order and, when there is a compatible adapter, executes the adapter **before** the next skill. The result of the adapter is injected into the temporary world model of the next skill in `hidden_state.handoff_context` and also preserved as `input_context` in `SkillOutput`. Thus, handoffs are effective inputs to the execution, and not just reports produced after it.
The first versioned executor analyzes state systems in
[`architecture/executors/discrete-state-machine-verification.ps1`](architecture/executors/discrete-state-machine-verification.ps1);
the minimum format is exemplified in
[`architecture/examples/state-system.example.json`](architecture/examples/state-system.example.json).
There are also executors for CSP and resource flow in
[`architecture/executors/`](architecture/executors), with fixtures in
[`architecture/examples/`](architecture/examples). They distinguish
local consistency, discrete balance, and sufficient evidence; they do not present
these metrics as global proof of solvency, healthy economy or
design quality.
The concurrent process executor uses
[`petri-net.schema.json`](architecture/schemas/petri-net.schema.json) and
reports observed firings and deadlocks in limited runs; global liveness
continues to require additional analysis.
The timing executor uses
[`frame-timing.schema.json`](architecture/schemas/frame-timing.schema.json) and
separates startup/active/recovery windows, calculated benefits and conditions
required for a loop candidate. It does not classify punishment or a loop as
guaranteed without spatial and escape data.
The ERA executor uses
[`procedural-expressive-range-analysis.schema.json`](architecture/schemas/procedural-expressive-range-analysis.schema.json)
and reports bin occupancy, classified samples, and declared bias. Occupation
of bins is not treated as area coverage; solvency must be provided
before analysis.
Progression and macroeconomics executors use,
respectively, [`progression-analysis.schema.json`](architecture/schemas/progression-analysis.schema.json)
and [`macroeconomic-conversion.schema.json`](architecture/schemas/macroeconomic-conversion.schema.json).
The first calculates discrete trajectories, growth regimes, and prestige
with blow-up guards; the second calculates input-output conversions,
efficiency, monetary balance, and an explicitly approximate price projection. Neither transforms conditional calculations into empirical evidence of retention, inflation or market behavior.
The executor [`committed-risk-reward-actions.ps1`](architecture/executors/committed-risk-reward-actions.ps1)
analyzes declared share contracts, detecting structural combinations such as
riskless dominance, stamina trap and incoherence between exposure and
range. These alerts depend on the parameters provided and must be
confirmed by timing, geometry and playtest; they are not empirical diagnoses.
The executor [`epistemic-holarchic-progression.ps1`](architecture/executors/epistemic-holarchic-progression.ps1)
checks graphs of holons and clues, informational islands, pseudo-holons
blocked by inventory, strictly linear graphs and declared coverage
of terminal predecessors. Inference capacity is a metric of
graph coverage, not a probability of player understanding.
The executor [`cognitive-schema-disruption.ps1`](architecture/executors/cognitive-schema-disruption.ps1)
verifies consolidation of conventions, retrospective coherence, preservation of
agency and change of strategic variable. It signals premature ruptures,
arbitrary dissonance, punitive rupture and breaks without strategic effect,
without claiming to measure surprise, confusion, or cognitive accommodation.
The executor [`competitive-negative-feedback.ps1`](architecture/executors/competitive-negative-feedback.ps1)
calculates relative deviations, gap between leader and last position and checks risks
of extreme rubber-banding, elastic oscillation and encouragement of sandbagging.
Mathematical stability is not treated as proof of perceived fairness;
strategic behavior requires simulation or telemetry.
The executor [`spatial-topology-and-learning-pacing.ps1`](architecture/executors/spatial-topology-and-learning-pacing.ps1)
checks declared reachability, isolated introduction of mechanics, peaks of
cognitive load, tension plateaus and decompression rooms. Reachable graph
does not prove physical solvency, discovery or learning; these properties
require route simulation and player testing.
Executors for agency composition and nested loops are also available,
in addition to [`simulation_runner.ps1`](architecture/simulation_runner.ps1),
[`regression_tests.ps1`](architecture/regression_tests.ps1) and
[`validate_handoff_compatibility.ps1`](architecture/validate_handoff_compatibility.ps1).
The schema [`playtest-hypothesis.schema.json`](architecture/schemas/playtest-hypothesis.schema.json)
separates future hypotheses and observations from derived calculations. The dashboard
allows you to load a local JSON report and displays status, seed, hash, claims,
trust, provenance and adapters; without report, the status remains
`not executed`.
The registry now separates `domain_role` from `routing_role` without keeping the legacy field
`role`. [`iterate_handoffs.ps1`](architecture/iterate_handoffs.ps1) runs cycles
limited with convergence criteria, reusing the context returned by the
chain rather than simply repeating the same analysis without intermediate input. Knowledge schemes, progression,
economy and space require IDs, relations, units or epistemological statuses
when these objects are provided.
The declarative adapters in [`handoff-adapters.json`](architecture/handoff-adapters.json)
can be executed by [`execute_handoff_adapter.ps1`](architecture/execute_handoff_adapter.ps1).
Non-derivable fields remain in `external_required` and are not manufactured.
When two compatible skills appear in the execution order, the dispatcher
runs the adapter between the two runs. The adapter can produce `ready`,
`partial` or `requires_external_evidence`; non-derivative fields remain
explicit in `external_required` and `warnings`. The context received by the skill
destination is registered in `input_context` and in `hidden_state.handoff_context`,
while `handoff_adapters` preserves the provenance of the transformation.
JSON Schema validation now uses AJV 8 and `ajv-formats`, performed by
[`validate_json_schema.js`](architecture/validate_json_schema.js) or
`npm run validate:schema`.
[`validate_adapter_dimensions.ps1`](architecture/validate_adapter_dimensions.ps1)
checks version, schemas and declared units of adapters.
[`query_evidence_store.ps1`](architecture/query_evidence_store.ps1) allows
consult persisted claims by skill, status and trust.
[`generate_recommendations.ps1`](architecture/generate_recommendations.ps1)
generates trackable recommendations and blocks actions when the claim is in
`INSUFFICIENT_EVIDENCE` or with low confidence.
`validate_recommendations.ps1` checks links between recommendations and
claims. The simulation runner can also persist its provenance directly
in the evidence store, and the dashboard offers claim filters by trust and
epistemological state.
`validate_report.ps1` validates a complete report, including provenance
supports input hashing and non-orphaned recommendations. The index of
evidence store is automatically updated by both the dispatcher and the
simulation runner.
`simulation_runner.ps1` reports follow
[`simulation-report.schema.json`](architecture/schemas/simulation-report.schema.json)
and can be checked directly with
`node architecture/validate_simulation_report.js <report.json>`.
The simulation fixture is also automatically generated and validated by
[`validate_all.ps1`](architecture/validate_all.ps1). Playtest hypotheses
can be checked by
[`validate_playtest_hypothesis.ps1`](architecture/validate_playtest_hypothesis.ps1);
the validator keeps executed observations separate from future hypotheses.
Valid observations can be recorded in the evidence store by
[`record_playtest_observation.ps1`](architecture/record_playtest_observation.ps1);
the record preserves hypothesis, metrics, sample, limitations and provenance
empirical without converting partial collection into conclusion.
[`validate_evidence_store.js`](architecture/validate_evidence_store.js) validates
each JSONL line persisted against `evidence.schema.json`; this check is
run for playtest and simulation stores in the aggregate pipeline.
The file [`web/data.js`](web/data.js) is generated by
[`architecture/generate_web_data.ps1`](architecture/generate_web_data.ps1)
from the registry, handoffs and `SKILL.md`; should not be edited as
primary source.

## Visualization interface

Presentation interface and visual exploration of the project:

**https://jeangoetten.github.io/GD-Skill-Codex/**

### How to use

1. **Explorer:** use search and filters to find a skill by name, type or evidence.
2. **Details:** select a skill to query its lens, outputs and downstream handoffs.
3. **Handoff map:** click on the nodes to track the relationships between skills.
4. **Examples:** open the JSON fixtures to see input models used by the system.
5. **Tutorial:** follow the three illustrated steps to understand the problem flow → World Model → skill → result.

For a quick overview, start with Explorer. To study a concrete analysis, first open one of the examples and then the corresponding skill in Explorer.

## Consolidated project file

[`GD-Skill-Codex.txt`](GD-Skill-Codex.txt) is the single textual distribution of the
project. It contains the full content of all other textual files,
organized by relative path and delimited by markers. The file is regenerated whenever any project file changes; the consolidated file itself is not included as input to prevent recursion.
