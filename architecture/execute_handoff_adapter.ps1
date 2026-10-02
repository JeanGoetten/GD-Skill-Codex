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

function Resolve-PathValue {
    param($Object,[string]$Path)
    $current = $Object
    foreach ($segment in $Path.Split('.')) {
        if ($segment -eq '') { continue }
        if ($segment.EndsWith('[]')) {
            $name=$segment.Substring(0,$segment.Length-2)
            if ($null -eq $current.PSObject.Properties[$name]) { return $null }
            $current=@($current.$name)
            continue
        }
        if ($current -is [System.Array]) {
            $current=@($current | ForEach-Object { $_.$segment })
        } elseif ($null -ne $current.PSObject.Properties[$segment]) {
            $current=$current.$segment
        } else {
            return $null
        }
    }
    return $current
}

function Derive-Value {
    param($Object,[string]$Expression)
    if ($Expression -match '^collect\((.+)\)$') {
        return @(Resolve-PathValue $Object $Matches[1])
    }
    if ($Expression -match '^(sum|mean|min|max)\((.+)\)$') {
        $values=@(Resolve-PathValue $Object $Matches[2] | Where-Object {$null -ne $_} | ForEach-Object {[double]$_})
        if ($values.Count -eq 0) { return $null }
        switch ($Matches[1]) {
            'sum' { return ($values | Measure-Object -Sum).Sum }
            'mean' { return ($values | Measure-Object -Average).Average }
            'min' { return ($values | Measure-Object -Minimum).Minimum }
            'max' { return ($values | Measure-Object -Maximum).Maximum }
        }
    }
    return Resolve-PathValue $Object $Expression
}

$output=[ordered]@{
    adapter_id="$SourceSkill->$TargetSkill"
    source=$SourceSkill
    target=$TargetSkill
    schema_version=$contracts.version
    contract_version=$adapter.version
    input_schema=$adapter.input_schema
    output_schema=$adapter.output_schema
    units=$adapter.units
    fields=[ordered]@{}
    external_required=@($adapter.external_required)
    warnings=@()
    status='ready'
}

foreach ($map in $adapter.maps.PSObject.Properties) {
    $value=Derive-Value $source ([string]$map.Value)
    if ($null -ne $value) { $output.fields[$map.Name]=$value }
    else { $output.warnings += "campo de origem ausente: $($map.Name) <- $($map.Value)" }
}
foreach ($derived in $adapter.derived.PSObject.Properties) {
    $value=Derive-Value $source ([string]$derived.Value)
    if ($null -ne $value) { $output.fields[$derived.Name]=$value }
    else { $output.warnings += "derivação não resolvida: $($derived.Name) <- $($derived.Value)" }
}
if ($output.warnings.Count -gt 0) { $output.status='partial' }
if ($output.external_required.Count -gt 0 -and $output.status -eq 'ready') { $output.status='requires_external_evidence' }

$json=$output | ConvertTo-Json -Depth 30
if ($OutputPath) { $json | Set-Content -LiteralPath $OutputPath -Encoding utf8 } else { $json }
