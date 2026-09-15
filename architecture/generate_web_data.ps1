$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path $root -Parent
$registry = Get-Content (Join-Path $root 'skill-registry.json') -Raw | ConvertFrom-Json
$handoffs = Get-Content (Join-Path $root 'handoffs.json') -Raw | ConvertFrom-Json
$skillsRoot = Join-Path $projectRoot 'GD-Skill-Codex'
$skillById = @{}
foreach ($skill in $registry.skills) { $skillById[$skill.id] = $skill }

function Convert-ToJsString([object]$Value) {
    return ($Value | ConvertTo-Json -Compress -Depth 10)
}
function Get-FrontMatter([string]$Path) {
    $content = Get-Content -LiteralPath $Path -Raw
    $match = [regex]::Match($content, '(?s)^---\s*(.*?)\s*---')
    if (-not $match.Success) { throw "Front matter ausente: $Path" }
    return $match.Groups[1].Value
}
function Get-FrontMatterList([string]$FrontMatter, [string]$Field) {
    $match = [regex]::Match($FrontMatter, "(?ms)^${Field}:\s*\r?\n((?:\s+-\s+.*\r?\n?)+)")
    if (-not $match.Success) { return @() }
    return @([regex]::Matches($match.Groups[1].Value, '(?m)^\s+-\s+(.+?)\s*$') | ForEach-Object { $_.Groups[1].Value.Trim() })
}
function Get-FirstHeading([string]$Path, [string]$Fallback) {
    $match = [regex]::Match((Get-Content -LiteralPath $Path -Raw), '(?m)^#\s+(.+?)\s*$')
    if ($match.Success) { return ($match.Groups[1].Value -replace ':\s*.*$', '').Trim() }
    return $Fallback
}

$worldFields = @(
    @('entities', 'entidades'), @('resources', 'recursos'), @('spatial', 'espacial'),
    @('temporal', 'temporal'), @('rules', 'regras'), @('knowledge', 'conhecimento'),
    @('progression', 'progressão'), @('economy', 'economia'), @('actors', 'atores'),
    @('actions', 'ações'), @('goals', 'objetivos'), @('hidden_state', 'estado oculto')
)
$downstream = @{}
foreach ($skill in $registry.skills) { $downstream[$skill.id] = [System.Collections.Generic.List[string]]::new() }
foreach ($handoff in $handoffs.handoffs) {
    if (-not $downstream.ContainsKey($handoff.source)) { throw "Handoff source não está no registry: $($handoff.source)" }
    if (-not $downstream[$handoff.source].Contains($handoff.target)) { $downstream[$handoff.source].Add($handoff.target) }
}

$records = foreach ($skill in $registry.skills) {
    $skillPath = Join-Path (Join-Path $skillsRoot $skill.id) 'SKILL.md'
    $frontMatter = Get-FrontMatter $skillPath
    $concepts = Get-FrontMatterList $frontMatter 'domain.primary'
    if ($concepts.Count -eq 0) { $concepts = Get-FrontMatterList $frontMatter 'activation_signals.concepts' }
    $outputs = @($skill.outputs)
    $type = switch ($skill.role) {
        'formal' { 'formal' }
        'design' { 'design' }
        default { 'hybrid' }
    }
    $color = switch ($type) {
        'formal' { 'cyan' }
        'design' { 'rose' }
        default { 'amber' }
    }
    [ordered]@{
        id = $skill.id
        title = Get-FirstHeading $skillPath $skill.id
        type = $type
        evidence = if ($type -eq 'formal') { @('formal', 'derived') } elseif ($type -eq 'design') { @('derived', 'heuristic', 'empirical') } else { @('derived', 'heuristic', 'empirical') }
        color = $color
        lens = "$($skill.formalism) · $($outputs -join ' · ')"
        concepts = @($concepts)
        outputs = $outputs
        downstream = @($downstream[$skill.id])
    }
}

$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add('window.CODEX_DATA = {')
$lines.Add("  worldFields: $(Convert-ToJsString $worldFields),")
$lines.Add("  skills: $(Convert-ToJsString @($records))")
$lines.Add('};')
Set-Content -LiteralPath (Join-Path $projectRoot 'web\data.js') -Value ($lines -join [Environment]::NewLine) -Encoding utf8
Write-Output "OK: web/data.js gerado a partir de registry, handoffs e SKILL.md ($($records.Count) skills)."
