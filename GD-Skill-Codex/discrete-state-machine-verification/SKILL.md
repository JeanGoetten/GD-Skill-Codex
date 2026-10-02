---
name: discrete-state-machine-verification
description: Formalizes and validates discrete rule systems and transition graphs in digital games. Use this skill when the user requests: (1) formal modeling of a game as a Discrete Finite Automaton, (2) logical consistency validation of rules, (3) reachability analysis of win/loss states, or (4) detection of ambiguous transitions and orphan states.
domain:
  primary:
    - state machines
    - formal verification
activation_signals:
  concepts:
    - automaton
    - invariant
    - reachability
  recognition_references:
    - "Super Mario Bros"
    - "The Legend of Zelda"
    - "XCOM"
outputs:
  - state model
  - invariant checks
  - reachability evidence
handoffs:
  downstream:
    - concurrent-gameplay-processes
    - procedural-level-constraint-solving
    - frame-based-combat-timing
exclusions:
  - franchise-specific canon
  - unvalidated claims
---

# Discrete State Machine Verification: Formalization and Reachability

## Domain

state spaces, invariants, transition functions, reachability.

## Purpose

translate rules into Q, Sigma, delta, q0 and F while separating possible, valid and reachable states.

## Activation Signals

state vector; invariant; precondition; reachable; orphan; deadlock; BFS; recognition anchors: Super Mario Bros.; The Legend of Zelda; XCOM.

## Scope

formal automata and graph anomalies.

## Exclusions

This skill does not resolve runtime implementation and player-experience proof.

## Handoff Conditions

When the problem crosses its boundary, hand off to: concurrent-gameplay-processes; procedural-level-constraint-solving; frame-based-combat-timing.

## Handoff Candidates

- **concurrent-gameplay-processes** — when several state machines advance in parallel and share resources, hand off the process interaction for Petri-net analysis.
- **procedural-level-constraint-solving** — when states describe generation constraints of levels rather than runtime transitions, hand off the constraint set for CSP analysis.
- **frame-based-combat-timing** — when legality is decided by frame windows (startup/active/recovery) instead of discrete events, hand off the action timing for frame analysis.
## Recognition References

These are semantic anchors only, not content to reproduce: Super Mario Bros.; The Legend of Zelda; XCOM.

## Theoretical Context and System Function

This skill operates at the primary ontological level of digital game design,
treating the game as a Discrete State Transition System. It is a finite-state
machine only when every state and event domain is finite:

$$M = (Q, \Sigma, \delta, q_0, F)$$

The objective of the agent when executing this skill is to translate ludic descriptions into strict mathematical specifications, preventing logical inconsistencies, indeterminate states, and reachability failures before the software coding phase.

---

## 1. Integrated Processing Protocol

When activating this skill, the agent must sequentially execute the following analytical stages:

### Stage 1: State Vector Formalization ($Q$)

1. Identify all discrete state variables of the system.
2. Distinguish the three sets used in the model:
   - **Possible states** are syntactically representable tuples in the declared Cartesian product of variable domains.
   - **Valid states** are possible states that satisfy the invariants $\Phi(q)$.
   - **Reachable states** are valid states for which a path $q_0 \leadsto q$ exists under $\delta$.
   A state may therefore be possible but invalid, or valid but unreachable.
3. Define the state vector $q \in Q$ as a tuple of attributes:

$$q = (v_1, v_2, v_3, \dots, v_n)$$

4. Establish the exact domain of each variable $v_i \in D_i$.
5. Formalize the set of Systemic Invariants $\Phi(q)$, which represent logical predicates that **must be true** for every valid $q \in Q$:

$$Valid = \{q \in Q \mid \Phi(q)\}$$

and the reachable set must satisfy:

$$Reach(q_0) \subseteq Valid$$

As stated this is nearly tautological (Reachable is defined over valid states), so the **non-trivial check it stands for is invariant preservation by $\delta$**: for every valid $q$ and every event $\sigma$ enabled at $q$ ($P_\sigma(q) = \text{True}$), the successor must also be valid:

$$\Phi(q) \land P_\sigma(q) \implies \Phi(\delta(q, \sigma))$$

Enumerating this check (or, equivalently, verifying that transitions never leave `Valid`) is what catches transitions from valid into invalid states — which the naive reachability set would silently exclude and thus mask. In a probabilistic automaton, require $\Phi(q')$ for every $q'$ in the support of $\delta(q, \sigma)$.

### Stage 2: Event Alphabet Specification ($\Sigma$)

1. Catalog all inputs, agent actions, and environment events in $\Sigma$.
2. For each event $\sigma \in \Sigma$, associate an explicit set of **Validity Preconditions** $P_\sigma(q)$. If $P_\sigma(q) = \text{False}$, the event $\sigma$ is rejected by the system and the transition is not executed.

### Stage 3: Transition Function Definition ($\delta$)

1. Build the deterministic state transition function:

$$\delta: Q \times \Sigma \longrightarrow Q$$

2. Explicitly define the resulting state $q' = \delta(q, \sigma)$ through post-condition assignments for each state vector variable.
3. If the dynamics are stochastic, extend the function to a probabilistic automaton with probability distribution over resulting states:

$$\delta: Q \times \Sigma \longrightarrow Dist(Q)$$

where `Dist(Q)` is a probability distribution when stochastic outcomes are
specified. A relation over possible successor states represents
non-determinism, not randomness; use it only when probabilities are unknown.

### Stage 4: Reachability Graph and $F$ Analysis

1. Define the unique initial state $q_0 \in Q$ and verify that it is valid.
2. Map the set of terminal states $F \subseteq Q$, subdividing $F$ into:
   - $F_{\text{victory}}$: States satisfying agent objectives.
   - $F_{\text{defeat}}$: States of irrecoverable failure.
   - $F_{\text{draw}}$: Terminal states without win/loss assignment.

3. Execute the Breadth-First Search (BFS) algorithm on the directed state graph $G = (Q, E)$ generated by $\delta$ to verify reachability of $F$.

---

## 2. Algorithmic Detection of Design Anomalies

The agent must apply the following logical verifications on the generated structure:

### A. Orphan State Detection (Unreachable)

$$\text{Orphans} = \{q \in Q_{\text{valid}} \setminus \{q_0\} \mid \nexists \text{ path } q_0\leadsto q\}$$

Here, **orphan** means only a valid state with no path from $q_0$; a merely possible state that violates $\Phi$ is invalid, not orphaned. A valid state with an incoming edge from another unreachable state is still orphaned because it has no path from $q_0$.

### B. Undesired Blocking Detection (Non-Terminal Deadlocks and Livelocks)

$$\text{Deadlock} = \{q \in Q \setminus F \mid \forall \sigma \in \Sigma, \, P_\sigma(q) = \text{False}\}$$

Action: Identify states where the game halts without having reached a terminal condition $F$.

$$\text{Livelock} = \{q \in Q \setminus F \mid \text{every cycle reachable from } q \text{ never reaches } F\}$$

Action: Also identify non-terminal states from which no terminal state is reachable — the game continues forever without resolution (e.g., infinite regeneration loops). Detect by computing, for each non-terminal state, whether $F$ is reachable via backward BFS from $F$; states outside the backward-reachable set are deadlock-or-livelock candidates. Under stochastic $\delta$ (Dist(Q)), reachability of $F$ is not *winnability*: a path existing does not mean the player can force it. Report probabilistic reachability (or explicitly scope the claim to "a path exists") instead of stating guaranteed victory.

### C. Improper Non-determinism

$$\exists (q, \sigma) \implies \text{multiple } q' \text{ without explicit probability function.}$$

Action: Require explicit resolution of ambiguity by adding tiebreaker variables.

---

## 3. Standard Analytical Output Format

The agent must structure the response to the user using strictly the following structure:

### 1. Formal Automaton Definition

* **State Vector ($Q$):** [List of variables and their domains]
* **Invariants ($\Phi(q)$):** [Absolute logical predicates]
* **Initial State ($q_0$):** [Initial variable configuration]
* **Terminal States ($F$):** [Victory, Defeat, and Draw conditions]

### 2. State Transition Matrix ($\delta$)

| Current State ($q$) | Event/Action ($\sigma$) | Precondition ($P_\sigma$) | Resulting State ($q'$) | Post-condition/Effect |
| --- | --- | --- | --- | --- |
| [State A] | [Action X] | [Condition] | [State B] | [Variable Changes] |

### 3. Validation Report and Reachability Graph

* **Graph Status:** [VALID / INCOMPLETE / CONTAINS ERRORS]
* **Reachability Analysis:** [Confirmation of critical path from $q_0 \to F$]
* **Detected Anomalies:** [List of orphan states, deadlocks, or ambiguities found]
* **Corrective Recommendations:** [Rule adjustment instructions]

---

## Mathematical Status

### Formal Guarantees
Reach(q0) is the smallest set containing q0 and closed under enabled transitions.

### Derived Metrics
Non-determinism means multiple possible transitions for a state/input; randomness is a probability distribution over outcomes, and they are distinct.

### Heuristics and Design Judgments
Reachability and invariants are conditional on the transition model.

### Required Simulation or Playtesting
Derived metrics include reachable-state count, dead transitions and violations. Heuristics prioritize meaningful states. Required simulation or playtesting: bounded traces, randomized seeds and runtime assertions.

## Hypotheses and Limitations

- Assumes the state vector, event alphabet, and transition rules are complete; hidden state, timing, and nondeterminism require explicit modeling.
- Reachability and anomaly results are conditional on the modeled graph and should be rechecked after implementation changes.

## 4. Procedure Execution Example

If the user provides the rule: *"A player needs to collect 3 keys to open the door and win, but if health reaches zero before that, they lose."*

The agent applying this skill must formalize:
- $q = (\text{keys}: \{0, 1, 2, 3\}, \text{health}: \mathbb{N}_{\ge 0}, \text{door}: \{\text{closed}, \text{open}\})$
- $q_0 = (0, 100, \text{closed})$
- $F_{\text{victory}} = \{(3, \text{health} > 0, \text{open})\}$
- $F_{\text{defeat}} = \{(\text{keys}, 0, \text{door})\}$
- $\delta$ matrix formally mapping inputs `collect_key`, `take_damage`, `use_key`.