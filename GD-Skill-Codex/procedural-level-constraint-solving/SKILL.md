---
name: procedural-level-constraint-solving
description: "Analyzes playability and solvability risks in procedural levels using Constraint Satisfaction Programming (CSP). Use this skill when the user requests: (1) modeling of map generators with a verifiable critical path, (2) definition of Hard Constraints and Soft Constraints in generation algorithms, (3) constraint propagation and consistency verification via AC-3/Backtracking, or (4) detection of blocked or impossible scenarios in procedurally generated levels."
metadata:
  domain:
    primary:
      - constraint solving
      - procedural level generation
  activation_signals:
    concepts:
      - CSP
      - AC-3
      - backtracking
    recognition_references:
      - "Spelunky"
      - "The Binding of Isaac"
      - "Baba Is You"
  outputs:
    - constraint model
    - solvability evidence
    - generator diagnostics
  handoffs:
    downstream:
      - discrete-state-machine-verification
      - procedural-expressive-range-analysis
      - spatial-topology-and-learning-pacing
  exclusions:
    - franchise-specific canon
    - unvalidated claims
---

# Procedural Level Constraint Solving: Solvable Generation

## Domain

constraint satisfaction, reachability, locks and repair.

## Purpose

generate or validate solvable levels with explicit hard and soft constraints.

## Activation Signals

CSP; domain; hard constraint; soft constraint; solvability; repair; recognition anchors: Spelunky; The Binding of Isaac; Baba Is You.

## Scope

solver checks, critical paths and repair operators.

## Exclusions

This skill does not resolve expressive diversity and combat feel.

## Handoff Conditions

When the problem crosses its boundary, hand off to: discrete-state-machine-verification; procedural-expressive-range-analysis; spatial-topology-and-learning-pacing.

## Handoff Candidates

- **discrete-state-machine-verification** — when the generated level gameplay reduces to discrete states and transitions, hand off the state model for reachability verification.
- **procedural-expressive-range-analysis** — when many generated instances must be characterized for diversity and bias, hand off the generator for expressive-range analysis.
- **spatial-topology-and-learning-pacing** — when solvability must be evaluated as traversable space and teaching rhythm, hand off the level graph for topology analysis.
## Recognition References

These are semantic anchors only, not content to reproduce: Spelunky; The Binding of Isaac; Baba Is You.

## Theoretical Context and System Function

This skill formalizes procedural level generation as a Constraint Satisfaction Problem (CSP). Instead of using purely stochastic approaches requiring heuristic post-hoc validation, Constraint Satisfaction Programming defines a formal triple:

$$CSP = (V, D, C)$$

where $V = \{V_1, V_2, \dots, V_n\}$ is the set of discrete map variables (e.g., room coordinates or block positions), $D = \{D_1, D_2, \dots, D_n\}$ is the set of finite domains of instantiable geographic pieces, and $C = \{C_1, C_2, \dots, C_m\}$ is the set of logical constraints restricting allowed combinations of values assigned to variables.

The objective of the agent is to establish evidence for at least one continuous and solvable critical path from Level Entry to Exit, subject to explicit global verification and the avatar's physical capabilities and metrics.

---

## 1. Integrated Processing Protocol

When activating this skill, the agent must sequentially execute the following logical formalization stages:

### Stage 1: Variable ($V$) and Domain ($D$) Definition

1. Discretize the level grid into a matrix of two-dimensional variables $V_{x,y}$ for $x \in [1, X_{\text{max}}]$ and $y \in [1, Y_{\text{max}}]$.
2. Map the domain $D(V_{x,y})$ as the set of structural modules or valid block types:

$$D(V_{x,y}) = \{d_1, d_2, \dots, d_k\} \quad (\text{e.g., Open Room, Platform, Solid Wall, Bottom Opening})$$

### Stage 2: Hard Constraints ($C_{\text{hard}}$) and Soft Constraints ($C_{\text{soft}}$) Formulation

1. **Hard Constraints ($C_{\text{hard}}$):** Inviolable logical conditions imposed on the code. If $C_{\text{hard}} = \text{False}$, the generated artifact is invalid and rejected:
   - **Critical Path Continuity:**

$$\exists \text{Path } P = (V_{\text{entry}}, \dots, V_{\text{exit}}) \quad \text{such that } \forall (V_a, V_b) \in P, \text{Transition}(V_a, V_b) = \text{Valid}$$

   - **Boundary Guarantee:** Boundary variables of the grid — $\forall y:\ V_{1,y}, V_{X,y}$ and $\forall x:\ V_{x,1}, V_{x,Y}$ — must have forced assignments of indestructible boundaries.

2. **Soft Constraints ($C_{\text{soft}}$):** Cost or preference functions used to rank valid solutions without discarding the instance. Declare the value range of every $C_{\text{soft}, i}$ (e.g., normalized to $[0,1]$) and the scale of the weights $w_i$; summing terms with heterogeneous scales makes the weights incomparable:

$$\text{Attractiveness}(N) = \sum_{i} w_i \cdot C_{\text{soft}, i}(N)$$

### Stage 3: Constraint Propagation (AC-3 Algorithm) and Backtracking Search

1. Execute the Arc Consistency algorithm (AC-3) as a **local consistency** pass on the constraint graph to remove values from domains $D(V_{i})$ that have no valid match in neighboring domains $D(V_{j})$. AC-3 alone does not prove a complete solution.
2. If a domain $D(V_{x,y})$ is reduced to the empty set $\emptyset$, trigger the *Backtracking* mechanism, reverting the previous variable's assignment and selecting an alternative value from its domain. After assignment, run a global path/constraint verification before accepting the level.

### Stage 4: Agent Translation Capacity Mapping ($\vec{K}_{\text{agent}}$)

1. Encode the avatar's physical limits vector:

$$\vec{K}_{\text{agent}} = (\Delta x_{\text{jump, max}}, \Delta y_{\text{jump, max}}, \text{MaxSafeFall})$$

where $\Delta y_{\text{jump, max}}$ is the maximum *ascent* the agent can reach (positive upward offset) and MaxSafeFall is the maximum descent that does not damage or kill the agent. Descents are gated by MaxSafeFall, not by the jump reach: a surface below the agent within falling distance needs no jump, so an absolute-value check on DistanceY would wrongly reject reachable drops.

2. As a coarse pre-filter, validate whether distance between two traversable
surfaces $V_a$ and $V_b$ satisfies:

$$\text{DistanceX}(V_a, V_b) \le \Delta x_{\text{jump, max}} \quad \land \quad \left( 0 \le \text{Rise}(V_a, V_b) \le \Delta y_{\text{jump, max}} \;\lor\; \text{Drop}(V_a, V_b) \le \text{MaxSafeFall} \right)$$

This is not a proof of physical reachability. The final check must use
`Reachability(V_a, V_b, agent_model)` and account for trajectory, gravity,
velocity, acceleration, obstacles, collisions and stamina.

---

## 2. Algorithmic Detection of Generation Anomalies

The agent must analyze the constraint matrix and flag the following specification errors:

### A. Absolute CSP Infeasibility (*Over-constrained System*)

$$\exists V_{x,y} \quad \text{such that post-AC-3 } D(V_{x,y}) = \emptyset$$

Action: Identify when the set of hard constraints is so rigid that no combination of pieces in the domain can simultaneously satisfy the level.

### B. Combinatorial Explosion from Open Domain (*Under-constrained System*)

Signal under-constraint by the *effective branching factor after propagation*: if the ratio of the mean post-AC-3 domain size $\bar{d}$ to the initial domain size $k$ stays close to 1 (propagation prunes almost nothing), backtracking search explores $\mathcal{O}(k^{|V|})$ assignments in the worst case — for enumeration or ranking tasks this is combinatorial in the number of variables $|V|$:

$$\frac{\bar{d}}{k} \approx 1 \quad \implies \quad \text{worst-case search cost} = \mathcal{O}(k^{|V|})$$

Action: Flag lack of local adjacency constraints when propagation barely reduces domains *and* the generator enumerates or ranks solutions (rejection sampling and "find one solution" tasks often get *easier* with many solutions — do not flag those). State whether the cost driver is search, enumeration, or filtering.

### C. Implicit Path Break by Unidirectional Opening

$$\text{Transition}(V_a \to V_b) = \text{Valid} \quad \land \quad \text{Transition}(V_b \to V_a) = \text{Invalid}$$

Action: Detect when a vertical drop forces the agent to advance into a dead-end area if they lack the resource required for return.

---

## 3. Standard Analytical Output Format

When responding to the user, the agent must present the specification in the following format:

### 1. CSP Problem Definition ($V, D, C$)

| Variable / Element ($V$) | Domain of Values ($D$) | Constraint Type ($C$) | Logical Description of Constraint |
| --- | --- | --- | --- |
| **Grid Rooms ($V_{x,y}$)** | [Modules $d_1, \dots, d_k$] | $C_{\text{hard}}$ (Adjacency) | Border openings of $V_{x,y}$ must match $V_{x+1,y}$ |
| **Critical Path ($P$)** | [Room sequence] | $C_{\text{hard}}$ (Solvability) | Must exist traversable path from $V_{\text{start}}$ to $V_{\text{end}}$ |
| **Item Density** | [Integer $0 \dots M$] | $C_{\text{soft}}$ (Distribution) | Maximize distance between collectibles |

### 2. Agent Capabilities Vector and Transition Validation

* **Horizontal Reach ($\Delta x_{\text{jump, max}}$):** [Distance units]
* **Vertical Reach ($\Delta y_{\text{jump, max}}$):** [Distance units]
* **Max Safe Fall:** [Vertical units]

### 3. Generator Diagnosis and Validation Algorithm

* **CSP System Status:** [SOLVABLE / INFEASIBLE / COMBINATORIAL EXPLOSION]
* **Identified Domain Bottlenecks:** [Rooms or pieces with few valid connections]
* **Recommended Backtracking Strategy:** [Instructions for variable ordering in algorithm]

---

## Mathematical Status

### Formal Guarantees
AC-3 guarantees arc consistency only, not global solvability; search or constructive proof is still required.

### Derived Metrics
Derived metrics include domain reduction, backtracks and solution rate.

### Heuristics and Design Judgments
Heuristics select constraints and ordering.

### Required Simulation or Playtesting
Required simulation or playtesting: seeded generation, adversarial constraints and solvability/quality review.

## Hypotheses and Limitations

- Assumes domains and adjacency predicates faithfully represent movement; physics, procedural scripting, and player skill can invalidate an abstract path.
- AC-3 is only local consistency; a complete assignment and global reachability/trajectory verification are still required.

## 4. Procedure Execution Example

If the user requests: *"Define a $4 \times 4$ room-based map generator where player falls from top entry and must reach bottom exit, guaranteeing they never get stuck."*

The agent applying this skill formalizes:

- $V = \{V_{x,y} \mid x \in [1..4], y \in [1..4]\}$.
- $D = \{S_{\text{closed}}, S_{\text{passage\_H}}, S_{\text{drop\_V}}, S_{\text{start}}, S_{\text{end}}\}$.
- **Hard Constraint $C_1$ (Main Path):**
  Define a sequence of connected rooms marked with `CriticalPath = True` flag.
- **Hard Constraint $C_2$ (Drop Topology):**
  If $V_{x,y}$ has bottom exit (`drop_V`), the room immediately below $V_{x,y+1}$ must have compatible top entry and be traversable.
- **Algorithmic Validation:**
  If generator draws a path dropping at $x=2, y=3$, room $V_{2,4}$ obligatorily assumes hard constraint of containing `S_end` or providing horizontal passage to it, reducing its domain $D(V_{2,4})$ to only compatible pieces.
- **Result:** Under the stated domains and a successful global verifier, each accepted instance has a validated path; this is not a guarantee outside the modeled rules.
