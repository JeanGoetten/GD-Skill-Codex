param(
    [Parameter(Mandatory = $true)]
    [string]$WorldModelPath
)
$ErrorActionPreference = 'Stop'
$world = Get-Content -LiteralPath $WorldModelPath -Raw | ConvertFrom-Json
$model = $world.hidden_state.competitive_feedback
if ($null -eq $model) {
    [ordered]@{
        skill_id = 'competitive-negative-feedback'
        status = 'blocked'
        results = [ordered]@{ execution = 'not_available'; reason = 'hidden_state.competitive_feedback ausente.' }
        metrics = @()
        evidence = @()
        errors = @('INSUFFICIENT_EVIDENCE: forneça posições, regras de feedback e valores de compensação.')
    } | ConvertTo-Json -Depth 10 -Compress
    exit 0
}
$players = @($model.player_positions)
$rules = $model.feedback_rules
$errors = [System.Collections.Generic.List[string]]::new()
$playerIds = @($players | ForEach-Object { [string]$_.player_id })
if ($playerIds.Count -lt 2) { $errors.Add('são necessários pelo menos dois jogadores.') }
if (@($playerIds | Select-Object -Unique).Count -ne $playerIds.Count) { $errors.Add('player_id duplicado.') }
foreach ($player in $players) {
    if ([int]$player.rank -lt 1) { $errors.Add("rank inválido: $($player.player_id)") }
}
if ($errors.Count -gt 0) {
    [ordered]@{ skill_id = 'competitive-negative-feedback'; status = 'failed'; results = [ordered]@{ execution = 'validation_failed' }; metrics = @(); evidence = @(); errors = @($errors) } | ConvertTo-Json -Depth 12 -Compress
    exit 0
}
$orderedPlayers = @($players | Sort-Object rank)
$leader = $orderedPlayers[0]
$last = $orderedPlayers[-1]
$scores = @($players | ForEach-Object { [double]$_.score })
$sortedScores = @($scores | Sort-Object)
$median = if ($sortedScores.Count % 2 -eq 1) { $sortedScores[[int]($sortedScores.Count / 2)] } else { ($sortedScores[($sortedScores.Count / 2) - 1] + $sortedScores[$sortedScores.Count / 2]) / 2 }
$deviations = @($players | ForEach-Object { [ordered]@{ player_id = [string]$_.player_id; score_deviation = ([double]$_.score - $median); rank = [int]$_.rank } })
$lastEffect = [double]$rules.last_place_effect
$leaderAdvantage = [double]$rules.leader_perfect_execution_advantage
$diagnoses = @()
if ($lastEffect -ge ([double]$leader.score - [double]$last.score)) {
    $diagnoses += [ordered]@{ code = 'EXTREME_RUBBER_BANDING'; status = 'flagged'; reason = 'efeito da compensação iguala ou excede a vantagem observada do líder.' }
}
$history = @($rules.leader_history | ForEach-Object { [string]$_ })
if ($history.Count -ge 3) {
    $alternates = $true
    for ($index = 2; $index -lt $history.Count; $index++) {
        if ($history[$index] -ne $history[$index - 2]) { $alternates = $false; break }
    }
    if ($alternates) { $diagnoses += [ordered]@{ code = 'DESTRUCTIVE_ELASTIC_OSCILLATION'; status = 'flagged'; reason = 'histórico alterna líderes em períodos consecutivos.' } }
}
$evByRank = @{}
if ($null -ne $rules.resource_expected_value_by_rank) {
    foreach ($property in $rules.resource_expected_value_by_rank.PSObject.Properties) { $evByRank[[string]$property.Name] = [double]$property.Value }
}
$leaderEv = if ($evByRank.ContainsKey([string]$leader.rank)) { $evByRank[[string]$leader.rank] } else { $null }
$lastEv = if ($evByRank.ContainsKey([string]$last.rank)) { $evByRank[[string]$last.rank] } else { $null }
if ($null -ne $leaderEv -and $null -ne $lastEv -and $lastEv -gt $leaderEv) {
    $diagnoses += [ordered]@{ code = 'SANDBAGGING_INCENTIVE'; status = 'flagged'; reason = 'valor esperado da compensação é maior na última posição.' }
}
$status = if ($leaderAdvantage -gt 0 -and $lastEffect -ge $leaderAdvantage) { 'skill_nullifying_risk' } elseif ($diagnoses.Count -gt 0) { 'calibration_hypotheses_required' } else { 'no_declared_anomaly' }
[ordered]@{
    skill_id = 'competitive-negative-feedback'
    status = 'success'
    results = [ordered]@{
        leader = [string]$leader.player_id
        last_place = [string]$last.player_id
        median_score = $median
        deviations = $deviations
        damping = [ordered]@{ leader_drag = [double]$rules.leader_drag; last_place_effect = $lastEffect }
        diagnoses = $diagnoses
        interpretation = $status
        limitations = @(
            'Estabilidade matemática não prova justiça percebida ou diversão.',
            'Sandbagging requer agentes estratégicos ou telemetria para confirmar comportamento.',
            'Uma amostra pontual de posições não demonstra dinâmica temporal.'
        )
    }
    metrics = @(
        [ordered]@{ name = 'player_count'; value = $players.Count; status = 'derived' },
        [ordered]@{ name = 'score_gap_leader_last'; value = ([double]$leader.score - [double]$last.score); status = 'derived' },
        [ordered]@{ name = 'flagged_diagnoses'; value = $diagnoses.Count; status = 'derived' }
    )
    evidence = @([ordered]@{ type = 'calculation'; id = 'competitive-feedback-checks'; status = 'derived'; source = 'hidden_state.competitive_feedback' })
    handoffs = @(
        [ordered]@{ target = 'resource-flow-economy'; reason = 'validar geração e consumo dos recursos de compensação' },
        [ordered]@{ target = 'exponential-progression-and-prestige'; reason = 'avaliar interação com progressão' }
    )
    errors = @()
} | ConvertTo-Json -Depth 15 -Compress
