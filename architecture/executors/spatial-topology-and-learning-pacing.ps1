param(
    [Parameter(Mandatory = $true)]
    [string]$WorldModelPath
)
$ErrorActionPreference = 'Stop'
$world = Get-Content -LiteralPath $WorldModelPath -Raw | ConvertFrom-Json
$model = $world.hidden_state.spatial_pacing
if ($null -eq $model) {
    [ordered]@{
        skill_id = 'spatial-topology-and-learning-pacing'
        status = 'blocked'
        results = [ordered]@{ execution = 'not_available'; reason = 'hidden_state.spatial_pacing ausente.' }
        metrics = @()
        evidence = @()
        errors = @('INSUFFICIENT_EVIDENCE: forneça nodes, edges e, opcionalmente, start_nodes.')
    } | ConvertTo-Json -Depth 10 -Compress
    exit 0
}
$nodes = @($model.nodes)
$edges = @($model.edges)
$ids = @($nodes | ForEach-Object { [string]$_.id })
$errors = [System.Collections.Generic.List[string]]::new()
if (@($ids | Select-Object -Unique).Count -ne $ids.Count) { $errors.Add('node id duplicado.') }
$incoming = @{}
$outgoing = @{}
foreach ($id in $ids) { $incoming[$id] = @(); $outgoing[$id] = @() }
foreach ($edge in $edges) {
    $from = [string]$edge.from
    $to = [string]$edge.to
    if ($ids -notcontains $from -or $ids -notcontains $to) { $errors.Add("edge referencia node inexistente: $from -> $to"); continue }
    $outgoing[$from] += $to
    $incoming[$to] += $from
}
if ($errors.Count -gt 0) {
    [ordered]@{ skill_id = 'spatial-topology-and-learning-pacing'; status = 'failed'; results = [ordered]@{ execution = 'validation_failed' }; metrics = @(); evidence = @(); errors = @($errors) } | ConvertTo-Json -Depth 12 -Compress
    exit 0
}
$starts = @($model.start_nodes | ForEach-Object { [string]$_ })
if ($starts.Count -eq 0) { $starts = @($nodes | Where-Object { $_.accessible_at_start -eq $true -or $incoming[[string]$_.id].Count -eq 0 } | ForEach-Object { [string]$_.id }) }
$reachable = [System.Collections.Generic.HashSet[string]]::new()
$queue = [System.Collections.Generic.Queue[string]]::new()
foreach ($start in $starts) { if ($ids -contains $start) { $reachable.Add($start) | Out-Null; $queue.Enqueue($start) } }
while ($queue.Count -gt 0) {
    $current = $queue.Dequeue()
    foreach ($next in @($outgoing[$current])) { if ($reachable.Add($next)) { $queue.Enqueue($next) } }
}
$unreachable = @($ids | Where-Object { -not $reachable.Contains($_) })
$diagnoses = @()
$mechanics = @($nodes | ForEach-Object { @($_.mechanics) } | Where-Object { $_ } | Select-Object -Unique)
foreach ($mechanic in $mechanics) {
    $introductions = @($nodes | Where-Object { @($_.mechanics) -contains $mechanic -and $_.phase -eq 'introduce' })
    $intro = $introductions | Sort-Object { $incoming[[string]$_.id].Count } | Select-Object -First 1
    if ($null -eq $intro) { continue }
    if ($intro.death_risk -eq $true -or @($intro.mechanics).Count -gt 1) {
        $diagnoses += [ordered]@{ code = 'COGNITIVE_LOAD_SPIKE'; status = 'flagged'; mechanic = $mechanic; node_id = [string]$intro.id; reason = 'introdução combina múltiplas mecânicas ou risco de morte.' }
    }
    $combines = @($nodes | Where-Object { $_.phase -eq 'combine' -and @($_.mechanics) -contains $mechanic })
    foreach ($combine in $combines) {
        $combinePreds = @($incoming[[string]$combine.id])
        if ($combinePreds -contains [string]$intro.id) { continue }
        $introIndex = $ids.IndexOf([string]$intro.id)
        $combineIndex = $ids.IndexOf([string]$combine.id)
        if ($introIndex -ge 0 -and $combineIndex -ge 0 -and $combineIndex -lt $introIndex) {
            $diagnoses += [ordered]@{ code = 'TOPOLOGICAL_PREREQUISITE_BREAK'; status = 'flagged'; mechanic = $mechanic; node_id = [string]$combine.id }
        }
    }
}
$orderedNodes = @($nodes | Sort-Object id)
$highRun = 0
$maxHighRun = 0
$decompressionAfterPeak = $false
$previousWasPeak = $false
foreach ($node in $orderedNodes) {
    if ([double]$node.tension -ge 0.8) { $highRun++; if ($highRun -gt $maxHighRun) { $maxHighRun = $highRun }; $previousWasPeak = $true }
    else { if ($previousWasPeak -and ([double]$node.tension -le 0.2 -or $node.is_decompression -eq $true)) { $decompressionAfterPeak = $true }; $highRun = 0; $previousWasPeak = $false }
}
if ($maxHighRun -gt 2 -and -not $decompressionAfterPeak) { $diagnoses += [ordered]@{ code = 'TENSION_PLATEAU'; status = 'flagged'; reason = 'sequência de alta tensão sem decompression room observável.' } }
if ($unreachable.Count -gt 0) { $diagnoses += [ordered]@{ code = 'UNREACHABLE_SPACE'; status = 'flagged'; nodes = $unreachable } }
$peak = if ($nodes.Count -gt 0) { ($nodes | Measure-Object -Property tension -Maximum).Maximum } else { 0 }
[ordered]@{
    skill_id = 'spatial-topology-and-learning-pacing'
    status = 'success'
    results = [ordered]@{
        node_count = $nodes.Count
        edge_count = $edges.Count
        reachable_nodes = @($reachable)
        unreachable_nodes = $unreachable
        peak_tension = $peak
        max_high_tension_run = $maxHighRun
        diagnoses = $diagnoses
        interpretation = if ($diagnoses.Count -gt 0) { 'pacing_risks_flagged' } else { 'topology_structurally_consistent' }
        limitations = @(
            'Graph reachability does not prove physical solvability, discoverability or accessibility.',
            'Tension and phases are declared proxies; learning quality requires route traces and novice testing.',
            'Node ordering is a declared analysis order, not a substitute for all possible player routes.'
        )
    }
    metrics = @(
        [ordered]@{ name = 'node_count'; value = $nodes.Count; status = 'derived' },
        [ordered]@{ name = 'edge_count'; value = $edges.Count; status = 'derived' },
        [ordered]@{ name = 'reachable_ratio'; value = if ($nodes.Count -gt 0) { $reachable.Count / $nodes.Count } else { 0 }; status = 'derived' },
        [ordered]@{ name = 'flagged_diagnoses'; value = $diagnoses.Count; status = 'derived' }
    )
    evidence = @([ordered]@{ type = 'calculation'; id = 'spatial-pacing-graph-checks'; status = 'derived'; source = 'hidden_state.spatial_pacing' })
    handoffs = @(
        [ordered]@{ target = 'procedural-level-constraint-solving'; reason = 'validar solvabilidade física das transições' },
        [ordered]@{ target = 'epistemic-holarchic-progression'; reason = 'alinhar pistas e descoberta' }
    )
    errors = @()
} | ConvertTo-Json -Depth 15 -Compress
