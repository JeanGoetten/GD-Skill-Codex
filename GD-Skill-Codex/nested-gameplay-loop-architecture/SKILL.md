---
name: nested-gameplay-loop-architecture
description: "Formalizes and designs nested gameplay loop architecture across multiple temporal scales (short, medium, and long term). Use this skill when the user requests: (1) design of continuous engagement and retention structures, (2) staggered alignment of temporal horizons (micro, meso, and macro loops), (3) observation and design of cognitive exit points, or (4) balancing of overlapping objective completions."
metadata:
  domain:
    primary:
      - nested gameplay loops
      - temporal architecture
  activation_signals:
    concepts:
      - short/mid/long loop
      - session structure
      - cognitive exit point
    recognition_references:
      - "Civilization"
      - "Animal Crossing"
      - "Hades"
  outputs:
    - loop map
    - continuity metrics
    - calibration plan
  handoffs:
    downstream:
      - frame-based-combat-timing
      - resource-flow-economy
      - epistemic-holarchic-progression
  exclusions:
    - franchise-specific canon
    - unvalidated claims
---

# Nested Gameplay Loop Architecture: Temporal Loop Alignment

## Domain

micro, meso and macro loops; temporal offsets; expectation horizons.

## Purpose

design staggered loops and measure exit-point opportunities without making retention universal.

## Activation Signals

micro-loop; meso-loop; macro-loop; temporal offset; cognitive exit point; recognition anchors: Civilization; Animal Crossing; Hades.

## Scope

loop durations and cross-loop feedback.

## Exclusions

This skill does not resolve monetization and narrative knowledge graphs.

## Handoff Conditions

When the problem crosses its boundary, hand off to: frame-based-combat-timing; resource-flow-economy; epistemic-holarchic-progression.

## Handoff Candidates

- **frame-based-combat-timing** — when the micro loop decomposes into frame-level action windows, hand off the core action for frame analysis.
- **resource-flow-economy** — when loop rewards are measured in accumulable resources, hand off the reward flows for stock-flow analysis.
- **epistemic-holarchic-progression** — when macro loops deliver information and understanding rather than numeric growth, hand off the knowledge structure for epistemic analysis.
## Recognition References

These are semantic anchors only, not content to reproduce: Civilization; Animal Crossing; Hades.

## Theoretical Context and System Function

This skill formalizes the psychology of action and continuous retention in digital games through the architecture of **Nested Gameplay Loops**. Uninterrupted agent engagement is not achieved by a single operational cycle, but by the staggered overlap of multiple feedback cycles acting at distinct temporal scales:

$$T_{\text{micro}} \ll T_{\text{meso}} \ll T_{\text{macro}}$$

The systemic retention force can derive from **Staggered Temporal Misalignment** ($\Delta t_{\text{offset}} \neq 0$). When a short-term loop reaches its terminal completion state $t_{\text{end, micro}}$, the corresponding medium-term loop may be in an incomplete transitive state (e.g., 70% progress), creating a measurable **Cognitive Exit Point** opportunity or reducing it. An exit point is a metric and design possibility to observe, not a universal problem or objective to eliminate.

The objective of the agent is to design nested task matrices whose expectation horizons are legible and appropriately staggered, while preserving voluntary stopping and allowing intentional exit points.

---

## 1. Integrated Processing Protocol

When activating this skill, the agent must sequentially execute the following analysis and design stages:

### Stage 1: Temporal Loop Triad Decomposition

1. Categorize game actions into three well-defined temporal scales:
   - **Micro-Loop (Short Term / Tactical):**

$$\text{Duration: } T_{\text{micro}} \in [1\text{s}, 60\text{s}] \quad \text{(heuristic reference band)}$$

Focus: Immediate mechanical resolution, unit allocation, instant tactile feedback.
   - **Meso-Loop (Medium Term / Strategic):**

$$\text{Duration: } T_{\text{meso}} \in [2\text{min}, 15\text{min}] \quad \text{(heuristic reference band)}$$

Focus: Building completion, mid-tier technology research, resource production cycles.
   - **Macro-Loop (Long Term / Systemic):**

$$\text{Duration: } T_{\text{macro}} \in [1\text{h}, 20\text{h}+] \quad \text{(heuristic reference band)}$$

Focus: Global victory conditions, cultural/military hegemony, historical era evolution.

These bands are heuristic anchors for session-scale strategy games, not definitions. A project may declare its own scale map (e.g., a roguelike run of 30–60 min acts as a meso-loop; a session-scale builder may run macro-loops inside 10 min) — the requirement is to *declare* the mapping and keep loop ordering strict ($T_{\text{micro}} < T_{\text{meso}} < T_{\text{macro}}$), not to force the default bands.

### Stage 2: Temporal Interleaving Matrix Mapping ($\Delta t_{\text{offset}}$)

1. Distinguish **intentional** from **unintentional** completion coincidence. For every completion boundary, declare whether simultaneous endings are designed (a session hook, a chapter finale) or accidental. Flag as a risk only *unintentional* coincidences — completions landing within an unplanned window:

$$\forall (i, j) \text{ unplanned}, \quad \vert{} t_{\text{completion, meso, i}} - t_{\text{completion, micro, j}} \vert{} \ge \tau_{\text{minimum}}$$

$\tau_{\text{minimum}}$ is a calibrated heuristic with no universal value: default to one micro-loop period and recalibrate per project from observed session traces.

2. Structure progression so that reward received upon completing a Micro-Loop injects resources that directly accelerate progress of a pending Meso-Loop.

### Stage 3: Cognitive Retention Pressure Calculation ($\Pi_{\text{retention}}$)

1. Define Cognitive Retention Pressure $\Pi(t)$ at instant $t$ over a declared measurement window as the sum over **open** loops (initiated and not yet completed; completed loops contribute 0 and exit the sum) weighted by proximity to completion:

$$\Pi(t) = \sum_{k \in \text{OpenLoops}(t)} w_k \cdot \left( 1 - \frac{t_{\text{remaining}, k}}{T_k} \right) \quad \text{with } \textstyle\sum_{k \in \text{OpenLoops}(t)} w_k = 1$$

where $w_k$ is the strategic relevance of loop $k$; weights are normalized so that $\Pi \in [0, 1]$ and is comparable across projects.
2. $\Pi(t)$ is a descriptive calibration heuristic, not a target: a floor such as $\Pi(t) > 0.40$ only makes sense per project, calibrated against observed session traces. The concept draws on the open-task/Zeigarnik literature (Zeigarnik, 1927), but the threshold itself has no validated empirical grounding and must never be used to manufacture engagement against voluntary stopping.

### Stage 4: Cross-Loop Feedback (Top-Down and Bottom-Up)

1. **Bottom-Up Flow (Micro $\to$ Macro):** Successful execution of micro-actions provides incremental inputs $\Delta R$ to feed the macro-objective progress bar.
2. **Top-Down Flow (Macro $\to$ Micro):** Completion of a macro-objective unlocks new tools, skills, or operational action types in the micro-loop.

---

## 2. Algorithmic Detection of Design Anomalies

The agent must analyze the loop plan and flag the following structural failures:

### A. Unintentional Synchronization of Exit Points (*Aligned Exit Points*)

$$\exists t_{\text{static}} \quad \text{such that} \quad t_{\text{end, micro}} = t_{\text{end, meso}} = t_{\text{end, macro}}$$

Action: Flag when multiple goal cycles end simultaneously *without declared design intent* (per Stage 2). An accidental all-levels coincidence creates a goal vacuum that invites the player to end the session. Deliberate alignment — a chapter finale, a session-shaped cadence — is a legitimate design tool and must be reported as "intentional synchronization", not flagged as failure.

### B. Sterile Micro-Loop Without Systemic Impact

$$\frac{\partial P_{\text{macro}}}{\partial A_{\text{micro}}} = 0$$

Action: Identify when short-term actions do not contribute to advancement of medium and long-term strategic objectives, making the micro-loop repetitive and uninteresting.

### C. Macro Barrier Without Granular Progress (*Feedback Drought*)

$$T_{\text{meso}} \text{ reaching } 15\text{ min or beyond} \quad \text{without intermediate rewards in Micro-Loop}$$

Action: Alert about strategic objectives that exceed the meso band (drifting toward macro scale) while requiring long passive waits without granting intermediate advancement milestones.

---

## 3. Standard Analytical Output Format

When responding to the user, the agent must structure the specification in the following format:

### 1. Nested Loop Matrix Hierarchy

| Loop Level | Temporal Scale ($T$) | Core Action / Mechanic | Generated Input | Destination Loop for Input |
| --- | --- | --- | --- | --- |
| **Micro-Loop** | $[1\text{s} - 60\text{s}]$ (heuristic range) | [Move unit / Collect node] | Production Points ($\Delta P$) | Meso-Loop (Construction) |
| **Meso-Loop** | $[2\text{min} - 15\text{min}]$ (heuristic range) | [Build Building / Research] | Capacity / Global Bonus | Macro-Loop (Victory Condition) |
| **Macro-Loop** | $[1\text{h} - 20\text{h}+]$ (heuristic range) | [Conquer Region / Era] | Tech Unlock | Micro-Loop (New Actions) |

### 2. Temporal Interleaving Analysis and Retention Curve

* **Micro Completion Frequency:** [Actions per minute]
* **Average Completion Offset ($\Delta t_{\text{offset}}$):** [Temporal difference between meso and micro completions]
* **Cognitive Pressure Index ($\Pi(t)$):** [Level of constant goal tension maintained]

### 3. Diagnosis and Recommended Retention Adjustments

* **Loop Status:** [ENGAGING / EXIT POINT RISK / EXCESSIVE RETENTION]
* **Identified Alignment Points:** [Instants where loops coincide in completion]
* **Suggested Parameter Adjustments:** [Changes to build times, research, or costs to stagger deadlines]

---

## Mathematical Status

### Formal Guarantees
Loop nesting can guarantee schedule relationships in the model, not engagement.

### Derived Metrics
Derived metrics include completion, re-entry, abandonment and transition latency, computable from session traces.

### Heuristics and Design Judgments
Continuity and exit metrics are descriptive and calibratable, not universal targets.

### Required Simulation or Playtesting
Heuristics tune cadence. Required simulation or playtesting: session traces, interruption tests and calibrated telemetry.

## Hypotheses and Limitations

- Assumes loop durations and completion events are measurable and that overlapping objectives are meaningful to the player.
- The Zeigarnik effect (1927) motivates open-task tension, but retention pressure as constructed here is a design metric, not a validated psychological quantity; compulsion-oriented uses of loop nesting are documented as dark patterns (Zagal, Björk & Lewis, 2013).
- Retention-pressure thresholds are conditional design hypotheses; protect voluntary stopping and validate through ethical playtesting.

## 4. Procedure Execution Example

If the user requests: *"Design the loop nesting for a turn-based space management game."*

The agent applying this skill formalizes:

- **Declared scale map (project remapping of the heuristic bands):** this is a session-scale builder, so the project remaps the bands: **Micro-Loop ($T_{\text{micro}} = 1\text{ turn / 10s}$):** move fleet, order planet exploration, allocate worker. **Meso-Loop ($T_{\text{meso}} = 5\text{ turns / 50s}$):** completion of space module or planetary mine. **Macro-Loop ($T_{\text{macro}} = 40\text{ turns / 6.6min}$):** complete colonization of a star system. The strict ordering $T_{\text{micro}} < T_{\text{meso}} < T_{\text{macro}}$ holds; the absolute durations deviate from the default bands by declared design intent.
- **Completion boundary intents:** the coincidence of the Meso-Loop $A$ completion with the micro completion cadence on Turn 5 is **intentional** (a declared hook), so the $\tau_{\text{minimum}}$ unplanned-coincidence check does not apply to it.
- **Temporal Misalignment Calculation ($\Delta t_{\text{offset}}$):**
  - On Turn 5, player completes Meso-Loop $A$ (Planetary Mine).
  - Newly completed Mine grants +50 metal alloy immediately.
  - This resource allows starting a new Meso-Loop $B$ (Colony Ship) on same Turn 5, taking 8 turns to complete (Turn 13).
  - Simultaneously, Macro-Loop (Star System) will be at 30% completion on Turn 5 and 80% on Turn 13.

- **Result:** On Turn 5 (completion of $A$), player is hooked by immediate opportunity to start $B$, which will carry them to Turn 13, when Macro-Loop will be nearly ready (Turn 15). The cognitive exit point is shifted into the future; whether that is desirable depends on design intent and must respect voluntary stopping — observe actual exit behavior in playtests instead of treating delayed exit as a success metric.
