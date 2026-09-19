param(
    [Parameter(Mandatory = $true)]
    [string]$Request
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$registry = Get-Content -Encoding UTF8 (Join-Path $root 'skill-registry.json') -Raw | ConvertFrom-Json
$normalize = {
    param([string]$Value)
    $normalized = $Value.ToLowerInvariant().Normalize([Text.NormalizationForm]::FormD)
    return [regex]::Replace($normalized, '\p{Mn}', '')
}
$text = & $normalize $Request
$textTokens = @($text -split '[^a-z0-9]+' | Where-Object { $_.Length -ge 3 })
$scores = foreach ($skill in $registry.skills) {
    $hits = 0
    $weightedHits = 0
    foreach ($signal in @($skill.activation.explicit)) {
        $signalText = & $normalize $signal
        $signalTokens = @($signalText -split '[^a-z0-9]+' | Where-Object { $_.Length -ge 3 })
        if ($text.Contains($signalText) -or (@($signalTokens | Where-Object { $textTokens -contains $_ }).Count -ge [Math]::Min(2, $signalTokens.Count))) { $hits++; $weightedHits += 3 }
    }
    foreach ($signal in @($skill.activation.semantic)) {
        $signalText = & $normalize $signal
        $signalTokens = @($signalText -split '[^a-z0-9]+' | Where-Object { $_.Length -ge 3 })
        if ($text.Contains($signalText) -or (@($signalTokens | Where-Object { $textTokens -contains $_ }).Count -ge [Math]::Min(2, $signalTokens.Count))) { $hits++; $weightedHits += 2 }
    }
    foreach ($signal in @($skill.activation.structural)) {
        $signalText = & $normalize $signal
        $signalTokens = @($signalText -split '[^a-z0-9]+' | Where-Object { $_.Length -ge 3 })
        if ($text.Contains($signalText) -or (@($signalTokens | Where-Object { $textTokens -contains $_ }).Count -ge [Math]::Min(2, $signalTokens.Count))) { $hits++; $weightedHits += 1 }
    }
    $antiHits = 0
    foreach ($signal in @($skill.activation.anti_signals)) {
        $signalText = & $normalize $signal
        $signalTokens = @($signalText -split '[^a-z0-9]+' | Where-Object { $_.Length -ge 3 })
        if ($text.Contains($signalText) -or (@($signalTokens | Where-Object { $textTokens -contains $_ }).Count -ge [Math]::Min(2, $signalTokens.Count))) { $antiHits++ }
    }
    $blocked = $antiHits -gt 0 -and $hits -eq 0
    [pscustomobject]@{ id = $skill.id; score = ($weightedHits - ($antiHits * 4)); priority = $skill.priority; hits = $hits; anti_hits = $antiHits; blocked = $blocked; role = $skill.role; domain_role = $skill.domain_role; routing_role = $skill.routing_role }
}
$ranked = @($scores | Sort-Object @{Expression = { $_.score }; Descending = $true }, @{Expression = { $_.priority }; Descending = $true })
$selected = @($ranked | Where-Object { $_.score -gt 0 -and -not $_.blocked })
if ($selected.Count -eq 0) { throw 'Nenhuma skill foi ativada pelos sinais disponíveis; decomponha o pedido ou registre uma hipótese.' }
$primary = $selected | Select-Object -First 1
$secondaryThreshold = [Math]::Max(2, [Math]::Ceiling($primary.score * 0.5))
$secondary = @($selected | Where-Object { $_.id -ne $primary.id -and $_.score -ge $secondaryThreshold -and $_.routing_role -ne 'validator_candidate' } | ForEach-Object { $_.id })
$validatorCandidate = $selected | Where-Object { $_.routing_role -eq 'validator_candidate' } | Select-Object -First 1
$validator = if ($null -ne $validatorCandidate) { $validatorCandidate.id } else { 'architecture/validate_cross_skill.ps1' }
[pscustomobject]@{
    primary = $primary.id
    secondary = $secondary
    validator = $validator
    execution_order = @($primary.id) + $secondary
    evidence = $selected
    routing_policy = [pscustomobject]@{ explicit_weight = 3; semantic_weight = 2; structural_weight = 1; anti_signal_penalty = 4; secondary_threshold = $secondaryThreshold }
} | ConvertTo-Json -Depth 6
