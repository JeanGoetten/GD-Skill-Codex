param(
    [Parameter(Mandatory = $true)][string]$HypothesisPath,
    [Parameter(Mandatory = $true)][string]$ObservationPath,
    [Parameter(Mandatory = $true)][string]$EvidenceStorePath
)
$ErrorActionPreference = 'Stop'
$hypothesis = Get-Content -Encoding UTF8 -LiteralPath $HypothesisPath -Raw | ConvertFrom-Json
$observation = Get-Content -Encoding UTF8 -LiteralPath $ObservationPath -Raw | ConvertFrom-Json
if ($observation.hypothesis_id -ne $hypothesis.id) { throw 'Observação não referencia a hipótese fornecida.' }
if ($observation.metric -ne $hypothesis.metric) { throw 'Métrica da observação diverge da hipótese.' }
if ([int]$observation.sample_size -gt [int]$hypothesis.sample_size) { throw 'Observação excede o tamanho de amostra planejado.' }
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
& node (Join-Path $root 'validate_playtest_observation.js') $ObservationPath
if ($LASTEXITCODE -ne 0) { throw 'Observação de playtest inválida.' }
$directory = Split-Path -Parent $EvidenceStorePath
if ($directory -and -not (Test-Path -LiteralPath $directory)) { New-Item -ItemType Directory -Path $directory | Out-Null }
$record = [ordered]@{
    claim = "A observação $($observation.id) registrou $($observation.metric) para a hipótese $($hypothesis.id)."
    skill_id = "playtest:$($hypothesis.id)"
    status = if ($observation.status -eq 'observed') { 'observed' } else { 'INSUFFICIENT_EVIDENCE' }
    source = 'architecture/record_playtest_observation.ps1'
    evidence = @([ordered]@{ type = 'playtest'; id = $observation.id; uri = $observation.source_uri })
    assumptions = @("A população observada corresponde à população planejada: $($hypothesis.population).")
    confidence = if ($observation.status -eq 'observed' -and $observation.sample_size -eq $hypothesis.sample_size) { 'medium' } else { 'low' }
    limitations = @($observation.limitations) + @('Observação de playtest não generaliza para toda a população.')
    input_hash = $observation.id
    world_model_version = 'playtest'
    skill_version = '1.0.0'
    created_at = $observation.collected_at
    provenance = [ordered]@{
        input_hash = $observation.id
        world_model_version = 'playtest'
        skill_version = '1.0.0'
        source_kind = if ($observation.status -eq 'observed') { 'empirical_observation' } else { 'INSUFFICIENT_EVIDENCE' }
        dependencies = @($hypothesis.id)
        conflicts = @()
    }
}
($record | ConvertTo-Json -Depth 12 -Compress) | Add-Content -LiteralPath $EvidenceStorePath -Encoding utf8
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'refresh_evidence_index.ps1') -EvidenceStorePath $EvidenceStorePath
Write-Output "OK: observação $($observation.id) registrada."
