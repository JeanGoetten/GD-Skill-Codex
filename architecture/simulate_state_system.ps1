param(
    [Parameter(Mandatory = $true)]
    [string]$WorldModelPath,
    [int]$Steps = 100,
    [int]$Seed = 0,
    [string]$OutputPath
)
$ErrorActionPreference = 'Stop'
if ($Steps -lt 1) { throw 'Steps deve ser positivo.' }
$world = Get-Content -LiteralPath $WorldModelPath -Raw | ConvertFrom-Json
$system = $world.hidden_state.state_system
if ($null -eq $system) { throw 'hidden_state.state_system ausente.' }
$states = @($system.states | ForEach-Object { [string]$_.id })
$current = [string]$system.initial_state
if ($states -notcontains $current) { throw 'initial_state inválido.' }
$random = [System.Random]::new($Seed)
$trace = [System.Collections.Generic.List[object]]::new()
for ($step = 0; $step -lt $Steps; $step++) {
    $state = @($system.states | Where-Object { $_.id -eq $current })[0]
    $trace.Add([ordered]@{ step = $step; state = $current; terminal = [bool]$state.terminal; outcome = if ($state.outcome) { $state.outcome } else { 'none' } })
    if ($state.terminal) { break }
    $options = @($system.transitions | Where-Object { $_.from -eq $current })
    if ($options.Count -eq 0) { break }
    $weighted = @($options | Where-Object { $null -ne $_.probability })
    if ($weighted.Count -eq $options.Count) {
        $roll = $random.NextDouble()
        $sum = 0.0; $chosen = $options[0]
        foreach ($option in $options) { $sum += [double]$option.probability; if ($roll -le $sum) { $chosen = $option; break } }
    } else {
        $chosen = $options[$random.Next(0, $options.Count)]
    }
    $current = [string]$chosen.to
}
$result = [ordered]@{
    schema_version = '1.0.0'
    simulation = 'discrete-state-system'
    seed = $Seed
    steps_requested = $Steps
    trace = @($trace)
    terminal_reached = [bool](@($trace | Where-Object { $_.terminal }).Count)
    status = if (@($trace | Where-Object { $_.terminal }).Count) { 'completed' } else { 'bounded' }
}
$json = $result | ConvertTo-Json -Depth 10
if ($OutputPath) { $json | Set-Content -LiteralPath $OutputPath -Encoding utf8 } else { $json }
