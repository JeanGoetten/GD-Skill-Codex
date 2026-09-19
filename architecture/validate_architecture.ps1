$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$worldModel = Get-Content -Encoding UTF8 (Join-Path $root 'world-model.schema.json') -Raw | ConvertFrom-Json
$registry = Get-Content -Encoding UTF8 (Join-Path $root 'handoffs.json') -Raw | ConvertFrom-Json
$skillRegistry = Get-Content -Encoding UTF8 (Join-Path $root 'skill-registry.json') -Raw | ConvertFrom-Json
$calibrationDefaults = Get-Content -Encoding UTF8 (Join-Path $root 'calibration.defaults.json') -Raw | ConvertFrom-Json
$evidenceSchema = Get-Content -Encoding UTF8 (Join-Path $root 'evidence.schema.json') -Raw | ConvertFrom-Json
$skillsRoot = Join-Path (Split-Path $root -Parent) 'GD-Skill-Codex'
$skillNames = @(Get-ChildItem -LiteralPath $skillsRoot -Directory | Select-Object -ExpandProperty Name)
$errors = [System.Collections.Generic.List[string]]::new()

foreach ($field in $worldModel.required) {
    if (-not $worldModel.properties.PSObject.Properties.Name.Contains($field)) {
        $errors.Add("world model sem propriedade obrigatória: $field")
    }
}

foreach ($handoff in $registry.handoffs) {
    if ($skillNames -notcontains $handoff.source) { $errors.Add("source inexistente: $($handoff.source)") }
    if ($skillNames -notcontains $handoff.target) { $errors.Add("target inexistente: $($handoff.target)") }
    foreach ($field in @('relation', 'when', 'input', 'expected_output')) {
        if (-not $handoff.PSObject.Properties.Name.Contains($field)) { $errors.Add("handoff sem $field") }
    }
}
if ($skillRegistry.skills.Count -ne 15) {
    $errors.Add("skill registry deve conter 15 skills")
}
foreach ($skill in $skillRegistry.skills) {
    if (-not $skill.PSObject.Properties.Name.Contains('activation')) { $errors.Add("$($skill.id): activation ausente") }
    if (-not $skill.PSObject.Properties.Name.Contains('inputs')) { $errors.Add("$($skill.id): inputs ausente") }
    if (-not $skill.PSObject.Properties.Name.Contains('outputs')) { $errors.Add("$($skill.id): outputs ausente") }
}
foreach ($record in $calibrationDefaults) {
    foreach ($field in @('parameter', 'value', 'status', 'confidence', 'requires_validation')) {
        if (-not $record.PSObject.Properties.Name.Contains($field)) { $errors.Add("calibration sem $field") }
    }
    foreach ($status in @('formal', 'derived', 'heuristic', 'empirical', 'observed', 'assumed', 'unknown', 'contradicted', 'validated', 'INSUFFICIENT_EVIDENCE')) {
        if ($evidenceSchema.properties.status.enum -notcontains $status) { $errors.Add("evidence status ausente: $status") }
    }
}

if ($errors.Count) { $errors | ForEach-Object { Write-Error $_ }; exit 1 }
Write-Output "OK: world model e $($registry.handoffs.Count) handoffs tipados passaram na validação."
