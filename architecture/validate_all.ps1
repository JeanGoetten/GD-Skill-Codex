$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$scripts = @(
    'generate_web_data.ps1',
    'validate_architecture.ps1',
    'validate_cross_skill.ps1',
    'validate_web_data.ps1',
    'validate_schema_interfaces.ps1',
    'validate_handoff_compatibility.ps1',
    'validate_semantic.ps1',
    'validate_adapter_dimensions.ps1'
)
foreach ($script in $scripts) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root $script)
    if ($LASTEXITCODE -ne 0) { throw "Validação falhou: $script" }
}
& node (Join-Path $root 'validate_json_schema.js')
if ($LASTEXITCODE -ne 0) { throw 'Validação JSON Schema falhou: validate_json_schema.js' }
$playtestFixture = Join-Path $root 'examples\playtest-hypothesis.example.json'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'validate_playtest_hypothesis.ps1') -Path $playtestFixture
if ($LASTEXITCODE -ne 0) { throw 'Validação de hipótese de playtest falhou.' }
$observationFixture = Join-Path $root 'examples\playtest-observation.example.json'
& node (Join-Path $root 'validate_playtest_observation.js') $observationFixture
if ($LASTEXITCODE -ne 0) { throw 'Validação de observação de playtest falhou.' }
$observationStore = Join-Path $env:TEMP 'gd-codex-playtest-evidence.jsonl'
Remove-Item -LiteralPath $observationStore,"$observationStore.index.json" -Force -ErrorAction SilentlyContinue
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'record_playtest_observation.ps1') -HypothesisPath $playtestFixture -ObservationPath $observationFixture -EvidenceStorePath $observationStore
if ($LASTEXITCODE -ne 0) { throw 'Registro de observação de playtest falhou.' }
& node (Join-Path $root 'validate_evidence_store.js') $observationStore
if ($LASTEXITCODE -ne 0) { throw 'Evidence store de playtest inválido.' }
Remove-Item -LiteralPath $observationStore,"$observationStore.index.json" -Force -ErrorAction SilentlyContinue
$simulationReport = Join-Path $env:TEMP 'gd-codex-validation-simulation.json'
 $simulationStore = Join-Path $env:TEMP 'gd-codex-validation-simulation-evidence.jsonl'
Remove-Item -LiteralPath $simulationStore,"$simulationStore.index.json" -Force -ErrorAction SilentlyContinue
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'simulation_runner.ps1') -WorldModelPath (Join-Path $root 'examples\state-system.example.json') -ExecutorId 'discrete-state-machine-verification' -Repeats 1 -Seed 0 -OutputPath $simulationReport -EvidenceStorePath $simulationStore
if ($LASTEXITCODE -ne 0) { throw 'Geração de fixture de simulação falhou.' }
& node (Join-Path $root 'validate_simulation_report.js') $simulationReport
if ($LASTEXITCODE -ne 0) { throw 'Validação de relatório de simulação falhou.' }
& node (Join-Path $root 'validate_evidence_store.js') $simulationStore
if ($LASTEXITCODE -ne 0) { throw 'Evidence store de simulação inválido.' }
Remove-Item -LiteralPath $simulationReport,$simulationStore,"$simulationStore.index.json" -Force -ErrorAction SilentlyContinue
Write-Output 'OK: validação agregada da arquitetura concluída.'
