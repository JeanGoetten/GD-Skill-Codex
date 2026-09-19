$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$registry = Get-Content -Encoding UTF8 (Join-Path $root 'skill-registry.json') -Raw | ConvertFrom-Json
$handoffs = Get-Content -Encoding UTF8 (Join-Path $root 'handoffs.json') -Raw | ConvertFrom-Json
$adapterContracts = Get-Content -Encoding UTF8 (Join-Path $root 'handoff-adapters.json') -Raw | ConvertFrom-Json
$ids = @($registry.skills | ForEach-Object { [string]$_.id })
$errors = [System.Collections.Generic.List[string]]::new()
$warnings = [System.Collections.Generic.List[string]]::new()
foreach ($handoff in $handoffs.handoffs) {
    if ($ids -notcontains [string]$handoff.source) { $errors.Add("handoff source desconhecido: $($handoff.source)") }
    if ($ids -notcontains [string]$handoff.target) { $errors.Add("handoff target desconhecido: $($handoff.target)") }
    $source = $registry.skills | Where-Object { $_.id -eq $handoff.source } | Select-Object -First 1
    $target = $registry.skills | Where-Object { $_.id -eq $handoff.target } | Select-Object -First 1
    $sourceFields = @($source.inputs) + @($source.outputs)
    $targetFields = @($target.inputs) + @($target.outputs)
    foreach ($field in @($handoff.input)) {
        if ($sourceFields -notcontains [string]$field) {
            $adapter = $adapterContracts.adapters | Where-Object { $_.source -eq $handoff.source -and $_.target -eq $handoff.target } | Select-Object -First 1
            if ($null -eq $adapter) { $errors.Add("adapter ausente para input ${field}: $($handoff.source) -> $($handoff.target)") }
            elseif ($null -eq $adapter.maps.PSObject.Properties[$field] -and $null -eq $adapter.derived.PSObject.Properties[$field] -and @($adapter.external_required) -notcontains $field) { $errors.Add("adapter sem mapeamento para input ${field}: $($handoff.source) -> $($handoff.target)") }
            else { $warnings.Add("adapter declarado para input ${field}: $($handoff.source) -> $($handoff.target)") }
        }
    }
    foreach ($field in @($handoff.expected_output)) {
        if ($targetFields -notcontains [string]$field) { $warnings.Add("output ${field} é contrato do destino e não é produzido pela origem: $($handoff.source) -> $($handoff.target)") }
    }
    if ([string]$handoff.schema_version -ne '1.0.0') { $errors.Add("schema_version incompatível no handoff $($handoff.source) -> $($handoff.target)") }
}
if ($errors.Count -gt 0) { $errors | ForEach-Object { Write-Error $_ }; exit 1 }
Write-Output "OK: $($handoffs.handoffs.Count) handoffs possuem origem, destino e versão compatíveis."
if ($warnings.Count -gt 0) {
    Write-Output "WARN: $($warnings.Count) campos exigem adapters explícitos; nenhum contrato foi silenciado."
    $warnings | ForEach-Object { Write-Output "WARN: $_" }
}
