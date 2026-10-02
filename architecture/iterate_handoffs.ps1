param(
    [Parameter(Mandatory = $true)][string]$Request,
    [Parameter(Mandatory = $true)][string]$WorldModelPath,
    [int]$MaxCycles = 3,
    [int]$Seed = 0
)
$ErrorActionPreference = 'Stop'
if ($MaxCycles -lt 1) { throw 'MaxCycles deve ser >= 1.' }
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$handoffs = Get-Content -Encoding UTF8 (Join-Path $root 'handoffs.json') -Raw | ConvertFrom-Json

function Get-Hash([string]$Text) {
    $bytes=[Text.Encoding]::UTF8.GetBytes($Text)
    return (([Security.Cryptography.SHA256]::Create().ComputeHash($bytes)) | ForEach-Object {$_.ToString('x2')}) -join ''
}

function Invoke-Analysis([string]$ContextPath,[int]$Cycle) {
    $args=@('-NoProfile','-ExecutionPolicy','Bypass','-File',(Join-Path $root 'execute_skills.ps1'),
            '-Request',$Request,'-WorldModelPath',$WorldModelPath,'-Seed',($Seed+$Cycle-1))
    if ($ContextPath) { $args += @('-HandoffInputPath',$ContextPath) }
    $json=& powershell.exe @args
    if ($LASTEXITCODE -ne 0) { throw "Execução falhou no ciclo $Cycle." }
    return ($json | ConvertFrom-Json)
}

$contextPath=$null
$history=@()
$previousFingerprint=$null
$converged=$false
$report=$null

for ($cycle=1; $cycle -le $MaxCycles; $cycle++) {
    $report=Invoke-Analysis $contextPath $cycle
    $adapterFingerprint=Get-Hash (($report.handoff_adapters | ConvertTo-Json -Depth 30))
    $claimFingerprint=Get-Hash (($report.claims | ConvertTo-Json -Depth 30))
    $fingerprint=Get-Hash ($adapterFingerprint+'|'+$claimFingerprint+'|'+$report.routing.primary)

    $returnContracts=@($handoffs.handoffs | Where-Object {$_.source -eq $report.routing.primary})
    $returnPackets=@()
    foreach ($contract in $returnContracts) {
        $targetId=[string]$contract.target
        $targetOutput=@($report.outputs | Where-Object {$_.skill_id -eq $targetId}) | Select-Object -First 1
        if ($null -eq $targetOutput) { continue }

        $packet=[ordered]@{
            schema_version='1.1.0'
            type='return_context'
            source_skill=$targetId
            target_skill=[string]$contract.return_to
            handoff_relation=$contract.relation
            expected_fields=@($contract.expected_output)
            payload=$targetOutput
            limitations=@('Contexto de retorno é evidência intermediária; não equivale a uma transformação ontológica reversa.')
        }
        $returnPackets+=,$packet
    }

    $history+=,[ordered]@{
        cycle=$cycle
        primary=$report.routing.primary
        execution_status=$report.execution_status
        fingerprint=$fingerprint
        adapter_fingerprint=$adapterFingerprint
        claim_fingerprint=$claimFingerprint
        return_packets=@($returnPackets | ForEach-Object {[ordered]@{source=$_.source_skill;target=$_.target_skill;fields=$_.expected_fields}})
    }

    if ($null -ne $previousFingerprint -and $fingerprint -eq $previousFingerprint) {
        $converged=$true
        break
    }

    if ($returnPackets.Count -eq 0) {
        break
    }

    $contextPath=Join-Path $env:TEMP ("gd-codex-return-"+[guid]::NewGuid().ToString()+".json")
    ([ordered]@{
        schema_version='1.1.0'
        cycle=$cycle
        packets=$returnPackets
    } | ConvertTo-Json -Depth 40) | Set-Content -LiteralPath $contextPath -Encoding utf8
    $previousFingerprint=$fingerprint
}

if ($contextPath) { Remove-Item -LiteralPath $contextPath -Force -ErrorAction SilentlyContinue }

[ordered]@{
    schema_version='1.1.0'
    request=$Request
    max_cycles=$MaxCycles
    cycles_run=$history.Count
    converged=$converged
    termination=if ($converged) {'stable_analysis_state'} elseif ($history.Count -ge $MaxCycles) {'max_cycles'} else {'no_return_path'}
    history=$history
    final_report=$report
} | ConvertTo-Json -Depth 40
