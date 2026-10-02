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
    - "Cookie Clicker"
    - "Diablo"
    - "incremental ascension systems"
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

When the problem crosses its boundary, hand off to: resource-flow-economy; macroeconomic-resource-conversion; competitive-negative-feedback.

## Handoff Candidates

- **resource-flow-economy** — when growth rates depend on accumulable resource stocks and flows, hand off the economy model for flow-balance analysis.
- **macroeconomic-resource-conversion** — when multi-tier production chains feed the progression curves, hand off the conversion matrix for input-output analysis.
- **competitive-negative-feedback** — when catch-up mechanisms must dampen progression gaps between players, hand off the gap dynamics for feedback analysis.
## Recognition References

These are semantic anchors only, not content to reproduce: Cookie Clicker; Diablo; incremental ascension systems.

## Curve-Family Clarification

“Exponential” is a family of curves, not a single mandatory formula: parameters, bases, offsets, and piecewise regimes change its behavior. Always compare it against linear, polynomial, logarithmic, piecewise, and soft-cap alternatives over the same range, using marginal gain, time-to-target, and reset-cost measures before selecting a model.

## Theoretical Context and System Function

This skill formalizes ludic engagement systems based on positive feedback loops, where accumulation of a primary resource $Q$ can increment the generation rate of that same resource. A continuous idealization of that feedback is the differential equation:

$$\frac{d Q(t)}{dt} = f(Q) = k \cdot Q(t)^\alpha$$

where $k > 0$ and $\alpha$ is the acceleration coefficient ($\alpha = 1$: constant relative growth rate — exponential, not accelerating in relative terms; $\alpha > 1$: super-exponential growth, which blows up to infinity in finite time $t^* = Q_0^{1-\alpha}/(k(\alpha-1))$ — relevant to the overflow check below). This ODE is a conceptual backdrop only: the operative model of this skill is the *discrete* purchase loop of Stages 1–2 (linear income in units owned, geometric cost), which does not satisfy the ODE. Do not substitute one for the other in calculations.

The objective of the agent when executing this skill is to calculate the system's growth trajectory, prevent uncontrolled accumulation from reaching computational data type limits, and structure reset layers (*Prestige*) to convert accumulated quantity into permanent multipliers.

---

## 1. Integrated Processing Protocol

When activating this skill, the agent must sequentially execute the following analytical stages:

### Stage 1: Cost Scaling Curve Definition

1. Map the cost $C_n$ for acquiring a unit of a resource-generating source. Convention: units are **0-indexed** — the first unit is $n = 0$ and costs $C_0$:

$$C(n) = C_0 \cdot r^n, \qquad n = 0, 1, 2, \dots$$

where $C_0$ is the base cost (cost of the first unit) and $r > 1$ is the geometric scaling ratio (typically $r \in [1.07, 1.15]$). All derived quantities ($C_{\text{total}}$, $ROI$, tables) must use the same indexing convention; with this convention the first unit costs $C_0$, not $C_0 \cdot r$.
2. Calculate the cumulative cost $C_{\text{total}}$ to acquire $k$ units at once starting from current quantity $n$ (0-indexed):

$$C_{\text{total}}(n, k) = C_0 \cdot \frac{r^n \cdot (r^k - 1)}{r - 1}$$

### Stage 2: Positive Feedback Equation and Gross Rate ($GPS$)

1. Define the gross generation per second ($GPS$) or per cycle as the weighted sum of all active sources:

$$GPS(t) = \left( \sum_{i=1}^{m} u_i \cdot g_i \right) \cdot M_{\text{global}}$$

where $u_i$ is the quantity of units of source $i$, $g_i$ is the individual base generation rate, and $M_{\text{global}}$ is the combined multiplier of all system upgrades.
2. Formulate the **Return on Investment Time ($ROI$)** for purchasing the next unit of source $i$ (payback of the *marginal* generation the purchase adds):

$$ROI_i(n) = \frac{C_i(n)}{\Delta GPS_i} = \frac{C_{0,i} \cdot r_i^n}{g_i \cdot M_{\text{global}}}$$

The agent uses $ROI$ to evaluate the optimal purchase decision from the player's perspective. $ROI$ is a **payback time** and must not be conflated with the *time-to-afford* $t_{\text{wait}}(n) = C_i(n)/GPS(t)$ — the wall-time for the player to accumulate the cost from current income. They diverge precisely near a progression wall: $t_{\text{wait}}$ explodes while $GPS$ stagnates, whereas $ROI$ can even improve. Use $t_{\text{wait}}$ to diagnose walls and $ROI$ to rank purchases.

### Stage 3: Prestige / Reset Layer Formulation

1. When progress rate approaches a practical asymptote due to high cost $C(n)$, the system offers a reset mechanic that clears $Q$ and $u_i$ in exchange for a prestige resource $P$.
2. Formalize the conversion function of total historical accumulation $Q_{\text{total}}$ into prestige resource $P$:

$$P(Q_{\text{total}}) = \left\lfloor a \cdot \left( \frac{Q_{\text{total}}}{10^b} \right)^\gamma \right\rfloor$$

where $\gamma \in (0, 1)$, ensuring diminishing returns per reset. The exponent is a design parameter, not a constant of nature — published games vary ($\gamma = 1/2$ in several idle titles, $\gamma = 1/3$ in Cookie Clicker); declare the chosen value and calibrate it against playtest retention data instead of treating any single value as typical.
3. Map the injection of prestige resource $P$ into the global multiplier:

$$M_{\text{prestige}} = 1 + (P \cdot \beta)$$

where $\beta > 0$ is the percentage bonus per prestige unit.

---

## 2. Algorithmic Detection of Balancing Anomalies

The agent must apply the following logical verifications on the exponential model:

### A. Numeric Overflow and Precision Loss Prevention

$$Q(t) > 2^{53} \approx 9.007 \times 10^{15} \quad \text{(integer precision limit of IEEE-754 double)}$$

Action: $2^{53}$ is the last integer exactly representable in a Float64; beyond it, additions and cost accumulations silently lose precision — counters, rankings and comparisons corrupt long before the representability ceiling of $\approx 1.79 \times 10^{308}$. If the time to cross $2^{53}$ is $t < t_{\text{expected}}$, require a BigNumber/custom scientific-notation representation (or adjust the ratio $r$); treat the $1.79 \times 10^{308}$ bound only as the hard overflow fallback.

### B. Insurmountable Progression Wall

$$\exists n \quad \text{such that} \quad t_{\text{wait}}(n) = \frac{C(n)}{GPS(t)} > t_{\text{session, max}}$$

Action: Flag if the *wait time to afford* the single next upgrade (cost divided by current income — not the marginal payback $ROI$) exceeds the acceptable user retention window without a prestige option being available. Report both $t_{\text{wait}}(n)$ and $ROI(n)$: a wall shows $t_{\text{wait}} \to \infty$ with stagnant $GPS$.

### C. Premature Prestige Devaluation

With $Q_{\text{total}}$ defined as lifetime accumulation (Stage 3), $P(Q_{\text{total, 2nd}}) > P(Q_{\text{total, 1st}})$ holds by monotonicity — comparing absolute prestige totals is vacuous. The design question is whether the *marginal* gain per reset justifies the re-progression time:

$$\frac{P(Q_{\text{total, k+1}}) - P(Q_{\text{total, k}})}{t_{\text{reprogression, k}}} \to 0$$

Action: Flag when the marginal prestige per unit of re-progression time collapses toward zero (the reset stops being worth performing) — verify by computing $\Delta P$ between consecutive resets against the measured time to redo the initial progression.

---

## 3. Standard Analytical Output Format

When responding to the user, the agent must structure the analysis in the following format:

### 1. Generator Source Scaling Parameters

| Generator / Source | Base Cost ($C_0$) | Ratio ($r$) | Base Generation ($g_i$) | Initial $ROI$ ($n=0$) |
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