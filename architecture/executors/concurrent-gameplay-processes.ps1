param(
    [Parameter(Mandatory = $true)]
    [string]$WorldModelPath,
    [int]$Steps = 100
)
$ErrorActionPreference = 'Stop'
if ($Steps -lt 1) { throw 'Steps deve ser positivo.' }
$world = Get-Content -LiteralPath $WorldModelPath -Raw | ConvertFrom-Json
$net = $world.hidden_state.petri_net
if ($null -eq $net) {
    [ordered]@{
        skill_id = 'concurrent-gameplay-processes'
        status = 'blocked'
        results = [ordered]@{ execution = 'not_available'; reason = 'hidden_state.petri_net ausente.' }
        metrics = @()
        evidence = @()
        errors = @('INSUFFICIENT_EVIDENCE: forneça places e transitions.')
    } | ConvertTo-Json -Depth 10 -Compress
    exit 0
}
$tokens = @{}
$errors = [System.Collections.Generic.List[string]]::new()
foreach ($place in @($net.places)) {
    $id = [string]$place.id
    if ([string]::IsNullOrWhiteSpace($id) -or $tokens.ContainsKey($id)) { $errors.Add("place inválido ou duplicado: $id"); continue }
    if ($null -eq $place.tokens -or [int]$place.tokens -lt 0) { $errors.Add("tokens inválidos no place: $id"); continue }
    $tokens[$id] = [int]$place.tokens
}
foreach ($transition in @($net.transitions)) {
    foreach ($arc in @($transition.inputs) + @($transition.outputs)) {
        if (-not $tokens.ContainsKey([string]$arc.place)) { $errors.Add("arco referencia place inexistente: $($arc.place)") }
        if ($null -eq $arc.weight -or [int]$arc.weight -lt 1) { $errors.Add("peso de arco inválido na transição: $($transition.id)") }
    }
}
if ($errors.Count) {
    [ordered]@{ skill_id = 'concurrent-gameplay-processes'; status = 'failed'; results = [ordered]@{ execution = 'validation_failed' }; metrics = @(); evidence = @(); errors = @($errors) } | ConvertTo-Json -Depth 10 -Compress
    exit 0
}
function Test-Enabled([object]$Transition) {
    foreach ($arc in @($Transition.inputs)) { if ($tokens[[string]$arc.place] -lt [int]$arc.weight) { return $false } }
    return $true
}
$fired = [System.Collections.Generic.List[string]]::new()
$markings = [System.Collections.Generic.List[object]]::new()
for ($step = 0; $step -lt $Steps; $step++) {
    $enabled = @($net.transitions | Where-Object { Test-Enabled $_ })
    $markingTokens = [ordered]@{}
    foreach ($key in $tokens.Keys) { $markingTokens[$key] = $tokens[$key] }
    $markings.Add([ordered]@{ step = $step; tokens = $markingTokens; enabled_transitions = @($enabled | ForEach-Object { [string]$_.id }) })
    if ($enabled.Count -eq 0) { break }
    $chosen = $enabled[0]
    foreach ($arc in @($chosen.inputs)) { $tokens[[string]$arc.place] -= [int]$arc.weight }
    foreach ($arc in @($chosen.outputs)) { $tokens[[string]$arc.place] += [int]$arc.weight }
    $fired.Add([string]$chosen.id)
}
$deadlock = @($net.transitions | Where-Object { Test-Enabled $_ }).Count -eq 0
$finalTokens = [ordered]@{}
foreach ($key in $tokens.Keys) { $finalTokens[$key] = $tokens[$key] }
[ordered]@{
    skill_id = 'concurrent-gameplay-processes'
    status = if ($deadlock) { 'partial' } else { 'success' }
    results = [ordered]@{
        places = $finalTokens
        fired_transitions = @($fired)
        markings = @($markings)
        deadlock = $deadlock
        liveness_status = if ($fired.Count -gt 0) { 'observed_progress' } else { 'no_transition_fired' }
        limitation = 'A simulação limitada observa uma trajetória; não prova vivacidade global.'
    }
    metrics = @(
        [ordered]@{ name = 'fired_transition_count'; value = $fired.Count; status = 'derived' },
        [ordered]@{ name = 'marking_count'; value = $markings.Count; status = 'derived' }
    )
    evidence = @([ordered]@{ type = 'simulation'; id = 'petri-net-bounded-run'; status = 'derived' })
    errors = @()
} | ConvertTo-Json -Depth 12 -Compress
