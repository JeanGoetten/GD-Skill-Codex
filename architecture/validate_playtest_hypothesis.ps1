param([Parameter(Mandatory = $true)][string]$Path)
$ErrorActionPreference = 'Stop'
& node (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'validate_playtest_hypothesis.js') $Path
if ($LASTEXITCODE -ne 0) { throw "Hipótese de playtest inválida: $Path" }
