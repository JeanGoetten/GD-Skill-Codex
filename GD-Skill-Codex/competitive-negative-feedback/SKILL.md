---
name: competitive-negative-feedback
description: "Formulates negative feedback loop mechanisms for damping and competition self-regulation in interactive games. Use this skill when the user requests: (1) design of performance equalization dynamics between agents, (2) creation of conditional probability tables for resources based on position/ranking, (3) damping of absolute leads via systemic drag or dynamic handicaps, or (4) prevention of early elimination of disadvantaged players while maintaining ludic balance."
metadata:
  domain:
    primary:
      - competitive balancing
      - negative feedback
  activation_signals:
    concepts:
      - rubber banding
      - catch-up mechanics
      - sandbagging
      - dynamic handicap
    recognition_references:
      - "Mario Kart"
      - "League of Legends"
      - "Rocket League"
  outputs:
    - feedback model
    - stability analysis
    - anti-exploit recommendations
  handoffs:
    downstream:
      - resource-flow-economy
      - exponential-progression-and-prestige
      - concurrent-gameplay-processes
  exclusions:
    - franchise-specific canon
    - unvalidated claims
---

# Competitive Negative Feedback: Catch-Up and Damping

## Domain

catch-up, damping, leads, variance and stability.

## Purpose

reduce runaway leads while preserving agency, skill expression and readable fairness.

## Activation Signals

negative feedback; damping; catch-up; lead; variance; stability; recognition anchors: Mario Kart; League of Legends; Rocket League.

## Scope

competitive adjustment functions and thresholds.

## Exclusions

This skill does not resolve matchmaking policy and solo economy.

## Handoff Conditions

When the problem crosses its boundary, hand off to: resource-flow-economy; exponential-progression-and-prestige; concurrent-gameplay-processes.

## Handoff Candidates

- **resource-flow-economy** — when the catch-up mechanism works by granting or draining transferable resources, hand off the stock-flow model for balance analysis.
- **exponential-progression-and-prestige** — when damping acts on progression rates or level gaps rather than in-match performance, hand off the curve family for trajectory analysis.
- **concurrent-gameplay-processes** — when several compensating processes run in parallel and may interleave or deadlock, hand off the process interaction for Petri-net analysis.
## Recognition References

These are semantic anchors only, not content to reproduce: Mario Kart; League of Legends; Rocket League.

## Theoretical Context and System Function

This skill formalizes equalization and stabilization dynamics of competitive ludic systems through negative feedback loops. While positive feedback accelerates divergence between agents, negative feedback imposes opposing forces proportional to the deviation from the desired equilibrium state.

The rate of change of an agent's performance gap relative to the group is described by the damping differential equation over the continuous gap $g_i$ (distance, time or score difference to the reference agent, typically the pack median):

$$\frac{d g_i}{dt} = u_{\text{base},i} - k \cdot g_i$$

where $g_i$ is the continuous performance gap of agent $i$, $u_{\text{base},i}$ is the agent's uncompensated performance rate, and $k > 0$ is the damping sensitivity coefficient. Damping must act on the metric gap, never on the ordinal ranking: $P_{\text{position}} \in \{1, \dots, N\}$ is a discrete, non-metric label (the gap between 1st and 2nd can be 0.1 s or 30 s), so it cannot be differentiated or scaled by a gain. The ranking is only an observable used to *select* the intensity class of the intervention (Stage 2); the control signal itself must be the continuous gap.

The objective of the agent is to design self-regulating mechanisms that reduce performance disparity without nullifying the merit of the dominant agent's strategic decision-making.

---

## 1. Integrated Processing Protocol

When activating this skill, the agent must sequentially execute the following analytical formalization stages:

### Stage 1: Relative Performance Vector Formalization ($P_{\text{position}}$)

1. Map the real-time ordinal ranking metric of agents:

$$\mathbf{P} = [P_1, P_2, \dots, P_N]^T \quad \text{where } P_1 = \text{Absolute Leader and } P_N = \text{Last Place}$$

2. Measure the continuous performance gap $g_i$ of each agent (distance, time or score to the reference) and use the ordinal deviation $\Delta P_i = P_i - P_{\text{median}}$ only to select intervention classes; the damping magnitude uses $g_i$, never the ordinal label.

### Stage 2: Conditional Resource Probability Matrix ($M_{\text{prob}}$)

1. To regulate allocation of operational tools or aids, build the conditional probability distribution matrix $M_{\text{prob}}(R_j \mid P_i)$, in which the utility of granted resource $R_j$ is inversely proportional to the agent's ordinal position $P_i$:

$$\sum_{j=1}^{m} M_{\text{prob}}(R_j \mid P_i) = 1.0 \quad \forall P_i$$

2. Define three formal resource classes:
   - **Defensive / Local Resources:** Low global impact, granted with high probability to agents in top positions ($P_i \approx 1$).
   - **Mobility / Advancement Resources:** Speed gain or ground recovery, granted to intermediate positions.
   - **Global Disruption Resources:** Abilities affecting the state vector of multiple adversaries or reducing leader's advantage, granted strictly to bottom positions ($P_i \to N$).

### Stage 3: Passive Damping Appliers and Systemic Drag

1. Incorporate passive friction forces (*handicaps*) on the leading agent ($P_1$):

$$\text{Resistance}(P_1) = \text{Resistance}_{\text{base}} \cdot (1 + \gamma \cdot \Delta x_{\text{distance}})$$

where $\Delta x_{\text{distance}}$ is the physical advantage relative to 2nd place and $\gamma$ is the friction coupling factor.

### Stage 4: Skill Ceiling Preservation

1. Ensure that compensation provided by negative feedback satisfies the conditional dominance constraint:

$$\text{MaxEffect}(R_{\text{last}}) < \text{Advantage}(\text{Perfect Execution by Leader})$$

This prevents a low-performance agent from winning without making correct operational decisions.

---

## 2. Algorithmic Detection of Balancing Anomalies

The agent must analyze the damping system and flag the following structural failures:

### A. Total Merit Nullification (*Extreme Rubber-banding*)

$$\text{Effect}(R_{\text{last}}) \ge \Delta x_{\text{accumulated by 1st place}}$$

Action: Flag when compensation resources granted to bottom positions exceed in magnitude all progress built by leader's skill.

### B. Destructive Elastic Oscillation (*Rubber-Band Fluctuation*)

$$P_1(t) \longrightarrow P_N(t+1) \longrightarrow P_1(t+2)$$

Action: Identify when damping application causes leadership to alternate chaotically and unpredictably between participants, removing strategic control of the match.

### C. Intentional Delay Strategy (*Sandbagging Meta*)

$$\exists P_i > 1 \quad \text{such that} \quad \text{ExpectedValue}(R \mid P_i) \gg \text{ExpectedValue}(R \mid P_1)$$

Action: Detect if system incentivizes agents to intentionally remain in bottom positions for most of the match to accumulate high-disruption resources used only at terminal state.

---

## 3. Standard Analytical Output Format

When responding to the user, the agent must structure the analysis in the following format:

### 1. Conditional Probability Matrix by Ranking

| Agent Position ($P_i$) | Defensive Resource Probability | Mobility Resource Probability | Global Disruption Probability |
| --- | --- | --- | --- |
| **Leader ($P_1$)** | 80% | 20% | 0% |
| **Intermediate ($P_{\text{middle}}$)** | 30% | 50% | 20% |
| **Last Place ($P_N$)** | 0% | 30% | 70% |

### 2. Damping Equations and Parameters

* **Tick Damping Function ($\frac{dQ}{dt}$):** [Mathematical compensation formula]
* **Systemic Drag Factor ($\gamma$):** [Friction or penalty for accumulated advantage]
* **Compensation Reward Ceiling:** [Maximum gain limit granted by trigger]

### 3. Competition Diagnosis and Recommendations

* **Damping Status:** [BALANCED / SKILL-NULLIFYING / INEFFECTIVE]
* **Sandbagging Risk:** [Identification of undue advantages by intentional delay]
* **Suggested Parameter Adjustments:** [Changes to $M_{\text{prob}}$ matrix percentages or coefficient $k$]

---

## Mathematical Status

### Formal Guarantees
For the discrete damping step $x_{t+1} = x_t - hkx_t + b = (1 - hk)x_t + b$ (tick $h$), the closed-loop pole is $(1 - hk)$: the loop is stable if and only if $0 < hk < 2$, and it overshoots/oscillates whenever $hk > 1$ — the regime that produces the Destructive Elastic Oscillation flagged below. These are properties of the linearized model under fixed assumptions; stable feedback does not imply fairness.

### Derived Metrics
Derived metrics include comeback probability, variance and intervention cost, computable from the declared model inputs.

### Heuristics and Design Judgments
The damping gain $k$, the friction factor $\gamma$ and the $M_{\text{prob}}$ rows are calibrated defaults; choosing them is a design judgment, not a derived quantity.

### Required Simulation or Playtesting
Sandbagging incentives require strategic simulation. Required simulation or playtesting: strategic agents, sandbagging probes and live telemetry.

## Hypotheses and Limitations

- Assumes rank, gap, and resource utility are observable at the cadence used by the controller.
- The gap-based damping formulation follows dynamic difficulty adjustment practice (Hunicke & Chapman, AIIDE 2005); the control-theoretic stability reading applies to the linearized, constant-gain model only.
- Compensation effects and fairness conclusions are conditional on skill distribution, latency, and player adaptation; validate with simulations and playtests.

## 4. Procedure Execution Example

If the user requests: *"Create a catch-up/equalization system for a racing game where last place gets a global turbo, but without making the race unfair for those who trained."*

The agent applying this skill formalizes:

- Metric: $P_i \in \{1, 2, \dots, 8\}$.
- **Compensation Resource ($R_{\text{global\_turbo}}$):**
  Increases agent speed by $v_{\text{extra}} = 20\%$ for $t = 3\text{ seconds}$.
- **Merit Preservation Constraint:**

$$\Delta x_{\text{gain}}(R_{\text{global\_turbo}}) = 0.20 \cdot v_{\text{base}} \cdot 3\text{ s} = 0.60 \cdot v_{\text{base}} \text{ meters}$$

- If trained leader's advantage executing perfect corners is $1.5 \cdot v_{\text{base}}$ meters per segment, last place's turbo reduces the gap by only $40\%$, allowing approach without granting automatic overtake.
- **Matrix $M_{\text{prob}}$:**
  $P_8 \implies M_{\text{prob}}(R_{\text{global\_turbo}} \mid P_8) = 0.40$.
  $P_1 \dots P_4 \implies M_{\text{prob}}(R_{\text{global\_turbo}} \mid P_i) = 0.00$.
