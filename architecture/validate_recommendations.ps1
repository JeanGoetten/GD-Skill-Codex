param([Parameter(Mandatory = $true)][string]$ReportPath)
$ErrorActionPreference = 'Stop'
$report = Get-Content -LiteralPath $ReportPath -Raw | ConvertFrom-Json
$errors = [System.Collections.Generic.List[string]]::new()
$claims = @($report.claims)
foreach ($recommendation in @($report.recommendations)) {
    if (-not $recommendation.claim_id) { $errors.Add('recommendation sem claim_id') ; continue }
    $claim = $claims | Where-Object { $_.claim_id -eq $recommendation.claim_id } | Select-Object -First 1
    if ($null -eq $claim) { $errors.Add("claim inexistente: $($recommendation.claim_id)"); continue }
    $mustBlock = $claim.status -eq 'INSUFFICIENT_EVIDENCE' -or $claim.confidence -eq 'low'
    if ($mustBlock -and $recommendation.priority -ne 'blocked') { $errors.Add("recommendation não bloqueada para claim insuficiente: $($recommendation.claim_id)") }
    if ($recommendation.evidence.Count -eq 0) { $errors.Add("recommendation sem evidência: $($recommendation.claim_id)") }
}
if ($errors.Count -gt 0) { $errors | ForEach-Object { Write-Error $_ }; exit 1 }
Write-Output "OK: $(@($report.recommendations).Count) recomendações rastreáveis verificadas."
