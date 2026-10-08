param(
    [Parameter(Mandatory = $true)]
    [string]$WorldModelPath
)
$ErrorActionPreference = 'Stop'
$world = Get-Content -LiteralPath $WorldModelPath -Raw | ConvertFrom-Json
$model = $world.hidden_state.risk_reward_actions
if ($null -eq $model) {
    [ordered]@{
        skill_id = 'committed-risk-reward-actions'
        status = 'blocked'
        results = [ordered]@{ execution = 'not_available'; reason = 'hidden_state.risk_reward_actions ausente.' }
        metrics = @()
        evidence = @()
        errors = @('INSUFFICIENT_EVIDENCE: forneça action_contracts e custos, janelas e consequências observáveis.')
    } | ConvertTo-Json -Depth 10 -Compress
    exit 0
}
$errors = [System.Collections.Generic.List[string]]::new()
$defaultReaction = if ($null -ne $model.reaction_min_frames) { [int]$model.reaction_min_frames } else { $null }
$diagnoses = @()
$undeclaredReaction = @()
$undeclaredPunisher = @()
$punishments = @()
$damageRatio = if ($null -ne $model.dominance_damage_ratio) { [double]$model.dominance_damage_ratio } else { 1.5 }
$hurtRatio = if ($null -ne $model.hurtbox_exposure_ratio) { [double]$model.hurtbox_exposure_ratio } else { 2.0 }
$contracts = @($model.action_contracts)
foreach ($action in $contracts) {
    $id = [string]$action.id
    if ([string]::IsNullOrWhiteSpace($id)) { $errors.Add('ação sem id.'); continue }
    $stamina = [double]$action.stamina_cost
    $recovery = [int]$action.recovery
    $damage = [double]$action.damage
    if ($null -ne $action.max_stamina -and $stamina -gt [double]$action.max_stamina) { $errors.Add("stamina_cost excede max_stamina: $id") }
    if ($null -ne $action.punishment_multiplier -and [double]$action.punishment_multiplier -lt 1) { $errors.Add("punishment_multiplier deve ser >= 1: $id") }
    $reaction = if ($null -ne $action.reaction_min_frames) { [int]$action.reaction_min_frames } else { $defaultReaction }
    $averageDamage = if ($null -ne $action.average_damage) { [double]$action.average_damage } else { 0 }
    $oppStartup = if ($null -ne $action.opponent_punish_startup_frames) { [int]$action.opponent_punish_startup_frames } elseif ($null -ne $model.opponent_punish_startup_frames) { [int]$model.opponent_punish_startup_frames } else { $null }
    if ($null -ne $oppStartup) {
        $margin = $recovery - $oppStartup
        $kPunish = if ($null -ne $action.punishment_multiplier) { [double]$action.punishment_multiplier } else { 1.0 }
        $oppDamage = if ($null -ne $action.opponent_punish_damage) { [double]$action.opponent_punish_damage } elseif ($null -ne $model.opponent_punish_damage) { [double]$model.opponent_punish_damage } else { $null }
        $punishments += [ordered]@{
            action_id = $id
            recovery_frames = $recovery
            opponent_startup_frames = $oppStartup
            margin_frames = $margin
            punishable_under_declared_model = ($margin -ge 0)
            expected_punish_damage = if ($null -ne $oppDamage) { $oppDamage * $kPunish } else { $null }
            epistemic_status = 'derived'
        }
    } else {
        $undeclaredPunisher += $id
    }
    if ($null -eq $reaction -and $averageDamage -gt 0) { $undeclaredReaction += $id }
    if ($null -ne $reaction -and $averageDamage -gt 0 -and $damage -gt ($averageDamage * $damageRatio) -and $recovery -le $reaction) {
        $diagnoses += [ordered]@{ action_id = $id; code = 'RISKLESS_DOMINANCE'; status = 'flagged'; reason = 'dano alto combinado com recovery abaixo da reação mínima declarada.' }
    }
    if ($null -ne $action.max_stamina -and $null -ne $action.dodge_cost -and ($stamina + [double]$action.dodge_cost) -gt [double]$action.max_stamina) {
        $diagnoses += [ordered]@{ action_id = $id; code = 'STAMINA_LOCK_TRAP'; status = 'flagged'; reason = 'custo da ação mais dodge excede a reserva máxima.' }
    }
    if ($null -ne $action.hitbox_area -and $null -ne $action.hurtbox_area -and [double]$action.hurtbox_area -gt ([double]$action.hitbox_area * $hurtRatio)) {
        $diagnoses += [ordered]@{ action_id = $id; code = 'REACH_EXPOSURE_INCOHERENCE'; status = 'flagged'; reason = 'hurtbox declarada excede a razao de exposicao configurada (default heuristico 2.0) sobre a area efetiva da hitbox.' }
    }
}
if ($errors.Count -gt 0) {
    [ordered]@{ skill_id = 'committed-risk-reward-actions'; status = 'failed'; results = [ordered]@{ execution = 'validation_failed' }; metrics = @(); evidence = @(); errors = @($errors) } | ConvertTo-Json -Depth 12 -Compress
    exit 0
}
[ordered]@{
    skill_id = 'committed-risk-reward-actions'
    status = if ($undeclaredReaction.Count -gt 0) { 'partial' } else { 'success' }
    results = [ordered]@{
        punish_windows = @($punishments)
        undeclared_inputs = [ordered]@{
            reaction_min_frames = @($undeclaredReaction | Select-Object -Unique)
            opponent_punish_startup_frames = @($undeclaredPunisher | Select-Object -Unique)
        }
        thresholds = [ordered]@{
            dominance_damage_ratio = [ordered]@{ value = $damageRatio; epistemic_status = 'heuristic'; declared_in_model = ($null -ne $model.dominance_damage_ratio) }
            hurtbox_exposure_ratio = [ordered]@{ value = $hurtRatio; epistemic_status = 'heuristic'; declared_in_model = ($null -ne $model.hurtbox_exposure_ratio) }
        }
        action_count = $contracts.Count
        diagnoses = @($diagnoses)
        interpretation = if ($diagnoses.Count -gt 0) { 'structural_risks_flagged' } else { 'no_declared_anomaly' }
        limitations = @(
            'Flags depend on declared averages, timing and spatial areas; they are not playtest findings.',
            'A risk flag does not prove dominance, unfairness or player frustration.',
            'Geometric areas are proxies and do not replace hitbox, spacing and escape simulation.',
            'Punish windows compare declared recovery with a declared opponent startup; they ignore spacing, latency, input buffer and escape states.',
            'Status is partial when reaction_min_frames is undeclared: RISKLESS_DOMINANCE cannot be evaluated, which is not the same as "no dominance".'
        )
    }
    metrics = @(
        [ordered]@{ name = 'action_count'; value = $contracts.Count; status = 'derived' },
        [ordered]@{ name = 'flagged_diagnoses'; value = $diagnoses.Count; status = 'derived' }
    )
    evidence = @([ordered]@{ type = 'calculation'; id = 'risk-reward-contract-checks'; status = 'derived'; source = 'hidden_state.risk_reward_actions' })
    handoffs = @(
        [ordered]@{ target = 'frame-based-combat-timing'; reason = 'validar a linha temporal e contato' },
        [ordered]@{ target = 'emergent-agency-composition'; reason = 'avaliar composição e alternativas de ação' }
    )
    errors = @()
} | ConvertTo-Json -Depth 15 -Compress
