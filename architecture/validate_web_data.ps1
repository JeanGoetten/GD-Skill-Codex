$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path $root -Parent
$registry = Get-Content -Encoding UTF8 (Join-Path $root 'skill-registry.json') -Raw | ConvertFrom-Json
$handoffs = Get-Content -Encoding UTF8 (Join-Path $root 'handoffs.json') -Raw | ConvertFrom-Json
$data = Get-Content -Encoding UTF8 (Join-Path $projectRoot 'web\data.js') -Raw
$errors = [System.Collections.Generic.List[string]]::new()

foreach ($skill in $registry.skills) {
    if ($data -notmatch ('"?id"?\s*:\s*"' + [regex]::Escape($skill.id) + '"')) {
        $errors.Add("web/data.js sem skill do registry: $($skill.id)")
    }
}
foreach ($handoff in $handoffs.handoffs) {
    $pattern = '"?id"?\s*:\s*"' + [regex]::Escape($handoff.source) + '".*?"?downstream"?\s*:\s*\[([^\]]*)\]'
    $match = [regex]::Match($data, $pattern, [Text.RegularExpressions.RegexOptions]::Singleline)
    if (-not $match.Success -or $match.Groups[1].Value -notmatch [regex]::Escape($handoff.target)) {
        $errors.Add("web/data.js sem downstream derivado: $($handoff.source) -> $($handoff.target)")
    }
}
if ($errors.Count) { $errors | ForEach-Object { Write-Error $_ }; exit 1 }
Write-Output "OK: web/data.js contém as skills e downstreams declarados."
