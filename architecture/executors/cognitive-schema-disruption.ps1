param(
    [Parameter(Mandatory = $true)]
    [string]$WorldModelPath
)
$ErrorActionPreference = 'Stop'
$world = Get-Content -LiteralPath $WorldModelPath -Raw | ConvertFrom-Json
$model = $world.hidden_state.cognitive_schema_disruption
if ($null -eq $model) {
    [ordered]@{
        skill_id = 'cognitive-schema-disruption'
        status = 'blocked'
        results = [ordered]@{ execution = 'not_available'; reason = 'hidden_state.cognitive_schema_disruption ausente.' }
        metrics = @()
        evidence = @()
        errors = @('INSUFFICIENT_EVIDENCE: forneça conventions e disruptions observáveis.')
    } | ConvertTo-Json -Depth 10 -Compress
    exit 0
}
$conventions = @($model.conventions)
$disruptions = @($model.disruptions)
$ids = @($conventions | ForEach-Object { [string]$_.id })
$errors = [System.Collections.Generic.List[string]]::new()
$defaultRepetitions = if ($null -ne $model.default_repetitions) { [int]$model.default_repetitions } else { 3 }
$diagnoses = @()
foreach ($disruption in $disruptions) {
    $id = [string]$disruption.id
    $conventionId = [string]$disruption.convention_id
    if ($ids -notcontains $conventionId) { $errors.Add("disruption referencia convention inexistente: $conventionId"); continue }
    $convention = $conventions | Where-Object { [string]$_.id -eq $conventionId } | Select-Object -First 1
    $repetitions = [int]$convention.repetitions
    $salience = if ($null -ne $convention.salience) { [double]$convention.salience } else { 0 }
    if ($repetitions -lt $defaultRepetitions -and $salience -lt 0.75) {
        $diagnoses += [ordered]@{ disruption_id = $id; code = 'PREMATURE_DISRUPTION'; status = 'flagged'; reason = 'convenção pouco consolidada antes da ruptura.' }
    }
    if ($disruption.hidden_coherence -ne $true) {
        $diagnoses += [ordered]@{ disruption_id = $id; code = 'ARBITRARY_DISSONANCE'; status = 'flagged'; reason = 'não há coerência retrospectiva declarada.' }
    }
    if ([double]$disruption.magnitude -gt [double]$disruption.threshold -and $disruption.agency_preserved -ne $true) {
        $diagnoses += [ordered]@{ disruption_id = $id; code = 'PUNITIVE_DISRUPTION'; status = 'flagged'; reason = 'magnitude acima do limiar e agência não preservada.' }
    }
    if ($disruption.strategic_variable_changed -ne $true) {
        $diagnoses += [ordered]@{ disruption_id = $id; code = 'NON_STRATEGIC_BREAK'; status = 'flagged'; reason = 'ruptura não declara mudança de variável estratégica.' }
    }
}
if ($errors.Count -gt 0) {
    [ordered]@{ skill_id = 'cognitive-schema-disruption'; status = 'failed'; results = [ordered]@{ execution = 'validation_failed' }; metrics = @(); evidence = @(); errors = @($errors) } | ConvertTo-Json -Depth 12 -Compress
    exit 0
}
[ordered]@{
    skill_id = 'cognitive-schema-disruption'
    status = 'success'
    results = [ordered]@{
        convention_count = $conventions.Count
        disruption_count = $disruptions.Count
        diagnoses = @($diagnoses)
        interpretation = if ($diagnoses.Count -gt 0) { 'calibration_hypotheses_required' } else { 'structurally_coherent' }
        limitations = @(
            'Magnitude and threshold are declared feature-space proxies, not measurements of player experience.',
            'A coherence flag does not prove that players will discover or accept the hidden rule.',
            'Cognitive surprise, confusion and accommodation require observation or playtest.'
        )
    }
    metrics = @(
        [ordered]@{ name = 'convention_count'; value = $conventions.Count; status = 'derived' },
        [ordered]@{ name = 'disruption_count'; value = $disruptions.Count; status = 'derived' },
        [ordered]@{ name = 'flagged_diagnoses'; value = $diagnoses.Count; status = 'derived' }
    )
    evidence = @([ordered]@{ type = 'calculation'; id = 'cognitive-disruption-checks'; status = 'derived'; source = 'hidden_state.cognitive_schema_disruption' })
    handoffs = @(
        [ordered]@{ target = 'epistemic-holarchic-progression'; reason = 'validar pistas e coerência informacional' },
        [ordered]@{ target = 'procedural-expressive-range-analysis'; reason = 'avaliar variedade de respostas quando aplicável' }
    )
    errors = @()
} | ConvertTo-Json -Depth 15 -Compress
