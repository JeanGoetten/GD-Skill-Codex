---
name: epistemic-holarchic-progression
description: "Models non-linear narrative structures and purely knowledge-driven progression (ludic epistemology) organized as graphs of informational holons. Use this skill when the user requests: (1) design of non-linear holarchic narrative structures, (2) modeling of information and mystery graphs without physical key locks, (3) definition of autonomous and relational informational holons, or (4) validation of universal accessibility based on player's cognitive discoveries."
metadata:
  domain:
    primary:
      - epistemic progression
      - holarchic knowledge
  activation_signals:
    concepts:
      - clue graph
      - knowledge state
      - revelation pacing
    recognition_references:
      - "Outer Wilds"
      - "Return of the Obra Dinn"
      - "Disco Elysium"
  outputs:
    - knowledge graph
    - progression map
    - uncertainty analysis
  handoffs:
    downstream:
      - cognitive-schema-disruption
      - spatial-topology-and-learning-pacing
      - discrete-state-machine-verification
  exclusions:
    - franchise-specific canon
    - unvalidated claims
---

# Epistemic Holarchic Progression: Layered Knowledge Graphs

## Domain

nested knowledge graphs, clues and revelation.

## Purpose

classify branching, redundancy, convergence, synthesis and optional knowledge.

## Activation Signals

epistemic graph; holon; branching; convergence; synthesis; optional; recognition anchors: Outer Wilds; Return of the Obra Dinn; Disco Elysium.

## Scope

knowledge dependencies and inference paths.

## Exclusions

This skill does not resolve prose authoring. It validates physical routes only as *modeled trajectory requirements* on the graph (Stage 3): checking that every holon location is reachable under the movement rules the user declares. Full physical validation against a concrete movement system — collision, physics, timing, interaction implementations — is out of scope and is the domain of discrete-state-machine-verification (see Handoff Conditions).

## Handoff Conditions

When the problem crosses its boundary, hand off to: cognitive-schema-disruption; spatial-topology-and-learning-pacing; discrete-state-machine-verification.

## Handoff Candidates

- **cognitive-schema-disruption** — when discovered knowledge should reframe prior expectations rather than only unlock content, hand off the schema model for disruption analysis.
- **spatial-topology-and-learning-pacing** — when clue discovery is gated by spatial topology and room sequence, hand off the level graph for topology and pacing analysis.
- **discrete-state-machine-verification** — when knowledge gates become explicit states with transitions, hand off the gated model for reachability analysis.
## Recognition References

These are semantic anchors only, not content to reproduce: Outer Wilds; Return of the Obra Dinn; Disco Elysium.

## Theoretical Context and System Function

This skill formalizes the structure of investigative narrative games through the concept of *Narrative Holarchy* (HS), based on Arthur Koestler's theory of holons. In a pure epistemic progression system, the agent's advancement in the game space is not blocked by physical barriers (keys, inventories, doors locked by experience level or inventory), but strictly by **epistemic blockade** (lack of knowledge about how to interact with the world).

The narrative system is represented by a directed graph of autonomous informational units $G_{\text{epistemic}} = (V_{\text{holons}}, E_{\text{clues}})$, where each vertex $H_i \in V$ is a *holon* (a unit of narrative information simultaneously self-contained and part of the global relational web).

The objective of the agent is to design discovery graphs where the $q_0$ state of the world already physically contains all exits and terminal mechanisms accessible, depending exclusively on the evolution of the player's mental model to be unraveled.

---

## 1. Integrated Processing Protocol

When activating this skill, the agent must sequentially execute the following narrative formalization stages:

### Stage 1: Decomposition into Informational Holons ($H_i$)

1. Identify and fragment the central mystery into atomic units of knowledge $H_i \in V_{\text{holons}}$.
2. Structure the formal attribute tuple of each *holon*:

$$H_i = (\text{Content}_{\text{autonomous}}, \text{Clues}_{\text{outgoing}}, \text{SpatialLocation}, \text{SpecialCondition})$$

- **Autonomous Content:** Narrative information intelligible on its own.
- **Outgoing Clues:** Edges $e \in E_{\text{clues}}$ pointing to coordinates or existence of other *holons* $H_j$.

### Stage 2: Epistemic Graph Mapping ($G = (V, E)$)

1. Build the informational adjacency matrix of graph $G$:

$$A_{ij} = \begin{cases} 1, & \text{if Holon } H_i \text{ contains a direct clue/instruction for understanding Holon } H_j \\ 0, & \text{otherwise} \end{cases}$$

2. Define **Convergence / Terminal Nodes ($H_{\text{terminal}}$)**:
   - Top-level holons containing operational instructions to reach terminal states $F \subset Q$.
3. Classify graph structure explicitly:
   - **Branching** creates multiple knowledge routes from one holon.
   - **Redundancy** repeats equivalent evidence without adding a new inference.
   - **Convergence** brings distinct routes to a shared inference or holon.
   - **Synthesis** requires combining non-equivalent clues to derive a new conclusion.
   - **Optional knowledge** is informative but not required for a valid solution path.
   These categories must not be conflated: a branch can be redundant, and convergence is not automatically synthesis.

### Stage 3: Universal Physical Accessibility Principle ($q_0$)

1. Validate the Physical Accessibility Invariant as a **trajectory-validity** requirement:

$$\forall H_i \in V_{\text{holons}}, \quad \exists \text{ valid trajectory } \tau:q_0\leadsto \text{Location}(H_i) \quad \text{at } t=0$$

2. Verify the trajectory respects movement, hazards, timing, and interaction rules; finite geometric distance alone is insufficient. No knowledge-gated mechanic should prevent a valid trajectory when the player possesses the required operational knowledge.

### Stage 4: Resolution by Cognitive Reconstruction ($C_{\text{reconstruction}}$)

1. The player agent accumulates a subset of known holons $K(t) \subseteq V_{\text{holons}}$ at time $t$.
2. Estimate the **coverage density** of the terminal mechanism's predecessor nodes $In(H_{\text{terminal}})$ by the player's known set:

$$\text{CoverageDensity}(H_{\text{terminal}}) = \frac{\vert{}K(t) \cap In(H_{\text{terminal}})\vert{}}{\vert{}In(H_{\text{terminal}})\vert{}}, \qquad In(H_{\text{terminal}}) \neq \emptyset$$

(when $In(H_{\text{terminal}}) = \emptyset$ the metric is undefined — report `UNDEFINED`, not 0 or 1). **Coverage density is not a probability of inference.** By this skill's own taxonomy, synthesis requires *combining non-equivalent clues*: knowing half of the required predecessors can carry probability ≈ 0 of inferring the solution, while a single sufficient holon can carry probability ≈ 1 at coverage $1/N$. A probabilistic claim requires a declared inference model (e.g., a conjunction of calibrated per-clue probabilities for synthesis nodes) validated by playtesting — see Mathematical Status. Report `CoverageDensity` as a structural readiness indicator and label any inference-probability statement `heuristic` or `empirical`.

---

## 2. Algorithmic Detection of Narrative Design Anomalies

The agent must analyze the narrative graph and flag the following structural errors:

### A. Physical Key Disguised as Information (Pseudo-Holon)

$$\exists H_i \quad \text{such that to access } H_j \text{ an inventory item } I_k \text{ is required instead of knowledge}$$

Action: Identify and reject blockages requiring inventory items or stat counters to allow state transition, violating the pure epistemic progression principle.

### B. Informational Island / Orphan Node ($In(H_i) = \emptyset$)

$$\exists H_i \in V \setminus \{H_{\text{root}}\} \quad \text{such that} \quad \text{InDegree}(H_i) = 0$$

Action: Flag holons **classified as required** (Stage 2 taxonomy) that have no incoming clues pointing to them in the graph, making their discovery dependent on random spatial scanning (*pixel hunting*). Do not flag *optional* knowledge nodes: deliberate unclued discoveries reward exploration and are a canonical pattern of the genre (e.g., Outer Wilds). Report optional unclued holons separately, without the anomaly label.

### C. False Holarchy / Strictly Linear Graph

$$\forall i, \quad \vert{}In(H_i)\vert{} \le 1 \quad \land \quad \vert{}Out(H_i)\vert{} \le 1$$

Action: Alert if the mystery graph is a simple linear sequence ($H_1 \to H_2 \to H_3$), removing the player's non-linear exploration agency.

---

## 3. Standard Analytical Output Format

When responding to the user, the agent must present the specification in the following format:

### 1. Informational Holons Table ($V_{\text{holons}}$)

| Holon ID ($H_i$) | Spatial Location in $q_0$ | Autonomous Information Content | Pointed Holons / Clues ($Out(H_i)$) |
| --- | --- | --- | --- |
| **$H_1$ (Root Holon)** | [Coordinates / Planet A] | [Record of ancestral event] | $H_2, H_3$ |
| **$H_2$ (Intermediate Holon)** | [Coordinates / Planet B] | [Mechanic of natural hazard deflection] | $H_4$ |
| **$H_3$ (Intermediate Holon)** | [Coordinates / Planet C] | [Radio signal frequency] | $H_4$ |
| **$H_4$ (Terminal Holon)** | [Coordinates / Central Core] | [Final mechanism activation instruction] | State $F_{\text{victory}}$ |

### 2. Epistemic Graph Metrics ($G$)

* **Total Number of Holons ($\vert{}V\vert{}$):** [Quantity of knowledge nodes]
* **Average Degree ($\vert{}E\vert{} / \vert{}V\vert{}$):** [Degree of clue interconnection; for cross-graph comparison use classic edge density $\vert{}E\vert{} / (\vert{}V\vert{}(\vert{}V\vert{}-1))$]
* **Solution Path Length (root $\to$ $H_{\text{terminal}}$):** [Minimum number of chained discoveries for the final solution — the directed shortest-path distance from root to terminal, *not* the graph diameter, which is dominated by the longest lateral branch]
* **Branching Degree:** [Percentage of nodes with $\vert{}Out(H_i)\vert{} \ge 2$ — branching is defined by outgoing routes; $\vert{}In(H_i)\vert{} \ge 2$ measures convergence, per the Stage 2 taxonomy]

### 3. Progression Diagnosis and Recommendations

* **Narrative System Status:** [PURE HOLARCHIC / PHYSICAL KEY VIOLATION / TOO LINEAR]
* **Identified Informational Islands:** [List of isolated holons requiring edge $E$ inclusion]
* **Recommended Accessibility Adjustments:** [Removal of hard blockages or insertion of redundant clues]

---

## Mathematical Status

### Formal Guarantees
A knowledge graph proves only modeled prerequisite relations.

### Derived Metrics
Distinguish the physical graph of world entities from the graph of player knowledge; they need not be isomorphic.

### Heuristics and Design Judgments
Derived metrics include clue coverage, uncertainty reduction and reveal latency.

### Required Simulation or Playtesting
Heuristics tune inference and pacing. Required simulation or playtesting: blind inference sessions and alternate-order clue tests.

## Hypotheses and Limitations

- Assumes every intended clue and interaction is represented in the graph; discoverability, accessibility, and player interpretation need separate validation.
- “Accessible” means a valid movement and interaction trajectory, not merely finite geometric distance; claims remain conditional on the modeled rules.

## 4. Procedure Execution Example

If the user requests: *"Create a non-linear narrative structure where the player needs to discover how to enter a magic tower protected by a water shield without using any physical key."*

The agent applying this skill formalizes:

- **State $q_0$:** The magic tower is physically accessible on the map from the first second of the game. The entry mechanism requires the player to throw themselves from the top of a cloud in free fall to cross the water shield by vector pressure.
- **Holon Structuring:**
  - **$H_{\text{tower}}$ (Terminal Node):** Requires knowledge $K = \{\text{DescentVector}, \text{MinimumAltitude}\}$.
  - **$H_1$ (Ruined Library):** Reveals that "the water shield yields only under pressures exceeding $500\text{ kPa}$" ($Out \to H_3$).
  - **$H_2$ (Astronomical Observatory):** Reveals that "upper clouds generate free-fall acceleration sufficient to reach $600\text{ kPa}$" ($Out \to H_3$).
  - **$H_3$ (Synthesis Holon):** Allows player's mental model to combine $H_1 + H_2 \implies$ "I must climb the upper cloud and jump directly onto the tower".
- **Epistemic Validation:** If a veteran player starts a *New Game* and jumps from the cloud immediately without reading $H_1$ and $H_2$, the tower opens normally. Progression was $100\%$ maintained at the player's cognitive level.
