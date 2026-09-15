param(
    [Parameter(Mandatory = $true)]
    [string]$WorldModelPath
)
$ErrorActionPreference = 'Stop'
$world = Get-Content -LiteralPath $WorldModelPath -Raw | ConvertFrom-Json
$timing = $world.hidden_state.frame_timing
if ($null -eq $timing) {
    [ordered]@{
        skill_id = 'frame-based-combat-timing'
        status = 'blocked'
        results = [ordered]@{ execution = 'not_available'; reason = 'hidden_state.frame_timing ausente.' }
        metrics = @()
        evidence = @()
        errors = @('INSUFFICIENT_EVIDENCE: forneça tick_rate_hz e actions.')
    } | ConvertTo-Json -Depth 10 -Compress
    exit 0
}
if ($null -eq $timing.tick_rate_hz -or [double]$timing.tick_rate_hz -le 0) { throw 'tick_rate_hz deve ser positivo.' }
$actionResults = [ordered]@{}
$errors = [System.Collections.Generic.List[string]]::new()
$loopCandidates = [System.Collections.Generic.List[string]]::new()
foreach ($action in @($timing.actions)) {
    $id = [string]$action.id
    if ([string]::IsNullOrWhiteSpace($id)) { $errors.Add('ação sem id.'); continue }
    $startup = [int]$action.startup
    $active = [int]$action.active
    $recovery = [int]$action.recovery
    if ($startup -lt 0 -or $active -lt 0 -or $recovery -lt 0) { $errors.Add("frames inválidos: $id"); continue }
    $total = $startup + $active + $recovery
    $hitFrame = if ($null -ne $action.hit_frame) { [int]$action.hit_frame } else { $startup + 1 }
    if ($hitFrame -lt ($startup + 1) -or $hitFrame -gt ($startup + $active)) { $errors.Add("hit_frame fora da janela active: $id"); continue }
    $hitAdvantage = $null
    $blockAdvantage = $null
    if ($null -ne $action.hit_stun) { $hitAdvantage = [int]$action.hit_stun - ($total - $hitFrame) }
    if ($null -ne $action.block_stun) { $blockAdvantage = [int]$action.block_stun - ($total - $hitFrame) }
    $conditions = [ordered]@{
        repeatable = [bool]$action.repeatable
        contact = if ($null -ne $action.contact_condition) { [bool]$action.contact_condition } else { $false }
        resource = if ($null -ne $action.resource_condition) { [bool]$action.resource_condition } else { $false }
        escape_denied = if ($null -ne $action.escape_condition) { -not [bool]$action.escape_condition } else { $false }
    }
    $candidate = ($null -ne $hitAdvantage -and $hitAdvantage -ge $startup -and $conditions.repeatable -and $conditions.contact -and $conditions.resource -and $conditions.escape_denied)
    if ($candidate) { $loopCandidates.Add($id) }
    $actionResults[$id] = [ordered]@{
        startup = $startup
        active = $active
        recovery = $recovery
        total_frames = $total
        total_seconds = $total / [double]$timing.tick_rate_hz
        hit_frame = $hitFrame
        hit_advantage = $hitAdvantage
        block_advantage = $blockAdvantage
        infinite_loop_candidate = $candidate
        loop_conditions = $conditions
    }
}
if ($errors.Count -gt 0) {
    [ordered]@{ skill_id = 'frame-based-combat-timing'; status = 'failed'; results = [ordered]@{ execution = 'validation_failed' }; metrics = @(); evidence = @(); errors = @($errors) } | ConvertTo-Json -Depth 12 -Compress
    exit 0
}
[ordered]@{
    skill_id = 'frame-based-combat-timing'
    status = 'success'
    results = [ordered]@{
        tick_rate_hz = [double]$timing.tick_rate_hz
        actions = $actionResults
        infinite_loop_candidates = @($loopCandidates)
        limitation = 'Vantagem de frames não prova punição, loop ou garantia sem geometria, spacing, input buffer e estados de escape.'
    }
    metrics = @(
        [ordered]@{ name = 'action_count'; value = @($timing.actions).Count; status = 'derived' },
        [ordered]@{ name = 'loop_candidate_count'; value = $loopCandidates.Count; status = 'derived' }
    )
    evidence = @([ordered]@{ type = 'calculation'; id = 'frame-window-analysis'; status = 'derived' })
    errors = @()
} | ConvertTo-Json -Depth 15 -Compress
