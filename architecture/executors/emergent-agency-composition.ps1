param(
    [Parameter(Mandatory = $true)]
    [string]$WorldModelPath
)
$ErrorActionPreference = 'Stop'
$world = Get-Content -LiteralPath $WorldModelPath -Raw | ConvertFrom-Json
$model = $world.hidden_state.emergent_agency_composition
if ($null -eq $model) {
    [ordered]@{
        schema_version = '1.0.0'
        skill_id = 'emergent-agency-composition'
        status = 'blocked'
        results = [ordered]@{ execution = 'not_available'; reason = 'hidden_state.emergent_agency_composition ausente.' }
        metrics = @(); evidence = @(); handoffs = @()
        errors = @('INSUFFICIENT_EVIDENCE: forneça verbos, matriz de propriedades e composições.')
    } | ConvertTo-Json -Depth 12 -Compress
    exit 0
}
$verbs = @($model.atomic_verbs)
$entities = @($model.properties_matrix)
$compositions = @($model.compositions)
$errors = [System.Collections.Generic.List[string]]::new()
$verbIds = @($verbs | ForEach-Object { [string]$_.id })
if (@($verbIds | Select-Object -Unique).Count -ne $verbIds.Count) { $errors.Add('id de verbo atômico duplicado.') }
foreach ($composition in $compositions) {
    $id = [string]$composition.id
    if ($verbIds -notcontains [string]$composition.first_verb) { $errors.Add("composição $id referencia first_verb inexistente.") }
    if ($verbIds -notcontains [string]$composition.second_verb) { $errors.Add("composição $id referencia second_verb inexistente.") }
}
if ($errors.Count -gt 0) {
    [ordered]@{ schema_version = '1.0.0'; skill_id = 'emergent-agency-composition'; status = 'failed'; results = [ordered]@{ execution = 'validation_failed' }; metrics = @(); evidence = @(); handoffs = @(); errors = @($errors) } | ConvertTo-Json -Depth 12 -Compress
    exit 0
}
$maxDepth = if ($null -ne $model.max_chain_depth) { [int]$model.max_chain_depth } else { 8 }
$energyDrain = if ($null -ne $model.energy_drain_per_trigger) { [double]$model.energy_drain_per_trigger } else { 0 }
$diagnoses = [System.Collections.Generic.List[object]]::new()
$cycles = [System.Collections.Generic.List[object]]::new()
$dominant = [System.Collections.Generic.List[object]]::new()
$races = [System.Collections.Generic.List[object]]::new()
foreach ($verb in $verbs) {
    $id = [string]$verb.id
    foreach ($trigger in @($verb.triggers)) {
        if ($verbIds -contains [string]$trigger) {
            $target = $verbs | Where-Object { [string]$_.id -eq [string]$trigger } | Select-Object -First 1
            if (@($target.triggers) -contains $id -and $energyDrain -le 0 -and $maxDepth -le 0) {
                $cycles.Add([ordered]@{ verbs = @($id, [string]$trigger); code = 'CYCLIC_TRIGGERING' })
            }
        }
    }
}
foreach ($composition in $compositions) {
    $id = [string]$composition.id
    $first = $verbs | Where-Object { [string]$_.id -eq [string]$composition.first_verb } | Select-Object -First 1
    $second = $verbs | Where-Object { [string]$_.id -eq [string]$composition.second_verb } | Select-Object -First 1
    $cost = [double]$first.cost + [double]$second.cost
    $reward = if ($null -ne $composition.reward) { [double]$composition.reward } else { [double]$composition.synergy_factor }
    $coverage = [Math]::Max([double]$first.challenge_coverage, [double]$second.challenge_coverage)
    if ($cost -le 0 -and $reward -gt 0 -and $coverage -ge 1) {
        $dominant.Add([ordered]@{ composition_id = $id; code = 'TRIVIALIZING_COMBO'; reason = 'recompensa sem custo cobre todos os desafios declarados.' })
    }
    if ($composition.destructive_collateral -eq $true -and $composition.PSObject.Properties.Name -contains 'reverse_result' -and -not [string]::IsNullOrWhiteSpace([string]$composition.reverse_result)) {
        $races.Add([ordered]@{ composition_id = $id; code = 'EXECUTION_PRIORITY_INCOHERENCE'; reason = 'ordens direta e reversa produzem efeitos destrutivos distintos.' })
    }
}
foreach ($cycle in $cycles) { $diagnoses.Add([ordered]@{ code = $cycle.code; status = 'flagged'; details = $cycle }) }
foreach ($item in $dominant) { $diagnoses.Add([ordered]@{ code = $item.code; status = 'flagged'; details = $item }) }
foreach ($item in $races) { $diagnoses.Add([ordered]@{ code = $item.code; status = 'flagged'; details = $item }) }
$emergentCount = @($compositions | Where-Object { $_.novel_affordance -eq $true }).Count
$degree = if ($emergentCount -eq 0) { 'LOW' } elseif ($emergentCount -lt $compositions.Count) { 'MEDIUM' } else { 'HIGH' }
[ordered]@{
    schema_version = '1.0.0'; skill_id = 'emergent-agency-composition'; status = 'success'
    results = [ordered]@{
        atomic_verb_count = $verbs.Count; entity_property_count = $entities.Count; composition_count = $compositions.Count
        composition_graph = @($compositions | ForEach-Object { [ordered]@{ id = [string]$_.id; from = [string]$_.first_verb; to = [string]$_.second_verb; synergy_factor = [double]$_.synergy_factor; result = [string]$_.result } })
        systemic_emergence_degree = $degree; diagnoses = @($diagnoses)
        integrity_adjustments = if ($diagnoses.Count -gt 0) { @('Adicionar limite de profundidade ou dreno de energia.', 'Definir prioridade determinística por tick e limitar cobertura de combinações.') } else { @() }
        limitations = @('Diagnósticos dependem de custos, coberturas e efeitos declarados; não substituem simulação ou playtest.')
    }
    metrics = @(
        [ordered]@{ name = 'atomic_verb_count'; value = $verbs.Count; status = 'derived' },
        [ordered]@{ name = 'composition_count'; value = $compositions.Count; status = 'derived' },
        [ordered]@{ name = 'emergent_composition_count'; value = $emergentCount; status = 'derived' },
        [ordered]@{ name = 'flagged_diagnoses'; value = $diagnoses.Count; status = 'derived' }
    )
    evidence = @([ordered]@{ type = 'calculation'; id = 'emergent-agency-composition-checks'; status = 'derived'; source = 'hidden_state.emergent_agency_composition' })
    handoffs = @(
        [ordered]@{ target = 'committed-risk-reward-actions'; reason = 'validar custos e risco das composições' },
        [ordered]@{ target = 'concurrent-gameplay-processes'; reason = 'validar concorrência e prioridades temporais' },
        [ordered]@{ target = 'cognitive-schema-disruption'; reason = 'avaliar descoberta e coerência das regras emergentes' }
    )
    errors = @()
} | ConvertTo-Json -Depth 15 -Compress
