param(
    [Parameter(Mandatory = $true)][string]$EvidenceStorePath,
    [string]$SkillId,
    [string]$Status,
    [string]$Confidence
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $EvidenceStorePath)) { throw "Evidence store não encontrado: $EvidenceStorePath" }
$records = @(Get-Content -LiteralPath $EvidenceStorePath | Where-Object { $_.Trim() } | ForEach-Object { $_ | ConvertFrom-Json })
$records = @($records | Where-Object {
    (-not $SkillId -or $_.skill_id -eq $SkillId) -and
    (-not $Status -or $_.status -eq $Status) -and
    (-not $Confidence -or $_.confidence -eq $Confidence)
})
[ordered]@{
    count = $records.Count
    filters = [ordered]@{ skill_id = $SkillId; status = $Status; confidence = $Confidence }
    records = $records
} | ConvertTo-Json -Depth 20
