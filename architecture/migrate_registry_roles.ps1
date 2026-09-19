$ErrorActionPreference = 'Stop'
$path = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'skill-registry.json'
$registry = Get-Content -Encoding UTF8 -LiteralPath $path -Raw | ConvertFrom-Json
foreach ($skill in $registry.skills) {
    if (-not $skill.PSObject.Properties.Name.Contains('domain_role')) {
        $skill | Add-Member -NotePropertyName domain_role -NotePropertyValue ([string]$skill.role)
    }
    if (-not $skill.PSObject.Properties.Name.Contains('routing_role')) {
        $routingRole = switch ([string]$skill.role) {
            'validator' { 'validator_candidate' }
            'primary' { 'primary_candidate' }
            default { 'secondary_candidate' }
        }
        $skill | Add-Member -NotePropertyName routing_role -NotePropertyValue $routingRole
    }
    $skill.PSObject.Properties.Remove('role')
}
$registry | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $path -Encoding utf8
Write-Output "OK: $($registry.skills.Count) skills migradas para domain_role/routing_role."
