---
name: spatial-topology-and-learning-pacing
description: Models spatial topology of levels and learning pacing based on progressive introduction of atomic mechanics and concept isolation. Use this skill when the user requests: (1) structuring of learning curve and skill introduction without explicit tutorials, (2) design of rooms/encounters with isolation of ludic variables, (3) analysis of spatial pacing and tension in level architecture, or (4) topological chaining of combinatorial challenges.
domain:
  primary:
    - spatial topology
    - learning pacing
activation_signals:
  concepts:
    - graph topology
    - branching
    - implicit teaching
  recognition_references:
    - spatial-topology-and-learning-pacing
outputs:
  - topology graph
  - pacing metrics
  - route recommendations
handoffs:
  downstream:
    - procedural-level-constraint-solving
    - epistemic-holarchic-progression
    - nested-gameplay-loop-architecture
exclusions:
  - franchise-specific canon
  - unvalidated claims
---

# Spatial Topology and Learning Pacing: Navigation as Implicit Teaching

## Domain

level graphs, affordances, gates and spatial rhythm.

## Purpose

sequence capabilities, risk, recovery and implicit teaching through topology.

## Activation Signals

topology; affordance; landmark; shortcut; capability test; recognition anchors: Metroid; Portal; Dark Souls.

## Scope

routes, locks, backtracking and teaching metrics.

## Exclusions

This skill does not resolve CSP solving, combat timing and economy tuning.

## Handoff Conditions

When the problem crosses its boundary, hand off to: procedural-level-constraint-solving; procedural-expressive-range-analysis; committed-risk-reward-actions.

## Handoff Candidates

- **procedural-level-constraint-solving** — encaminhar quando o problema exigir sua interface específica.
- **epistemic-holarchic-progression** — encaminhar quando o problema exigir sua interface específica.
- **nested-gameplay-loop-architecture** — encaminhar quando o problema exigir sua interface específica.

## Recognition References

These are semantic anchors only, not content to reproduce: Metroid; Portal; Dark Souls.

## Theoretical Context and System Function

This skill formalizes level architecture and spatial topology of digital games as an implicit pedagogical system. Instead of relying on intrusive textual instructions, level progression is structured to guide the agent's mental model through isolation of atomic mechanics, variation of environmental parameters, and progressive combination of verbs.

The level topology is modeled as a directed graph of spaces $G_{\text{level}} = (V_{\text{rooms}}, E_{\text{portals}})$, where each vertex $v \in V$ imposes a mechanical capability challenge and each edge $e \in E$ represents a transition validated by an execution test.

The objective of the agent is to design topological sequences that maximize player learning, eliminating spatial noise and controlling the tension curve along the world geometry.

---

## 1. Integrated Processing Protocol

When activating this skill, the agent must sequentially execute the following topological analysis stages:

### Stage 1: Atomic Mechanic Isolation ($M_{\text{atomic}}$)

1. Identify the primary skill or mechanic $M_k$ to be taught in the level segment.
2. Build the **Strict Isolation Environment ($V_{\text{isolated}}$)**:
   - Remove all secondary risk variables (enemies, instant-death hazards, time limits).
   - Guarantee that the only available interactivity allowing level state transition is the correct execution of mechanic $M_k$.

### Stage 2: Teaching Tetralogy Structuring (Encounter Arc)

For each new mechanic $M_k$, organize the topological sequence of rooms in 4 distinct phases:

1. **Introduction / Revelation ($V_1$ - Introduce):**
   - Safe space with no death risk. Geometry forces agent to use $M_k$ to advance (e.g., a high wall blocks the path, requiring invocation of jump mechanic).

2. **Development / Retention Test ($V_2$ - Develop):**
   - Reapplication of $M_k$ in geometry adding mild consequences for failure (e.g., error doesn't kill, but requires retracing the path).

3. **Variation / Complication ($V_3$ - Twist):**
   - Alteration of environmental variables during $M_k$ execution (e.g., mechanic must be executed on a moving platform or under altered gravity).

4. **Mastery / Integration ($V_4$ - Test/Combine):**
   - Complex space requiring execution of mechanic $M_k$ in sequential or simultaneous combination with previously mastered mechanics $M_0, M_1, \dots, M_{k-1}$.

### Stage 3: Spatial Tension Mapping ($T_{\text{spatial}}$)

1. Assign a continuous tension value $T(v) \in [0.0, 1.0]$ to each level room $v \in V_{\text{rooms}}$ based on risk presence, time limit, and combinatorial complexity.
2. Calculate discrete derivative of tension between consecutive rooms $\Delta T = T(v_{i+1}) - T(v_i)$.
3. Guarantee existence of **Decompression / Rest Rooms ($T(v) \le 0.20$)** immediately after tension peaks ($T(v) \ge 0.80$) to allow cognitive assimilation.

---

## 2. Algorithmic Detection of Level Design Anomalies

The agent must analyze the topological sequence and flag the following pacing errors:

### A. Cognitive Load Spike / Lack of Isolation

$$V_1(M_k) \quad \text{simultaneously contains } M_{k+1} \quad \lor \quad \text{DeathRisk} = \text{True}$$

Action: Identify if a level introduces a new mechanic in a high-risk environment or polluted by multiple simultaneous elements, preventing learning through safe experimentation.

### B. Tension Plateau / Spatial Exhaustion

$$\forall i \in [1 \dots k], \quad T(v_i) \ge 0.80 \quad \text{without decompression rooms}$$

Action: Flag prolonged high-risk sequences without rest intervals, leading to player fatigue and increase in unintentional errors.

### C. Topological Prerequisite Break

$$\text{Room } V_{\text{combination}}(M_1, M_2) \quad \text{topologically precedes } V_{\text{introduction}}(M_2)$$

Action: Alert if the map requires combined use of mechanics before player has passed through isolated introduction phase of each.

---

## 3. Standard Analytical Output Format

When responding to the user, the agent must structure the analysis in the following format:

### 1. Topological Progression Arc of Mechanic ($M_k$)

| Topology Phase | Room / Vertex ($V_i$) | Geometry and Spatial Constraints | Tension Level ($T$) | Death Risk |
| --- | --- | --- | --- | --- |
| **1. Introduce** | $V_1$ | Safe environments without hazards; single path requires $M_k$ | $0.10$ | None |
| **2. Develop** | $V_2$ | Insertion of small obstacles without lethality | $0.35$ | Low |
| **3. Twist** | $V_3$ | Addition of environmental modifier to mechanic $M_k$ | $0.65$ | Medium |
| **4. Combine** | $V_4$ | Integration of $M_k$ with previous mechanics | $0.90$ | High |

### 2. Pacing Profile and Spatial Tension Curve

* **Level Peak Tension ($T_{\text{peak}}$):** [Numerical value in Combine phase]
* **Presence of Decompression Rooms:** [Yes / No - Topological location]
* **Learning Curve Analysis:** [CONTINUOUS / ABRUPT / CHAOTIC]

### 3. Diagnosis and Recommended Geometric Adjustments

* **Level Design Status:** [CORRECT / LEARNING NOISE / INADEQUATE DIFFICULTY SPIKE]
* **Spatial Pollution Points:** [Identification of elements to remove in introduction rooms]
* **Suggested Modifications:** [Reordering of rooms in graph $G_{\text{level}}$ or insertion of rest zones]

---

## Mathematical Status

### Formal Guarantees
Graph metrics guarantee properties of modeled topology, not discoverability or learning.

### Derived Metrics
Derived metrics include branching factor, path length, revisit rate and teaching interval.

### Heuristics and Design Judgments
Heuristics assess affordance and cognitive load.

### Required Simulation or Playtesting
Required simulation or playtesting: route traces, novice navigation and accessibility review.

## Hypotheses and Limitations

- Assumes tension and mechanic requirements can be operationalized per room; player familiarity and accessibility needs may vary.
- Pacing flags identify conditional cognitive-load risks, not universal thresholds.

## 4. Procedure Execution Example

If the user requests: *"Design the pacing of a level introducing 'Inverted Gravity' mechanic in a 2D platformer."*

The agent applying this skill formalizes:

- **Atomic Mechanic ($M_{\text{gravity}}$):** Alters avatar gravity vector from $\vec{g} = (0, -g)$ to $\vec{g} = (0, +g)$.
- **Topological Sequence:**
  1. **Room $V_1$ (Introduce):** Enclosed corridor with button on ceiling. No bottom edge or spikes. Player presses button, gravity inverts, walks on ceiling to exit door. Tension $T = 0.10$.
  2. **Room $V_2$ (Develop):** Vertical shaft. Player must alternate gravity to climb by jumping between ceiling and floor. If timing is wrong, falls to floor without damage and retries. Tension $T = 0.35$.
  3. **Room $V_3$ (Twist):** Gravity inversion must be performed mid-horizontal jump over an abyss. Tension $T = 0.65$.
  4. **Room $V_4$ (Combine):** Player must invert gravity while dodging projectiles and invoking previously learned dash mechanic ($M_{\text{dash}}$) from previous level. Tension $T = 0.90$.
  5. **Room $V_5$ (Rest):** Small room with reward, no enemies or obstacles, gravity normalized. Tension $T = 0.10$.