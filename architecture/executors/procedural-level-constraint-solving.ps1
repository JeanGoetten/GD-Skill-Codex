param(
    [Parameter(Mandatory = $true)]
    [string]$WorldModelPath
)
$ErrorActionPreference = 'Stop'
$world = Get-Content -LiteralPath $WorldModelPath -Raw | ConvertFrom-Json
$csp = $world.hidden_state.csp_system
if ($null -eq $csp) {
    [ordered]@{
        skill_id = 'procedural-level-constraint-solving'
        status = 'blocked'
        results = [ordered]@{ execution = 'not_available'; reason = 'hidden_state.csp_system ausente.' }
        metrics = @()
        evidence = @()
        errors = @('INSUFFICIENT_EVIDENCE: forneça variables e constraints.')
    } | ConvertTo-Json -Depth 10 -Compress
    exit 0
}
$domains = @{}
foreach ($variable in @($csp.variables)) {
    if ($domains.ContainsKey([string]$variable.id)) { throw "variável duplicada: $($variable.id)" }
    $domains[[string]$variable.id] = [System.Collections.Generic.List[object]]::new()
    foreach ($value in @($variable.domain)) { $domains[[string]$variable.id].Add($value) }
}
$constraints = @($csp.constraints)
$errors = [System.Collections.Generic.List[string]]::new()
foreach ($constraint in $constraints) {
    if (-not $domains.ContainsKey([string]$constraint.left)) { $errors.Add("variável inexistente: $($constraint.left)") }
    if (-not $domains.ContainsKey([string]$constraint.right)) { $errors.Add("variável inexistente: $($constraint.right)") }
}
if ($errors.Count) { throw ($errors -join '; ') }

function Test-Relation([object]$Relation, [object]$Left, [object]$Right) {
    switch ([string]$Relation) {
        'different' { return -not ([string]$Left -eq [string]$Right) }
        'equal' { return [string]$Left -eq [string]$Right }
        'adjacent' {
            if ($Left -is [int] -and $Right -is [int]) { return [Math]::Abs($Left - $Right) -eq 1 }
            return $false
        }
        default { throw "relação desconhecida: $Relation" }
    }
}
$revisions = 0
do {
    $changed = $false
    foreach ($constraint in $constraints) {
        $leftId = [string]$constraint.left
        $rightId = [string]$constraint.right
        $kept = @($domains[$leftId] | Where-Object {
            $leftValue = $_
            @($domains[$rightId] | Where-Object { Test-Relation $constraint.relation $leftValue $_ }).Count -gt 0
        })
        if ($kept.Count -ne $domains[$leftId].Count) {
            $domains[$leftId] = [System.Collections.Generic.List[object]]::new()
            foreach ($value in $kept) { $domains[$leftId].Add($value) }
            $changed = $true
        }
        $revisions++
    }
} while ($changed)
$empty = @($domains.Keys | Where-Object { $domains[$_].Count -eq 0 })
$status = if ($empty.Count -gt 0) { 'partial' } else { 'success' }
$domainOutput = [ordered]@{}
foreach ($key in $domains.Keys) { $domainOutput[$key] = @($domains[$key]) }
[ordered]@{
    skill_id = 'procedural-level-constraint-solving'
    status = $status
    results = [ordered]@{
        solvability_status = if ($empty.Count -eq 0) { 'locally_consistent' } else { 'infeasible_after_arc_consistency' }
        domains = $domainOutput
        empty_domains = $empty
        global_solution_proven = $false
        limitation = 'AC-3 fornece consistência local; não prova solução global.'
    }
    metrics = @(
        [ordered]@{ name = 'arc_revisions'; value = $revisions; status = 'derived' },
        [ordered]@{ name = 'empty_domain_count'; value = $empty.Count; status = 'derived' }
    )
    evidence = @([ordered]@{ type = 'calculation'; id = 'ac3-domain-filter'; status = 'derived' })
    errors = @()
} | ConvertTo-Json -Depth 12 -Compress
