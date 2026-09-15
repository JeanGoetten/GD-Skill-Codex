param([Parameter(Mandatory = $true)][string]$ReportPath)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$report = Get-Content -LiteralPath $ReportPath -Raw | ConvertFrom-Json
$errors = [System.Collections.Generic.List[string]]::new()
foreach ($claim in @($report.claims)) {
    foreach ($field in @('claim_id','skill_id','status','confidence','provenance')) {
        if (-not $claim.PSObject.Properties.Name.Contains($field)) { $errors.Add("claim sem campo obrigatório: $field") }
    }
    if ($claim.provenance -and $claim.provenance.input_hash -ne $report.input_hash) { $errors.Add("provenance divergente no claim: $($claim.claim_id)") }
}
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'validate_recommendations.ps1') -ReportPath $ReportPath *> $null
if ($LASTEXITCODE -ne 0) { $errors.Add('recomendações inválidas') }
if ($errors.Count -gt 0) { $errors | ForEach-Object { Write-Error $_ }; exit 1 }
Write-Output "OK: relatório com $(@($report.claims).Count) claims e $(@($report.recommendations).Count) recomendações."
