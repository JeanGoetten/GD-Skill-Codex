param(
    [Parameter(Mandatory = $true)]
    [string]$WorldModelPath
)
$ErrorActionPreference = 'Stop'
$world = Get-Content -LiteralPath $WorldModelPath -Raw | ConvertFrom-Json
$model = $world.hidden_state.nested_gameplay_loop_architecture
if ($null -eq $model) {
    [ordered]@{
        schema_version = '1.0.0'; executor_version = '1.0.0'
        skill_id = 'nested-gameplay-loop-architecture'; status = 'blocked'
        results = [ordered]@{ execution = 'not_available'; reason = 'hidden_state.nested_gameplay_loop_architecture ausente.' }
        metrics = @(); evidence = @(); handoffs = @()
        errors = @('INSUFFICIENT_EVIDENCE: forneça loops micro, meso e macro.')
    } | ConvertTo-Json -Depth 12 -Compress
    exit 0
}

$loops = @($model.loops)
$errors = [System.Collections.Generic.List[string]]::new()
$ids = @{}
foreach ($loop in $loops) {
    $id = [string]$loop.id
    if ([string]::IsNullOrWhiteSpace($id)) { $errors.Add('cada loop requer id.'); continue }
    if ($ids.ContainsKey($id)) { $errors.Add("loop duplicado: $id") } else { $ids[$id] = $true }
    if ([double]$loop.duration_seconds -le 0) { $errors.Add("duração inválida: $id") }
}
foreach ($level in @('micro','meso','macro')) {
    if (@($loops | Where-Object { [string]$_.level -eq $level }).Count -eq 0) { $errors.Add("loop $level ausente.") }
}
foreach ($loop in $loops) {
    foreach ($targetId in @($loop.contributes_to)) {
        if (-not [string]::IsNullOrWhiteSpace([string]$targetId) -and -not $ids.ContainsKey([string]$targetId)) { $errors.Add("loop $($loop.id) referencia loop inexistente: $targetId") }
    }
    foreach ($targetId in @($loop.receives_from)) {
        if (-not [string]::IsNullOrWhiteSpace([string]$targetId) -and -not $ids.ContainsKey([string]$targetId)) { $errors.Add("loop $($loop.id) referencia loop inexistente: $targetId") }
    }
}
if ($errors.Count -gt 0) {
    [ordered]@{ schema_version = '1.0.0'; executor_version = '1.0.0'; skill_id = 'nested-gameplay-loop-architecture'; status = 'failed'; results = [ordered]@{ execution = 'validation_failed' }; metrics = @(); evidence = @(); handoffs = @(); errors = @($errors) } | ConvertTo-Json -Depth 12 -Compress
    exit 0
}

$micro = @($loops | Where-Object { $_.level -eq 'micro' })
$meso = @($loops | Where-Object { $_.level -eq 'meso' })
$macro = @($loops | Where-Object { $_.level -eq 'macro' })
$allTimes = @{}
foreach ($loop in $loops) {
    foreach ($time in @($loop.completion_times_seconds)) {
        $key = ([double]$time).ToString([Globalization.CultureInfo]::InvariantCulture)
        if (-not $allTimes.ContainsKey($key)) { $allTimes[$key] = @() }
        $allTimes[$key] += [string]$loop.id
    }
}
$aligned = @($allTimes.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 } | ForEach-Object { [ordered]@{ time_seconds = [double]$_.Key; loops = @($_.Value) } })
$offsets = @()
foreach ($short in $micro) {
    foreach ($medium in $meso) {
        foreach ($a in @($short.completion_times_seconds)) {
            foreach ($b in @($medium.completion_times_seconds)) { $offsets += [math]::Abs([double]$b - [double]$a) }
        }
    }
}
$minOffset = if ($offsets.Count) { ($offsets | Measure-Object -Minimum).Minimum } else { $null }
$sterile = @($micro | Where-Object { @($_.contributes_to).Count -eq 0 } | ForEach-Object { [string]$_.id })
$drought = @($meso | Where-Object { [double]$_.duration_seconds -gt 1800 -and @($_.intermediate_rewards).Count -eq 0 } | ForEach-Object { [string]$_.id })
$target = if ($null -ne $model.retention_pressure_target) { [double]$model.retention_pressure_target } else { 0.40 }
$pressure = @()
foreach ($loop in $loops) {
    $progress = if ($null -ne $loop.progress) { [double]$loop.progress } elseif ($null -ne $loop.remaining_seconds) { 1 - ([double]$loop.remaining_seconds / [double]$loop.duration_seconds) } else { $null }
    if ($null -ne $progress) {
        $weight = if ($null -ne $loop.weight) { [double]$loop.weight } else { 1.0 }
        $pressure += $weight * [math]::Max(0, [math]::Min(1, $progress))
    }
}
$pressureIndex = if ($pressure.Count) { ($pressure | Measure-Object -Average).Average } else { $null }
$diagnoses = @()
if ($aligned.Count) { $diagnoses += [ordered]@{ code = 'ALIGNED_EXIT_POINTS'; status = 'flagged'; points = $aligned } }
if ($sterile.Count) { $diagnoses += [ordered]@{ code = 'STERILE_MICRO_LOOP'; status = 'flagged'; loops = $sterile } }
if ($drought.Count) { $diagnoses += [ordered]@{ code = 'FEEDBACK_DROUGHT'; status = 'flagged'; loops = $drought } }
$status = if ($aligned.Count -or $drought.Count) { 'exit_point_risk' } elseif ($null -ne $pressureIndex -and $pressureIndex -gt 0.85) { 'excessive_retention' } else { 'engaging' }
[ordered]@{
    schema_version = '1.0.0'; executor_version = '1.0.0'; skill_id = 'nested-gameplay-loop-architecture'; status = 'success'
    results = [ordered]@{
        loop_matrix = @($loops | ForEach-Object { [ordered]@{ id = [string]$_.id; level = [string]$_.level; duration_seconds = [double]$_.duration_seconds; action = [string]$_.action; generated_input = [string]$_.generated_input; destination_loop = [string]$_.destination_loop } })
        temporal_interleaving = [ordered]@{ minimum_micro_meso_offset_seconds = $minOffset; configured_minimum_offset_seconds = if ($null -ne $model.minimum_completion_offset_seconds) { [double]$model.minimum_completion_offset_seconds } else { $null }; aligned_completion_points = $aligned }
        retention_curve = [ordered]@{ pressure_index = $pressureIndex; target = $target; sample_count = $pressure.Count }
        diagnoses = $diagnoses
        loop_status = $status
        calibration_plan = @('Stagger completion times that coincide across loop levels.', 'Connect every micro loop to a meso or macro objective.', 'Add intermediate rewards before long meso barriers.')
        limitations = @('Completion offsets are evaluated only at declared samples.', 'Retention pressure is a heuristic index, not a measure of player cognition or enjoyment.')
    }
    metrics = @(
        [ordered]@{ name = 'loop_count'; value = $loops.Count; status = 'derived' },
        [ordered]@{ name = 'micro_completion_frequency_per_minute'; value = if ($micro.Count -and @($micro[0].completion_times_seconds).Count) { @($micro[0].completion_times_seconds).Count / ([double]$micro[0].duration_seconds / 60) } else { $null }; status = 'derived' },
        [ordered]@{ name = 'minimum_completion_offset_seconds'; value = $minOffset; status = 'derived' },
        [ordered]@{ name = 'retention_pressure_index'; value = $pressureIndex; status = 'derived' },
        [ordered]@{ name = 'flagged_diagnoses'; value = $diagnoses.Count; status = 'derived' }
    )
    evidence = @([ordered]@{ type = 'calculation'; id = 'nested-loop-temporal-checks'; status = 'derived'; source = 'hidden_state.nested_gameplay_loop_architecture' })
    handoffs = @(
        [ordered]@{ target = 'frame-based-combat-timing'; reason = 'validar resolução temporal de ações micro' },
        [ordered]@{ target = 'resource-flow-economy'; reason = 'validar fluxo de recompensas entre loops' },
        [ordered]@{ target = 'epistemic-holarchic-progression'; reason = 'validar compreensão dos objetivos aninhados' }
    )
    errors = @()
} | ConvertTo-Json -Depth 15 -Compress
