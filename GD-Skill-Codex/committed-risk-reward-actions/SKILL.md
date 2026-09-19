---
name: committed-risk-reward-actions
description: Specifies agent methods (mechanics) with high state restriction, high risk/reward, and spatial penalties for invocation errors. Use this skill when the user requests: (1) formalization of agent methods (operational verbs) in object-oriented style f(S, A, P) -> S', (2) modeling of mechanics with high action commitment and static vulnerability windows, (3) balancing of real-time stamina/resource costs, or (4) calculation of spatial punishment for incorrect positioning.
domain:
  primary:
    - risk-reward actions
    - commitment contracts
activation_signals:
  concepts:
    - irreversibility
    - expected value
    - spatial risk
  recognition_references:
    - "Dark Souls"
    - "Monster Hunter"
    - "Street Fighter"
outputs:
  - action contract
  - risk ledger
  - playtest hypotheses
handoffs:
  downstream:
    - frame-based-combat-timing
    - emergent-agency-composition
    - competitive-negative-feedback
exclusions:
  - franchise-specific canon
  - unvalidated claims
---

# Committed Risk-Reward Actions: Spatial Commitment Contracts

## Domain

commitment windows, exposure, recovery and spatial verbs.

## Purpose

formalize action contracts and expected payoff under positional risk.

## Activation Signals

commitment window; exposure; telegraph; recovery; risk budget; recognition anchors: Dark Souls; Monster Hunter; Street Fighter.

## Scope

punishability, escape routes and positional uncertainty.

## Exclusions

This skill does not resolve frame tree definition and procedural solvability.

## Handoff Conditions

When the problem crosses its boundary, hand off to: frame-based-combat-timing; emergent-agency-composition; competitive-negative-feedback.

## Handoff Candidates

- **frame-based-combat-timing** — when commitment risk must be priced in exact startup/active/recovery frames instead of declared windows, hand off the action signatures for frame-advantage analysis.
- **emergent-agency-composition** — when several committed actions should combine into player-invented tactics, hand off the verb set for compositional agency analysis.
- **competitive-negative-feedback** — when committed actions must not become dominant or useless under catch-up or handicap pressure, hand off the payoff table for feedback-stability analysis.
## Recognition References

These are semantic anchors only, not content to reproduce: Dark Souls; Monster Hunter; Street Fighter.

## Theoretical Context and System Function

This skill formalizes player agency through operational methods in Object-Oriented Programming (OOP), where invocation of a verb is neither instantaneous nor risk-free. The agent method alters the global world state $S$ through the function:

$$f_{\text{action}}: (S_{\text{current}}, A_{\text{agent}}, P_{\text{parameters}}) \longrightarrow S_{\text{new}}$$

Unlike actions with free cancellation, verbs under this architecture impose **rigid state commitment** (*Action Commitment*): once invocation is initiated, the agent temporarily loses the ability to invoke other methods while transitioning through temporal and spatial vulnerability windows.

The objective of the agent is to balance the risk/reward vector, ensuring that devastating actions require precise spatial positioning and correct timing, under penalty of suffering severe counter-attacks.

---

## 1. Integrated Processing Protocol

When activating this skill, the agent must sequentially execute the following analytical formalization stages:

### Stage 1: Agent Method Formalization and Precondition Validation

1. Define the formal signature of the method for each action $a$:

$$f_a(S, A, P) = \begin{cases} S_{\text{success}}, & \text{if } \mathcal{P}_{\text{pre}}(S) = \text{True} \\ S_{\text{error}}(S,\text{reason}), & \text{if } \mathcal{P}_{\text{pre}}(S) = \text{False} \end{cases}$$

The contract must specify whether invalid input is rejected without mutation, returns a recoverable error, or enters a defined penalty state; callers must not infer a penalty from an unspecified failure.

2. Define the set of State Preconditions $\mathcal{P}_{\text{pre}}(S)$:
   - **Minimum Resource:** Stamina or energy level $E_{\text{agent}} \ge C_{\text{stamina}}$.
   - **Valid Agent State:** $A_{\text{state}} \in \{\text{Idle}, \text{Moving}\}$, rejecting invocations during recovery state of previous actions.

### Stage 2: Temporal Commitment Windows and Static Vulnerability

1. Fragment the action duration $T(a)$ into three indivisible temporal intervals:
   - **Anticipation / Wind-up ($T_{\text{wind}}$):** Initial charge time. Agent consumes resource $C_{\text{stamina}}$ at frame $t=0$, but attack vector has no physical harmful representation yet.
   - **Execution / Active ($T_{\text{act}}$):** Method alters spatial properties or deals damage in a vector region $\vec{V}_{\text{hitbox}}$.
   - **Recovery / Vulnerability ($T_{\text{rec}}$):** Agent remains locked at final spatial position without dodge or defense capability.

### Stage 3: Spatial Punishment Resolution and Knockback Vector ($\vec{F}_{\text{knockback}}$)

1. If agent is hit during windows $T_{\text{wind}}$ or $T_{\text{rec}}$, action is interrupted and spatial punishment is calculated:

$$S'_{\text{health}} = S_{\text{health}} - \Delta H_{\text{amplified}}$$

$$S'_{\text{position}} = S_{\text{position}} + \Delta \vec{x}$$

$$S'_{\text{velocity}} = S_{\text{velocity}} + \Delta \vec{v}$$

Health, position and velocity are separate state components with distinct
units; they must not be added in one scalar equation.

2. Apply vulnerability multiplier $k_{\text{punish}} > 1.0$ to received damage ($\Delta H_{\text{amplified}} = \Delta H_{\text{base}} \cdot k_{\text{punish}}$) for timing failure.

### Stage 4: Stamina Bar Management and Regeneration Rate

1. Model agent stamina reserve as a reservoir with deferred regeneration:

$$\frac{d E(t)}{dt} = \begin{cases} 0, & \text{if } t < t_{\text{delay}} \text{ post-action} \\ R_{\text{stamina}}, & \text{if } t \ge t_{\text{delay}} \text{ and agent is not executing actions} \end{cases}$$

---

## 2. Algorithmic Detection of Balancing Anomalies

The agent must analyze the method vector and flag the following structural failures:

### A. Riskless Dominance (*Safe Heavy Attack*)

$$T_{\text{rec}}(a) \le t_{\text{reaction, min}} \quad \land \quad \Delta H_{\text{base}}(a) \gg \text{Average}$$

Action: Flag if a high-damage method has a recovery phase so short it prevents spatial punishment by adversarial agents.

### B. Stamina Lock Trap

$$C_{\text{stamina}}(a) + C_{\text{dodge}} > E_{\text{max}}$$

Action: Alert if invocation cost of a basic action prevents the player from executing the primary evasion mechanic immediately afterwards, generating inevitable deaths by design limitation.

### C. Reach vs. Exposure Incoherence (Hitbox/Hurtbox Disparity)

$$\text{Area}(\vec{V}_{\text{hurtbox}}) \gg \text{Area}(\vec{V}_{\text{hitbox}}) \quad \text{during } T_{\text{act}}$$

Action: Identify when attacker's spatial vulnerability exposes disproportionately more than the effective area of their own attack.

---

## 3. Standard Analytical Output Format

When responding to the user, the agent must structure the specification in the following format:

### 1. Action Signature and Parameters ($f_a$)

| Action Parameter | Value / Formula | Systemic Description |
| --- | --- | --- |
| **Stamina Cost ($C_{\text{stamina}}$)** | [Numerical value] | Resource consumed instantly at frame $t=0$ |
| **Wind-up ($T_{\text{wind}}$)** | [X frames / ms] | Initial charge window without hitbox |
| **Active ($T_{\text{act}}$)** | [Y frames / ms] | Attack effectiveness window ($\vec{V}_{\text{hitbox}}$) |
| **Recovery ($T_{\text{rec}}$)** | [Z frames / ms] | Absolute static vulnerability window |
| **Punishment Multiplier ($k_{\text{punish}}$)** | [$k \times$ base damage] | Penalization factor for interruption during action |

### 2. Spatial Analysis and Punishment Vector

* **Coverage Area ($\vec{V}_{\text{hitbox}}$):** [Vector or angular description of reach]
* **Agent Displacement During Action:** [Forced movement vector $\vec{d}$]
* **Knockback Vector on Error ($\vec{F}_{\text{knockback}}$):** [Magnitude of impact suffered on interruption]

### 3. Risk/Reward Diagnosis and Recommendation

* **Risk Classification:** [LOW / MEDIUM / HIGH / EXTREME]
* **Effective Spatial Punishment:** [Confirmed viability of adversary counter-attack]
* **Suggested Adjustments:** [Changes to $T_{\text{wind}}$, $T_{\text{rec}}$ times or $C_{\text{stamina}}$ cost]

---

## Mathematical Status

### Formal Guarantees
Expected value compares modeled outcomes but does not determine player choice; commitment and spatial risk remain preference-dependent.

### Derived Metrics
Derived metrics include risk exposure, option value, recovery time and payoff variance.

### Heuristics and Design Judgments
Heuristics set telegraphing and commitment.

### Required Simulation or Playtesting
Required simulation or playtesting: risk cohorts, failure recovery and latency tests.

## Hypotheses and Limitations

- Assumes resource costs, action phases, hitboxes, and error contracts are explicit and consistently enforced.
- Punishment and safety diagnoses are conditional on reaction times, latency, and adversary behavior; test representative traces.

## 4. Procedure Execution Example

If the user requests: *"Create specification for a 'Devastating Axe Attack' that deals massive damage but leaves player defenseless if missed."*

The agent applying this skill formalizes:

- Signature: $f_{\text{axe}}(S, A, P)$
- $C_{\text{stamina}} = 60$ (Consumes $60\%$ of a base 100 bar).
- $T_{\text{wind}} = 45\text{ frames}$ ($750\text{ ms}$ at 60 Hz).
- $T_{\text{act}} = 6\text{ frames}$ ($100\text{ ms}$).
- $T_{\text{rec}} = 50\text{ frames}$ ($833\text{ ms}$).
- $k_{\text{punish}} = 1.5$ ($+50\%$ damage taken if interrupted).
- **Punishment Window Calculation:**
If attack misses target's hurtbox, attacker remains immobile for $50\text{ frames}$ ($833\text{ ms}$). An adversary within reach range with a response action of $T_{\text{startup}} \le 40\text{ frames}$ has enough time to advance and inflict a guaranteed critical hit.
- **Diagnosis:** Extreme risk, massive reward action. Requires adjustment to stamina regeneration delay ($t_{\text{delay}} = 1.0\text{ s}$) to prevent disordered consecutive use.