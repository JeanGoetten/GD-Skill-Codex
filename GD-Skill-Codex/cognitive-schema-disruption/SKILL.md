---
name: cognitive-schema-disruption
description: Models intentional cognitive schema disruption, rule expectation subversion, and cognitive accommodation induction in digital games. Use this skill when the user requests: (1) design of mechanical or narrative expectation-breaking moments, (2) modeling of transition functions with deliberate cognitive noise, (3) analysis of player's predictive mental models versus actual system response, or (4) balancing tension between engagement through dissonance and frustration from rejection.
domain:
  primary:
    - cognitive schemas
    - expectation disruption
activation_signals:
  concepts:
    - prediction error
    - Bayesian update
    - KL divergence
  recognition_references:
    - "The Witness"
    - "Portal"
    - "Outer Wilds"
outputs:
  - schema model
  - surprise analysis
  - calibrated disruption plan
handoffs:
  downstream:
    - epistemic-holarchic-progression
    - frame-based-combat-timing
    - procedural-expressive-range-analysis
exclusions:
  - franchise-specific canon
  - unvalidated claims
---

# Cognitive Schema Disruption: Reinterpretation and Learning

## Domain

expectation, surprise, dissonance, confusion, discovery and accommodation.

## Purpose

design coherent reinterpretation that targets discovery and accommodation rather than confusion.

## Activation Signals

schema; surprise; dissonance; confusion; discovery; accommodation; reinterpretation; recognition anchors: The Witness; Portal; Outer Wilds.

## Scope

expectation setup, evidence and model revision.

## Exclusions

This skill does not resolve plot authorship and accessibility testing.

## Handoff Conditions

When the problem crosses its boundary, hand off to: epistemic-holarchic-progression; frame-based-combat-timing; procedural-expressive-range-analysis.

## Handoff Candidates

- **epistemic-holarchic-progression** — when the disruption depends on which clues the player has actually integrated rather than which rules changed, hand off the knowledge state (holons, clues, known/unknown) for graph-level epistemic analysis.
- **frame-based-combat-timing** — when the expectation rupture targets input timing, cancel windows or frame legality rather than rules themselves, hand off the move data for frame-window analysis.
- **procedural-expressive-range-analysis** — when disrupted conventions must stay consistent across many generated variants, hand off the generator for expressive-range measurement of rupture density and bias.
## Recognition References

These are semantic anchors only, not content to reproduce: The Witness; Portal; Outer Wilds.

## Disruption Vocabulary

Separate the observable responses: **surprise** is an immediate prediction error; **dissonance** is sustained conflict between models; **confusion** is inability to select a workable interpretation; **discovery** is acquiring evidence for a rule; **accommodation** is restructuring the schema; and **reinterpretation** is assigning new meaning to prior evidence. A disruptive design should target discovery and accommodation, not confusion by default.

## Theoretical Context and System Function

This skill formalizes *Schematically Disruptive Design*, a cognitive-theoretical approach that deliberately manipulates the predictive mental schemas built by the agent during playful interaction. As the agent interacts with the system, they internally develop a probabilistic state transition model $P_{\text{cognitive}}(S_{t+1} \mid S_t, a_t)$.

Schematic disruption occurs when the system intentionally replaces the expected transition function $\delta_{\text{expected}}$ with a disruptive function $\delta_{\text{real}}$, generating a non-zero Kullback-Leibler divergence ($D_{\text{KL}}$) between mental expectation and actual computed state:

$$D_{\text{KL}}(P_{\text{real}} \parallel P_{\text{cognitive}}) = \sum_{s} P_{\text{real}}(s \mid S_t, a_t) \ln \left( \frac{P_{\text{real}}(s \mid S_t, a_t)}{P_{\text{cognitive}}(s \mid S_t, a_t)} \right)$$

For heterogeneous or mixed state spaces, define a common feature representation and metric first; use KL only for distributions over the same measurable outcomes. For continuous variables, use a density or an alternative divergence with matched units.

The objective of the agent is to design systematically coherent a posteriori noises and expectation breaks, forcing the player to shift from the **assimilation** process (fitting new events into old rules) to the **cognitive accommodation** process (reorganizing their own mental model of how the game functions).

---

## 1. Integrated Processing Protocol

When activating this skill, the agent must sequentially execute the following cognitive formalization stages:

### Stage 1: Convention Mapping and Schema Construction ($S_{\text{cognitive}}$)

1. Identify the established mechanical or narrative pattern in the game (e.g., "Dialoguing with a friendly NPC always grants a useful quest").
2. Formalize the mental schema as provisional rule inferences $\mathcal{I} = \{\text{Action } a \Rightarrow \text{likely Result } R\}$.
3. Measure **Accumulated Familiarity ($f_{\text{pattern}}$)**. Use $N_{\text{repetitions}} = 3$ as a low-confidence heuristic default, not a universal requirement; adjust for salience, consistency, feedback and prior knowledge.

### Stage 2: Disruption Point Injection ($\delta_{\text{disruptive}}$)

1. Defines the Disruption Trigger $T_{\text{disruption}}$ activated by a hidden conditional condition in state $S$.
2. Formulate the disruptive real transition:

$$\delta_{\text{real}}(S_t, a_t) = S_{\text{subverted}} \quad \text{where } S_{\text{subverted}} \neq \delta_{\text{expected}}(S_t, a_t)$$

3. Guarantee that the disruptive response alters strategic variables (agent attributes, narrative perception, or local rule state).

### Stage 3: Accommodation vs. Rejection Threshold Calculation ($\Delta_{\text{cognitive}}$)

1. Define Disruption Magnitude ($\Delta_{\text{mag}}$):

$$\Delta_{\text{mag}} = \lVert \phi(S_{\text{real}}) - \phi(S_{\text{expected}}) \rVert_W$$

Here $\phi$ maps heterogeneous state components into a common feature space and $\lVert\cdot\rVert_W$ is a declared, dimensionless weighted norm; do not subtract incomparable categorical, continuous, and narrative values ​​directly.

2. Evaluate post-disruption player behavior based on two theoretical limits:
   - **Accommodation Zone ($\Delta_{\text{mag}} \le \Delta_{\text{threshold}}$):** Prediction error provokes curiosity, strategic re-evaluation, and deep analytical engagement.
   - **Rejection / Dissonance Zone ($\Delta_{\text{mag}} > \Delta_{\text{threshold}}$):** Disruption is perceived as code failure (*bug*), arbitrary punishment, or systemic injustice.

### Stage 4: Retrospective Coherence Resolution (Systemic Justification)

1. Instantiate hidden clues ($P_{\text{hidden}}$) in the environment that make the disruption logically understandable *a posteriori*.
2. The disruptive transition must satisfy the hidden coherence invariant:

$$\Phi_{\text{hidden}}(S_t) = \text{True} \implies \delta_{\text{real}} \text{ is the only valid conclusion under deep mechanics}$$

---

## 2. Algorithmic Detection of Design Anomalies

The agent must analyze the disruption plan and flag the following structural failures:

### A. Subversion Without Prior Consolidation (*Premature Disruption*)

$$N_{\text{repetitions}} < N_{\text{default}} \land \text{low salience} \implies P_{\text{cognitive}} \text{ may be weak}$$

Here $N_{\text{default}}=3$ is a calibratable heuristic parameter. Strong genre
conventions, explicit tutorial reinforcement or highly salient repetition may
override it; record the override in the empirical calibration layer.

Action: Flag if expectation break is executed before player has assimilated the base rule, making the event imperceptible as subversion.

### B. Arbitrary Dissonance Without Retrospective Clues (*Arbitrary Randomness*)

$$\Phi_{\text{hidden}}(S_t) = \text{Undefined} \implies \text{Bug Perception}$$

Action: Alert if disruptive result lacks underlying logical justification in game rules, being perceived as a random software error.

### C. Frustration from Punishment Without Agency (*Punitive Disruption*)

$$\Delta_{\text{mag}} > \Delta_{\text{threshold}} \quad \land \quad S_{\text{real}} \text{ permanently removes agency capacity}$$

Action: Block designs where disruption serves only to destroy player progress without opening new gameplay or learning branches.

---

## 3. Standard Analytical Output Format

When responding to the user, the agent must present the specification in the following format:

### 1. Cognitive Schema Mapping

| Disruption Phase | Agent Action ($a_t$) | Expected Result ($S_{\text{expected}}$) | Real Disruptive Result ($S_{\text{real}}$) | Retrospective Hidden Clues |
| --- | --- | --- | --- | --- |
| **Consolidation Pattern** | [Action repeated $N$ times] | [Conventional result] | [Conventional result] | N/A |
| **Disruption Point** | [Trigger action] | [Predictable result] | [Subverted result] | [Clue A, Clue B present in state] |

### 2. Cognitive Divergence Metrics

* **Disruption Magnitude ($\Delta_{\text{mag}}$):** [Low / Medium / High]
* **Expectation Divergence ($D_{\text{KL}}$):** [Estimated cognitive impact value]
* **Threshold Status:** [WITHIN ACCOMMODATION ZONE / REJECTION RISK]

### 3. Impact Diagnosis and Recommendations

* **Effect Classification:** [COGNITIVE CURIOSITY / FRUSTRATING DISSONANCE / RULE REFRAMING]
* **Identified Incoherence Points:** [Identification of missing clues or excessive punishment]
* **Suggested Adjustments:** [Reinforcement of consolidation phase or addition of posterior revelation layers]

---

## Mathematical Status

### Formal Guarantees
The cognitive model is inferred, not directly observed; KL is asymmetric and requires the same event space, with direction and baseline declared.

### Derived Metrics
Derived metrics include prediction error, update magnitude and recovery time.

### Heuristics and Design Judgments
Heuristics judge legibility rather than arbitrariness.

### Required Simulation or Playtesting
Required simulation or playtesting: expectation elicitation, surprise ratings and comprehension retests.

## Hypotheses and Limitations

- Assumes the expected and real outcomes share a defined outcome space; heterogeneous states require a common feature representation before divergence or norm comparisons.
- Cognitive response thresholds are hypotheses, not universal constants; validate with observation and accessibility testing.

## 4. Procedure Execution Example

If the user requests: *"Create a mechanic where the player spends the entire game using a 'Logic' skill check to solve crimes, but in the final investigation Logic itself lies to the player."*

The agent applying this skill formalizes:

- **Initial Schema ($S_{\text{cognitive}}$):** The *Logic* skill is modeled as a highly reliable advisor ($P_{\text{expected}}$ near 1.0); the disruption risk is that players may treat this as certainty.
- **Consolidation Phase:** $N = 15$ successful checks where *Logic* provided correct clues.
- **Disruption Point ($T_{\text{disruption}}$):** Final suspect interrogation. *Logic* states: "He's lying because his pulse accelerated."
- **Disruptive Real Transition ($\delta_{\text{real}}$):** *Logic*'s statement is a rationalist delusion induced by the protagonist's own childhood trauma (hidden state variable $S_{\text{trauma}} = \text{True}$). *Logic*'s advice leads to a wrongful accusation.
- **Retrospective Hidden Clues:** Previous item descriptions in inventory indicated *Logic* became overly aggressive when dealing with certain family themes.
- **Analysis:** Disruption requires player to stop blindly trusting the game interface and start analyzing "Logic" as an imperfect character with their own agenda (Cognitive Accommodation).