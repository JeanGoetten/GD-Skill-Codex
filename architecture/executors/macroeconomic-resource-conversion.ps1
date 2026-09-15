param(
    [Parameter(Mandatory = $true)]
    [string]$WorldModelPath
)
$ErrorActionPreference = 'Stop'
$world = Get-Content -LiteralPath $WorldModelPath -Raw | ConvertFrom-Json
$model = $world.hidden_state.macroeconomic_conversion
if ($null -eq $model) {
    [ordered]@{
        skill_id = 'macroeconomic-resource-conversion'
        status = 'blocked'
        results = [ordered]@{ execution = 'not_available'; reason = 'hidden_state.macroeconomic_conversion ausente.' }
        metrics = @()
        evidence = @()
        errors = @('INSUFFICIENT_EVIDENCE: forneça resources, products e conversions.')
    } | ConvertTo-Json -Depth 10 -Compress
    exit 0
}
$resourceIds = @($model.resources | ForEach-Object { [string]$_.id })
$productIds = @($model.products | ForEach-Object { [string]$_.id })
$errors = [System.Collections.Generic.List[string]]::new()
$productResults = [ordered]@{}
foreach ($conversion in @($model.conversions)) {
    $product = [string]$conversion.product
    if ($productIds -notcontains $product) { $errors.Add("produto inexistente: $product"); continue }
    $efficiency = if ($null -ne $conversion.efficiency) { [double]$conversion.efficiency } else { 1.0 }
    if ($efficiency -le 0 -or $efficiency -gt 1) { $errors.Add("efficiency inválida: $($conversion.id)"); continue }
    $planned = [double]$conversion.planned_output
    $required = [ordered]@{}
    foreach ($inputProperty in $conversion.inputs.PSObject.Properties) {
        $inputId = [string]$inputProperty.Name
        if ($resourceIds -notcontains $inputId) { $errors.Add("recurso inexistente: $inputId"); continue }
        $required[$inputId] = [double]$inputProperty.Value * $planned / $efficiency
    }
    $productResults[$product] = [ordered]@{
        conversion_id = [string]$conversion.id
        planned_output = $planned
        effective_output = $planned * $efficiency
        efficiency = $efficiency
        required_inputs = $required
    }
}
if ($errors.Count -gt 0) {
    [ordered]@{ skill_id = 'macroeconomic-resource-conversion'; status = 'failed'; results = [ordered]@{ execution = 'validation_failed' }; metrics = @(); evidence = @(); errors = @($errors) } | ConvertTo-Json -Depth 12 -Compress
    exit 0
}
$money = $model.money
$source = if ($null -ne $money.source) { [double]$money.source } else { 0 }
$drain = if ($null -ne $money.drain) { [double]$money.drain } else { 0 }
$netMoney = $source - $drain
$moneyStatus = if ($netMoney -gt 0) { 'net_injection' } elseif ($netMoney -lt 0) { 'net_drain' } else { 'balanced' }
$priceProjection = $null
if ($null -ne $money.supply -and $money.supply -gt 0 -and $null -ne $money.demand -and $null -ne $money.price) {
    $imbalance = ([double]$money.demand - [double]$money.supply) / [double]$money.supply
    $priceProjection = [double]$money.price * [Math]::Exp($imbalance)
}
$effectiveOutputTotal = 0.0
foreach ($productResult in $productResults.Values) { $effectiveOutputTotal += [double]$productResult.effective_output }
[ordered]@{
    skill_id = 'macroeconomic-resource-conversion'
    status = 'success'
    results = [ordered]@{
        time_basis = if ($model.time_basis) { [string]$model.time_basis } else { 'discrete_period' }
        products = $productResults
        money_balance = [ordered]@{ source = $source; drain = $drain; net = $netMoney; status = $moneyStatus }
        price_projection = $priceProjection
        limitations = @(
            'Input-output balance is conditional on declared coefficients and efficiency.',
            'Money balance does not prove inflation or deflation without supply, demand, velocity and time-series evidence.',
            'Price projection uses a bounded exponential approximation and is not a market forecast.'
        )
    }
    metrics = @(
        [ordered]@{ name = 'conversion_count'; value = @($model.conversions).Count; status = 'derived' },
        [ordered]@{ name = 'net_money_flow'; value = $netMoney; status = 'derived' },
        [ordered]@{ name = 'effective_output_total'; value = $effectiveOutputTotal; status = 'derived' }
    )
    evidence = @([ordered]@{ type = 'calculation'; id = 'macro-conversion-balance'; status = 'derived' })
    errors = @()
} | ConvertTo-Json -Depth 15 -Compress
