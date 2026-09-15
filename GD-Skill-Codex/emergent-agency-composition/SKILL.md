---
name: emergent-agency-composition
description: Models composition and emergent synergy between multiple simultaneous operational verbs and shared physical properties. Use this skill when the user requests: (1) design of combinatorial ability systems, (2) modeling of interactions based on generic physical/elemental properties, (3) resolution of functional compositions of methods f_2(f_1(S)), or (4) creation of emergent agency through overlap of atomic mechanics.
domain:
  primary:
    - emergent agency
    - verb composition
activation_signals:
  concepts:
    - action affordance
    - composition
    - agency space
  recognition_references:
    - emergent-agency-composition
outputs:
  - verb taxonomy
  - composition graph
  - agency diagnostics
handoffs:
  downstream:
    - committed-risk-reward-actions
    - concurrent-gameplay-processes
    - cognitive-schema-disruption
exclusions:
  - franchise-specific canon
  - unvalidated claims
---

# Emergent Agency Composition: Combinatorial Action Systems

## Domain

atomic verbs, affordances and interaction matrices.

## Purpose

evaluate valid, redundant, emergent, destructive and trivializing compositions.

## Activation Signals

atomic verb; composition; emergent effect; redundancy; destructive; trivializing; recognition anchors: The Legend of Zelda: Breath of the Wild; Magicka; immersive sims.

## Scope

systemic combinations and readable consequences.

## Exclusions

This skill does not resolve individual move-set authoring and spatial pacing.

## Handoff Conditions

When the problem crosses its boundary, hand off to: frame-based-combat-timing; committed-risk-reward-actions; concurrent-gameplay-processes.

## Handoff Candidates

- **committed-risk-reward-actions** — encaminhar quando o problema exigir sua interface específica.
- **concurrent-gameplay-processes** — encaminhar quando o problema exigir sua interface específica.
- **cognitive-schema-disruption** — encaminhar quando o problema exigir sua interface específica.

## Recognition References

These are semantic anchors only, not content to reproduce: The Legend of Zelda: Breath of the Wild; Magicka; immersive sims.

## Composition Taxonomy

Classify each candidate interaction before evaluating its value:

- **Valid composition:** the combined preconditions and effects are coherent, legible, and executable.
- **Redundant composition:** it produces no materially new affordance beyond an existing action.
- **Emergent composition:** interaction yields a novel consequence not explicitly encoded as a single atomic verb.
- **Destructive composition:** interaction violates safety, resource, or state invariants, or removes agency without a justified contract.
- **Trivializing composition:** interaction bypasses meaningful constraints so broadly that it collapses challenge or choice.

## Theoretical Context and System Function

This skill formalizes emergent agency in digital games through functional composition of operational verbs. Instead of programming explicit paired interactions between abilities (which would generate $O(n^2)$ complexity), the system assigns generic physical and ontological properties to world entities.

Given two atomic mechanics $f_1$ and $f_2$, the temporal or spatial composition is formally described as:

$$S_{\text{result}} = f_2(f_1(S_{\text{initial}}), P_2)$$

The execution of composition $f_2(f_1(S))$ is logically valid if and only if the state vector alteration $\Delta S_1 = f_1(S_{\text{initial}}) - S_{\text{initial}}$ satisfies the invocation preconditions of method $f_2$.

The objective of the agent is to design orthogonal mechanics systems capable of interacting through a common set of world attributes, amplifying player resolution freedom without compromising rule stability.

---

## 1. Integrated Processing Protocol

When activating this skill, the agent must sequentially execute the following analytical stages:

### Stage 1: Atomic Verb Graph Formalization

1. Catalog agent methods $f_i \in F$, identifying the isolated effect of each verb on state vector $S$:

$$f_i: (S, A, P_i) \longrightarrow S'$$

2. Decompose each verb into its primary functional alteration: *Spatial Translation*, *Movement Vector Inversion*, *Material State Alteration*, *Secondary Entity Invocation*, or *Energy Transfer*.

### Stage 2: Shared Properties Matrix Mapping ($M_{\text{prop}}$)

1. To avoid rigid coupling between scripts, define world entities through a matrix of state flags and continuous numerical values:

| Entity / Object | Physical Properties ($P_{\text{physical}}$) | Elemental States ($E_{\text{elem}}$) | Verb Susceptibility |
| --- | --- | --- | --- |
| **Object Type A** | Movable = True, Mass = 15 | Flammable = True, Conductor = False | Supports Translation, Supports Ignition |
| **Object Type B** | Movable = False, Mass = Inf | Conductor = True, Freezable = True | Supports Electrical Conduction |

### Stage 3: Functional Composition Resolution $f_2(f_1(S))$

1. Evaluate invocation sequence of two or more methods at time $t_1$ and $t_2$:
   - If $f_1$ alters spatial position or state of an entity $E$ generating $S'$, and $S'$ activates $f_2$'s precondition, calculate the composed function $f_{1,2}(S) = (f_2 \circ f_1)(S)$.

2. Calculate synergy factor $K_{\text{synergy}}$ in output variable alteration:

$$\text{CombinedEffect} = (\text{Effect}(f_1) + \text{Effect}(f_2)) \cdot K_{\text{synergy}}$$

### Stage 4: Spatial Propagation and Effect Radius ($\vec{r}_{\text{effect}}$)

1. When a composition generates an alteration at a node in matrix $M_{\text{prop}}$, extend effect to bordering entities contained in the spatial region defined by the effect radius:

$$\text{Distance}(E_{\text{source}}, E_{\text{target}}) \le \vec{r}_{\text{effect}} \implies M_{\text{prop}}(E_{\text{target}}) = \text{Updated}$$

---

## 2. Algorithmic Detection of Balancing Anomalies

The agent must analyze the combination matrix and flag the following systemic risks:

### A. Infinite Mutual Invocation Loops (*Cyclic Triggering*)

$$f_1(S) \implies \text{Activates } f_2(S) \implies \text{Activates } f_1(S)$$

Action: Identify when chain reaction between two entities enters an unlimited invocation cycle without energy drain or iteration count limit.

### B. Absolutely Dominant Combination (*Trivializing Combo*)

$$\exists (f_i, f_j) \quad \text{such that} \quad \text{Cost}(f_i) + \text{Cost}(f_j) \ll \text{Reward} \quad \land \quad \text{Solves } 100\% \text{ of challenges}$$

Action: Flag if a single skill combination negates the need to use other system tools.

### C. Execution Priority Incoherence (*Race Condition*)

$$\text{Order } f_1 \to f_2 \neq \text{Order } f_2 \to f_1 \quad \text{with destructive collateral results}$$

Action: Require strict definition of operational priorities when two actions affect the same entity properties on the same update tick.

---

## 3. Standard Analytical Output Format

When responding to the user, the agent must structure the analysis in the following format:

### 1. Atomic Verb Specification

| Operational Verb ($f_i$) | Preconditions ($\mathcal{P}_{\text{pre}}$) | Primary Effect on $S$ | Required Property on Target |
| --- | --- | --- | --- |
| **[Verb 1]** | [Resource / Required State] | [Direct variable modification] | [Flag in $M_{\text{prop}}$ matrix] |
| **[Verb 2]** | [Resource / Required State] | [Direct variable modification] | [Flag in $M_{\text{prop}}$ matrix] |

### 2. Functional Composition Matrix ($f_2 \circ f_1$)

| Combination ($f_1 + f_2$) | Connection Precondition | Resulting State ($S_{\text{result}}$) | Synergy Factor ($K_{\text{synergy}}$) |
| --- | --- | --- | --- |
| **[Verb 1 + Verb 2]** | [Logical condition fulfilled] | [Description of emergent gameplay] | [Numerical modifier / Regional effect] |

### 3. Emergent Agency Diagnosis and Recommendations

* **Systemic Emergence Degree:** [LOW / MEDIUM / HIGH]
* **Detected Execution Anomalies:** [Identification of infinite loops or trivializing combos]
* **Recommended Integrity Adjustments:** [Inclusion of propagation limits or energy drains]

---

## Mathematical Status

### Formal Guarantees
Composition graphs guarantee listed combinations only, not perceived agency.

### Derived Metrics
Derived metrics include reachable verbs, affordance overlap and decision density.

### Heuristics and Design Judgments
Heuristics judge clarity and expressive value.

### Required Simulation or Playtesting
Required simulation or playtesting: discovery tasks, interaction tests and interviews.

## Hypotheses and Limitations

- Assumes state properties, preconditions, ordering, and propagation radii are explicit and deterministic enough to simulate.
- Synergy and dominance are conditional risks; timing, implementation details, and player strategies require empirical validation.

## 4. Procedure Execution Example

If the user requests: *"Create a system where the player can invoke 'Time Stop' and 'Position Swap Teleport', allowing placing enemy projectiles aimed at enemies themselves during the pause."*

The agent applying this skill formalizes:

- **Verb 1 ($f_{\text{pause}}$):** Sets $\text{TimeScale} = 0$ for all entities except agent. Projectiles retain momentum vector $\vec{v}_{\text{projectile}}$, but suspend translation update.
- **Verb 2 ($f_{\text{swap}}$):** Alters spatial coordinates $\vec{x}_{\text{projectile}} \longleftrightarrow \vec{x}_{\text{target}}$, maintaining projectile angular orientation.
- **Functional Composition:**

$$S_1 = f_{\text{pause}}(S_0) \implies \text{Projectile suspended at } \vec{x}_1 \text{ with vector } \vec{v}_1$$

$$S_2 = f_{\text{swap}}(S_1, \text{Projectile}, \text{Enemy}) \implies \text{Projectile positioned at } \vec{x}_{\text{enemy}}$$

$$S_3 = f_{\text{resume}}(S_2) \implies \text{TimeScale} = 1 \implies \text{Immediate projectile impact on enemy}$$

- **Analysis:** Emergence occurs because the position swap method operates on the generic `SpatialEntity` class, allowing affecting projectiles without a specific "redirect projectile" script being programmed.
- **Adjustment:** Define that $f_{\text{swap}}$ cost when affecting fast-moving entities consumes $1.5\times$ more energy to prevent boss fight trivialization.