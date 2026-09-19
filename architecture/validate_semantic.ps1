param(
    [string]$WorldModelPath,
    [string]$HandoffsPath,
    [string]$AdapterPath
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$errors = [System.Collections.Generic.List[string]]::new()

function Read-Json([string]$path) {
    try { return Get-Content -Encoding UTF8 -LiteralPath $path -Raw | ConvertFrom-Json }
    catch { $errors.Add("JSON inválido ou ausente: $path ($($_.Exception.Message))"); return $null }
}
$skillRegistry = Read-Json (Join-Path $root 'skill-registry.json')
function Add-DuplicateErrors($items, [string]$label) {
    $seen = @{}
    foreach ($item in @($items)) {
        if ($null -eq $item -or -not $item.PSObject.Properties.Name.Contains('id')) { continue }
        $id = [string]$item.id
        if ([string]::IsNullOrWhiteSpace($id)) { $errors.Add("$label com id vazio") }
        elseif ($seen.ContainsKey($id)) { $errors.Add("$label com id duplicado: $id") }
        else { $seen[$id] = $true }
    }
    return @($seen.Keys)
}
function Add-ReferenceError([string]$label, [string]$value, $known) {
    if ([string]::IsNullOrWhiteSpace($value) -or @($known) -notcontains $value) {
        $errors.Add("$label referencia id inexistente: $value")
    }
}
function Test-Number($value, [string]$label, [bool]$nonNegative = $true) {
    if ($null -eq $value) { return }
    if ($value -isnot [ValueType] -or $value -isnot [double] -and $value -isnot [decimal] -and $value -isnot [int] -and $value -isnot [long]) { return }
    $number = [double]$value
    if ([double]::IsNaN($number) -or [double]::IsInfinity($number)) { $errors.Add("$label não pode ser NaN/Infinity") }
    elseif ([double]::IsPositiveInfinity($number) -or $number -gt [double]::MaxValue) { $errors.Add("$label excede o limite numérico") }
    elseif ($nonNegative -and $number -lt 0) { $errors.Add("$label não pode ser negativo") }
}
function Test-Acyclic($items, [string]$label) {
    $graph = @{}
    foreach ($item in @($items)) {
        if ($null -eq $item) { continue }
        $from = [string]$item.from; $to = [string]$item.to
        if (-not $graph.ContainsKey($from)) { $graph[$from] = @() }
        $graph[$from] += $to
    }
    $visiting = @{}; $visited = @{}
    function Visit([string]$node) {
        if ($visiting.ContainsKey($node)) { return $true }
        if ($visited.ContainsKey($node)) { return $false }
        $visiting[$node] = $true
        foreach ($next in @($graph[$node])) { if (Visit $next) { return $true } }
        $visiting.Remove($node); $visited[$node] = $true; return $false
    }
    foreach ($node in @($graph.Keys)) { if (Visit $node) { $errors.Add("$label contém ciclo"); break } }
}
function Validate-World($world, [string]$label) {
    if ($null -eq $world) { return }
    foreach ($required in @('entities','resources','spatial','knowledge')) {
        if (-not $world.PSObject.Properties.Name.Contains($required)) { $errors.Add("$label sem seção obrigatória: $required") }
    }
    $entityIds = Add-DuplicateErrors $world.entities "$label entities"
    $resourceIds = Add-DuplicateErrors $world.resources "$label resources"
    foreach ($resource in @($world.resources)) {
        if ($null -eq $resource) { continue }
        if ($resource.PSObject.Properties.Name.Contains('owner_id')) { Add-ReferenceError "$label resource.owner_id" ([string]$resource.owner_id) $entityIds }
        foreach ($field in @('quantity','capacity','initial_quantity')) {
            if ($resource.PSObject.Properties.Name.Contains($field)) { Test-Number $resource.$field "$label resource.$field" }
        }
        if ($resource.PSObject.Properties.Name.Contains('unit') -and [string]::IsNullOrWhiteSpace([string]$resource.unit)) { $errors.Add("$label resource com unidade vazia: $($resource.id)") }
    }
    $spatial = $world.spatial
    $nodeIds = Add-DuplicateErrors $spatial.nodes "$label spatial.nodes"
    foreach ($edge in @($spatial.edges)) {
        if ($null -eq $edge) { continue }
        Add-ReferenceError "$label spatial edge.from" ([string]$edge.from) $nodeIds
        Add-ReferenceError "$label spatial edge.to" ([string]$edge.to) $nodeIds
    }
    $knowledge = $world.knowledge
    $factIds = Add-DuplicateErrors $knowledge.facts "$label knowledge.facts"
    foreach ($dep in @($knowledge.dependencies)) {
        if ($null -eq $dep) { continue }
        Add-ReferenceError "$label knowledge dependency.from" ([string]$dep.from) $factIds
        Add-ReferenceError "$label knowledge dependency.to" ([string]$dep.to) $factIds
    }
    Test-Acyclic $knowledge.dependencies "$label knowledge dependencies"
    foreach ($property in @($world.PSObject.Properties)) {
        if ($property.Name -match 'quantity|capacity|weight|rate|duration|cost|tokens') {
            if ($property.Value -is [ValueType]) { Test-Number $property.Value "$label.$($property.Name)" }
        }
    }
    foreach ($state in @($world.hidden_state.PSObject.Properties)) {
        $model = $state.Value
        if ($null -eq $model) { continue }
        if ($model.PSObject.Properties.Name.Contains('resources')) {
            foreach ($item in @($model.resources)) {
                if ($null -eq $item) { continue }
                if ($item.PSObject.Properties.Name.Contains('id') -and $resourceIds.Count -gt 0) { Add-ReferenceError "$label $($state.Name) resource" ([string]$item.id) $resourceIds }
                foreach ($field in @('initial_quantity','quantity','capacity','tokens','weight','rate')) {
                    if ($item.PSObject.Properties.Name.Contains($field)) { Test-Number $item.$field "$label $($state.Name).$field" }
                }
            }
        }
        if ($model.PSObject.Properties.Name.Contains('places')) {
            $placeIds = Add-DuplicateErrors $model.places "$label $($state.Name).places"
            foreach ($place in @($model.places)) { if ($null -ne $place -and $place.PSObject.Properties.Name.Contains('tokens')) { Test-Number $place.tokens "$label petri tokens" } }
            foreach ($transition in @($model.transitions)) {
                if ($null -eq $transition) { continue }
                $enabled = $true
                foreach ($input in @($transition.inputs)) {
                    Add-ReferenceError "$label petri input.place" ([string]$input.place) $placeIds
                    $place = @($model.places | Where-Object id -eq $input.place)[0]
                    $weight = if ($input.PSObject.Properties.Name.Contains('weight')) { [double]$input.weight } else { 1 }
                    Test-Number $weight "$label petri input weight"
                    if ($null -eq $place -or [double]$place.tokens -lt $weight) { $enabled = $false }
                }
                foreach ($output in @($transition.outputs)) { Add-ReferenceError "$label petri output.place" ([string]$output.place) $placeIds; if ($output.PSObject.Properties.Name.Contains('weight')) { Test-Number $output.weight "$label petri output weight" } }
                if (@($model.transitions).Count -gt 0 -and -not $enabled) { $errors.Add("$label petri net deadlock: transition $($transition.id) não habilitada") }
            }
        }
    }
}

if ($WorldModelPath) { Validate-World (Read-Json $WorldModelPath) (Split-Path $WorldModelPath -Leaf) }
else {
    foreach ($file in @(Get-ChildItem -LiteralPath (Join-Path $root 'examples') -Filter '*.example.json')) {
        if ($file.Name -notlike 'playtest-hypothesis.*' -and $file.Name -notlike 'playtest-observation.*') { Validate-World (Read-Json $file.FullName) $file.Name }
    }
}

if (-not $HandoffsPath) { $HandoffsPath = Join-Path $root 'handoffs.json' }
if (-not $AdapterPath) { $AdapterPath = Join-Path $root 'handoff-adapters.json' }
$handoffs = Read-Json $HandoffsPath
$adapters = Read-Json $AdapterPath
if ($null -ne $handoffs -and $null -ne $adapters) {
    foreach ($handoff in @($handoffs.handoffs)) {
        $adapter = @($adapters.adapters | Where-Object { $_.source -eq $handoff.source -and $_.target -eq $handoff.target })[0]
        if ($null -eq $adapter) { continue }
        $source = @($skillRegistry.skills | Where-Object id -eq $handoff.source)[0]
        $sourceFields = @($source.inputs) + @($source.outputs)
        foreach ($field in @($handoff.input)) {
            $mapped = $adapter.maps.PSObject.Properties.Name -contains $field -or $adapter.derived.PSObject.Properties.Name -contains $field -or @($adapter.external_required) -contains $field
            if (-not $mapped -and $sourceFields -notcontains $field -and $field -notmatch '^world_state\.') { $errors.Add("adapter incompleto: $($handoff.source) -> $($handoff.target), campo $field") }
        }
    }
}
if ($errors.Count) { $errors | ForEach-Object { Write-Error $_ }; exit 1 }
Write-Output 'OK: validações semânticas cross-skill concluídas.'
