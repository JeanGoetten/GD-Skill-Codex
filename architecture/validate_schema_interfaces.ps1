$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$schemaRoot = Join-Path $root 'schemas'
$expected = @(
  'ids.schema.json','units.schema.json','entities.schema.json','actors.schema.json','resources.schema.json',
  'actions.schema.json','rules.schema.json','goals.schema.json','spatial.schema.json','temporal.schema.json',
  'knowledge.schema.json','hidden-state.schema.json','progression.schema.json','economy.schema.json',
  'skill-input.schema.json','skill-output.schema.json',
  'handoff-contract.schema.json','metric.schema.json','assumption.schema.json','evidence.schema.json','state-system.schema.json','csp-system.schema.json','petri-net.schema.json','frame-timing.schema.json',
  'recommendation.schema.json','test-plan.schema.json','resource-flow-economy.schema.json',
  'playtest-observation.schema.json',
  'procedural-expressive-range-analysis.schema.json','macroeconomic-conversion.schema.json','risk-reward-action.schema.json','epistemic-progression.schema.json','cognitive-schema-disruption.schema.json','competitive-feedback.schema.json','progression-analysis.schema.json','spatial-pacing.schema.json','playtest-hypothesis.schema.json','provenance.schema.json','emergent-agency-composition.schema.json','nested-gameplay-loop-architecture.schema.json'
)
$errors = [System.Collections.Generic.List[string]]::new()
foreach ($file in $expected) {
  $path = Join-Path $schemaRoot $file
  if (-not (Test-Path $path)) { $errors.Add("schema ausente: $file"); continue }
  try { $schema = Get-Content -Encoding UTF8 $path -Raw | ConvertFrom-Json } catch { $errors.Add("JSON inválido: $file"); continue }
  foreach ($field in @('$schema','$id','title','type')) {
    if (-not $schema.PSObject.Properties.Name.Contains($field)) { $errors.Add("$file sem $field") }
  }
}
try { $world = Get-Content -Encoding UTF8 (Join-Path $root 'world-model.schema.json') -Raw | ConvertFrom-Json } catch { $errors.Add('world-model.schema.json inválido') }
try { $handoffs = Get-Content -Encoding UTF8 (Join-Path $root 'handoffs.json') -Raw | ConvertFrom-Json } catch { $errors.Add('handoffs.json inválido') }
if ($world) {
  foreach ($field in @('entities','resources','actors','actions','rules','goals','spatial','temporal','knowledge','hidden_state')) {
    $value = $world.properties.$field.'$ref'
    if (-not $value) { $errors.Add("world model sem referência composável: $field") }
  }
  $hiddenStateSchema = Get-Content -Encoding UTF8 (Join-Path $schemaRoot 'hidden-state.schema.json') -Raw | ConvertFrom-Json
  if ($hiddenStateSchema) {
    $emergentRef = $hiddenStateSchema.properties.emergent_agency_composition.'$ref'
    if ($emergentRef -ne 'https://gd-skill-codex.local/schemas/emergent-agency-composition.schema.json') { $errors.Add('hidden-state sem referência emergent-agency-composition compatível') }
  }
}
if ($handoffs) {
  if ($handoffs.contract_schema -ne 'https://gd-skill-codex.local/schemas/handoff-contract.schema.json') { $errors.Add('handoffs sem contract_schema compatível') }
  foreach ($handoff in $handoffs.handoffs) {
    foreach ($field in @('source','target','relation','when','input','expected_output','return_to','iteration','schema_version','input_schema','output_schema')) {
      if (-not $handoff.PSObject.Properties.Name.Contains($field)) { $errors.Add("handoff sem $field") }
    }
    if ($handoff.input_schema -ne 'https://gd-skill-codex.local/schemas/skill-input.schema.json') { $errors.Add('handoff input_schema incompatível') }
    if ($handoff.output_schema -ne 'https://gd-skill-codex.local/schemas/skill-output.schema.json') { $errors.Add('handoff output_schema incompatível') }
  }
}
if ($errors.Count) { $errors | ForEach-Object { Write-Error $_ }; exit 1 }
Write-Output "OK: $($expected.Count) schemas composáveis/interfaces e contratos compatíveis."
