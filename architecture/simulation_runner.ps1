param(
    [Parameter(Mandatory = $true)][string]$WorldModelPath,
    [Parameter(Mandatory = $true)][string]$ExecutorId,
    [string]$OutputPath,
    [string]$EvidenceStorePath,
    [int]$Seed = 0,
    [int]$Repeats = 1
)
$ErrorActionPreference = 'Stop'
if ($Repeats -lt 1) { throw 'Repeats deve ser >= 1.' }
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$executor = Join-Path (Join-Path $root 'executors') ($ExecutorId + '.ps1')
if (-not (Test-Path -LiteralPath $executor)) { throw "Executor não encontrado: $ExecutorId" }
$worldJson = Get-Content -Encoding UTF8 -LiteralPath $WorldModelPath -Raw
$world = $worldJson | ConvertFrom-Json
$hash = ([Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes($worldJson)) | ForEach-Object { $_.ToString('x2') }) -join ''
$runs = @()
$snapshots = @()
$events = @()
for ($i = 0; $i -lt $Repeats; $i++) {
    $runSeed = $Seed + $i
    $output = (& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $executor -WorldModelPath $WorldModelPath) | ConvertFrom-Json
    $runs += [ordered]@{ run_id = "$ExecutorId-$runSeed"; seed = $runSeed; status = $output.status; output = $output }
    $snapshots += [ordered]@{
        tick = $i
        seed = $runSeed
        status = $output.status
        metrics = @($output.metrics)
        state_hash = $hash
    }
    $events += [ordered]@{
        tick = $i
        type = 'executor_result'
        skill_id = $ExecutorId
        status = $output.status
    }
}
$report = [ordered]@{
    schema_version = '1.0.0'
    runner = 'architecture/simulation_runner.ps1'
    executor_id = $ExecutorId
    world_model_hash = $hash
    seed = $Seed
    repeats = $Repeats
    created_at = (Get-Date).ToUniversalTime().ToString('o')
    runs = $runs
    time_series = [ordered]@{ ticks = $snapshots; metrics = @($snapshots | ForEach-Object { $_.metrics }) }
    events = $events
    agents = @($world.actors | ForEach-Object {
        [ordered]@{
            id = if ($_.id) { $_.id } else { 'actor' }
            strategy = if ($_.strategy) { $_.strategy } else { 'declared_world_model' }
            source = 'world_model'
        }
    })
    evidence_status = if (@($runs | Where-Object { $_.status -eq 'success' }).Count -gt 0) { 'derived_from_simulation' } else { 'INSUFFICIENT_EVIDENCE' }
    aggregate = [ordered]@{
        successful_runs = @($runs | Where-Object { $_.status -eq 'success' }).Count
        partial_runs = @($runs | Where-Object { $_.status -eq 'partial' }).Count
        failed_runs = @($runs | Where-Object { $_.status -eq 'failed' }).Count
        metric_names = @($snapshots | ForEach-Object { $_.metrics } | ForEach-Object { $_.name } | Sort-Object -Unique)
    }
}
$json = $report | ConvertTo-Json -Depth 20
if ($OutputPath) { $json | Set-Content -LiteralPath $OutputPath -Encoding utf8 } else { $json }
if ($EvidenceStorePath) {
    $directory = Split-Path -Parent $EvidenceStorePath
    if ($directory -and -not (Test-Path -LiteralPath $directory)) { New-Item -ItemType Directory -Path $directory | Out-Null }
    $record = [ordered]@{
        claim = "A simulação $ExecutorId produziu $Repeats execução(ões) reproduzível(is)."
        skill_id = $ExecutorId
        status = if ($report.evidence_status -eq 'derived_from_simulation') { 'derived' } else { 'INSUFFICIENT_EVIDENCE' }
        source = 'architecture/simulation_runner.ps1'
        evidence = @([ordered]@{ type = 'simulation'; id = "$ExecutorId-$hash" })
        assumptions = @('O world model e o executor representam adequadamente o sistema analisado.')
        confidence = if ($report.evidence_status -eq 'derived_from_simulation') { 'medium' } else { 'low' }
        limitations = @('Repetição de executor não substitui telemetria ou playtest.')
        input_hash = $hash
        world_model_version = if ($world.version) { $world.version } else { 'unknown' }
        skill_version = '1.0.0'
        seed = $Seed
        created_at = $report.created_at
        provenance = [ordered]@{
            input_hash = $hash
            world_model_version = if ($world.version) { $world.version } else { 'unknown' }
            skill_version = '1.0.0'
            source_kind = $report.evidence_status
            dependencies = @()
            conflicts = @()
        }
    }
    ($record | ConvertTo-Json -Depth 12 -Compress) | Add-Content -LiteralPath $EvidenceStorePath -Encoding utf8
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'refresh_evidence_index.ps1') -EvidenceStorePath $EvidenceStorePath
}
