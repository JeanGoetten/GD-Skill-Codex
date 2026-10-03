# Benchmarks

`routing-cases.json` is an internal routing regression set. It does not count as
independent empirical evidence because its prompts are authored from the same
taxonomy as the registry.

Run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File architecture/evaluate_routing.ps1
```

External cases should be stored under `benchmarks/cases/` with anonymized
project context, pre-registered expected routing from independent reviewers,
and permission to redistribute the material.
