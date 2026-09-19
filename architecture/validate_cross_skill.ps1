$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$registry = Get-Content -Encoding UTF8 (Join-Path $root 'skill-registry.json') -Raw | ConvertFrom-Json
$missingRoleFields = @($registry.skills | Where-Object { -not $_.domain_role -or -not $_.routing_role })
if ($missingRoleFields.Count -gt 0) { throw "Skills sem domain_role/routing_role: $($missingRoleFields.id -join ', ')" }
$handoffs = Get-Content -Encoding UTF8 (Join-Path $root 'handoffs.json') -Raw | ConvertFrom-Json
$skillsRoot = Join-Path (Split-Path $root -Parent) 'GD-Skill-Codex'
$ids = @($registry.skills | ForEach-Object { $_.id })
$errors = [System.Collections.Generic.List[string]]::new()
if ($ids.Count -ne 15 -or ($ids | Sort-Object -Unique).Count -ne 15) { $errors.Add('registry deve conter exatamente 15 ids únicos') }
foreach ($skill in $registry.skills) {
    foreach ($target in @($skill.complements)) {
        if ($ids -notcontains $target) { $errors.Add("$($skill.id): complemento inexistente $target") }
    }
    foreach ($field in @('explicit', 'semantic', 'structural', 'anti_signals')) {
        if (-not $skill.activation.PSObject.Properties.Name.Contains($field)) { $errors.Add("$($skill.id): activation sem $field") }
    }
    if (-not (Test-Path (Join-Path (Join-Path $skillsRoot $skill.id) 'SKILL.md'))) { $errors.Add("skill sem SKILL.md: $($skill.id)") }
}
foreach ($handoff in $handoffs.handoffs) {
    if (-not $handoff.PSObject.Properties.Name.Contains('return_to')) { $errors.Add("handoff sem return_to: $($handoff.source) -> $($handoff.target)") }
    if (-not $handoff.PSObject.Properties.Name.Contains('iteration')) { $errors.Add("handoff sem iteration: $($handoff.source) -> $($handoff.target)") }
    if ($handoff.iteration.max_cycles -lt 1) { $errors.Add("handoff com max_cycles inválido: $($handoff.source) -> $($handoff.target)") }
    if ($ids -notcontains $handoff.return_to) { $errors.Add("handoff com return_to inválido: $($handoff.return_to)") }
}
if ($errors.Count) { $errors | ForEach-Object { Write-Error $_ }; exit 1 }
Write-Output "OK: registry com 15 skills e consistência cross-skill verificada."
