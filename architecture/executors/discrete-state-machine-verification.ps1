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
$transitions = @($system.transitions)
$adjacency = @{}
foreach ($id in $stateIds) { $adjacency[$id] = [System.Collections.Generic.List[object]]::new() }
$errors = [System.Collections.Generic.List[string]]::new()
foreach ($transition in $transitions) {
    if (-not $adjacency.ContainsKey([string]$transition.from)) { $errors.Add("origem inexistente: $($transition.from)"); continue }
    if (-not $adjacency.ContainsKey([string]$transition.to)) { $errors.Add("destino inexistente: $($transition.to)"); continue }
    $adjacency[[string]$transition.from].Add($transition)
}
if ($errors.Count) { throw ($errors -join '; ') }
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
$nondeterministic = @($visited | ForEach-Object {
    $events = @($adjacency[$_] | Group-Object event | Where-Object { $_.Count -gt 1 })
    if ($events.Count -gt 0) { $_ }
})
[ordered]@{
    skill_id = 'discrete-state-machine-verification'
    status = if ($orphans.Count -eq 0 -and $deadlocks.Count -eq 0) { 'success' } else { 'partial' }
    results = [ordered]@{
        graph_status = if ($orphans.Count -eq 0 -and $deadlocks.Count -eq 0) { 'VALID' } else { 'CONTAINS_ERRORS' }
        reachable_states = @($visited)
        reachable_terminal_states = $reachableTerminals
        orphan_states = $orphans
        deadlocks = $deadlocks
        nondeterministic_states = $nondeterministic
    }
    metrics = @(
        [ordered]@{ name = 'reachable_state_count'; value = $visited.Count; status = 'derived' },
        [ordered]@{ name = 'orphan_state_count'; value = $orphans.Count; status = 'derived' },
        [ordered]@{ name = 'deadlock_count'; value = $deadlocks.Count; status = 'derived' }
    )
    evidence = @([ordered]@{ type = 'calculation'; id = 'bfs-reachability'; status = 'derived' })
    errors = @()
} | ConvertTo-Json -Depth 12 -Compress
