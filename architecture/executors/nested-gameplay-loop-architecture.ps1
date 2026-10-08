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
    foreach ($time in @($loop.completion_times_seconds | Where-Object { $null -ne $_ })) {
        $key = ([double]$time).ToString([Globalization.CultureInfo]::InvariantCulture)
        if (-not $allTimes.ContainsKey($key)) { $allTimes[$key] = @() }
        $allTimes[$key] += [string]$loop.id
    }
}
$intentionalKeys = @{}
foreach ($loop in $loops) {
    foreach ($time in @($loop.intentional_completion_times_seconds)) {
        if ($null -ne $time) { $intentionalKeys[([string]$loop.id) + '|' + ([double]$time).ToString([Globalization.CultureInfo]::InvariantCulture)] = $true }
    }
}
$aligned = @()
$intentionalSync = @()
foreach ($entry in @($allTimes.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 })) {
    $participants = @($entry.Value | Select-Object -Unique)
    if ($participants.Count -lt 2) { continue }
    $entryKey = [string]$entry.Key
    $declared = @($participants | Where-Object { $intentionalKeys.ContainsKey($_ + '|' + $entryKey) })
    $point = [ordered]@{ time_seconds = [double]$entryKey; loops = $participants }
    if ($declared.Count -eq $participants.Count) {
        $intentionalSync += $point
    } else {
        $point['undeclared_loops'] = @($participants | Where-Object { $declared -notcontains $_ })
        $aligned += $point
    }
}
$offsets = @()
foreach ($short in $micro) {
    foreach ($medium in $meso) {
        foreach ($a in @($short.completion_times_seconds | Where-Object { $null -ne $_ })) {
            foreach ($b in @($medium.completion_times_seconds | Where-Object { $null -ne $_ })) { $offsets += [math]::Abs([double]$b - [double]$a) }
        }
    }
}
$minOffset = if ($offsets.Count) { ($offsets | Measure-Object -Minimum).Minimum } else { $null }
$sterile = @($micro | Where-Object { @($_.contributes_to | Where-Object { $null -ne $_ }).Count -eq 0 } | ForEach-Object { [string]$_.id })
$droughtThreshold = if ($null -ne $model.drought_threshold_seconds) { [double]$model.drought_threshold_seconds } else { 900.0 }
$drought = @($meso | Where-Object { [double]$_.duration_seconds -ge $droughtThreshold -and @($_.intermediate_rewards | Where-Object { $null -ne $_ }).Count -eq 0 } | ForEach-Object { [string]$_.id })
$target = if ($null -ne $model.retention_pressure_target) { [double]$model.retention_pressure_target } else { 0.40 }
$excessiveThreshold = if ($null -ne $model.excessive_retention_threshold) { [double]$model.excessive_retention_threshold } else { 0.85 }
$pressure = @()
$pressureWeightSum = 0.0
foreach ($loop in $loops) {
    $progress = if ($null -ne $loop.progress) { [double]$loop.progress } elseif ($null -ne $loop.remaining_seconds) { 1 - ([double]$loop.remaining_seconds / [double]$loop.duration_seconds) } else { $null }
    if ($null -ne $progress) {
        $weight = if ($null -ne $loop.weight) { [double]$loop.weight } else { 1.0 }
        $clamped = [math]::Max(0.0, [math]::Min(1.0, [double]$progress))
        # Only OPEN loops contribute (completed loops exit the sum), weights normalized over open loops.
        if ($clamped -lt 1) { $pressure += $weight * $clamped; $pressureWeightSum += $weight }
    }
}
$pressureIndex = if ($pressure.Count -and $pressureWeightSum -gt 0) { ($pressure | Measure-Object -Sum).Sum / $pressureWeightSum } else { $null }
$diagnoses = @()
if ($aligned.Count) { $diagnoses += [ordered]@{ code = 'ALIGNED_EXIT_POINTS'; status = 'flagged'; points = $aligned } }
if ($sterile.Count) { $diagnoses += [ordered]@{ code = 'STERILE_MICRO_LOOP'; status = 'flagged'; loops = $sterile } }
if ($drought.Count) { $diagnoses += [ordered]@{ code = 'FEEDBACK_DROUGHT'; status = 'flagged'; loops = $drought } }
$status = if ($aligned.Count -or $drought.Count) { 'exit_point_risk' } elseif ($null -ne $pressureIndex -and $pressureIndex -gt $excessiveThreshold) { 'excessive_retention' } else { 'engaging' }
[ordered]@{
    schema_version = '1.0.0'; executor_version = '1.0.0'; skill_id = 'nested-gameplay-loop-architecture'; status = 'success'
    results = [ordered]@{
        loop_matrix = @($loops | ForEach-Object { [ordered]@{ id = [string]$_.id; level = [string]$_.level; duration_seconds = [double]$_.duration_seconds; action = [string]$_.action; generated_input = [string]$_.generated_input; destination_loop = [string]$_.destination_loop } })
        temporal_interleaving = [ordered]@{ minimum_micro_meso_offset_seconds = $minOffset; configured_minimum_offset_seconds = if ($null -ne $model.minimum_completion_offset_seconds) { [double]$model.minimum_completion_offset_seconds } else { $null }; aligned_completion_points = $aligned; intentional_synchronizations = $intentionalSync }
        retention_curve = [ordered]@{ pressure_index = $pressureIndex; target = $target; below_declared_target = if ($null -ne $pressureIndex) { [bool]($pressureIndex -lt $target) } else { $null }; open_loop_count = $pressure.Count; sample_count = $pressure.Count; note = 'Descriptive heuristic. Declared target is not a goal to maximize; never use it against voluntary stopping.' }
        thresholds = [ordered]@{
            drought_threshold_seconds = [ordered]@{ value = $droughtThreshold; epistemic_status = 'heuristic'; declared_in_model = ($null -ne $model.drought_threshold_seconds) }
            excessive_retention_threshold = [ordered]@{ value = $excessiveThreshold; epistemic_status = 'heuristic'; declared_in_model = ($null -ne $model.excessive_retention_threshold) }
            retention_pressure_target = [ordered]@{ value = $target; epistemic_status = 'heuristic'; declared_in_model = ($null -ne $model.retention_pressure_target) }
        }
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
