param(
    [Parameter(Mandatory = $true)]
    [string]$Request,
    [string]$WorldModelPath,
    [string]$OutputPath,
    [string]$EvidenceStorePath,
    [int]$Seed = 0
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($Request)) { throw 'Request não pode ser vazio.' }

$worldModel = $null
if ($WorldModelPath) {
    if (-not (Test-Path -LiteralPath $WorldModelPath)) { throw "World model não encontrado: $WorldModelPath" }
    $worldModel = Get-Content -LiteralPath $WorldModelPath -Raw | ConvertFrom-Json
}

$routingJson = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'route_request.ps1') -Request $Request
if ($LASTEXITCODE -ne 0) { throw 'Roteamento falhou.' }
$routing = $routingJson | ConvertFrom-Json
$timestamp = (Get-Date).ToUniversalTime().ToString('o')
$worldVersion = if ($worldModel -and $worldModel.version) { $worldModel.version } else { 'unknown' }
$hashInput = $Request
if ($WorldModelPath) { $hashInput += '|' + (Get-Content -LiteralPath $WorldModelPath -Raw) }
$hashBytes = [Text.Encoding]::UTF8.GetBytes($hashInput)
$inputHash = ([Security.Cryptography.SHA256]::Create().ComputeHash($hashBytes) | ForEach-Object { $_.ToString('x2') }) -join ''
$confidence = if (-not $WorldModelPath) {
    'low'
} elseif ($routing.evidence.Count -gt 1 -and $routing.primary.score -ge 6) {
    'high'
} else {
    'medium'
}
$report = [ordered]@{
    schema_version = '1.0.0'
    request = $Request
    world_model_version = $worldVersion
    routing = $routing
    execution_order = @($routing.execution_order)
    evidence_sufficiency = [ordered]@{
        status = 'INSUFFICIENT_EVIDENCE'
        reason = 'O reference runner planeja a execução, mas não executa as skills nem uma simulação.'
        required_next_step = 'Fornecer um executor de skill ou evidência de simulação/playtest.'
    }
    claims = @(
        [ordered]@{
            claim = 'O conjunto roteado é um plano de análise determinístico para o pedido.'
            status = 'derived'
            source = 'architecture/route_request.ps1'
            evidence = @([ordered]@{ type = 'calculation'; id = 'routing-plan' })
            assumptions = @('Os sinais cadastrados no registry são adequados ao domínio do pedido.')
            confidence = $confidence
            limitations = @('O runner não prova a validade do sistema de jogo nem executa skills.')
            input_hash = $inputHash
            world_model_version = $worldVersion
            skill_version = '1.0.0'
            seed = $Seed
            created_at = $timestamp
        }
    )
}
$json = $report | ConvertTo-Json -Depth 10
if ($OutputPath) {
    $json | Set-Content -LiteralPath $OutputPath -Encoding utf8
} else {
    $json
}
if ($EvidenceStorePath) {
    $storeDirectory = Split-Path -Parent $EvidenceStorePath
    if ($storeDirectory -and -not (Test-Path -LiteralPath $storeDirectory)) {
        New-Item -ItemType Directory -Path $storeDirectory | Out-Null
    }
    $report.claims | ForEach-Object {
        ($_ | ConvertTo-Json -Depth 10 -Compress) | Add-Content -LiteralPath $EvidenceStorePath -Encoding utf8
    }
}
