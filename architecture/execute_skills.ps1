param(
    [Parameter(Mandatory = $true)][string]$Request,
    [Parameter(Mandatory = $true)][string]$WorldModelPath,
    [string]$OutputPath,
    [string]$EvidenceStorePath,
    [string]$HandoffInputPath,
    [int]$Seed = 0
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not (Test-Path -LiteralPath $WorldModelPath)) { throw "World model não encontrado: $WorldModelPath" }

$worldModel = Get-Content -Encoding UTF8 -LiteralPath $WorldModelPath -Raw | ConvertFrom-Json
foreach ($field in @('entities','resources','spatial','temporal','rules','knowledge','progression','economy','actors','actions','goals','hidden_state')) {
    if (-not $worldModel.PSObject.Properties.Name.Contains($field)) { throw "World model sem campo obrigatório: $field" }
}

$routing = (& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'route_request.ps1') -Request $Request) | ConvertFrom-Json
if ($LASTEXITCODE -ne 0) { throw 'Roteamento falhou.' }
$registry = Get-Content -Encoding UTF8 (Join-Path $root 'skill-registry.json') -Raw | ConvertFrom-Json
$registryIds = @($registry.skills | ForEach-Object { $_.id })
$timestamp = (Get-Date).ToUniversalTime().ToString('o')
$worldJson = Get-Content -Encoding UTF8 -LiteralPath $WorldModelPath -Raw
$hashBytes = [Text.Encoding]::UTF8.GetBytes($Request + '|' + $worldJson)
$inputHash = ([Security.Cryptography.SHA256]::Create().ComputeHash($hashBytes) | ForEach-Object { $_.ToString('x2') }) -join ''
$skillAssumptions = @('O world model fornecido representa o estado relevante do sistema.')
$skillUnknowns = @('Valores não presentes no world model permanecem desconhecidos; não são inferidos.')

$initialHandoff = $null
if ($HandoffInputPath) {
    if (-not (Test-Path -LiteralPath $HandoffInputPath)) { throw "Handoff input não encontrado: $HandoffInputPath" }
    $initialHandoff = Get-Content -Encoding UTF8 -LiteralPath $HandoffInputPath -Raw | ConvertFrom-Json
}

$adapterContracts = Get-Content -Encoding UTF8 (Join-Path $root 'handoff-adapters.json') -Raw | ConvertFrom-Json
$outputs = [System.Collections.Generic.List[object]]::new()
$adapterReports = [System.Collections.Generic.List[object]]::new()
$tempWorldPaths = [System.Collections.Generic.List[string]]::new()

function New-HandoffWorld {
    param([string]$BaseWorldPath,[object]$Handoff)
    if ($null -eq $Handoff) { return $BaseWorldPath }
    $baseWorld = Get-Content -Encoding UTF8 -LiteralPath $BaseWorldPath -Raw | ConvertFrom-Json
    if (-not $baseWorld.PSObject.Properties.Name.Contains('hidden_state')) {
        $baseWorld | Add-Member -NotePropertyName hidden_state -NotePropertyValue ([pscustomobject]@{})
    }
    $context = [pscustomobject]@{
        source = $Handoff.source
        target = $Handoff.target
        adapter_id = $Handoff.adapter_id
        status = $Handoff.status
        fields = $Handoff.fields
        warnings = @($Handoff.warnings)
        external_required = @($Handoff.external_required)
    }
    $baseWorld.hidden_state | Add-Member -NotePropertyName handoff_context -NotePropertyValue $context -Force
    $path = Join-Path $env:TEMP ("gd-codex-world-" + [guid]::NewGuid().ToString() + ".json")
    ($baseWorld | ConvertTo-Json -Depth 40) | Set-Content -LiteralPath $path -Encoding utf8
    $tempWorldPaths.Add($path)
    return $path
}

function Invoke-Adapter {
    param([string]$SourceSkill,[string]$TargetSkill,[object]$SourceOutput)
    $adapter = $adapterContracts.adapters | Where-Object { $_.source -eq $SourceSkill -and $_.target -eq $TargetSkill } | Select-Object -First 1
    if ($null -eq $adapter -or $null -eq $SourceOutput) { return $null }
    $sourcePath = Join-Path $env:TEMP ("gd-codex-source-" + [guid]::NewGuid().ToString() + ".json")
    $adaptedPath = Join-Path $env:TEMP ("gd-codex-adapted-" + [guid]::NewGuid().ToString() + ".json")
    try {
        ($SourceOutput | ConvertTo-Json -Depth 30) | Set-Content -LiteralPath $sourcePath -Encoding utf8
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'execute_handoff_adapter.ps1') -SourceSkill $SourceSkill -TargetSkill $TargetSkill -SourceOutputPath $sourcePath -OutputPath $adaptedPath
        if ($LASTEXITCODE -ne 0) { throw "Adapter falhou: $SourceSkill -> $TargetSkill" }
        return (Get-Content -Encoding UTF8 -LiteralPath $adaptedPath -Raw | ConvertFrom-Json)
    } finally {
        Remove-Item -LiteralPath $sourcePath,$adaptedPath -Force -ErrorAction SilentlyContinue
    }
}

try {
    foreach ($skillIndex in 0..(@($routing.execution_order).Count - 1)) {
        $skillId = [string]$routing.execution_order[$skillIndex]
        if ($registryIds -notcontains $skillId) { throw "Skill roteada não está no registry: $skillId" }

        $handoffInput = if ($skillIndex -eq 0) { $initialHandoff } else { $null }
        if ($skillIndex -gt 0) {
            $sourceSkill = [string]$routing.execution_order[$skillIndex - 1]
            $sourceOutput = @($outputs | Where-Object { $_.skill_id -eq $sourceSkill }) | Select-Object -First 1
            $handoffInput = Invoke-Adapter -SourceSkill $sourceSkill -TargetSkill $skillId -SourceOutput $sourceOutput
            if ($null -ne $handoffInput) { $adapterReports.Add($handoffInput) }
        }

        $executionWorldPath = New-HandoffWorld -BaseWorldPath $WorldModelPath -Handoff $handoffInput
        $executorPath = Join-Path (Join-Path $root 'executors') ($skillId + '.ps1')

        if (Test-Path -LiteralPath $executorPath) {
            $executorJson = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $executorPath -WorldModelPath $executionWorldPath
            if ($LASTEXITCODE -ne 0) { throw "Executor falhou: $skillId" }
            $normalizedOutput = $executorJson | ConvertFrom-Json
            foreach ($pair in @(
                @('claims', @()), @('anomalies', @()), @('assumptions', $skillAssumptions),
                @('limitations', @('Resultado formal/derivado não substitui validação empírica.')),
                @('handoffs', @()), @('metrics', @()), @('evidence', @())
            )) {
                if (-not ($normalizedOutput.PSObject.Properties.Name -contains $pair[0])) {
                    $normalizedOutput | Add-Member -NotePropertyName $pair[0] -NotePropertyValue $pair[1]
                }
            }
            $normalizedOutput | Add-Member -NotePropertyName input_context -NotePropertyValue $handoffInput -Force
            $outputs.Add($normalizedOutput)
        } else {
            $outputs.Add([ordered]@{
                schema_version='1.0.0'; skill_id=$skillId; status='blocked'
                world_model=[ordered]@{version=if($worldModel.version){$worldModel.version}else{'unknown'};input_hash=$inputHash}
                results=[ordered]@{execution='not_available';reason='SKILL.md é uma especificação declarativa; não existe executor implementado para esta skill.'}
                metrics=@(); evidence=@([ordered]@{type='input';id='world-model';status='available'})
                handoffs=@(); claims=@(); anomalies=@(); assumptions=$skillAssumptions
                limitations=@('Skill declarativa sem executor operacional; nenhum resultado analítico foi produzido.')
                input_context=$handoffInput; errors=@('INSUFFICIENT_EVIDENCE: execução sem implementação da skill ou simulação.')
            })
        }
    }
} finally {
    foreach ($path in $tempWorldPaths) { Remove-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue }
}

$claims = [System.Collections.Generic.List[object]]::new()
foreach ($output in $outputs) {
    $executed = $output.status -in @('success','partial')
    $confidence = if (-not $executed -or $output.status -eq 'partial') { 'low' } elseif (@($output.evidence | Where-Object {$_.type -in @('simulation','playtest','observation')}).Count -gt 0) { 'high' } else { 'medium' }
    $sourceKind = if ($executed) { 'derived_from_declared_model' } else { 'INSUFFICIENT_EVIDENCE' }
    $dependencies = @($adapterReports | Where-Object {$_.target -eq $output.skill_id} | ForEach-Object {$_.adapter_id})
    $claims.Add([ordered]@{
        claim_id="claim-$($output.skill_id)"; skill_id=$output.skill_id
        text=if($executed){"A skill $($output.skill_id) produziu um resultado derivado a partir do world model declarado."}else{"A skill $($output.skill_id) foi selecionada, mas não executada."}
        status=if($executed){'derived'}else{'INSUFFICIENT_EVIDENCE'}; confidence=$confidence
        dependencies=$dependencies; conflicts=@($output.conflicts | Where-Object {$null -ne $_ -and $_ -ne ''})
        provenance=[ordered]@{input_hash=$inputHash;world_model_version=if($worldModel.version){$worldModel.version}else{'unknown'};skill_version='1.0.0';source_kind=$sourceKind;dependencies=$dependencies;conflicts=@($output.conflicts)}
    })
}

$claims = @($claims | ForEach-Object {[pscustomobject]$_})
$confRank=@{low=0;medium=1;high=2}; $confLabel=@{0='low';1='medium';2='high'}; $propagated=@{}
foreach ($skillId in @($routing.execution_order)) {
    $claim=@($claims | Where-Object {$_.skill_id -eq $skillId}) | Select-Object -First 1
    if($null -eq $claim){continue}
    $own=$confRank[[string]$claim.confidence]
    $up=@($adapterReports | Where-Object {$_.target -eq $skillId} | ForEach-Object {if($propagated.ContainsKey([string]$_.source)){$propagated[[string]$_.source]}else{0}})
    $p=if($up.Count -gt 0){[Math]::Min($own,($up|Measure-Object -Minimum).Minimum)}else{$own}
    $propagated[$skillId]=$p
    $claim | Add-Member -NotePropertyName propagated_confidence -NotePropertyValue $confLabel[$p] -Force
}

$report=[ordered]@{
    schema_version='1.1.0'; request=$Request; seed=$Seed; created_at=$timestamp
    world_model_version=if($worldModel.version){$worldModel.version}else{'unknown'}; input_hash=$inputHash
    routing=$routing; handoff_adapters=@($adapterReports); claims=@($claims)
    outputs=@($outputs)
    execution_status=if(@($outputs|Where-Object{$_.status -eq 'failed'}).Count -gt 0){'failed'}elseif(@($outputs|Where-Object{$_.status -eq 'blocked'}).Count -gt 0){'blocked'}elseif(@($outputs|Where-Object{$_.status -eq 'partial'}).Count -gt 0){'partial'}else{'completed'}
    recommendations=@($claims | ForEach-Object {
        $c=if($_.PSObject.Properties.Name -contains 'propagated_confidence'){[string]$_.propagated_confidence}else{[string]$_.confidence}
        [ordered]@{recommendation=if($_.status -eq 'INSUFFICIENT_EVIDENCE' -or $c -eq 'low'){"Coletar evidência adicional antes de alterar o sistema analisado por $($_.skill_id)."}else{"Revisar o resultado de $($_.skill_id) em um teste controlado antes de implementação."};rationale='Resultado rastreável ao modelo declarado; handoffs e confiança propagada são preservados.';priority=if($_.status -eq 'INSUFFICIENT_EVIDENCE' -or $c -eq 'low'){'blocked'}else{'conditional'};confidence=$c;claim_id=$_.claim_id}
    })
    evidence_sufficiency=[ordered]@{status=if(@($outputs|Where-Object{$_.status -eq 'success'}).Count -gt 0){'PARTIAL'}else{'INSUFFICIENT_EVIDENCE'};reason='Resultados formais não substituem evidência empírica.';required_next_step='Executar simulação ou playtest quando a propriedade exigir validação empírica.'}
}

$json=$report|ConvertTo-Json -Depth 40
if($OutputPath){$json|Set-Content -LiteralPath $OutputPath -Encoding utf8}else{$json}

if($EvidenceStorePath){
    $dir=Split-Path -Parent $EvidenceStorePath
    if($dir -and -not(Test-Path -LiteralPath $dir)){New-Item -ItemType Directory -Path $dir|Out-Null}
    foreach($output in $outputs){
        $executed=$output.status -in @('success','partial')
        $record=[ordered]@{claim=if($executed){"A skill $($output.skill_id) produziu um resultado derivado a partir do world model declarado."}else{"A skill $($output.skill_id) foi selecionada, mas não executada."};skill_id=$output.skill_id;status=if($executed){'derived'}else{'INSUFFICIENT_EVIDENCE'};source='architecture/execute_skills.ps1';evidence=$output.evidence;assumptions=$output.assumptions;confidence=if($executed -and $output.status -eq 'success'){'medium'}else{'low'};limitations=$output.limitations;input_hash=$inputHash;world_model_version=$report.world_model_version;skill_version='1.0.0';seed=$Seed;created_at=$timestamp;provenance=[ordered]@{input_hash=$inputHash;world_model_version=$report.world_model_version;skill_version='1.0.0';source_kind=if($executed){'derived_from_declared_model'}else{'INSUFFICIENT_EVIDENCE'}}}
        ($record|ConvertTo-Json -Depth 15 -Compress)|Add-Content -LiteralPath $EvidenceStorePath -Encoding utf8
    }
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'refresh_evidence_index.ps1') -EvidenceStorePath $EvidenceStorePath
}
