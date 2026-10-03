param(
    [Parameter(Mandatory = $true)]
    [string]$WorldModelPath,
    [int]$MaxStates = 10000
)
$ErrorActionPreference = 'Stop'
$WorldModel = Get-Content -LiteralPath $WorldModelPath -Raw | ConvertFrom-Json
$system = $WorldModel.hidden_state.state_system
if ($null -eq $system) {
    return ([ordered]@{
        skill_id = 'discrete-state-machine-verification'
        status = 'blocked'
        results = [ordered]@{ execution = 'not_available'; reason = 'hidden_state.state_system ausente.' }
        metrics = @()
        evidence = @()
        errors = @('INSUFFICIENT_EVIDENCE: forneça initial_state, states e transitions.')
    } | ConvertTo-Json -Depth 10 -Compress)
}
$stateIds = @($system.states | ForEach-Object { [string]$_.id })
if ($stateIds.Count -eq 0 -or $stateIds -notcontains [string]$system.initial_state) {
    throw 'state_system precisa de states e initial_state válido.'
}
if (@($stateIds | Sort-Object -Unique).Count -ne $stateIds.Count) { throw 'state_system contém ids de estado duplicados.' }
$transitions = @($system.transitions)
$adjacency = @{}
 $reverseAdjacency = @{}
foreach ($id in $stateIds) {
    $adjacency[$id] = [System.Collections.Generic.List[object]]::new()
    $reverseAdjacency[$id] = [System.Collections.Generic.List[string]]::new()
}
$errors = [System.Collections.Generic.List[string]]::new()
foreach ($transition in $transitions) {
    if (-not $adjacency.ContainsKey([string]$transition.from)) { $errors.Add("origem inexistente: $($transition.from)"); continue }
    if (-not $adjacency.ContainsKey([string]$transition.to)) { $errors.Add("destino inexistente: $($transition.to)"); continue }
    $adjacency[[string]$transition.from].Add($transition)
    $reverseAdjacency[[string]$transition.to].Add([string]$transition.from)
}
if ($errors.Count) { throw ($errors -join '; ') }

$probabilityIssues = [System.Collections.Generic.List[string]]::new()
foreach ($group in @($transitions | Group-Object { "$($_.from)|$($_.event)" })) {
    $withProbability = @($group.Group | Where-Object { $_.PSObject.Properties.Name -contains 'probability' })
    if ($withProbability.Count -gt 0 -and $withProbability.Count -ne $group.Count) {
        $probabilityIssues.Add("$($group.Name): mistura transições probabilísticas e não probabilísticas")
    } elseif ($withProbability.Count -eq $group.Count -and $group.Count -gt 0) {
        $sum = ($withProbability | Measure-Object -Property probability -Sum).Sum
        if ([Math]::Abs([double]$sum - 1.0) -gt 0.000001) {
            $probabilityIssues.Add("$($group.Name): probabilidades somam $sum, esperado 1")
        }
    }
}
$visited = [System.Collections.Generic.HashSet[string]]::new()
$queue = [System.Collections.Generic.Queue[string]]::new()
$queue.Enqueue([string]$system.initial_state)
while ($queue.Count -gt 0) {
    $current = $queue.Dequeue()
    if (-not $visited.Add($current)) { continue }
    if ($visited.Count -gt $MaxStates) { throw "limite de estados excedido: $MaxStates" }
    foreach ($transition in $adjacency[$current]) { if (-not $visited.Contains([string]$transition.to)) { $queue.Enqueue([string]$transition.to) } }
}
$terminalIds = @($system.states | Where-Object { $_.terminal -eq $true } | ForEach-Object { [string]$_.id })
$reachableTerminals = @($terminalIds | Where-Object { $visited.Contains($_) })
$orphans = @($stateIds | Where-Object { -not $visited.Contains($_) })
$deadlocks = @($visited | Where-Object { $terminalIds -notcontains $_ -and $adjacency[$_].Count -eq 0 })
$canReachTerminal = [System.Collections.Generic.HashSet[string]]::new()
$backwardQueue = [System.Collections.Generic.Queue[string]]::new()
foreach ($terminal in $terminalIds) { $backwardQueue.Enqueue($terminal) }
while ($backwardQueue.Count -gt 0) {
    $current = $backwardQueue.Dequeue()
    if (-not $canReachTerminal.Add($current)) { continue }
    foreach ($previous in $reverseAdjacency[$current]) { if (-not $canReachTerminal.Contains($previous)) { $backwardQueue.Enqueue($previous) } }
}
$livelocks = @($visited | Where-Object {
    $terminalIds -notcontains $_ -and $deadlocks -notcontains $_ -and -not $canReachTerminal.Contains($_)
})
$nondeterministic = @($visited | ForEach-Object {
    $events = @($adjacency[$_] | Group-Object event | Where-Object { $_.Count -gt 1 })
    if ($events.Count -gt 0) { $_ }
})

$invalidStates = [System.Collections.Generic.List[string]]::new()
$unknownInvariants = [System.Collections.Generic.List[string]]::new()
foreach ($invariant in @($system.invariants)) {
    $match = [regex]::Match([string]$invariant, '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*(<=|>=|==|!=|<|>)\s*(-?[0-9]+(?:\.[0-9]+)?)\s*$')
    if (-not $match.Success) { $unknownInvariants.Add([string]$invariant); continue }
    $property = $match.Groups[1].Value; $operator = $match.Groups[2].Value; $expected = [double]$match.Groups[3].Value
    $observedAny = $false
    foreach ($state in @($system.states)) {
        if (-not ($state.PSObject.Properties.Name -contains $property) -or $state.$property -isnot [ValueType]) { continue }
        $observedAny = $true; $actual = [double]$state.$property
        $valid = switch ($operator) {
            '<=' { $actual -le $expected } '>=' { $actual -ge $expected }
            '==' { $actual -eq $expected } '!=' { $actual -ne $expected }
            '<' { $actual -lt $expected } '>' { $actual -gt $expected }
        }
        if (-not $valid -and -not $invalidStates.Contains([string]$state.id)) { $invalidStates.Add([string]$state.id) }
    }
    if (-not $observedAny) { $unknownInvariants.Add([string]$invariant) }
}
$invariantTransitionViolations = @($transitions | Where-Object { $invalidStates.Contains([string]$_.to) } | ForEach-Object { "$($_.from) --$($_.event)--> $($_.to)" })
$hasAnomaly = $orphans.Count -gt 0 -or $deadlocks.Count -gt 0 -or $livelocks.Count -gt 0 -or $invalidStates.Count -gt 0 -or $probabilityIssues.Count -gt 0
[ordered]@{
    skill_id = 'discrete-state-machine-verification'
    status = if ($hasAnomaly) { 'partial' } else { 'success' }
    results = [ordered]@{
        graph_status = if ($hasAnomaly) { 'CONTAINS_ERRORS' } else { 'VALID' }
        reachable_states = @($visited)
        reachable_terminal_states = $reachableTerminals
        orphan_states = $orphans
        deadlocks = $deadlocks
        livelock_candidates = $livelocks
        nondeterministic_states = $nondeterministic
        probability_issues = @($probabilityIssues)
        invalid_states = @($invalidStates)
        invariant_transition_violations = $invariantTransitionViolations
        unevaluated_invariants = @($unknownInvariants)
        reachability_scope = 'A reachable terminal proves that a path exists; it does not prove that a player can force the outcome.'
    }
    metrics = @(
        [ordered]@{ name = 'reachable_state_count'; value = $visited.Count; status = 'derived' },
        [ordered]@{ name = 'orphan_state_count'; value = $orphans.Count; status = 'derived' },
        [ordered]@{ name = 'deadlock_count'; value = $deadlocks.Count; status = 'derived' },
        [ordered]@{ name = 'livelock_candidate_count'; value = $livelocks.Count; status = 'derived' },
        [ordered]@{ name = 'invalid_state_count'; value = $invalidStates.Count; status = 'derived' }
    )
    evidence = @([ordered]@{ type = 'calculation'; id = 'bfs-reachability'; status = 'derived' })
    errors = @($probabilityIssues)
} | ConvertTo-Json -Depth 12 -Compress
