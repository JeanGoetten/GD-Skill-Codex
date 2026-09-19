param([Parameter(Mandatory = $true)][string]$EvidenceStorePath)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $EvidenceStorePath)) { throw "Evidence store não encontrado: $EvidenceStorePath" }
$records = @(Get-Content -Encoding UTF8 -LiteralPath $EvidenceStorePath | Where-Object { $_.Trim() } | ForEach-Object { $_ | ConvertFrom-Json })
$index = [ordered]@{
    schema_version = '1.0.0'
    updated_at = (Get-Date).ToUniversalTime().ToString('o')
    count = $records.Count
    by_status = [ordered]@{}
    by_skill = [ordered]@{}
    records = @($records | ForEach-Object {
        [ordered]@{
            claim = $_.claim
            skill_id = $_.skill_id
            status = $_.status
            confidence = $_.confidence
            input_hash = $_.input_hash
            skill_version = $_.skill_version
        }
    })
}
foreach ($record in $records) {
    $index.by_status[$record.status] = @($records | Where-Object { $_.status -eq $record.status }).Count
    if ($record.skill_id) { $index.by_skill[$record.skill_id] = @($records | Where-Object { $_.skill_id -eq $record.skill_id }).Count }
}
$index | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath "$EvidenceStorePath.index.json" -Encoding utf8
Write-Output "OK: índice atualizado com $($records.Count) registros."
