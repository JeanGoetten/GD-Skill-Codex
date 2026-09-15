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
$defaultReaction = if ($null -ne $model.reaction_min_frames) { [int]$model.reaction_min_frames } else { 0 }
$diagnoses = @()
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
    if ($averageDamage -gt 0 -and $damage -gt ($averageDamage * 1.5) -and $recovery -le $reaction) {
        $diagnoses += [ordered]@{ action_id = $id; code = 'RISKLESS_DOMINANCE'; status = 'flagged'; reason = 'dano alto combinado com recovery abaixo da reação mínima declarada.' }
    }
    if ($null -ne $action.max_stamina -and $null -ne $action.dodge_cost -and ($stamina + [double]$action.dodge_cost) -gt [double]$action.max_stamina) {
        $diagnoses += [ordered]@{ action_id = $id; code = 'STAMINA_LOCK_TRAP'; status = 'flagged'; reason = 'custo da ação mais dodge excede a reserva máxima.' }
    }
    if ($null -ne $action.hitbox_area -and $null -ne $action.hurtbox_area -and [double]$action.hurtbox_area -gt ([double]$action.hitbox_area * 2)) {
        $diagnoses += [ordered]@{ action_id = $id; code = 'REACH_EXPOSURE_INCOHERENCE'; status = 'flagged'; reason = 'hurtbox declarada excede o dobro da área efetiva da hitbox.' }
    }
}
if ($errors.Count -gt 0) {
    [ordered]@{ skill_id = 'committed-risk-reward-actions'; status = 'failed'; results = [ordered]@{ execution = 'validation_failed' }; metrics = @(); evidence = @(); errors = @($errors) } | ConvertTo-Json -Depth 12 -Compress
    exit 0
}
[ordered]@{
    skill_id = 'committed-risk-reward-actions'
    status = 'success'
    results = [ordered]@{
        action_count = $contracts.Count
        diagnoses = @($diagnoses)
        interpretation = if ($diagnoses.Count -gt 0) { 'structural_risks_flagged' } else { 'no_declared_anomaly' }
        limitations = @(
            'Flags depend on declared averages, timing and spatial areas; they are not playtest findings.',
            'A risk flag does not prove dominance, unfairness or player frustration.',
            'Geometric areas are proxies and do not replace hitbox, spacing and escape simulation.'
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
