# Skill specification and implementation matrix

This matrix prevents narrative requirements from silently exceeding executable
coverage. “Core” means the principal structural checks are executable; it does
not mean empirical game quality is proven.

| Skill | Executable coverage | Known boundary | Required external validation |
| --- | --- | --- | --- |
| discrete-state-machine-verification | Core + invariant/probability/livelock checks | Simple numeric invariants; path existence is not a winning strategy | Runtime assertions and strategic traces |
| concurrent-gameplay-processes | Bounded Petri-net execution | No global liveness proof for arbitrary nets | Longer traces and model checking |
| procedural-level-constraint-solving | Arc-consistency filtering | AC-3 does not prove a global solution | Search or constructive solver |
| procedural-expressive-range-analysis | Declared-bin occupancy and bias | No geometric valid-space coverage | Independent generator samples |
| resource-flow-economy | Discrete source/sink balance | Surplus is not inflation | Longitudinal economy telemetry |
| macroeconomic-resource-conversion | Conversion and bounded price proxy | Not a market forecast | Supply, demand, velocity, and price series |
| frame-based-combat-timing | Frame windows and loop candidates | Geometry, latency, and escape policies are external | Instrumented combat tests |
| committed-risk-reward-actions | Declared action-contract risks | Player valuation is not inferred | Playtests and spatial simulation |
| emergent-agency-composition | Verb chains and structural anomalies | Synergy utility is context-dependent | Sandbox telemetry |
| spatial-topology-and-learning-pacing | Graph reachability and pacing proxies | Traversability is not physical solvability or learning | Route tests and novice playtests |
| epistemic-holarchic-progression | Knowledge graph and clue coverage | Coverage is not comprehension probability | Recall/inference studies |
| cognitive-schema-disruption | Structural disruption conditions | Surprise and accommodation are unobserved | Controlled player observation |
| competitive-negative-feedback | Gap, damping, oscillation, sandbagging risk | Fairness is not proved | Strategic agents and telemetry |
| exponential-progression-and-prestige | Discrete curves and overflow guards | Retention is not inferred | Cohort progression data |
| nested-gameplay-loop-architecture | Loop hierarchy and cadence proxies | Engagement is not measured | Session telemetry and interviews |
