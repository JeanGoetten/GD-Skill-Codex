param(
    [Parameter(Mandatory = $true)][string]$Request,
    [Parameter(Mandatory = $true)][string]$WorldModelPath,
    [int]$MaxCycles = 3,
    [int]$Seed = 0
)
$ErrorActionPreference = 'Stop'
if ($MaxCycles -lt 1) { throw 'MaxCycles deve ser >= 1.' }
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$handoffs = Get-Content -Encoding UTF8 (Join-Path $root 'handoffs.json') -Raw | ConvertFrom-Json
$report = (& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'execute_skills.ps1') -Request $Request -WorldModelPath $WorldModelPath -Seed $Seed) | ConvertFrom-Json
$history = @([ordered]@{ cycle = 1; status = $report.execution_status; output_hash = $report.input_hash; return_to = @($handoffs.handoffs | Where-Object { $_.source -eq $report.routing.primary } | ForEach-Object { $_.return_to }) })
$converged = $false
$cycle = 1
while ($cycle -lt $MaxCycles -and -not $converged) {
    $cycle++
    $next = (& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'execute_skills.ps1') -Request $Request -WorldModelPath $WorldModelPath -Seed ($Seed + $cycle - 1)) | ConvertFrom-Json
    $returnTargets = @($handoffs.handoffs | Where-Object { $_.source -eq $report.routing.primary } | ForEach-Object { $_.return_to })
    $conflicts = @($next.claims | Where-Object { @($_.conflicts).Count -gt 0 })
    $history += [ordered]@{ cycle = $cycle; status = $next.execution_status; output_hash = $next.input_hash; return_to = $returnTargets; conflicts = $conflicts.Count }
    $converged = ($next.execution_status -eq $report.execution_status -and $next.routing.primary -eq $report.routing.primary -and $conflicts.Count -eq 0)
    $report = $next
}
[ordered]@{
    schema_version = '1.0.0'
    request = $Request
    max_cycles = $MaxCycles
    cycles_run = $history.Count
    converged = $converged
    termination = if ($converged) { 'converged' } else { 'max_cycles_or_status_changed' }
    history = $history
    final_report = $report
} | ConvertTo-Json -Depth 20
