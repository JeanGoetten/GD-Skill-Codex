param(
    [Parameter(Mandatory = $true)][string]$SourceSkill,
    [Parameter(Mandatory = $true)][string]$TargetSkill,
    [Parameter(Mandatory = $true)][string]$SourceOutputPath,
    [string]$OutputPath
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$contracts = Get-Content -Encoding UTF8 (Join-Path $root 'handoff-adapters.json') -Raw | ConvertFrom-Json
$adapter = $contracts.adapters | Where-Object { $_.source -eq $SourceSkill -and $_.target -eq $TargetSkill } | Select-Object -First 1
if ($null -eq $adapter) { throw "Adapter não encontrado: $SourceSkill -> $TargetSkill" }
$source = Get-Content -Encoding UTF8 -LiteralPath $SourceOutputPath -Raw | ConvertFrom-Json
$output = [ordered]@{ adapter_id = "$SourceSkill->$TargetSkill"; source = $SourceSkill; target = $TargetSkill; schema_version = $contracts.version; contract_version = $adapter.version; input_schema = $adapter.input_schema; output_schema = $adapter.output_schema; units = $adapter.units; fields = [ordered]@{}; external_required = @($adapter.external_required); warnings = @() }
foreach ($map in $adapter.maps.PSObject.Properties) {
    $sourceProperty = $map.Value -split '\.' | Select-Object -First 1
    if ($null -ne $source.results.PSObject.Properties[$sourceProperty]) {
        $output.fields[$map.Name] = $source.results.$sourceProperty
    } else {
        $output.warnings += "campo de origem ausente para $($map.Name): $($map.Value)"
    }
}
foreach ($derived in $adapter.derived.PSObject.Properties) {
    $output.fields[$derived.Name] = [ordered]@{ expression = $derived.Value; status = 'derived_pending' }
}
$json = $output | ConvertTo-Json -Depth 20
if ($OutputPath) { $json | Set-Content -LiteralPath $OutputPath -Encoding utf8 } else { $json }
