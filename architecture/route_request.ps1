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

# Domain cues prevent a single generic token from dominating routing.
$problemProfiles = @(
    [pscustomobject]@{ id='concurrent-gameplay-processes'; cues=@('simultane','paralel','concorr','sincron','recurso compartilhado','deadlock','petri','token'); weight=5 },
    [pscustomobject]@{ id='procedural-level-constraint-solving'; cues=@('geracao procedural','gerado','mapa sem solucao','solvabilidade','restricao','constraint','csp','backtracking'); weight=5 },
    [pscustomobject]@{ id='frame-based-combat-timing'; cues=@('startup','active','recovery','cancel','parry','frames','frame','janela de timing','tick'); weight=5 },
    [pscustomobject]@{ id='resource-flow-economy'; cues=@('estoque','fluxo','produz','consome','fonte','sink','gargalo','taxa','recurso acumula','recurso esgota'); weight=5 },
    [pscustomobject]@{ id='macroeconomic-resource-conversion'; cues=@('cadeia produtiva','multiplos estagios','input-output','bens intermediarios','choque de oferta','multiplicador'); weight=5 },
    [pscustomobject]@{ id='discrete-state-machine-verification'; cues=@('estado impossivel','alcancabilidade','transicao invalida','invariante','fsm','automato','deadlock sequencial'); weight=5 },
    [pscustomobject]@{ id='committed-risk-reward-actions'; cues=@('risco-recompensa','risk reward','compromisso','exposicao','acao pesada','custo de errar','janela de escape'); weight=4 },
    [pscustomobject]@{ id='emergent-agency-composition'; cues=@('combinar habilidades','solucoes multiplas','acao emergente','composicao de acoes','affordance'); weight=4 },
    [pscustomobject]@{ id='spatial-topology-and-learning-pacing'; cues=@('topologia','ritmo de salas','gating espacial','aprende pelo espaco','grafo de salas','learning beat'); weight=4 },
    [pscustomobject]@{ id='epistemic-holarchic-progression'; cues=@('descobrir','pistas','conhecimento','interpretacao','epistemico','knowledge graph','dependencia de pistas'); weight=4 },
    [pscustomobject]@{ id='cognitive-schema-disruption'; cues=@('expectativa','surpresa','regra parece bug','regra reinterpreta','reinterpreta','reinterpretar','prediction error','schema','bayesian'); weight=4 },
    [pscustomobject]@{ id='competitive-negative-feedback'; cues=@('lider','catch-up','rubber band','competicao','snowball','posicao relativa'); weight=4 },
    [pscustomobject]@{ id='exponential-progression-and-prestige'; cues=@('custo cresce','exponencial','prestigio','reset com bonus','nivel','progressao desacelera'); weight=4 },
    [pscustomobject]@{ id='nested-gameplay-loop-architecture'; cues=@('micro loop','macro loop','loop aninhado','varias escalas','ritmo temporal','exit point'); weight=4 },
    [pscustomobject]@{ id='procedural-expressive-range-analysis'; cues=@('repetitivo','variedade','expressive range','entropia','distribuicao de variantes','gerador enviesado'); weight=3 }
)

function Get-MatchScore {
    param($Skill)
    $score = 0
    $hits = @()
    foreach ($profile in $problemProfiles | Where-Object { $_.id -eq $Skill.id }) {
        foreach ($cue in $profile.cues) {
            $c = & $normalize $cue
            if ($text.Contains($c)) { $score += $profile.weight; $hits += $cue; continue }
            $tokens = @($c -split '[^a-z0-9]+' | Where-Object { $_.Length -ge 4 })
            $overlap = @($tokens | Where-Object { $textTokens -contains $_ }).Count
            if ($tokens.Count -gt 0 -and $overlap -ge [Math]::Min(2,$tokens.Count)) { $score += [Math]::Max(1,[Math]::Floor($profile.weight/2)); $hits += $cue }
        }
    }
    foreach ($signal in @($Skill.activation.explicit)) {
        $s = & $normalize $signal
        if ($text.Contains($s)) { $score += 3; $hits += $signal }
    }
    foreach ($signal in @($Skill.activation.semantic)) {
        $s = & $normalize $signal
        $tokens = @($s -split '[^a-z0-9]+' | Where-Object { $_.Length -ge 4 })
        if ($text.Contains($s) -or (@($tokens | Where-Object { $textTokens -contains $_ }).Count -ge [Math]::Min(2,$tokens.Count))) { $score += 2; $hits += $signal }
    }
    foreach ($signal in @($Skill.activation.structural)) {
        $s = & $normalize $signal
        $tokens = @($s -split '[^a-z0-9]+' | Where-Object { $_.Length -ge 4 })
        if ($text.Contains($s) -or (@($tokens | Where-Object { $textTokens -contains $_ }).Count -ge [Math]::Min(2,$tokens.Count))) { $score += 1; $hits += $signal }
    }
    $anti = 0
    foreach ($signal in @($Skill.activation.anti_signals)) {
        $s = & $normalize $signal
        if ($text.Contains($s)) { $anti++ }
    }
    return [pscustomobject]@{ score=$score-($anti*5); hits=$hits; anti_hits=$anti }
}
$scores = foreach ($skill in $registry.skills) {
    $m = Get-MatchScore $skill
    [pscustomobject]@{
        id=$skill.id
        score=$m.score
        hits=@($m.hits)
        anti_hits=$m.anti_hits
        domain_role=$skill.domain_role
        routing_role=$skill.routing_role
        priority=$skill.priority
    }
}
$ranked = @($scores | Sort-Object @{Expression={$_.score};Descending=$true}, @{Expression={$_.priority};Descending=$true})
$positive = @($ranked | Where-Object {$_.score -gt 0})
if ($positive.Count -eq 0) {
    throw 'Nenhuma skill foi ativada. Registre a hipótese ou decomponha explicitamente o problema.'
}

# Primary routing requires a meaningful margin. Close candidates remain secondary.
$primary = $positive | Select-Object -First 1
$second = if ($positive.Count -gt 1) { $positive[1] } else { $null }
$secondary = @($positive | Where-Object {
    $_.id -ne $primary.id -and
    $_.routing_role -ne 'validator_candidate' -and
    ($_.score -ge [Math]::Max(3,[Math]::Floor($primary.score * 0.45)))
} | ForEach-Object {$_.id})

$validatorCandidate = $positive | Where-Object {$_.routing_role -eq 'validator_candidate'} | Select-Object -First 1
$validator = if ($null -ne $validatorCandidate) {$validatorCandidate.id} else {'architecture/validate_cross_skill.ps1'}

[pscustomobject]@{
    schema_version='1.1.0'
    primary=$primary.id
    secondary=$secondary
    validator=$validator
    execution_order=@($primary.id)+$secondary
    evidence=$ranked
    routing_policy=[pscustomobject]@{
        profile_weight=5
        explicit_weight=3
        semantic_weight=2
        structural_weight=1
        anti_signal_penalty=5
        secondary_ratio=0.45
        principle='problem-profile score precedes generic keyword score; close candidates compose instead of replacing the primary'
    }
} | ConvertTo-Json -Depth 8
