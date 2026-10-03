param(
    [Parameter(Mandatory = $true)][string]$ExecutorPath,
    [Parameter(Mandatory = $true)][string]$WorldModelPath,
    [switch]$SkipValidation
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not (Test-Path -LiteralPath $ExecutorPath -PathType Leaf)) { throw "Executor não encontrado: $ExecutorPath" }
if (-not (Test-Path -LiteralPath $WorldModelPath -PathType Leaf)) { throw "World model não encontrado: $WorldModelPath" }

$raw = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $ExecutorPath -WorldModelPath $WorldModelPath
if ($LASTEXITCODE -ne 0) { throw "Executor falhou: $ExecutorPath" }
$output = $raw | ConvertFrom-Json

$defaults = [ordered]@{
    schema_version = '1.0.0'
    claims = @()
    anomalies = @()
    assumptions = @('The result is conditioned on the supplied world model.')
    limitations = @('Formal or derived output does not replace empirical validation when a property depends on players.')
    handoffs = @()
    metrics = @()
    evidence = @()
    errors = @()
}
foreach ($entry in $defaults.GetEnumerator()) {
    if (-not ($output.PSObject.Properties.Name -contains $entry.Key)) {
        $output | Add-Member -NotePropertyName $entry.Key -NotePropertyValue $entry.Value
    }
}

$json = $output | ConvertTo-Json -Depth 40
if (-not $SkipValidation) {
    $tempPath = Join-Path $env:TEMP ("gd-codex-skill-output-" + [guid]::NewGuid().ToString() + '.json')
    try {
        $json | Set-Content -LiteralPath $tempPath -Encoding utf8
        & node (Join-Path $root 'validate_skill_output.js') $tempPath *> $null
        if ($LASTEXITCODE -ne 0) { throw "SkillOutput inválido produzido por $ExecutorPath" }
    } finally {
        Remove-Item -LiteralPath $tempPath -Force -ErrorAction SilentlyContinue
    }
}
$json
