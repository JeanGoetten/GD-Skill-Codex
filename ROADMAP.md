# Roadmap

This is the live roadmap. Historical implementation notes remain in
`docs/action-plan.md`.

## Current release gate

- [x] All public executor results pass `SkillOutput` validation.
- [x] Registry, handoffs, adapters, fixtures, evidence examples, and playtest
  contracts are validated by AJV or their semantic validators.
- [x] Pull requests and Pages deployment run the complete validation suite.
- [x] The local server uses allowlists, bounded requests, and loopback binding.
- [x] Generated catalog metadata contains roles and searchable concepts.
- [x] A routing benchmark is executable and versioned.
- [ ] Independent designers have evaluated recommendation usefulness.
- [ ] Confidence labels are calibrated against observational or playtest data.
- [ ] At least three external game projects reproduce the end-to-end workflow.

## Next research milestones

1. Collect the first external benchmark corpus under `benchmarks/cases/`.
2. Measure routing accuracy, inter-rater agreement, and recommendation utility.
3. Replace ordinal confidence where possible with calibrated probabilities and
   documented uncertainty intervals.
4. Publish a tagged release after external replication, without adding new
   skills until the current 15 have evidence-backed calibration.
