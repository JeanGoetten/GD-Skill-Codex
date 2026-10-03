param(
    [string]$CasesPath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'benchmarks\routing-cases.json'),
    [double]$MinimumAccuracy = 1.0
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not (Test-Path -LiteralPath $CasesPath)) { throw "Benchmark não encontrado: $CasesPath" }
$benchmark = Get-Content -Encoding UTF8 -LiteralPath $CasesPath -Raw | ConvertFrom-Json
$results = [System.Collections.Generic.List[object]]::new()
foreach ($case in @($benchmark.cases)) {
    $routing = (& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'route_request.ps1') -Request ([string]$case.request)) | ConvertFrom-Json
    $actual = [string]$routing.primary
    $results.Add([ordered]@{
        id = [string]$case.id
        expected = [string]$case.expected_primary
        actual = $actual
        correct = $actual -eq [string]$case.expected_primary
    })
}
$correct = @($results | Where-Object { $_.correct }).Count
$accuracy = if ($results.Count -gt 0) { $correct / [double]$results.Count } else { 0 }
$summary = [ordered]@{ cases = $results.Count; correct = $correct; accuracy = $accuracy; results = @($results) }
$summary | ConvertTo-Json -Depth 8
if ($accuracy -lt $MinimumAccuracy) { exit 1 }
