---
name: resource-flow-economy
description: Models and balances static and dynamic internal economy systems using the Machinations framework. Use this skill when the user requests: (1) design or balancing of resource flow equations (dQ/dt), (2) definition of primitive nodes (Sources, Sinks, Converters, Pools), (3) analysis of generation rates and sinks to prevent inflation or scarcity, or (4) stabilization of complex ludic economic systems.
domain:
  primary:
    - resource flows
    - economy balancing
activation_signals:
  concepts:
    - stock and flow
    - production rate
    - bottleneck
  recognition_references:
    - resource-flow-economy
outputs:
  - flow model
  - balance metrics
  - tuning recommendations
handoffs:
  downstream:
    - macroeconomic-resource-conversion
    - exponential-progression-and-prestige
    - committed-risk-reward-actions
exclusions:
  - franchise-specific canon
  - unvalidated claims
---

# Resource Flow Economy: Stock-Flow Balance

## Domain

stocks, flows, rates, sources, sinks and equilibrium.

## Purpose

balance creation, storage, conversion, consumption and loss over time.

## Activation Signals

stock; flow; source; sink; throughput; equilibrium; conservation; recognition anchors: SimCity; Stardew Valley; Factorio.

## Scope

flow equations, bounds and stability.

## Exclusions

This skill does not resolve full production matrices and competitive catch-up.

## Handoff Conditions

When the problem crosses its boundary, hand off to: macroeconomic-resource-conversion; competitive-negative-feedback; exponential-progression-and-prestige.

## Handoff Candidates

- **macroeconomic-resource-conversion** — encaminhar quando o problema exigir sua interface específica.
- **exponential-progression-and-prestige** — encaminhar quando o problema exigir sua interface específica.
- **committed-risk-reward-actions** — encaminhar quando o problema exigir sua interface específica.

## Recognition References

These are semantic anchors only, not content to reproduce: SimCity; Stardew Valley; Factorio.

## Theoretical Context and System Function

This skill formalizes internal economies of digital games as directed graphs of quantifiable resource flow according to the *Machinations* framework. The state of the economy at a time instant $t$ is determined by a mass balance
at each node. Use a difference equation for tick-based or event-driven systems:

$$\frac{d Q_R(t)}{dt} = \sum \text{Rate}_{\text{Source}}(t) - \sum \text{Rate}_{\text{Drain}}(t)$$

$$Q_R(t+1) = Q_R(t) + \text{Sources}(t) - \text{Sinks}(t)$$

The continuous form is an approximation and requires a declared time basis.

The objective of the agent is to map the circulation of tangible, intangible, and abstract resources, deterministically adjusting flow rates to achieve a desired equilibrium point or growth curve.

---

## 1. Integrated Processing Protocol

When activating this skill, the agent must sequentially execute the following economic formalization steps:

### Stage 1: Resource Categorization ($R$)

1. Catalog all system resources into three formal categories:
   - **Tangible:** Resources with physical/spatial representation in the simulation (e.g., raw materials, units, buildings).
   - **Intangible:** Global numerical variable or attribute (e.g., gold, experience, energy).
   - **Abstract:** Conditional quantities of transient state (e.g., happiness, reputation, threat).

### Stage 2: Primitive Node Specification

1. **Sources:** Nodes that instantiate new resources into the system. Define the generation function $\Delta R_{\text{created}} = g(S, t)$, where $S$ is the current state and $t$ is time.
2. **Pools:** Storage nodes that retain accumulated quantity $Q_R(t)$. Define minimum capacity $Q_{\text{min}}$ and maximum capacity $Q_{\text{max}}$.
3. **Sinks:** Nodes that permanently destroy resources. Define the removal rate $\Delta R_{\text{removed}} = h(S)$.
4. **Converters:** Nodes that destroy a quantity of resource $R_A$ to simultaneously instantiate a proportional quantity of $R_B$, according to the relation:

$$k \cdot R_A \longrightarrow m \cdot R_B$$

### Stage 3: Connection and Trigger Mapping

1. Define **Flow Connectors** specifying the transfer rate $\lambda$ (resources transferred per second or per turn).
2. Define **State Connections**, where the accumulated quantity in a $Pool$ modifies the rate $\lambda$ of another connection without consuming the resource from the $Pool$.
3. Configure node trigger modes: *Automatic* (fires continuously every cycle), *Passive* (fires only on demand), or *Interactive* (triggered by agent action).

### Stage 4: Steady-State Analysis ($\frac{dQ}{dt} = 0$)

1. Calculate the net rate vector for all $Pools$ in the system.
2. Determine if the economy tends toward sustainable equilibrium, collapse by scarcity, or saturation by numerical hypertrophy.

---

## 2. Algorithmic Detection of Economic Anomalies

The agent must apply the following logical verifications on the resource graph:

### A. Hyperinflation / Infinite Accumulation Without Cap

$$\exists \text{Pool}_i \quad \text{such that} \quad \frac{d Q_i(t)}{dt} > 0 \quad \land \quad \text{Sink}(Q_i) = 0 \quad \land \quad Q_{\text{max}} = \infty$$

Action: Flag uncontrolled accumulation of currency or intangible resource. Require creation of an equivalent Sink or progressive maintenance cost.

### B. Economic Asphyxiation / Premature Depletion

$$\exists \text{Pool}_i \quad \text{such that} \quad \frac{d Q_i(t)}{dt} < 0 \quad \land \quad Q_i(t) \to 0 \text{ in } t \le t_{\text{minimum}}$$

Action: Identify when costs and drains exceed the production capacity of Sources, preventing the agent from performing basic transactions.

### C. Conversion Bottleneck Blockage

$$k \cdot R_A \to m \cdot R_B \quad \text{where } \text{Rate}(R_A) \ll k$$

Action: Alert if a conversion rate requires more inputs than the maximum output rate of the source Source.

---

## 3. Standard Analytical Output Format

When responding to the user, the agent must structure the analysis in the following format:

### 1. Resource Network Architecture

| Node / Element | Machinations Type | Linked Resource | Input/Output Rate ($\lambda$) | Trigger Condition |
| --- | --- | --- | --- | --- |
| **[Node A Name]** | Source | [Resource Name] | $+N$ per second/turn | Automatic / Action |
| **[Node B Name]** | Pool | [Resource Name] | Capacity: $[Q_{\text{min}}, Q_{\text{max}}]$ | Storage |
| **[Node C Name]** | Converter | $R_A \to R_B$ | Ratio $k:m$ | On demand |
| **[Node D Name]** | Sink | [Resource Name] | $-M$ per operation | Conditional |

### 2. System Balance Equation

* **Daily/Turn Balance ($\frac{dQ}{dt}$):** [Quantitative formula of net flow per resource]
* **Time to Saturation ($t_{\text{sat}}$):** [Time to reach $Q_{\text{max}}$]
* **Time to Exhaustion ($t_{\text{exhaustion}}$):** [Time to reach $0$ if Sources stop]

### 3. Stability Diagnosis and Recommendations

* **System Status:** [STABLE / INFLATIONARY / DEFICITARY]
* **Identified Bottlenecks:** [List of nodes blocking circulation]
* **Recommended Parameter Adjustments:** [Suggested numerical changes to $\lambda$, $k$, $m$ or capacities]

---

## Mathematical Status

### Formal Guarantees
Balance equations guarantee only the declared steady state under fixed rates.

### Derived Metrics
Derived metrics include stock half-life, throughput, scarcity and sink/source ratios.

### Heuristics and Design Judgments
Heuristics judge pacing and legibility.

### Required Simulation or Playtesting
Required simulation or playtesting: demand shocks, exploit probes and economy telemetry.

## Hypotheses and Limitations

- Assumes rates, capacities, and sinks are measured on a compatible time basis and that all relevant flows are represented.
- Stability diagnoses are conditional scenarios; player behavior, price feedback, and discrete events can change the result.

## 4. Procedure Execution Example

Given the request: *"In a strategy game, a mine generates 10 gold per second. A city consumes 2 gold per second as living cost. The player can convert 50 gold into 1 soldier. Create the specification and analyze the economy."*

The agent applying this skill formalizes:

- Resource: $R_{\text{gold}}$ (intangible), $R_{\text{soldier}}$ (tangible).
- Node 1 (Source): $\text{Mine} \implies \Delta R_{\text{gold}} = +10/\text{s}$ (Automatic).
- Node 2 (Pool): $\text{Vault} \implies Q_{\text{gold}}(t)$ with $Q_{\text{min}} = 0, Q_{\text{max}} = \infty$.
- Node 3 (Sink): $\text{CityCost} \implies \Delta R_{\text{gold}} = -2/\text{s}$ (Automatic).
- Node 4 (Converter): $\text{Barracks} \implies 50 R_{\text{gold}} \longrightarrow 1 R_{\text{soldier}}$ (Interactive).
- **Balance Calculation:**

$$\frac{d Q_{\text{gold}}(t)}{dt} = +10 - 2 = +8/\text{s}$$

- **Analysis:** The system is inflationary ($\frac{dQ}{dt} = +8/\text{s}$). Every 6.25 seconds ($50 / 8$), the player accumulates enough gold to produce 1 soldier. Without maintenance costs for generated soldiers, there will be infinite accumulation of military force.
- **Recommendation:** Add a conditional Sink $\Delta R_{\text{gold}} = -0.5/\text{s}$ per active soldier.