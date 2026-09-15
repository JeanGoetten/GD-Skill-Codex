param(
    [Parameter(Mandatory = $true)]
    [string]$WorldModelPath
)
$ErrorActionPreference = 'Stop'

$world = Get-Content -LiteralPath $WorldModelPath -Raw | ConvertFrom-Json
$era = $world.hidden_state.era
$hasSolvability = $null -ne $era -and $era.PSObject.Properties.Name.Contains('solvability_status') -and
    -not [string]::IsNullOrWhiteSpace([string]$era.solvability_status)
$hasSamples = $null -ne $era -and $era.PSObject.Properties.Name.Contains('generated_samples') -and
    $null -ne $era.generated_samples -and @($era.generated_samples).Count -gt 0
if (-not $hasSolvability -or -not $hasSamples) {
    [ordered]@{
        schema_version = '1.0.0'
        skill_id = 'procedural-expressive-range-analysis'
        status = 'blocked'
        results = [ordered]@{ execution = 'not_available'; reason = 'hidden_state.era requer solvability_status e generated_samples.' }
        metrics = @()
        evidence = @()
        errors = @('INSUFFICIENT_EVIDENCE: forneça hidden_state.era com solvability_status e generated_samples.')
    } | ConvertTo-Json -Depth 12 -Compress
    exit 0
}

$errors = [System.Collections.Generic.List[string]]::new()
$dimensions = @($era.bc_dimensions)
if ($dimensions.Count -eq 0) { $errors.Add('era.bc_dimensions requer ao menos uma dimensão BC.') }
$dimensionMap = [ordered]@{}
foreach ($dimension in $dimensions) {
    $dimensionId = [string]$dimension.id
    if ([string]::IsNullOrWhiteSpace($dimensionId)) { $errors.Add('cada dimensão BC requer id.'); continue }
    if ($dimensionMap.Contains($dimensionId)) { $errors.Add("dimensão BC duplicada: $dimensionId"); continue }
    $bins = @($dimension.bins)
    if ($bins.Count -eq 0) { $errors.Add("dimensão BC sem bins: $dimensionId"); continue }
    $binList = [System.Collections.Generic.List[object]]::new()
    $binIds = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($bin in $bins) {
        $binId = [string]$bin.id
        $min = $bin.min
        $max = $bin.max
        if ([string]::IsNullOrWhiteSpace($binId) -or -not $binIds.Add($binId)) {
            $errors.Add("bin inválido ou duplicado na dimensão $dimensionId."); continue
        }
        if ($null -eq $min -or $null -eq $max -or [double]$max -le [double]$min) {
            $errors.Add("bin $dimensionId/$binId requer max maior que min."); continue
        }
        $binList.Add([ordered]@{ id = $binId; min = [double]$min; max = [double]$max })
    }
    $dimensionMap[$dimensionId] = $binList
}
if ($errors.Count -gt 0) {
    [ordered]@{ schema_version = '1.0.0'; skill_id = 'procedural-expressive-range-analysis'; status = 'failed'
        results = [ordered]@{ execution = 'validation_failed' }; metrics = @(); evidence = @(); errors = @($errors)
    } | ConvertTo-Json -Depth 12 -Compress
    exit 0
}

$samples = @($era.generated_samples)
$occupancy = [ordered]@{}
$totalBins = 1
foreach ($dimensionId in $dimensionMap.Keys) {
    $totalBins *= $dimensionMap[$dimensionId].Count
}
$classifiedSamples = 0
foreach ($sample in $samples) {
    if ($sample.valid -eq $false) { continue }
    $parts = [System.Collections.Generic.List[string]]::new()
    $classifiable = $true
    foreach ($dimensionId in $dimensionMap.Keys) {
        $values = $sample.values
        $valueProperty = $values.PSObject.Properties[$dimensionId]
        if ($null -eq $valueProperty -or $null -eq $valueProperty.Value) { $classifiable = $false; break }
        $value = [double]$valueProperty.Value
        $dimensionBins = @($dimensionMap[$dimensionId])
        $matching = @()
        for ($binIndex = 0; $binIndex -lt $dimensionBins.Count; $binIndex++) {
            $bin = $dimensionBins[$binIndex]
            $isFinalBin = $binIndex -eq ($dimensionBins.Count - 1)
            if (($value -ge $bin.min) -and (($value -lt $bin.max) -or ($isFinalBin -and $value -eq $bin.max))) {
                $matching += $bin
            }
        }
        if ($matching.Count -ne 1) { $classifiable = $false; break }
        $parts.Add("$dimensionId=$($matching[0].id)")
    }
    if (-not $classifiable) { continue }
    $key = $parts -join '|'
    if (-not $occupancy.Contains($key)) { $occupancy[$key] = 0 }
    $occupancy[$key]++
    $classifiedSamples++
}
$occupiedBins = $occupancy.Count
$biasKey = $null
$biasCount = 0
foreach ($key in $occupancy.Keys) {
    if ($occupancy[$key] -gt $biasCount) { $biasKey = $key; $biasCount = $occupancy[$key] }
}
$biasShare = if ($classifiedSamples -gt 0) { $biasCount / $classifiedSamples } else { 0 }
[ordered]@{
    schema_version = '1.0.0'
    skill_id = 'procedural-expressive-range-analysis'
    status = 'success'
    results = [ordered]@{
        solvability_status = [string]$era.solvability_status
        bc_dimensions = @($dimensionMap.Keys)
        bin_occupancy = $occupancy
        bin_occupancy_coverage = if ($totalBins -gt 0) { $occupiedBins / $totalBins } else { 0 }
        bias_bin = $biasKey
        bias_share = $biasShare
        limitation = 'Bin occupancy coverage is not geometric or area coverage; it only measures occupied declared bins.'
    }
    metrics = @(
        [ordered]@{ name = 'sample_count'; value = $samples.Count; status = 'derived' }
        [ordered]@{ name = 'classified_sample_count'; value = $classifiedSamples; status = 'derived' }
        [ordered]@{ name = 'occupied_bin_count'; value = $occupiedBins; status = 'derived' }
        [ordered]@{ name = 'declared_bin_count'; value = $totalBins; status = 'derived' }
        [ordered]@{ name = 'bin_occupancy_coverage'; value = if ($totalBins -gt 0) { $occupiedBins / $totalBins } else { 0 }; status = 'derived' }
        [ordered]@{ name = 'distribution_bias'; value = $biasShare; status = 'derived' }
    )
    evidence = @([ordered]@{ type = 'calculation'; id = 'era-bin-occupancy'; status = 'derived'; source = 'hidden_state.era' })
    errors = @()
} | ConvertTo-Json -Depth 15 -Compress
