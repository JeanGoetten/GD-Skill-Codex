---
name: exponential-progression-and-prestige
description: Formulates and balances positive feedback loops, exponential growth curves, and prestige mechanics. Use this skill when the user requests: (1) design of exponential or incremental progression curves (idle/incremental games), (2) calculation of scaled acquisition costs and resource generation, (3) prevention of numeric overflow, or (4) formulation of prestige and reset systems to convert stalled progress.
domain:
  primary:
    - progression curves
    - prestige systems
activation_signals:
  concepts:
    - exponential curve
    - reset
    - upgrade time
  recognition_references:
    - exponential-progression-and-prestige
outputs:
  - curve comparison
  - income-cost forecast
  - prestige tuning report
handoffs:
  downstream:
    - resource-flow-economy
    - macroeconomic-resource-conversion
    - competitive-negative-feedback
exclusions:
  - franchise-specific canon
  - unvalidated claims
---

# Exponential Progression and Prestige: Curve Families

## Domain

progression curves, compounding, resets and soft caps.

## Purpose

compare exponential as a curve family with linear, polynomial, logarithmic, piecewise and soft-cap alternatives.

## Activation Signals

exponential family; linear; polynomial; logarithmic; piecewise; soft cap; prestige; recognition anchors: Cookie Clicker; Diablo; incremental ascension systems.

## Scope

curve fitting, marginal gains and reset costs.

## Exclusions

This skill does not resolve all resource balance and combat timing.

## Handoff Conditions

When the problem crosses its boundary, hand off to: resource-flow-economy; macroeconomic-resource-conversion; nested-gameplay-loop-architecture.

## Handoff Candidates

- **resource-flow-economy** — encaminhar quando o problema exigir sua interface específica.
- **macroeconomic-resource-conversion** — encaminhar quando o problema exigir sua interface específica.
- **competitive-negative-feedback** — encaminhar quando o problema exigir sua interface específica.

## Recognition References

These are semantic anchors only, not content to reproduce: Cookie Clicker; Diablo; incremental ascension systems.

## Curve-Family Clarification

“Exponential” is a family of curves, not a single mandatory formula: parameters, bases, offsets, and piecewise regimes change its behavior. Always compare it against linear, polynomial, logarithmic, piecewise, and soft-cap alternatives over the same range, using marginal gain, time-to-target, and reset-cost measures before selecting a model.

## Theoretical Context and System Function

This skill formalizes ludic engagement systems based on positive feedback loops, where accumulation of a primary resource $Q$ directly increments the generation rate of that same resource. The fundamental accumulation dynamics over time are governed by the differential equation:

$$\frac{d Q(t)}{dt} = f(Q) = k \cdot Q(t)^\alpha$$

where $\alpha \ge 1$ is the acceleration coefficient and $k > 0$ is the base infrastructure efficiency.

The objective of the agent when executing this skill is to calculate the system's growth trajectory, prevent uncontrolled accumulation from reaching computational data type limits, and structure reset layers (*Prestige*) to convert accumulated quantity into permanent multipliers.

---

## 1. Integrated Processing Protocol

When activating this skill, the agent must sequentially execute the following analytical stages:

### Stage 1: Cost Scaling Curve Definition

1. Map the cost $C_n$ for acquiring the $n$-th unit of a resource-generating source:

$$C(n) = C_0 \cdot r^n$$

where $C_0$ is the base cost and $r > 1$ is the geometric scaling ratio (typically $r \in [1.07, 1.15]$).
2. Calculate the cumulative cost $C_{\text{total}}$ to acquire $k$ units at once starting from current quantity $n$:

$$C_{\text{total}}(n, k) = C_0 \cdot \frac{r^n \cdot (r^k - 1)}{r - 1}$$

### Stage 2: Positive Feedback Equation and Gross Rate ($GPS$)

1. Define the gross generation per second ($GPS$) or per cycle as the weighted sum of all active sources:

$$GPS(t) = \left( \sum_{i=1}^{m} u_i \cdot g_i \right) \cdot M_{\text{global}}$$

where $u_i$ is the quantity of units of source $i$, $g_i$ is the individual base generation rate, and $M_{\text{global}}$ is the combined multiplier of all system upgrades.
2. Formulate the **Return on Investment Time ($ROI$)** for purchasing the $n$-th unit of source $i$:

$$ROI_i(n) = \frac{C_i(n)}{\Delta GPS_i} = \frac{C_{0,i} \cdot r_i^n}{g_i \cdot M_{\text{global}}}$$

The agent uses $ROI$ to evaluate the optimal purchase decision from the player's perspective.

### Stage 3: Prestige / Reset Layer Formulation

1. When progress rate approaches a practical asymptote due to high cost $C(n)$, the system offers a reset mechanic that clears $Q$ and $u_i$ in exchange for a prestige resource $P$.
2. Formalize the conversion function of total historical accumulation $Q_{\text{total}}$ into prestige resource $P$:

$$P(Q_{\text{total}}) = \left\lfloor a \cdot \left( \frac{Q_{\text{total}}}{10^b} \right)^\gamma \right\rfloor$$

where $\gamma \in (0, 1)$ (frequently $\gamma = 0.5$ for square root), ensuring diminishing returns per reset.
3. Map the injection of prestige resource $P$ into the global multiplier:

$$M_{\text{prestige}} = 1 + (P \cdot \beta)$$

where $\beta > 0$ is the percentage bonus per prestige unit.

---

## 2. Algorithmic Detection of Balancing Anomalies

The agent must apply the following logical verifications on the exponential model:

### A. Numeric Overflow Prevention

$$Q(t) > \text{MaxValue}(\text{Float64}) \approx 1.79 \times 10^{308}$$

Action: If the time to reach the numerical limit of the programming language's data type is $t < t_{\text{expected}}$, the agent must require implementation of custom scientific notation representation (*BigNumber*) or adjust the ratio $r$.

### B. Insurmountable Progression Wall

$$\exists n \quad \text{such that} \quad ROI(n) > t_{\text{session, max}}$$

Action: Flag if the wait time to acquire a single next upgrade exceeds the acceptable user retention window without a prestige option being available.

### C. Premature Prestige Devaluation

$$P(Q_{\text{total, 2nd reset}}) \le P(Q_{\text{total, 1st reset}})$$

Action: Verify if the prestige curve offers a real incremental gain that reduces the time needed to redo the initial progression.

---

## 3. Standard Analytical Output Format

When responding to the user, the agent must structure the analysis in the following format:

### 1. Generator Source Scaling Parameters

| Generator / Source | Base Cost ($C_0$) | Ratio ($r$) | Base Generation ($g_i$) | Initial $ROI$ ($n=1$) |
| --- | --- | --- | --- | --- |
| **[Source Level 1]** | $15$ | $1.15$ | $0.1$/s | $150$s |
| **[Source Level 2]** | $100$ | $1.15$ | $1.0$/s | $100$s |
| **[Source Level 3]** | $1100$ | $1.14$ | $8.0$/s | $137.5$s |

### 2. Feedback and Prestige Equations

* **Total Gross Generation ($GPS$):** [Mathematical formula with multipliers]
* **Prestige Resource Formula ($P$):** [Conversion formula $P(Q_{\text{total}})$]
* **Prestige Multiplier ($M_{\text{prestige}}$):** [Impact of $P$ on $GPS$]

### 3. Progression Projection and Diagnosis

* **Time to First Reset ($t_{\text{prestige1}}$):** [Estimated time in hours/days]
* **Progression Wall Diagnosis:** [Identification of extreme slowdown moments]
* **Recommended Parameter Adjustments:** [Adjustments to ratios $r$, costs $C_0$ or coefficients $\gamma$]

---

## Mathematical Status

### Formal Guarantees
Curve equations guarantee modeled growth only.

### Derived Metrics
Compare linear, polynomial, exponential and logistic families, and measure upgrade time while income also grows.

### Heuristics and Design Judgments
Derived metrics include marginal cost, time-to-upgrade, reset ROI and pacing variance.

### Required Simulation or Playtesting
Heuristics tune motivation. Required simulation or playtesting: long-horizon simulation and progression cohorts.

## Hypotheses and Limitations

- Assumes rates, costs, precision, and reset accounting use compatible units and that offline progress is modeled explicitly.
- Overflow and retention risks are conditional on session length, implementation numeric type, and player behavior; simulate representative trajectories.

## 4. Procedure Execution Example

If the user requests: *"Create an incremental curve where generator 1 costs 10 and generates 1 per second with ratio 1.10, and define a prestige reset formula for when the player reaches 1,000,000 total coins."*

The agent applying this skill calculates:

- $C(n) = 10 \cdot (1.10)^n$
- $g_1 = 1.0$/s
- $GPS(n) = n \cdot 1.0 \cdot M_{\text{global}}$
- Cost for 100 units of generator 1:

$$C_{\text{total}}(0, 100) = 10 \cdot \frac{1.10^{100} - 1}{0.10} \approx 1.378 \times 10^6 \text{ coins}$$

- **Prestige Formula:**

$$P(Q_{\text{total}}) = \left\lfloor \sqrt{\frac{Q_{\text{total}}}{1000}} \right\rfloor$$

- For $Q_{\text{total}} = 1,000,000$:

$$P = \lfloor \sqrt{1000} \rfloor = 31 \text{ Prestige Crystals}$$

- If $\beta = 0.05$ (+$5\%$ bonus per crystal):

$$M_{\text{prestige}} = 1 + (31 \cdot 0.05) = 2.55 \quad (\text{155\% increase in } GPS)$$