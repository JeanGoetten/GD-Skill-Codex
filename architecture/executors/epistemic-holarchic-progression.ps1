param(
    [Parameter(Mandatory = $true)]
    [string]$WorldModelPath
)
$ErrorActionPreference = 'Stop'
$world = Get-Content -LiteralPath $WorldModelPath -Raw | ConvertFrom-Json
$model = $world.hidden_state.epistemic_progression
if ($null -eq $model) {
    [ordered]@{
        skill_id = 'epistemic-holarchic-progression'
        status = 'blocked'
        results = [ordered]@{ execution = 'not_available'; reason = 'hidden_state.epistemic_progression ausente.' }
        metrics = @()
        evidence = @()
        errors = @('INSUFFICIENT_EVIDENCE: forneça holons, clues e, opcionalmente, known_holons.')
    } | ConvertTo-Json -Depth 10 -Compress
    exit 0
}
$holons = @($model.holons)
$clues = @($model.clues)
$ids = @($holons | ForEach-Object { [string]$_.id })
$errors = [System.Collections.Generic.List[string]]::new()
$incoming = @{}
$outgoing = @{}
foreach ($id in $ids) { $incoming[$id] = 0; $outgoing[$id] = 0 }
foreach ($clue in $clues) {
    $from = [string]$clue.from
    $to = [string]$clue.to
    if ($ids -notcontains $from -or $ids -notcontains $to) {
        $errors.Add("clue referencia holon inexistente: $from -> $to")
        continue
    }
    $outgoing[$from]++
    $incoming[$to]++
}
if ($errors.Count -gt 0) {
    [ordered]@{ skill_id = 'epistemic-holarchic-progression'; status = 'failed'; results = [ordered]@{ execution = 'validation_failed' }; metrics = @(); evidence = @(); errors = @($errors) } | ConvertTo-Json -Depth 12 -Compress
    exit 0
}
$roots = @($holons | Where-Object { $_.root -eq $true } | ForEach-Object { [string]$_.id })
if ($roots.Count -eq 0) { $roots = @($holons | Where-Object { $incoming[[string]$_.id] -eq 0 } | ForEach-Object { [string]$_.id }) }
$orphans = @($holons | Where-Object { $_.root -ne $true -and $incoming[[string]$_.id] -eq 0 } | ForEach-Object { [string]$_.id })
$pseudoHolons = @($holons | Where-Object { $_.access_requires_inventory -eq $true } | ForEach-Object { [string]$_.id })
$linear = ($holons.Count -gt 1) -and (@($incoming.Values | Where-Object { $_ -gt 1 }).Count -eq 0) -and (@($outgoing.Values | Where-Object { $_ -gt 1 }).Count -eq 0)
$terminalIds = @($holons | Where-Object { $_.terminal -eq $true } | ForEach-Object { [string]$_.id })
$known = @($model.known_holons | ForEach-Object { [string]$_ })
$terminalCoverage = @()
foreach ($terminal in $terminalIds) {
    $predecessors = @($clues | Where-Object { [string]$_.to -eq $terminal -and $_.required_for_terminal -eq $true } | ForEach-Object { [string]$_.from })
    $covered = @($predecessors | Where-Object { $known -contains $_ })
    $ratio = if ($predecessors.Count -gt 0) { $covered.Count / $predecessors.Count } else { $null }
    $terminalCoverage += [ordered]@{ terminal_id = $terminal; required_predecessors = $predecessors; known_predecessors = $covered; inference_capacity = $ratio }
}
$diagnoses = @()
if ($orphans.Count -gt 0) { $diagnoses += [ordered]@{ code = 'INFORMATIONAL_ISLAND'; status = 'flagged'; holons = $orphans } }
if ($pseudoHolons.Count -gt 0) { $diagnoses += [ordered]@{ code = 'PSEUDO_HOLON'; status = 'flagged'; holons = $pseudoHolons } }
if ($linear) { $diagnoses += [ordered]@{ code = 'FALSE_HOLARCHY'; status = 'flagged'; reason = 'grafo sem ramificação ou convergência estrutural.' } }
[ordered]@{
    skill_id = 'epistemic-holarchic-progression'
    status = 'success'
    results = [ordered]@{
        holon_count = $holons.Count
        clue_count = $clues.Count
        roots = $roots
        terminals = $terminalIds
        terminal_coverage = $terminalCoverage
        diagnoses = $diagnoses
        interpretation = if ($diagnoses.Count -gt 0) { 'structural_risks_flagged' } else { 'no_declared_anomaly' }
        limitations = @(
            'Inference capacity is graph coverage, not probability of player understanding.',
            'Physical accessibility is only checked from declared flags; trajectory validity still requires movement and hazard simulation.',
            'The executor does not infer cognitive accessibility or enjoyment from graph topology.'
        )
    }
    metrics = @(
        [ordered]@{ name = 'holon_count'; value = $holons.Count; status = 'derived' },
        [ordered]@{ name = 'clue_count'; value = $clues.Count; status = 'derived' },
        [ordered]@{ name = 'orphan_count'; value = $orphans.Count; status = 'derived' },
        [ordered]@{ name = 'terminal_count'; value = $terminalIds.Count; status = 'derived' }
    )
    evidence = @([ordered]@{ type = 'calculation'; id = 'epistemic-graph-checks'; status = 'derived'; source = 'hidden_state.epistemic_progression' })
    handoffs = @(
        [ordered]@{ target = 'cognitive-schema-disruption'; reason = 'avaliar interpretação e surpresa' },
        [ordered]@{ target = 'spatial-topology-and-learning-pacing'; reason = 'validar acessibilidade física e pacing' }
    )
    errors = @()
} | ConvertTo-Json -Depth 15 -Compress
