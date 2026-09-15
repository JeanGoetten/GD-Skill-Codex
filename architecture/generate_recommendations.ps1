param([Parameter(Mandatory = $true)][string]$ReportPath, [string]$OutputPath)
$ErrorActionPreference = 'Stop'
$report = Get-Content -LiteralPath $ReportPath -Raw | ConvertFrom-Json
$recommendations = @()
foreach ($claim in @($report.claims)) {
    $blocked = $claim.status -eq 'INSUFFICIENT_EVIDENCE' -or $claim.confidence -eq 'low'
    $recommendations += [ordered]@{
        recommendation = if ($blocked) { "Coletar evidência adicional antes de alterar o sistema analisado por $($claim.skill_id)." } else { "Revisar o resultado de $($claim.skill_id) em um teste controlado antes de implementação." }
        rationale = if ($blocked) { 'O claim não possui evidência suficiente ou tem baixa confiança.' } else { 'O resultado é derivado do modelo e deve ser confrontado com observação ou simulação.' }
        priority = if ($blocked) { 'blocked' } else { 'conditional' }
        confidence = if ($blocked) { 'low' } else { $claim.confidence }
        claim_id = $claim.claim_id
        evidence = @($claim.provenance.source_kind)
    }
}
$result = [ordered]@{ schema_version = '1.0.0'; source_report = $ReportPath; blocked_count = @($recommendations | Where-Object { $_.priority -eq 'blocked' }).Count; recommendations = $recommendations }
$json = $result | ConvertTo-Json -Depth 20
if ($OutputPath) { $json | Set-Content -LiteralPath $OutputPath -Encoding utf8 } else { $json }
