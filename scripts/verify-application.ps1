$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$DiagnosticsRoot = Join-Path $Root 'diagnostics'
$RunId = Get-Date -Format 'yyyyMMdd-HHmmss'
$RunDir = Join-Path $DiagnosticsRoot "verification-$RunId"
New-Item -ItemType Directory -Force -Path $RunDir | Out-Null

function Invoke-Check([string]$Name, [scriptblock]$Command) {
    $stdout = Join-Path $RunDir "$Name.log"
    $stderr = Join-Path $RunDir "$Name-error.log"
    try {
        & $Command 1> $stdout 2> $stderr
        if ($LASTEXITCODE -ne 0) { throw "$Name exited with code $LASTEXITCODE." }
        return $true
    } catch {
        $script:Failure = $_.Exception.Message
        return $false
    }
}

try {
    Set-Location $Root
    $env:PYTHONPATH = Join-Path $Root 'src'
    $checks = @(
        @{ Name = 'pytest'; Command = { & (Join-Path $Root '.venv\Scripts\python.exe') -m pytest } },
        @{ Name = 'flutter-analyze'; Command = { Push-Location (Join-Path $Root 'presentation'); try { flutter analyze } finally { Pop-Location } } },
        @{ Name = 'flutter-test'; Command = { Push-Location (Join-Path $Root 'presentation'); try { flutter test } finally { Pop-Location } } }
    )

    foreach ($check in $checks) {
        if (-not (Invoke-Check -Name $check.Name -Command $check.Command)) { throw $script:Failure }
    }

    "[$(Get-Date -Format o)] S3 verification passed." | Set-Content (Join-Path $RunDir 'verification.md')
    Write-Host "S3 verification passed. Evidence: $RunDir"
    exit 0
} catch {
    $incidentId = "CVX-VERIFY-$RunId"
    $incidentDir = Join-Path $DiagnosticsRoot "incident-$incidentId"
    New-Item -ItemType Directory -Force -Path $incidentDir | Out-Null
    $observed = $_.Exception.Message
    @"
# Criterivox S3 Verification Incident

- **Incident ID:** $incidentId
- **Time:** $(Get-Date -Format o)
- **Stage:** S3 verification

## Expected
All S3 Python and Flutter automated checks pass.

## Observed
$observed

## Evidence
Verification command logs are stored in `$RunDir`.

## Investigation
Inspect the failing `*-error.log` and `*.log` first. Do not change architecture based only on a compiler/test failure. Compare the failure with the S3 contracts, permanent runtime boundary, and existing S2 evidence.
"@ | Set-Content (Join-Path $incidentDir 'incident.md') -Encoding UTF8

    [ordered]@{
        incident_id = $incidentId
        timestamp = (Get-Date).ToString('o')
        severity = 'high'
        stage = 's3_verification'
        expected = 'All S3 Python and Flutter automated checks pass.'
        observed = $observed
        evidence_directory = $RunDir
    } | ConvertTo-Json -Depth 4 | Set-Content (Join-Path $incidentDir 'incident.json') -Encoding UTF8

    Write-Error "S3 verification failed. Incident: $incidentDir"
    exit 1
}
