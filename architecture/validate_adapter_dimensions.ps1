$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$contracts = Get-Content -Encoding UTF8 (Join-Path $root 'handoff-adapters.json') -Raw | ConvertFrom-Json
$errors = [System.Collections.Generic.List[string]]::new()
$knownUnits = @('resource', 'resource/second', 'dimensionless', 'frames')
foreach ($adapter in $contracts.adapters) {
    foreach ($required in @('version','input_schema','output_schema','maps','derived','external_required','units')) {
        if (-not $adapter.PSObject.Properties.Name.Contains($required)) { $errors.Add("$($adapter.source)->$($adapter.target): campo obrigatório ausente: $required") }
    }
    foreach ($unit in $adapter.units.PSObject.Properties) {
        if ([string]$unit.Value -notin $knownUnits) { $errors.Add("$($adapter.source)->$($adapter.target): unidade não registrada: $($unit.Name)=$($unit.Value)") }
    }
    foreach ($field in @($adapter.maps.PSObject.Properties.Name) + @($adapter.derived.PSObject.Properties.Name)) {
        if ([string]$field -notin @($adapter.units.PSObject.Properties.Name) -and [string]$field -in @('transition_rates','source_rates','sink_rates','stocks','resource_list')) {
            $errors.Add("$($adapter.source)->$($adapter.target): campo sem unidade declarada: $field")
        }
    }
}
if ($errors.Count -gt 0) { $errors | ForEach-Object { Write-Error $_ }; exit 1 }
Write-Output "OK: $($contracts.adapters.Count) adapters possuem versão, schemas e unidades válidos."
