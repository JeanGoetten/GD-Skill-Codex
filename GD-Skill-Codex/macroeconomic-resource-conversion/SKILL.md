---
name: macroeconomic-resource-conversion
description: Maps and balances complex resource conversion matrices, internal exchange markets, and hyperinflation containment systems. Use this skill when the user requests: (1) design of multi-input composite production chains, (2) modeling of resource Input-Output matrices, (3) dynamic pricing by supply and demand in virtual markets, or (4) dampening of macroeconomic shocks and combating ludic hyperinflation.
domain:
  primary:
    - macroeconomics
    - resource conversion
activation_signals:
  concepts:
    - input-output matrix
    - Leontief
    - conversion bottleneck
  recognition_references:
    - "Civilization"
    - "EVE Online"
    - "Anno"
outputs:
  - production matrix
  - dependency analysis
  - scenario recommendations
handoffs:
  downstream:
    - resource-flow-economy
    - exponential-progression-and-prestige
    - competitive-negative-feedback
exclusions:
  - franchise-specific canon
  - unvalidated claims
---

# Macroeconomic Resource Conversion: Production Matrices

## Domain

input-output matrices, production chains and bottlenecks.

## Purpose

analyze multi-tier conversion, capacity and shocks across producers and sinks.

## Activation Signals

input-output matrix; conversion ratio; bottleneck; sink; throughput; recognition anchors: Civilization; EVE Online; Anno.

## Scope

production matrices and tier sensitivity.

## Exclusions

This skill does not resolve moment-to-moment pacing and narrative resource meaning.

## Handoff Conditions

When the problem crosses its boundary, hand off to: resource-flow-economy; exponential-progression-and-prestige; competitive-negative-feedback.

## Handoff Candidates

- **resource-flow-economy** — when the question reduces to single-tier stock and flow balance without intermediate goods, hand off the simplified model for flow analysis.
- **exponential-progression-and-prestige** — when conversion efficiency feeds long-run player growth curves, hand off the growth model for trajectory analysis.
- **competitive-negative-feedback** — when wealth gaps between players are the concern rather than absolute prices, hand off the relative positions for feedback analysis.
## Recognition References

These are semantic anchors only, not content to reproduce: Civilization; EVE Online; Anno.

## Theoretical Context and System Function

This skill formalizes complex economic systems characterized by multi-factorial production chains, inter-agent exchange markets, and large-scale monetary circulation. The transformation of raw materials and intermediate inputs into finished products is described by the matrix of theoretical production coefficients $K$:

$$K \cdot \mathbf{R}_{\text{input}} \longrightarrow \mathbf{R}_{\text{product}}$$

where $K$ is a matrix of dimension $m \times n$: rows index inputs and columns index products, so $K_{ij}$ is the quantity of input $i$ required per unit of product $j$.

The objective of the agent is to ensure supply chain integrity, prevent systemic liquidity failures, and design dynamic economic drains to stabilize the real value of the game's currency.

---

## 1. Integrated Processing Protocol

When activating this skill, the agent must sequentially execute the following macroeconomic analysis stages:

### Stage 1: Input-Output Matrix Formalization

1. Catalog the vector of primary raw materials $\mathbf{R}_{\text{primary}}$, intermediate goods $\mathbf{R}_{\text{intermediate}}$, and final products $\mathbf{R}_{\text{final}}$.
2. Structure the Conversion Matrix $K$ with $\mathbf{x}\in\mathbb{R}^{m}$ (input quantities), $\mathbf{y}\in\mathbb{R}^{n}$ (product quantities), and $K\in\mathbb{R}^{m\times n}$:

$$\mathbf{x}\ \ge\ K\mathbf{y}, \qquad K=\begin{bmatrix} k_{1,1} & \cdots & k_{1,n}\\ \vdots & \ddots & \vdots\\ k_{m,1} & \cdots & k_{m,n}\end{bmatrix},\quad \mathbf{x}\in\mathbb{R}^{m},\ \mathbf{y}\in\mathbb{R}^{n}$$

3. Add the technological efficiency factor or process loss rate $\boldsymbol{\eta} \in (0,1]^n$ (one entry per product; use a scalar $\eta$ only when all products share the same yield, in which case ordinary multiplication replaces the Hadamard product):

$$\mathbf{y}_{\text{effective}} = \boldsymbol{\eta} \odot \mathbf{y}, \qquad \mathbf{x}_{\text{required}} = K\mathbf{y}$$

4. For multi-tier goods whose outputs are also inputs, formalize the square Leontief intermediate-use form over the $n$ produced goods:

$$\mathbf{z} = A\mathbf{z} + \mathbf{d}$$

where $A \in \mathbb{R}^{n\times n}$ holds per-unit intermediate consumption, $\mathbf{z} \in \mathbb{R}^n$ is gross output (a distinct vector from the input quantities $\mathbf{x} \in \mathbb{R}^m$ of step 2 — do not reuse the symbol), and $\mathbf{d}$ is final demand. The total-requirements matrix $(I - A)^{-1}$ gives the gross output needed per unit of final demand (the Leontief multipliers used for ripple-effect analysis), and the economy is structurally productive if and only if the Hawkins–Simon condition holds: every leading principal minor of $(I - A)$ is positive. A violated Hawkins–Simon condition is a hard infeasibility certificate for the production graph — some demand vector cannot be met at any scale.

### Stage 2: Transaction Mechanisms and Dynamic Pricing

1. Model price formation of a good $j$ in an exchange market based on the relation between supply ($S_j$) and demand ($D_j$). Use the *relative* excess demand normalized by total market activity, which stays defined when $S_j = 0$ and keeps the multiplicative factor positive for $\gamma \le 1$:

$$P_j(t+1) = \mathrm{clamp}\left(P_j(t) \cdot \left(1 + \gamma \cdot \frac{D_j(t) - S_j(t)}{D_j(t) + S_j(t)}\right),\ P_{\min},\ P_{\max}\right)$$

where $0 < \gamma \le 1$ is the market sensitivity to inventory imbalance. If the absolute-excess form $(D_j - S_j)/S_j$ is retained instead, guard the division ($S_j = 0$ is exactly the interesting case: a new or collapsed market — treat it as maximal upward pressure), note that the factor turns negative only when surplus exceeds $S_j/\gamma$ (which additionally requires $\gamma > 1$, since $(D_j - S_j)/S_j > -1$ always), and still declare $P_{\min} > 0$ and $P_{\max}$ per market.
2. Define transaction fees and market taxes ($T_{\text{market}}$) acting as currency drains on every completed trade.

### Stage 3: Quantity Theory of Money and Circulation Velocity

1. Evaluate the monetary exchange equation in the game universe:

$$M \cdot V = P \cdot Y$$

where $M$ is the total money supply in circulation, $V$ is the velocity of money circulation, $P$ is the general price level, and $Y$ is the aggregate real output (income form of the equation; the transactional form $MV = PT$ uses the number of transactions $T$ instead — declare which form the analysis adopts).
2. Monitor the net money emission rate from system Sources ($\Delta M_{\text{source}}$) compared to money destruction by code-imposed Drains ($\Delta M_{\text{drain}}$).

---

## 2. Algorithmic Detection of Macroeconomic Anomalies

The agent must analyze the economic matrix and flag the following systemic risks:

### A. Monetary Expansion from Source Imbalance

$$\Delta M_{\text{source}} \gg \Delta M_{\text{drain}} \implies \frac{d M}{dt} > 0 \quad (\text{precondition for price growth})$$

Action: Identify uncontrolled liquidity accumulation. By $M V = P Y$, sustained monetary growth raises the price level only while $V$ and $Y$ remain fixed; both are behavioral, so treat $dM/dt > 0$ as a risk signal, not a price proof (reserve "hyperinflation" for observed price series, in the technical sense of Cagan). Design automatic and proportional drains to agent wealth (e.g., asset maintenance fees, progressive manufacturing costs).

### B. Chain Disruption by Bottleneck Input (*Bottleneck Resource*)

$$\exists R_{\text{input, i}} \quad \text{such that} \quad \text{Supply}(R_i) = 0 \implies \text{Production}(\mathbf{R}_{\text{final}}) = 0$$

Action: Flag if absolute scarcity of a single secondary input halts production of the entire game tech tree.

### C. Deflationary Spiral / Market Paralysis

$$\Delta M_{\text{drain}} > \Delta M_{\text{source}} \implies \text{Liquidity Shortage}$$

Action: Detect when tax costs and drains remove excess money from the system, preventing agents from trading due to lack of payment medium. Under $MV = PY$ with sticky prices, monetary contraction predicts a fall in transacted volume $Y$ (or in $P$); $V$ is behavioral and is *not* implied — report $V \to 0$ only as an observed empirical trend, never as a formal consequence.

---

## 3. Standard Analytical Output Format

When responding to the user, the agent must present data in the following structure:

### 1. Conversion and Input Matrix ($K$)

| Final Product ($R_{\text{final}}$) | Input $R_1$ Required | Input $R_2$ Required | Processing Time | Yield ($\eta$) |
| --- | --- | --- | --- | --- |
| **[Item A]** | $k_{1,1}$ units | $k_{2,1}$ units | $[T$ seconds$]$ | $[\eta_1\%]$ |
| **[Item B]** | $k_{1,2}$ units | $k_{2,2}$ units | $[T$ seconds$]$ | $[\eta_2\%]$ |

### 2. Global Monetary Balance ($M \cdot V = P \cdot Y$)

* **Total Money Supply ($M$):** [Volume of currency in circulation]
* **Gross Injection ($\Delta M_{\text{source}}$):** [Rate of money creation per period]
* **Total Drains ($\Delta M_{\text{drain}}$):** [Rate of money destruction by taxes/fees]
* **Net Monetary Flow ($\frac{dM}{dt}$):** [Net emission: EXPANSIONARY / CONTRACTIONARY / BALANCED — price trend conclusions additionally require observed $V$ and $Y$]

### 3. Tax Matrix and Recommended Adjustment Drains

* **Transaction Fee ($T_{\text{market}}$):** [Percentage collected per transaction]
* **Accumulated Wealth Drains:** [Operational costs of high-value assets]
* **Corrective Actions:** [Adjustments to input tables $K$ or absorption rates $M$]

---

## Mathematical Status

### Formal Guarantees
Input-output balance applies to the declared matrix and demand vector, not price formation or adaptation.

### Derived Metrics
Derived metrics include Leontief multipliers, bottleneck sensitivity and surplus.

### Heuristics and Design Judgments
Heuristics judge resilience.

### Required Simulation or Playtesting
Required simulation or playtesting: demand shocks, substitution scenarios and economy playtests.

## Hypotheses and Limitations

- Assumes input rows and product columns remain fixed, units are compatible, and yields/losses are measured per production batch.
- The intermediate-use form, multipliers and the Hawkins–Simon condition follow Leontief (1941/1966); see Miller & Blair, *Input-Output Analysis*, for the full treatment.
- Price and inflation risks are conditional on modeled supply, demand, velocity, and player behavior; validate with time-series data.

## 4. Procedure Execution Example

If the user requests: *"Design a production chain where 1 Ship requires 100 Metal and 20 Crystal. The market has a daily injection rate of 1,000,000 coins from missions and only 200,000 destroyed by ship destruction. Adjust the system."*

The agent applying this skill processes:

- **Conversion Matrix:**

$$K = \begin{bmatrix} 100 & (\text{Metal}) \\ 20 & (\text{Crystal}) \end{bmatrix} \longrightarrow 1 \text{ Ship}$$

- **Monetary Analysis:**

$$\Delta M_{\text{source}} = +1,000,000/\text{day}, \quad \Delta M_{\text{drain}} = -200,000/\text{day}$$

$$\frac{dM}{dt} = +800,000\text{ coins/day} \quad (\text{sustained net emission; price-level risk})$$

- **Proposed Systemic Adjustment:**
  1. Add production registration tax per factory: $T_{\text{fab}} = 500,000\text{ coins/day}$.
  2. Implement 10% market sales tax on Metal and Crystal transactions ($T_{\text{market}} \approx 300,000\text{ coins/day}$).
  3. Post-adjustment result: $\frac{dM}{dt} = 1,000,000 - (200,000 + 500,000 + 300,000) = 0$ (zero net emission achieved; a price-trend conclusion still requires observed $V$ and $Y$).