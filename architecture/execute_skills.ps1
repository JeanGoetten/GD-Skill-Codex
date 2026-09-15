param(
    [Parameter(Mandatory = $true)]
    [string]$Request,
    [Parameter(Mandatory = $true)]
    [string]$WorldModelPath,
    [string]$OutputPath,
    [string]$EvidenceStorePath,
    [int]$Seed = 0
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not (Test-Path -LiteralPath $WorldModelPath)) { throw "World model não encontrado: $WorldModelPath" }
$worldModel = Get-Content -LiteralPath $WorldModelPath -Raw | ConvertFrom-Json
foreach ($field in @('entities','resources','spatial','temporal','rules','knowledge','progression','economy','actors','actions','goals','hidden_state')) {
    if (-not $worldModel.PSObject.Properties.Name.Contains($field)) { throw "World model sem campo obrigatório: $field" }
}

$routing = (& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'route_request.ps1') -Request $Request) | ConvertFrom-Json
if ($LASTEXITCODE -ne 0) { throw 'Roteamento falhou.' }
$registry = Get-Content (Join-Path $root 'skill-registry.json') -Raw | ConvertFrom-Json
$registryIds = @($registry.skills | ForEach-Object { $_.id })
$timestamp = (Get-Date).ToUniversalTime().ToString('o')
$worldJson = Get-Content -LiteralPath $WorldModelPath -Raw
$hashBytes = [Text.Encoding]::UTF8.GetBytes($Request + '|' + $worldJson)
$inputHash = ([Security.Cryptography.SHA256]::Create().ComputeHash($hashBytes) | ForEach-Object { $_.ToString('x2') }) -join ''

$outputs = foreach ($skillId in @($routing.execution_order)) {
    if ($registryIds -notcontains $skillId) { throw "Skill roteada não está no registry: $skillId" }
    $executorPath = Join-Path (Join-Path $root 'executors') ($skillId + '.ps1')
    if (Test-Path -LiteralPath $executorPath) {
        $executorJson = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $executorPath -WorldModelPath $WorldModelPath
        if ($LASTEXITCODE -ne 0) { throw "Executor falhou: $skillId" }
        $executorJson | ConvertFrom-Json
    } else {
        [ordered]@{
        schema_version = '1.0.0'
        skill_id = $skillId
        status = 'blocked'
        world_model = [ordered]@{ version = if ($worldModel.version) { $worldModel.version } else { 'unknown' }; input_hash = $inputHash }
        results = [ordered]@{
            execution = 'not_available'
            reason = 'SKILL.md é uma especificação declarativa; não existe executor implementado para esta skill.'
        }
        metrics = @()
        evidence = @(
            [ordered]@{
                type = 'input'
                id = 'world-model'
                status = 'available'
            }
        )
        handoffs = @()
        errors = @('INSUFFICIENT_EVIDENCE: execução sem implementação da skill ou simulação.')
        }
    }
}

$adapterReports = @()
$adapterContracts = Get-Content (Join-Path $root 'handoff-adapters.json') -Raw | ConvertFrom-Json
for ($index = 0; $index -lt (@($routing.execution_order).Count - 1); $index++) {
    $sourceSkill = [string]$routing.execution_order[$index]
    $targetSkill = [string]$routing.execution_order[$index + 1]
    $adapter = $adapterContracts.adapters | Where-Object { $_.source -eq $sourceSkill -and $_.target -eq $targetSkill } | Select-Object -First 1
    if ($null -eq $adapter) { continue }
    $sourceOutput = @($outputs | Where-Object { $_.skill_id -eq $sourceSkill }) | Select-Object -First 1
    if ($null -eq $sourceOutput) { continue }
    $sourcePath = Join-Path $env:TEMP ("gd-codex-source-" + [guid]::NewGuid().ToString() + ".json")
    $adaptedPath = Join-Path $env:TEMP ("gd-codex-adapted-" + [guid]::NewGuid().ToString() + ".json")
    try {
        ($sourceOutput | ConvertTo-Json -Depth 20) | Set-Content -LiteralPath $sourcePath -Encoding utf8
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'execute_handoff_adapter.ps1') -SourceSkill $sourceSkill -TargetSkill $targetSkill -SourceOutputPath $sourcePath -OutputPath $adaptedPath
        if ($LASTEXITCODE -ne 0) { throw "Adapter falhou: $sourceSkill -> $targetSkill" }
        $adapterReports += Get-Content -LiteralPath $adaptedPath -Raw | ConvertFrom-Json
    } finally {
        Remove-Item -LiteralPath $sourcePath,$adaptedPath -Force -ErrorAction SilentlyContinue
    }
}

$claims = @()
foreach ($output in $outputs) {
    $isExecuted = $output.status -in @('success','partial')
    $confidence = if (-not $isExecuted) { 'low' } elseif ($output.status -eq 'partial') { 'low' } elseif (@($output.evidence | Where-Object { $_.type -in @('simulation','playtest','observation') }).Count -gt 0) { 'high' } else { 'medium' }
    $sourceKind = if (-not $isExecuted) { 'INSUFFICIENT_EVIDENCE' } else { 'derived_from_declared_model' }
    $claims += [ordered]@{
        claim_id = "claim-$($output.skill_id)"
        skill_id = $output.skill_id
        text = if ($isExecuted) { "A skill $($output.skill_id) produziu um resultado derivado a partir do world model declarado." } else { "A skill $($output.skill_id) foi selecionada, mas não executada." }
        status = if ($isExecuted) { 'derived' } else { 'INSUFFICIENT_EVIDENCE' }
        confidence = $confidence
        dependencies = @($adapterReports | Where-Object { $_.target -eq $output.skill_id } | ForEach-Object { $_.adapter_id })
        conflicts = @($output.conflicts | Where-Object { $null -ne $_ -and $_ -ne '' })
        provenance = [ordered]@{
            input_hash = $inputHash
            world_model_version = if ($worldModel.version) { $worldModel.version } else { 'unknown' }
            skill_version = '1.0.0'
            source_kind = $sourceKind
            dependencies = @($adapterReports | Where-Object { $_.target -eq $output.skill_id } | ForEach-Object { $_.adapter_id })
            conflicts = @($output.conflicts | Where-Object { $null -ne $_ -and $_ -ne '' })
        }
    }
}

$claims = @($claims | ForEach-Object { [pscustomobject]$_ })
$confRank = @{ low = 0; medium = 1; high = 2 }
$confLabel = @{ 0 = 'low'; 1 = 'medium'; 2 = 'high' }
$propagated = @{}
foreach ($skillId in @($routing.execution_order)) {
    $claim = @($claims | Where-Object { $_.skill_id -eq $skillId }) | Select-Object -First 1
    if ($null -eq $claim) { continue }
    $own = $confRank[[string]$claim.confidence]
    $upstreams = @($adapterReports | Where-Object { $_.target -eq $skillId })
    $upstreamRanks = @($upstreams | ForEach-Object {
        $src = [string]$_.source
        if ($propagated.ContainsKey($src)) { $propagated[$src] } else { 0 }
    })
    $p = if ($upstreamRanks.Count -gt 0) { [Math]::Min($own, ($upstreamRanks | Measure-Object -Minimum).Minimum) } else { $own }
    $propagated[$skillId] = $p
    $chain = @($upstreams | ForEach-Object {
        $src = [string]$_.source
        [ordered]@{ source = $src; target = [string]$_.target; upstream_confidence = if ($propagated.ContainsKey($src)) { $confLabel[$propagated[$src]] } else { 'unknown' } }
    })
    $claim | Add-Member -NotePropertyName propagated_confidence -NotePropertyValue $confLabel[$p] -Force
    $claim | Add-Member -NotePropertyName confidence_chain -NotePropertyValue $chain -Force
}

$report = [ordered]@{
    schema_version = '1.0.0'
    request = $Request
    seed = $Seed
    created_at = $timestamp
    world_model_version = if ($worldModel.version) { $worldModel.version } else { 'unknown' }
    input_hash = $inputHash
    routing = $routing
    handoff_adapters = @($adapterReports)
    claims = @($claims)
    recommendations = @($claims | ForEach-Object {
        $effectiveConfidence = if ($_.PSObject.Properties.Name -contains 'propagated_confidence') { [string]$_.propagated_confidence } else { [string]$_.confidence }
        $blocked = $_.status -eq 'INSUFFICIENT_EVIDENCE' -or $effectiveConfidence -eq 'low'
        [ordered]@{
            recommendation = if ($blocked) { "Coletar evidência adicional antes de alterar o sistema analisado por $($_.skill_id)." } else { "Revisar o resultado de $($_.skill_id) em um teste controlado antes de implementação." }
            rationale = if ($blocked) { 'O claim não possui evidência suficiente ou tem baixa confiança (incluindo propagação de handoffs).' } else { 'O resultado é derivado do modelo e deve ser confrontado com observação ou simulação.' }
            priority = if ($blocked) { 'blocked' } else { 'conditional' }
            confidence = $effectiveConfidence
            claim_id = $_.claim_id
            evidence = @($_.provenance.source_kind)
        }
    })
    execution_status = if (@($outputs | Where-Object { $_.status -eq 'failed' }).Count -gt 0) { 'failed' } elseif (@($outputs | Where-Object { $_.status -eq 'blocked' }).Count -gt 0) { 'blocked' } elseif (@($outputs | Where-Object { $_.status -eq 'partial' }).Count -gt 0) { 'partial' } else { 'completed' }
    outputs = @($outputs)
    evidence_sufficiency = [ordered]@{
        status = if (@($outputs | Where-Object { $_.status -eq 'success' }).Count -gt 0) { 'PARTIAL' } else { 'INSUFFICIENT_EVIDENCE' }
        reason = 'Apenas skills com executor versionado produziram resultados; as demais permanecem bloqueadas.'
        required_next_step = 'Adicionar executors versionados para as skills restantes e fornecer evidência de simulação/playtest.'
    }
}
$json = $report | ConvertTo-Json -Depth 12
if ($OutputPath) {
    $json | Set-Content -LiteralPath $OutputPath -Encoding utf8
} else {
    $json
}
if ($EvidenceStorePath) {
    $directory = Split-Path -Parent $EvidenceStorePath
    if ($directory -and -not (Test-Path -LiteralPath $directory)) { New-Item -ItemType Directory -Path $directory | Out-Null }
    foreach ($output in $outputs) {
        $isExecuted = $output.status -in @('success','partial')
        $claimStatus = if ($isExecuted) { 'derived' } else { 'INSUFFICIENT_EVIDENCE' }
        $claimText = if ($isExecuted) { "A skill $($output.skill_id) produziu um resultado derivado a partir do world model declarado." } else { "A skill $($output.skill_id) foi selecionada, mas não executada." }
        $record = [ordered]@{
            claim = $claimText
            skill_id = $output.skill_id
            status = $claimStatus
            source = 'architecture/execute_skills.ps1'
            evidence = $output.evidence
            assumptions = if ($isExecuted) { @('O world model e os parâmetros declarados representam o sistema analisado.') } else { @('A especificação declarativa ainda não possui um executor.') }
            confidence = if ($isExecuted -and $output.status -eq 'success') { 'medium' } else { 'low' }
            limitations = if ($isExecuted) { @('Resultado derivado não equivale a observação empírica ou playtest.') } else { @('Nenhum resultado analítico foi produzido.') }
            input_hash = $inputHash
            world_model_version = $report.world_model_version
            skill_version = '1.0.0'
            seed = $Seed
            created_at = $timestamp
            provenance = [ordered]@{
                input_hash = $inputHash
                world_model_version = $report.world_model_version
                skill_version = '1.0.0'
                source_kind = if ($isExecuted) { 'derived_from_declared_model' } else { 'INSUFFICIENT_EVIDENCE' }
                dependencies = @($adapterReports | Where-Object { $_.target -eq $output.skill_id } | ForEach-Object { $_.adapter_id })
                conflicts = @($output.conflicts | Where-Object { $null -ne $_ -and $_ -ne '' })
            }
        }
        ($record | ConvertTo-Json -Depth 10 -Compress) | Add-Content -LiteralPath $EvidenceStorePath -Encoding utf8
    }
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'refresh_evidence_index.ps1') -EvidenceStorePath $EvidenceStorePath
}
