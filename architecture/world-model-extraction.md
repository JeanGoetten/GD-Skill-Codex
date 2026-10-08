# World Model Extraction Protocol

How an agent turns a natural-language description of a game into a world model that the
skills can check. This is the step the runtime cannot do for you: the executors only check a
world model that already exists.

## Output contract

The result is one JSON object validated against `architecture/world-model.schema.json`.
It has 12 required top-level keys and no others:

`entities`, `resources`, `spatial`, `temporal`, `rules`, `knowledge`, `progression`,
`economy`, `actors`, `actions`, `goals`, `hidden_state`.

Optional: `version`, `ontology`.

Check it with `node bin/gd-codex.js validate --world <file>`. A world model that does not
pass the schema is not usable, whatever the description says.

## Procedure

1. **Inventory what the description states.** List the entities, resources, actions and
   goals that are named explicitly. Mark each as `stated`.
2. **Mark what is inferred.** Anything you add to fill a structure but that the description
   does not say is `inferred`. Keep the two lists apart.
3. **Declare the unknowns.** A value the description does not give is `unknown`, not a
   plausible number. Leave it out of the model and list it under `limitations` or in the
   answer.
4. **Fill `hidden_state` only for the skills the request needs.** Look up the key for each
   skill with `node bin/gd-codex.js skill <id>` (the `hidden_state_key` field). Do not fill
   slices for skills that were not asked about.
5. **Validate, then read the errors.** `validate --skill <id>` reports missing or malformed
   slices. Fix only what the errors name. Do not add fields to make an error disappear.
6. **Answer with the epistemic status.** Every conclusion you draw from the model is
   `formal`, `derived`, `heuristic` or `empirical` (see `AGENTS.md`). If a required input
   is `unknown`, the honest answer for that part is `INSUFFICIENT_EVIDENCE`.

## Rules

- Never invent a number to make a skill run. A threshold, rate or cost that the description
  does not give is a gap to report, not a value to fill in.
- Do not copy a franchise into the model as a fact about the user's game. A reference game
  is an anchor for intuition, not evidence about this design.
- Keep `stated` and `inferred` separate in your reasoning, and say which one a conclusion
  depends on.
- A declared threshold overrides the executor default. Say so when you declare one, because
  the default is a heuristic (`architecture/threshold-provenance.json`).

## Minimal valid skeleton

The skeleton below has the 12 required keys with no content and a single `hidden_state` slice.
It is the starting point for a new world model. It is checked by
`architecture/tests/extraction_guide.test.js`, so it stays valid.

```json
{
  "entities": [],
  "resources": [],
  "spatial": {},
  "temporal": {},
  "rules": [],
  "knowledge": {},
  "progression": {},
  "economy": {},
  "actors": [],
  "actions": [],
  "goals": [],
  "hidden_state": {}
}
```

## Worked example

`architecture/examples/nested-gameplay-loop-architecture.example.json` is a complete model
for the loop-architecture skill. Read it as a reference for shape and granularity, not as
a template to copy values from.
