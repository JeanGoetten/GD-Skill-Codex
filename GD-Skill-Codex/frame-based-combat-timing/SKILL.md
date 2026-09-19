---
name: frame-based-combat-timing
description: Models deterministic high-frame-rate decision trees, cancel windows, and command priorities in combat systems. Use this skill when the user requests: (1) design or balancing of frame data tables, (2) formalization of action temporal phases (Startup, Active, Recovery), (3) calculation of frame advantages on hit or block (hit advantage / block advantage), or (4) algorithmic resolution of cancel windows and collision priorities (hit priority/trades).
domain:
  primary:
    - combat timing
    - discrete frames
activation_signals:
  concepts:
    - startup, active, recovery
    - cancel windows
    - input latency
  recognition_references:
    - "Street Fighter"
    - "Devil May Cry"
    - "Super Smash Bros."
outputs:
  - frame timeline
  - effective-window table
  - timing recommendations
handoffs:
  downstream:
    - discrete-state-machine-verification
    - committed-risk-reward-actions
    - concurrent-gameplay-processes
exclusions:
  - franchise-specific canon
  - unvalidated claims
---

# Frame-Based Combat Timing: Discrete Timing Trees

## Domain

startup, active, recovery, hitstop and cancel windows.

## Purpose

validate combat timing trees, interrupts, links and terminal recovery.

## Activation Signals

startup; active; recovery; hitstop; cancel; link; invulnerability; recognition anchors: Street Fighter; Devil May Cry; Super Smash Bros.

## Scope

discrete timing legality and combo termination.

## Exclusions

This skill does not resolve macro progression and spatial layout.

## Handoff Conditions

When the problem crosses its boundary, hand off to: discrete-state-machine-verification; committed-risk-reward-actions; concurrent-gameplay-processes.

## Handoff Candidates

- **discrete-state-machine-verification** — when the frame system abstracts into discrete states and legality transitions, hand off the state model for reachability and invariant analysis.
- **committed-risk-reward-actions** — when the relevant question is cost, exposure and reversibility of an action rather than frame legality, hand off the contract for risk-reward analysis.
- **concurrent-gameplay-processes** — when multiple timed processes (projectiles, buffs, recovery) interact causally, hand off the interaction graph for Petri-net analysis.
## Recognition References

These are semantic anchors only, not content to reproduce: Street Fighter; Devil May Cry; Super Smash Bros.

## Theoretical Context and System Function

This skill formalizes combat mechanics and high-frequency actions in a discrete frame-oriented time domain, where the tick rate is fixed at $f_{\text{tick}}$ (e.g., 60 Hz, where 1 frame $\approx 16.67\text{ ms}$).

Each action $a \in A$ executed by an agent is decomposed into a temporally constrained finite state machine, whose total duration $T(a)$ in frames is given by the invariant sum:

$$T(a) = T_{\text{startup}} + T_{\text{active}} + T_{\text{recovery}}$$

The objective of the agent is to model combat determinism under explicit tick, ordering, and latency assumptions, calculate reaction-time advantage/disadvantage windows, and structure the grammar of state cancellations.

---

## 1. Integrated Processing Protocol

When activating this skill, the agent must sequentially execute the following temporal formalization steps:

### Stage 1: Tripartite Frame Data Decomposition

For each action $a$, formalize the three operational phases:

1. **Startup Phase ($T_{\text{startup}}$):** Interval $t \in [1, T_{\text{startup}}]$ where agent state transitions from *Idle/Input* to action preparation. No offensive collision box (*Hitbox*) is active. Interruption by impact applies *Counter-Hit* state.
2. **Active Phase ($T_{\text{active}}$):** Interval $t \in [T_{\text{startup}} + 1, T_{\text{startup}} + T_{\text{active}}]$ where the offensive *Hitbox* is instantiated in space. If intersection with target's vulnerability box (*Hurtbox*) occurs, impact event is triggered.
3. **Recovery Phase ($T_{\text{recovery}}$):** Interval $t \in [T_{\text{startup}} + T_{\text{active}} + 1, T(a)]$ where *Hitbox* is deactivated and agent remains unable to accept new standard commands until end of $T(a)$.

### Stage 2: Frame-by-Frame Advantage Calculation ($\Delta_{\text{frame}}$)

When an impact occurs at frame $t_{\text{hit}} \in T_{\text{active}}$, the target enters a temporal incapacitation state (*Stun*).

1. **Hit Advantage ($\Delta_{\text{hit}}$):**

$$\Delta_{\text{hit}} = \text{Stun}_{\text{hit}} - (T(a) - t_{\text{hit}})$$

- If $\Delta_{\text{hit}} > 0$, attacker regains agency $\Delta_{\text{hit}}$ frames before target (Advantage / *Plus on Hit*).
- If $\Delta_{\text{hit}} < 0$, attacker is vulnerable to guaranteed counter-attacks (*Punish*).

2. **Block Advantage ($\Delta_{\text{block}}$):**

$$\Delta_{\text{block}} = \text{Stun}_{\text{block}} - (T(a) - t_{\text{hit}})$$

### Stage 3: Cancellation Matrix and Transition Windows ($W_{\text{cancel}}$)

1. Define the subset of cancellable frames $W_{\text{cancel}} \subseteq [1, T(a)]$.
2. If an input $\sigma \in \Sigma$ is validated during $W_{\text{cancel}}$, the state transition interrupts $T(a)$ immediately at current frame $t$, initiating the $T_{\text{startup}}$ phase of the next action $a_{\text{next}}$.
3. Classify cancellation type:
   - **Special Cancel:** Interruption of $T_{\text{active}}$ phase or start of $T_{\text{recovery}}$ by a special move.
   - **Chain/Target Combo:** Interruption by a predefined sequence of light commands.
   - **Dash/Super Cancel:** Consumption of secondary resource to cancel $T_{\text{recovery}}$.

### Stage 4: Algorithmic Resolution of Simultaneous Collision (*Trades*)

If two *Hitboxes* from distinct agents collide on the same instantaneous frame $t$, apply the **Impact Priority Function ($P(a)$)**:

$$\text{Result} = \begin{cases} \text{Victory for } a_1, & \text{if } P(a_1) > P(a_2) \\ \text{Victory for } a_2, & \text{if } P(a_2) > P(a_1) \\ \text{Mutual Impact (Trade)}, & \text{if } P(a_1) = P(a_2) \end{cases}$$

---

## 2. Algorithmic Detection of Balancing Anomalies

The agent must analyze the action vector and flag the following design risks:

### A. Unintentional Infinite Combo Detection (*Infinite Links*)

$$\exists a_1, a_2 \in A \quad \text{such that} \quad \Delta_{\text{hit}}(a_1) \ge T_{\text{startup}}(a_2)$$

Action: If hit advantage of $a_1$ is greater than or equal to startup of $a_2$ (and $a_1$ can be repeated infinitely), flag an unblockable infinite combo.

### B. Absolute Safe Block Traps (*Safe Jumps / True Blockstrings*)

$$\Delta_{\text{block}}(a_1) + T_{\text{startup}}(a_2) \le 0 \quad \text{without interruption windows}$$

Action: Verify if the action combination prevents any defensive decision-making by the target.

### C. Unpunishable High-Reward Moves

$$\Delta_{\text{block}}(a) \ge -T_{\text{startup, min}}(A)$$

Action: Identify high-damage moves whose block disadvantages are smaller than the fastest response action in the system.

---

## 3. Standard Analytical Output Format

When responding to the user, the agent must present data in the following structure:

### 1. Action Frame Data Table ($a$)

| Temporal Parameter | Value in Frames | Real Time ($f_{\text{tick}} = 60\text{ Hz}$) |
| --- | --- | --- |
| **Startup ($T_{\text{startup}}$)** | [X frames] | [X * 16.67 ms] |
| **Active ($T_{\text{active}}$)** | [Y frames] | [Y * 16.67 ms] |
| **Recovery ($T_{\text{recovery}}$)** | [Z frames] | [Z * 16.67 ms] |
| **Total Duration ($T(a)$)** | [X+Y+Z frames] | [(X+Y+Z) * 16.67 ms] |
| **Hit Stun ($\text{Stun}_{\text{hit}}$)** | [H frames] | [H * 16.67 ms] |
| **Block Stun ($\text{Stun}_{\text{block}}$)** | [B frames] | [B * 16.67 ms] |

### 2. Advantage and Punishment Calculation

* **Hit Advantage ($\Delta_{\text{hit}}$):** [Numerical value: $+N$ or $-N$ frames]
* **Block Advantage ($\Delta_{\text{block}}$):** [Numerical value: $+N$ or $-N$ frames]
* **Safety Status on Block:** [SAFE / PUNISHABLE by moves with startup $\le N$ frames]

### 3. Cancellation Grammar and Priority

* **Cancellation Window ($W_{\text{cancel}}$):** [Frames where cancellations are accepted]
* **Allowed Cancellable Actions:** [List of valid transitions]
* **Priority Level ($P(a)$):** [Light / Medium / Heavy / Special / Invincible]

---

## Mathematical Status

### Formal Guarantees
Frames are discrete indices.

### Derived Metrics
The effective window is W_eff = W - (displacement + reaction + execution + latency), bounded below by zero.

### Heuristics and Design Judgments
Guarantees cover declared frame order and cancellation legality, not readability or fairness.

### Required Simulation or Playtesting
Derived metrics include startup, active, recovery, buffer and hit-confirm windows. Heuristics tune affordance and forgiveness. Required simulation or playtesting: latency sweeps, reaction-time cohorts and adversarial cancel tests.

## Hypotheses and Limitations

- Assumes a fixed tick rate, deterministic collision ordering, and explicitly measured hit/block stun; network delay and animation interpolation can alter observed outcomes.
- Treat anomaly checks as conditional risks requiring playtest or trace data, not guarantees.

## 4. Procedure Execution Example

If the user provides the specification: *"Heavy Attack: 10 frame startup, active for 4 frames, 18 frame recovery. Gives 25 frames of stun on hit and 15 on block. Impact occurs on 1st active frame."*

The agent applying this skill calculates:

- $T_{\text{startup}} = 10$, $T_{\text{active}} = 4$, $T_{\text{recovery}} = 18 \implies T(a) = 32\text{ frames}$.
- Impact at $t_{\text{hit}} = 11$ (1st active frame).
- Frames remaining post-impact = $T(a) - t_{\text{hit}} = 32 - 11 = 21\text{ frames}$.
- $\Delta_{\text{hit}} = 25 - 21 = +4\text{ frames}$ (Hit Advantage).
- $\Delta_{\text{block}} = 15 - 21 = -6\text{ frames}$ (Block Disadvantage: punishable by any move with $T_{\text{startup}} \le 6\text{ frames}$).