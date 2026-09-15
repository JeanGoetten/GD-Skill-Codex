param(
    [Parameter(Mandatory = $true)]
    [string]$WorldModelPath
)
$ErrorActionPreference = 'Stop'

function New-Output([string]$Status, $Results, $Metrics, $Evidence, $Errors) {
    $safeErrors = @($Errors | Where-Object { $null -ne $_ })
    [ordered]@{
        schema_version = '1.0.0'
        skill_id = 'exponential-progression-and-prestige'
        status = $Status
        results = $Results
        metrics = @($Metrics)
        evidence = @($Evidence)
        errors = $safeErrors
    } | ConvertTo-Json -Depth 20 -Compress
}

$world = Get-Content -LiteralPath $WorldModelPath -Raw | ConvertFrom-Json
$model = $null
if ($world.hidden_state -and $world.hidden_state.PSObject.Properties.Name -contains 'progression_analysis') {
    $model = $world.hidden_state.progression_analysis
}
if ($null -eq $model) {
    New-Output 'blocked' ([ordered]@{
        execution = 'not_available'
        reason = 'hidden_state.progression_analysis ausente.'
    }) @() @() @('INSUFFICIENT_EVIDENCE: forneça os parâmetros da recorrência de progressão.') 
    exit 0
}

$errors = [System.Collections.Generic.List[string]]::new()
foreach ($field in @('initial_value', 'base_rate', 'feedback_exponent', 'periods')) {
    if (-not ($model.PSObject.Properties.Name -contains $field) -or $null -eq $model.$field) {
        $errors.Add("parâmetro obrigatório ausente: $field")
    }
}
if ($errors.Count -gt 0) {
    New-Output 'failed' ([ordered]@{ execution = 'validation_failed' }) @() @() @($errors)
    exit 0
}

try {
    $initial = [double]$model.initial_value
    $baseRate = [double]$model.base_rate
    $alpha = [double]$model.feedback_exponent
    $periods = [int]$model.periods
    $step = if ($null -ne $model.time_step) { [double]$model.time_step } else { 1.0 }
    $maxValue = if ($null -ne $model.max_value) { [double]$model.max_value } else { [double]::MaxValue }
} catch {
    $errors.Add('parâmetros numéricos inválidos.')
}
if ($errors.Count -eq 0) {
    if ($initial -le 0) { $errors.Add('initial_value deve ser maior que zero.') }
    if ($baseRate -le 0) { $errors.Add('base_rate deve ser maior que zero.') }
    if ($alpha -lt 0) { $errors.Add('feedback_exponent não pode ser negativo.') }
    if ($periods -lt 1 -or $periods -gt 100000) { $errors.Add('periods deve estar entre 1 e 100000.') }
    if ($step -le 0) { $errors.Add('time_step deve ser maior que zero.') }
    if ($maxValue -le 0 -or [double]::IsNaN($maxValue) -or [double]::IsInfinity($maxValue)) { $errors.Add('max_value deve ser finito e maior que zero.') }
}
$prestige = $model.prestige
if ($null -ne $prestige) {
    try {
        $threshold = [double]$prestige.threshold
        $prestigeExponent = [double]$prestige.exponent
        $prestigeBeta = [double]$prestige.multiplier_per_prestige
        if ($threshold -le 0 -or $prestigeExponent -le 0 -or $prestigeExponent -gt 1 -or $prestigeBeta -le 0) {
            $errors.Add('prestige requer threshold > 0, exponent em (0,1] e multiplier_per_prestige > 0.')
        }
    } catch {
        $errors.Add('parâmetros de prestige inválidos.')
    }
}
if ($errors.Count -gt 0) {
    New-Output 'failed' ([ordered]@{ execution = 'validation_failed' }) @() @() @($errors)
    exit 0
}

$trajectory = [System.Collections.Generic.List[object]]::new()
$current = $initial
$peak = $initial
$blowup = $false
$blowupPeriod = $null
for ($period = 0; $period -lt $periods; $period++) {
    $increment = $baseRate * [Math]::Pow($current, $alpha) * $step
    $next = $current + $increment
    if ([double]::IsNaN($next) -or [double]::IsInfinity($next) -or $next -gt $maxValue) {
        $blowup = $true
        $blowupPeriod = $period + 1
        break
    }
    $growthFactor = if ($current -ne 0) { $next / $current } else { $null }
    $trajectory.Add([ordered]@{
        period = $period + 1
        value = $next
        increment = $increment
        growth_factor = $growthFactor
    })
    $current = $next
    if ($current -gt $peak) { $peak = $current }
}

$classification = if ($alpha -eq 0) {
    'linear'
} elseif ($alpha -lt 1) {
    'sublinear'
} elseif ($alpha -eq 1) {
    'exponential'
} else {
    'superlinear'
}
$prestigeResult = $null
if ($null -ne $prestige) {
    $prestigePoints = [Math]::Floor([Math]::Pow($peak / $threshold, $prestigeExponent))
    $prestigeResult = [ordered]@{
        peak_value = $peak
        prestige_points = $prestigePoints
        multiplier = 1 + ($prestigePoints * $prestigeBeta)
    }
}
$status = if ($blowup) { 'partial' } else { 'success' }
$result = [ordered]@{
    recurrence = 'Q[t+1] = Q[t] + base_rate * Q[t]^feedback_exponent * time_step'
    classification = $classification
    periods_requested = $periods
    periods_simulated = $trajectory.Count
    trajectory = @($trajectory)
    final_value = $current
    peak_value = $peak
    finite_time_blowup = $blowup
    blowup_period = $blowupPeriod
    prestige = $prestigeResult
    safety_limit = $maxValue
}
$metricList = @(
    [ordered]@{ name = 'periods_simulated'; value = $trajectory.Count; status = 'derived' },
    [ordered]@{ name = 'final_value'; value = $current; status = 'derived' },
    [ordered]@{ name = 'peak_value'; value = $peak; status = 'derived' },
    [ordered]@{ name = 'feedback_exponent'; value = $alpha; status = 'input' }
)
$errorList = if ($blowup) { @('FINITE_TIME_BLOWUP_GUARDED: simulação interrompida no limite numérico declarado.') } else { @() }
New-Output $status $result $metricList @([ordered]@{ type = 'calculation'; id = 'discrete-positive-feedback-recurrence'; status = 'derived'; source = 'hidden_state.progression_analysis' }) $errorList
