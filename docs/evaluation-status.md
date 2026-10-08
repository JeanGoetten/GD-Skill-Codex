# External evaluation status

Protocol: [`research-validity.md`](research-validity.md). Record format:
[`architecture/schemas/external-case.schema.json`](../architecture/schemas/external-case.schema.json).

## Current status

| Requirement | Target | Recorded | Status |
|---|---|---|---|
| External cases (3 per skill: positive, negative, ambiguous) | 45 | 0 | not started |
| Independent raters per case | 2 | 0 | not started |
| Cases recorded before Codex output is shown | all | 0 | not started |
| Observed empirical outcomes | per skill | 0 | not started |

No confidence level in the framework is calibrated against observed outcomes. The
`low`, `medium` and `high` labels are ordinal design judgments.

## What blocks this

Collecting cases requires two independent game designers per case, who record their expected
diagnosis before seeing the Codex result. This cannot be produced by the repository or by an
AI agent authoring the cases, because an agent-authored case is not external evidence.

## Steps to start

1. Recruit at least two designers who did not author any fixture.
2. For each skill, write one positive, one negative and one ambiguous system description.
3. Each designer records an expected diagnosis in a case file that validates against the schema.
4. Only then run the Codex on the description and record the result in the same file.
5. Update the table above. Agreement is recorded per case; calibration waits for outcomes.
