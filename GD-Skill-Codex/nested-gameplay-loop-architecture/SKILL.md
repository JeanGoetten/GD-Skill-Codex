---
name: nested-gameplay-loop-architecture
description: Formalizes and designs nested gameplay loop architecture across multiple temporal scales (short, medium, and long term). Use this skill when the user requests: (1) design of continuous engagement and retention structures, (2) staggered alignment of temporal horizons (micro, meso, and macro loops), (3) elimination of cognitive exit points, or (4) balancing of overlapping objective completions.
domain:
  primary:
    - nested gameplay loops
    - temporal architecture
activation_signals:
  concepts:
    - short/mid/long loop
    - continuity
    - exit point
  recognition_references:
    - nested-gameplay-loop-architecture
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

When the problem crosses its boundary, hand off to: frame-based-combat-timing; exponential-progression-and-prestige; spatial-topology-and-learning-pacing.

## Handoff Candidates

- **frame-based-combat-timing** — encaminhar quando o problema exigir sua interface específica.
- **resource-flow-economy** — encaminhar quando o problema exigir sua interface específica.
- **epistemic-holarchic-progression** — encaminhar quando o problema exigir sua interface específica.

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

$$\text{Duration: } T_{\text{micro}} \in [1\text{s}, 60\text{s}]$$

Focus: Immediate mechanical resolution, unit allocation, instant tactile feedback.
   - **Meso-Loop (Medium Term / Strategic):**

$$\text{Duration: } T_{\text{meso}} \in [2\text{min}, 15\text{min}]$$

Focus: Building completion, mid-tier technology research, resource production cycles.
   - **Macro-Loop (Long Term / Systemic):**

$$\text{Duration: } T_{\text{macro}} \in [1\text{h}, 20\text{h}+]$$

Focus: Global victory conditions, cultural/military hegemony, historical era evolution.

### Stage 2: Temporal Interleaving Matrix Mapping ($\Delta t_{\text{offset}}$)

1. Ensure task completion times do not coincide on the same temporal frame $t$:

$$\forall (i, j), \quad \vert{} t_{\text{completion, meso, i}} - t_{\text{completion, micro, j}} \vert{} \ge \tau_{\text{minimum}}$$

2. Structure progression so that reward received upon completing a Micro-Loop injects resources that directly accelerate progress of a pending Meso-Loop.

### Stage 3: Cognitive Retention Pressure Calculation ($\Pi_{\text{retention}}$)

1. Define Cognitive Retention Pressure $\Pi(t)$ at instant $t$ as the sum of initiated but uncompleted tasks weighted by proximity to completion:

$$\Pi(t) = \sum_{k \in \text{Loops}} w_k \cdot \left( 1 - \frac{t_{\text{remaining}, k}}{T_k} \right)$$

where $w_k$ is the strategic relevance of loop $k$.
2. Maintain $\Pi(t) > 0.40$ throughout the session to avoid cognitive exit points.

### Stage 4: Cross-Loop Feedback (Top-Down and Bottom-Up)

1. **Bottom-Up Flow (Micro $\to$ Macro):** Successful execution of micro-actions provides incremental inputs $\Delta R$ to feed the macro-objective progress bar.
2. **Top-Down Flow (Macro $\to$ Micro):** Completion of a macro-objective unlocks new tools, skills, or operational action types in the micro-loop.

---

## 2. Algorithmic Detection of Design Anomalies

The agent must analyze the loop plan and flag the following structural failures:

### A. Destructive Synchronization of Exit Points (*Aligned Exit Points*)

$$\exists t_{\text{static}} \quad \text{such that} \quad t_{\text{end, micro}} = t_{\text{end, meso}} = t_{\text{end, macro}}$$

Action: Flag when multiple goal cycles end simultaneously at the same instant. This creates a goal vacuum signaling the ideal moment for the player to end the session.

### B. Sterile Micro-Loop Without Systemic Impact

$$\frac{\partial P_{\text{macro}}}{\partial A_{\text{micro}}} = 0$$

Action: Identify when short-term actions do not contribute to advancement of medium and long-term strategic objectives, making the micro-loop repetitive and uninteresting.

### C. Macro Barrier Without Granular Progress (*Feedback Drought*)

$$T_{\text{meso}} \gg 30\text{ min} \quad \text{without intermediate rewards in Micro-Loop}$$

Action: Alert about strategic objectives requiring long periods of passive waiting without granting intermediate advancement milestones.

---

## 3. Standard Analytical Output Format

When responding to the user, the agent must structure the specification in the following format:

### 1. Nested Loop Matrix Hierarchy

| Loop Level | Temporal Scale ($T$) | Core Action / Mechanic | Generated Input | Destination Loop for Input |
| --- | --- | --- | --- | --- |
| **Micro-Loop** | $[1\text{s} - 30\text{s}]$ (heuristic range) | [Move unit / Collect node] | Production Points ($\Delta P$) | Meso-Loop (Construction) |
| **Meso-Loop** | $[3\text{min} - 10\text{min}]$ (heuristic range) | [Build Building / Research] | Capacity / Global Bonus | Macro-Loop (Victory Condition) |
| **Macro-Loop** | $[2\text{h} - 10\text{h}]$ (heuristic range) | [Conquer Region / Era] | Tech Unlock | Micro-Loop (New Actions) |

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
Continuity and exit metrics are descriptive and calibratable, not universal targets.

### Heuristics and Design Judgments
Derived metrics include completion, re-entry, abandonment and transition latency.

### Required Simulation or Playtesting
Heuristics tune cadence. Required simulation or playtesting: session traces, interruption tests and calibrated telemetry.

## Hypotheses and Limitations

- Assumes loop durations and completion events are measurable and that overlapping objectives are meaningful to the player.
- Retention-pressure thresholds are conditional design hypotheses; protect voluntary stopping and validate through ethical playtesting.

## 4. Procedure Execution Example

If the user requests: *"Design the loop nesting for a turn-based space management game."*

The agent applying this skill formalizes:

- **Micro-Loop ($T_{\text{micro}} = 1\text{ turn / 10s}$):** Move fleet, order planet exploration, allocate worker.
- **Meso-Loop ($T_{\text{meso}} = 5\text{ turns / 50s}$):** Completion of space module or planetary mine.
- **Macro-Loop ($T_{\text{macro}} = 40\text{ turns / 6.6min}$):** Complete colonization of a star system.
- **Temporal Misalignment Calculation ($\Delta t_{\text{offset}}$):**
  - On Turn 5, player completes Meso-Loop $A$ (Planetary Mine).
  - Newly completed Mine grants +50 metal alloy immediately.
  - This resource allows starting a new Meso-Loop $B$ (Colony Ship) on same Turn 5, taking 8 turns to complete (Turn 13).
  - Simultaneously, Macro-Loop (Star System) will be at 30% completion on Turn 5 and 80% on Turn 13.

- **Result:** On Turn 5 (completion of $A$), player is hooked by immediate opportunity to start $B$, which will carry them to Turn 13, when Macro-Loop will be nearly ready (Turn 15). The cognitive exit point is systematically pushed into the future.