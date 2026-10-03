$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$skillsRoot = Join-Path $root 'GD-Skill-Codex'
$requiredHeadings = @(
    'Domain',
    'Purpose',
    'Activation Signals',
    'Scope',
    'Exclusions',
    'Handoff Conditions',
    'Handoff Candidates',
    'Recognition References',
    'Theoretical Context and System Function',
    'Integrated Processing Protocol',
    'Mathematical Status',
    'Formal Guarantees',
    'Derived Metrics',
    'Heuristics and Design Judgments',
    'Required Simulation or Playtesting',
    'Hypotheses and Limitations',
    'Procedure Execution Example'
)
$franchiseNames = @(
    'Mario', 'Zelda', 'Pokémon', 'Pokemon', 'Dark Souls', 'Elden Ring',
    'Civilization', 'XCOM', 'Portal', 'Minecraft', 'Warcraft', 'StarCraft',
    'Hades', 'Hollow Knight', 'Metroid', 'Final Fantasy', 'League of Legends',
    'Dota', 'Street Fighter', 'Tekken', 'Mortal Kombat', 'Persona',
    'Fire Emblem', 'Mass Effect', 'Fallout', 'Skyrim', 'Dragon Age', 'Diablo',
    'Overwatch', 'Destiny', 'Warframe', 'Monster Hunter', 'Genshin',
    'Baldur', 'God of War', 'Doom', 'Dishonored', 'BioShock', 'Resident Evil',
    'Metal Gear', 'Sonic', 'Outer Wilds', 'Spelunky'
)
$errors = [System.Collections.Generic.List[string]]::new()

Get-ChildItem -LiteralPath $skillsRoot -Directory | ForEach-Object {
    $dir = $_
    $file = Join-Path $dir.FullName 'SKILL.md'
    if (-not (Test-Path -LiteralPath $file)) {
        $errors.Add("$($dir.Name): SKILL.md ausente")
        return
    }
    $lines = Get-Content -Encoding UTF8 -LiteralPath $file
    if ($lines.Count -lt 4 -or $lines[0] -ne '---') {
        $errors.Add("$($dir.Name): front matter não inicia na primeira linha")
        return
    }
    $end = [Array]::IndexOf($lines, '---', 1)
    if ($end -lt 0) {
        $errors.Add("$($dir.Name): front matter sem fechamento")
        return
    }
    $allowedTopLevel = @('name', 'description', 'metadata')
    for ($i = 1; $i -lt $end; $i++) {
        if ($lines[$i] -match '^([a-zA-Z0-9_-]+):') {
            $topLevelKey = $Matches[1]
            if ($topLevelKey -notin $allowedTopLevel) {
                $errors.Add("$($dir.Name): chave de front matter não padronizada: $topLevelKey")
            }
        }
    }
    $nameLine = $lines | Where-Object { $_ -match '^name:\s*(.+)$' } | Select-Object -First 1
    if (-not $nameLine) {
        $errors.Add("$($dir.Name): campo name ausente")
    } elseif ($nameLine -replace '^name:\s*', '' -ne $dir.Name) {
        $errors.Add("$($dir.Name): name não corresponde ao diretório")
    }
    $descriptionLine = $lines | Where-Object { $_ -match '^description:\s*(.+)$' } | Select-Object -First 1
    if (-not ($lines | Where-Object { $_ -eq 'metadata:' })) {
        $errors.Add("$($dir.Name): campo metadata ausente")
    }
    $structuredFields = @('  domain:', '  activation_signals:', '  outputs:', '  handoffs:', '  exclusions:')
    foreach ($field in $structuredFields) {
        if (-not ($lines | Where-Object { $_ -match ('^' + [regex]::Escape($field)) })) {
            $errors.Add("$($dir.Name): campo estruturado ausente: $field")
        }
    }
    foreach ($field in @('    primary:', '    concepts:', '    recognition_references:', '    downstream:')) {
        if (-not ($lines | Where-Object { $_ -eq $field })) {
            $errors.Add("$($dir.Name): subcampo estruturado ausente: $field")
        }
    }
    if (-not ($lines | Where-Object { $_ -match '^\s+-\s+\S+' })) {
        $errors.Add("$($dir.Name): listas estruturadas sem itens")
    }
    if ($descriptionLine) {
        $descriptionValue = ($descriptionLine -replace '^description:\s*', '').Trim()
        if (-not ($descriptionValue.StartsWith('"') -and $descriptionValue.EndsWith('"'))) {
            $errors.Add("$($dir.Name): description deve ser uma string YAML entre aspas")
        }
        if ($descriptionValue -match '[<>]') {
            $errors.Add("$($dir.Name): description contém colchete angular proibido")
        }
        foreach ($franchise in $franchiseNames) {
            if ($descriptionLine -match [regex]::Escape($franchise)) {
                $errors.Add("$($dir.Name): description contém referência proibida: $franchise")
            }
        }
    }
    foreach ($heading in $requiredHeadings) {
        if (-not ($lines | Where-Object { $_ -match ("^#{2,3}\s+.*" + [regex]::Escape($heading)) })) {
            $errors.Add("$($dir.Name): heading obrigatório ausente: $heading")
        }
    }
}

if ($errors.Count) {
    $errors | ForEach-Object { Write-Error $_ }
    exit 1
}
Write-Output 'OK: todas as skills passaram na validação.'
