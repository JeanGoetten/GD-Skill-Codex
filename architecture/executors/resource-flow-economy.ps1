param(
    [Parameter(Mandatory = $true)]
    [string]$WorldModelPath
)
$ErrorActionPreference = 'Stop'

$world = Get-Content -LiteralPath $WorldModelPath -Raw | ConvertFrom-Json
$flowModel = $world.hidden_state.resource_flow
if ($null -eq $flowModel) {
    [ordered]@{
        schema_version = '1.0.0'
        skill_id = 'resource-flow-economy'
        status = 'blocked'
        results = [ordered]@{ execution = 'not_available'; reason = 'hidden_state.resource_flow ausente.' }
        metrics = @()
        evidence = @()
        errors = @('INSUFFICIENT_EVIDENCE: forneça hidden_state.resource_flow com flows.')
    } | ConvertTo-Json -Depth 12 -Compress
    exit 0
}

$errors = [System.Collections.Generic.List[string]]::new()
if (-not $flowModel.version) { $errors.Add('resource_flow.version ausente.') }
if ($null -eq $flowModel.flows) { $errors.Add('resource_flow.flows ausente.') }
$resourceIds = [System.Collections.Generic.HashSet[string]]::new()
foreach ($resource in @($flowModel.resources)) {
    $id = [string]$resource.id
    if ([string]::IsNullOrWhiteSpace($id)) { $errors.Add('resource_flow.resources contém recurso sem id.'); continue }
    if (-not $resourceIds.Add($id)) { $errors.Add("recurso duplicado: $id") }
}
$balances = @{}
$sourceTotals = @{}
$sinkTotals = @{}
$flowEvidence = [System.Collections.Generic.List[object]]::new()
foreach ($flow in @($flowModel.flows)) {
    $id = [string]$flow.id
    $resourceId = [string]$flow.resource_id
    $direction = [string]$flow.direction
    $quantityValue = $flow.quantity
    if ([string]::IsNullOrWhiteSpace($id) -or [string]::IsNullOrWhiteSpace($resourceId)) {
        $errors.Add('cada flow requer id e resource_id.'); continue
    }
    if ($direction -notin @('source', 'sink')) { $errors.Add("flow $id tem direction inválida: $direction"); continue }
    if ($null -eq $quantityValue -or -not ($quantityValue -is [ValueType]) -or [double]$quantityValue -lt 0) {
        $errors.Add("flow $id requer quantity numérica não negativa."); continue
    }
    if ($resourceIds.Count -gt 0 -and -not $resourceIds.Contains($resourceId)) {
        $errors.Add("flow $id referencia recurso inexistente: $resourceId")
    }
    $quantity = [double]$quantityValue
    if (-not $balances.ContainsKey($resourceId)) { $balances[$resourceId] = 0.0; $sourceTotals[$resourceId] = 0.0; $sinkTotals[$resourceId] = 0.0 }
    if ($flow.active -eq $false) { continue }
    if ($direction -eq 'source') { $sourceTotals[$resourceId] += $quantity; $balances[$resourceId] += $quantity }
    else { $sinkTotals[$resourceId] += $quantity; $balances[$resourceId] -= $quantity }
    $flowEvidence.Add([ordered]@{ type = 'input'; id = $id; status = 'available'; resource_id = $resourceId; direction = $direction; quantity = $quantity })
}
if ($errors.Count -gt 0) {
    [ordered]@{
        schema_version = '1.0.0'; skill_id = 'resource-flow-economy'; status = 'failed'
        results = [ordered]@{ execution = 'validation_failed' }; metrics = @(); evidence = @(); errors = @($errors)
    } | ConvertTo-Json -Depth 12 -Compress
    exit 0
}

$resourceResults = [ordered]@{}
$surplus = [System.Collections.Generic.List[string]]::new()
$deficit = [System.Collections.Generic.List[string]]::new()
$balanced = [System.Collections.Generic.List[string]]::new()
foreach ($resourceId in @($balances.Keys | Sort-Object)) {
    $balance = [double]$balances[$resourceId]
    $state = if ($balance -gt 0) { 'surplus' } elseif ($balance -lt 0) { 'deficit' } else { 'balanced' }
    if ($state -eq 'surplus') { $surplus.Add($resourceId) }
    elseif ($state -eq 'deficit') { $deficit.Add($resourceId) } else { $balanced.Add($resourceId) }
    $resourceResults[$resourceId] = [ordered]@{
        source_total = $sourceTotals[$resourceId]
        sink_total = $sinkTotals[$resourceId]
        discrete_balance = $balance
        state = $state
        equation = "$($sourceTotals[$resourceId]) - $($sinkTotals[$resourceId]) = $balance"
    }
}
$overall = if ($deficit.Count -gt 0 -and $surplus.Count -gt 0) { 'mixed' } elseif ($deficit.Count -gt 0) { 'deficit' } elseif ($surplus.Count -gt 0) { 'surplus' } else { 'balanced' }
[ordered]@{
    schema_version = '1.0.0'
    skill_id = 'resource-flow-economy'
    status = 'success'
    results = [ordered]@{
        model_version = [string]$flowModel.version
        time_basis = if ($flowModel.time_basis) { [string]$flowModel.time_basis } else { 'discrete_tick' }
        balance_equation = 'Q_R(t+1) = Q_R(t) + sources_R - sinks_R'
        stability_status = $overall
        resources = $resourceResults
        surplus_resources = @($surplus)
        deficit_resources = @($deficit)
        balanced_resources = @($balanced)
        bottlenecks = @($deficit)
    }
    metrics = @(
        [ordered]@{ name = 'resource_count'; value = $balances.Count; status = 'derived' }
        [ordered]@{ name = 'flow_count'; value = @($flowModel.flows).Count; status = 'derived' }
        [ordered]@{ name = 'surplus_resource_count'; value = $surplus.Count; status = 'derived' }
        [ordered]@{ name = 'deficit_resource_count'; value = $deficit.Count; status = 'derived' }
    )
    evidence = @(
        [ordered]@{ type = 'calculation'; id = 'discrete-resource-balance'; status = 'derived'; source = 'hidden_state.resource_flow' }
        $flowEvidence
    )
    errors = @()
} | ConvertTo-Json -Depth 15 -Compress
