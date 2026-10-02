$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$examples = Get-ChildItem -LiteralPath (Join-Path $root 'examples') -Filter '*.example.json'
$failures = [System.Collections.Generic.List[string]]::new()
$executorAliases = @{
    'competitive-negative-feedback' = 'competitive_feedback'
    'macroeconomic-resource-conversion' = 'macroeconomic_conversion'
    'procedural-level-constraint-solving' = 'csp_system'
    'concurrent-gameplay-processes' = 'petri_net'
    'frame-based-combat-timing' = 'frame_timing'
    'procedural-expressive-range-analysis' = 'era'
    'discrete-state-machine-verification' = 'state_system'
    'resource-flow-economy' = 'resource_flow'
    'exponential-progression-and-prestige' = 'progression_analysis'
    'committed-risk-reward-actions' = 'risk_reward_actions'
    'epistemic-holarchic-progression' = 'epistemic_progression'
    'cognitive-schema-disruption' = 'cognitive_schema_disruption'
    'spatial-topology-and-learning-pacing' = 'spatial_pacing'
    'emergent-agency-composition' = 'emergent_agency_composition'
    'nested-gameplay-loop-architecture' = 'nested_gameplay_loop_architecture'
}
foreach ($example in $examples) {
    $world = Get-Content -Encoding UTF8 $example.FullName -Raw | ConvertFrom-Json
    if ($null -eq $world.hidden_state) { continue }
    $candidates = Get-ChildItem -LiteralPath (Join-Path $root 'executors') -Filter '*.ps1'
    $matched = $false
    foreach ($executor in $candidates) {
        $id = [IO.Path]::GetFileNameWithoutExtension($executor.Name)
        $property = if ($executorAliases.ContainsKey($id)) { $executorAliases[$id] } else { ($id -replace '-', '_') }
        if ($world.hidden_state.PSObject.Properties.Name -contains $property) {
            $matched = $true
            $result = (& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $executor.FullName -WorldModelPath $example.FullName) | ConvertFrom-Json
            if ($result.status -notin @('success','partial','blocked')) { $failures.Add("$($example.Name): status inválido $($result.status)") }
        }
    }
    if (-not $matched) { $failures.Add("$($example.Name): nenhum executor correspondente") }
}

# Semantic boundary cases are intentionally generated in-process so the suite is deterministic.
$fixtureRoot = Join-Path $root 'regression-fixtures'
New-Item -ItemType Directory -Force -Path $fixtureRoot | Out-Null
$semanticValidator = Join-Path $root 'validate_semantic.ps1'
$base = [ordered]@{
    version = '1.0.0'; entities = @(); resources = @(); spatial = @{}; temporal = @{}
    rules = @(); knowledge = @{}; progression = @{}; economy = @{}; actors = @()
    actions = @(); goals = @(); hidden_state = @{}
}
function Run-SemanticCase([string]$name, $world, [bool]$shouldPass, [string]$rawJson = '') {
    $path = Join-Path $fixtureRoot "$name.json"
    if ($rawJson) { Set-Content -LiteralPath $path -Value $rawJson -Encoding UTF8 }
    else { $world | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $path -Encoding UTF8 }
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $semanticValidator -WorldModelPath $path *> $null
    $passed = $LASTEXITCODE -eq 0
    $ErrorActionPreference = $previousPreference
    if ($passed -ne $shouldPass) { $failures.Add("semantic/${name}: resultado inesperado (esperado=$shouldPass, obtido=$passed)") }
    Remove-Item -LiteralPath $path -Force
}
try {
    $missing = [ordered]@{} + $base; $missing.Remove('entities')
    Run-SemanticCase 'absence' $missing $false
    $duplicate = [ordered]@{} + $base; $duplicate.entities = @(@{ id = 'hero' }, @{ id = 'hero' })
    Run-SemanticCase 'duplicate-id' $duplicate $false
    $invalidRef = [ordered]@{} + $base; $invalidRef.spatial = @{ nodes = @(@{ id = 'a' }); edges = @(@{ from = 'a'; to = 'missing' }) }
    Run-SemanticCase 'invalid-ref' $invalidRef $false
    $zero = [ordered]@{} + $base; $zero.resources = @(@{ id = 'fuel'; unit = 'unit'; quantity = 0; capacity = 0 })
    Run-SemanticCase 'zero' $zero $true
    $negative = [ordered]@{} + $base; $negative.resources = @(@{ id = 'fuel'; quantity = -1 })
    Run-SemanticCase 'negative' $negative $false
    Run-SemanticCase 'overflow' $base $false '{"version":"1.0.0","entities":[],"resources":[{"id":"x","quantity":1e400}],"spatial":{},"temporal":{},"rules":[],"knowledge":{},"progression":{},"economy":{},"actors":[],"actions":[],"goals":[],"hidden_state":{}}'
    $cycle = [ordered]@{} + $base; $cycle.knowledge = @{ facts = @(@{ id = 'a'; content = 'a'; epistemic_status = 'assumed' }, @{ id = 'b'; content = 'b'; epistemic_status = 'assumed' }); dependencies = @(@{ from = 'a'; to = 'b' }, @{ from = 'b'; to = 'a' }) }
    Run-SemanticCase 'cycle' $cycle $false
    $deadlock = [ordered]@{} + $base; $deadlock.hidden_state = @{ petri_net = @{ places = @(@{ id = 'p'; tokens = 0 }); transitions = @(@{ id = 't'; inputs = @(@{ place = 'p'; weight = 1 }); outputs = @() }) } }
    Run-SemanticCase 'deadlock' $deadlock $false
    $partial = [ordered]@{} + $base; $partial.hidden_state = @{ result = @{ status = 'partial'; missing = @('external_input') } }
    Run-SemanticCase 'partial' $partial $true
    $badHandoff = Join-Path $fixtureRoot 'handoffs.json'; $badAdapter = Join-Path $fixtureRoot 'adapters.json'
    '{"version":"1.0.0","handoffs":[{"source":"concurrent-gameplay-processes","target":"resource-flow-economy","input":["not_declared"]}]}' | Set-Content $badHandoff -Encoding UTF8
    '{"version":"1.0.0","adapters":[{"source":"concurrent-gameplay-processes","target":"resource-flow-economy","maps":{},"derived":{},"external_required":[]}]}' | Set-Content $badAdapter -Encoding UTF8
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $semanticValidator -WorldModelPath (Join-Path $root 'examples\state-system.example.json') -HandoffsPath $badHandoff -AdapterPath $badAdapter *> $null
    $ErrorActionPreference = $previousPreference
    if ($LASTEXITCODE -eq 0) { $failures.Add('semantic/adapter-incomplete: deveria falhar') }
    $reportValidator = Join-Path $root 'validate_report.ps1'
    $validReport = Join-Path $fixtureRoot 'valid-report.json'
    @{
        input_hash = 'hash'; claims = @(@{
            claim_id = 'claim-a'; skill_id = 'skill-a'; status = 'INSUFFICIENT_EVIDENCE'
            confidence = 'low'; provenance = @{ input_hash = 'hash' }
        }); recommendations = @(@{
            claim_id = 'claim-a'; priority = 'blocked'; confidence = 'low'
            evidence = @('INSUFFICIENT_EVIDENCE'); recommendation = 'collect evidence'
        })
    } | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $validReport -Encoding UTF8
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $reportValidator -ReportPath $validReport *> $null
    $validReportExit = $LASTEXITCODE
    $ErrorActionPreference = $previousPreference
    if ($validReportExit -ne 0) { $failures.Add('report/valid: deveria passar') }
    $invalidReport = Join-Path $fixtureRoot 'invalid-report.json'
    @{
        input_hash = 'hash'; claims = @(@{
            claim_id = 'claim-a'; skill_id = 'skill-a'; status = 'INSUFFICIENT_EVIDENCE'
            confidence = 'low'; provenance = @{ input_hash = 'other' }
        }); recommendations = @(@{
            claim_id = 'claim-a'; priority = 'conditional'; confidence = 'medium'
            evidence = @(); recommendation = 'act'
        })
    } | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $invalidReport -Encoding UTF8
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $reportValidator -ReportPath $invalidReport *> $null
    $invalidReportExit = $LASTEXITCODE
    $ErrorActionPreference = $previousPreference
    if ($invalidReportExit -eq 0) { $failures.Add('report/invalid: deveria falhar') }
    $playtestValidator = Join-Path $root 'validate_playtest_hypothesis.ps1'
    $invalidPlaytest = Join-Path $fixtureRoot 'invalid-playtest.json'
    @{
        id = 'invalid'; hypothesis = 'x'; population = 'p'; metric = 'm'; protocol = 'run'
        sample_size = 0; success_criterion = 'criterion'
    } | ConvertTo-Json | Set-Content -LiteralPath $invalidPlaytest -Encoding UTF8
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $playtestValidator -Path $invalidPlaytest *> $null
    $invalidPlaytestExit = $LASTEXITCODE
    $ErrorActionPreference = $previousPreference
    if ($invalidPlaytestExit -eq 0) { $failures.Add('playtest/invalid: deveria falhar') }
    $observationValidator = Join-Path $root 'validate_playtest_observation.js'
    $invalidObservation = Join-Path $fixtureRoot 'invalid-observation.json'
    @{
        id = 'bad-observation'; hypothesis_id = 'spatial-learning-h1'; metric = 'wrong metric'
        value = 1; sample_size = 0; collected_at = '2026-09-14T19:30:00Z'; status = 'observed'
    } | ConvertTo-Json | Set-Content -LiteralPath $invalidObservation -Encoding UTF8
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & node $observationValidator $invalidObservation *> $null
    $invalidObservationExit = $LASTEXITCODE
    $ErrorActionPreference = $previousPreference
    if ($invalidObservationExit -eq 0) { $failures.Add('playtest/observation-schema: deveria falhar') }
    $evidenceValidator = Join-Path $root 'validate_evidence_store.js'
    $invalidEvidence = Join-Path $fixtureRoot 'invalid-evidence.jsonl'
    '{"claim":"bad","status":"derived","assumptions":[],"evidence":[],"confidence":"unknown","limitations":[]}' | Set-Content -LiteralPath $invalidEvidence -Encoding UTF8
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & node $evidenceValidator $invalidEvidence *> $null
    $invalidEvidenceExit = $LASTEXITCODE
    $ErrorActionPreference = $previousPreference
    if ($invalidEvidenceExit -eq 0) { $failures.Add('evidence/invalid: deveria falhar') }
}
finally { Remove-Item -LiteralPath $fixtureRoot -Recurse -Force -ErrorAction SilentlyContinue }

# Handoff regression: adapters must be injected into the next skill's execution context.
$handoffReport = Join-Path $env:TEMP ("gd-codex-handoff-" + [guid]::NewGuid().ToString() + ".json")
try {
    $executeSkills = Join-Path $root 'execute_skills.ps1'
    $petriExample = Join-Path $root 'examples\petri-net.example.json'
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $executeSkills -Request 'analisar concorrência e fluxo de recursos' -WorldModelPath $petriExample -OutputPath $handoffReport *> $null
    $handoffExit = $LASTEXITCODE
    $ErrorActionPreference = $previousPreference
    if ($handoffExit -ne 0) {
        $failures.Add('handoff/execution: dispatcher deveria concluir sem erro')
    } else {
        $handoffResult = Get-Content -Encoding UTF8 -LiteralPath $handoffReport -Raw | ConvertFrom-Json
        $targetOutput = @($handoffResult.outputs | Where-Object { $_.skill_id -eq 'resource-flow-economy' }) | Select-Object -First 1
        if ($null -eq $targetOutput -or $null -eq $targetOutput.input_context -or $targetOutput.input_context.adapter_id -ne 'concurrent-gameplay-processes->resource-flow-economy') {
            $failures.Add('handoff/execution-context: target skill não recebeu o adapter no input_context')
        }
    }
} finally {
    Remove-Item -LiteralPath $handoffReport -Force -ErrorAction SilentlyContinue
}

if ($failures.Count -gt 0) { $failures | ForEach-Object { Write-Error $_ }; exit 1 }
Write-Output "OK: $($examples.Count) fixtures executadas sem status inválido."
