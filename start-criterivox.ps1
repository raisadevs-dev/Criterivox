$ErrorActionPreference = 'Stop'

# Criterivox local runtime host.
# Starts the Python application, waits for readiness, then starts Flutter.
# Critical startup/runtime failures produce a developer incident report.

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$DiagnosticsRoot = Join-Path $Root 'diagnostics'
$RuntimeLog = Join-Path $DiagnosticsRoot 'runtime.log'
$BackendLog = Join-Path $DiagnosticsRoot 'python-runtime.log'
$FlutterLog = Join-Path $DiagnosticsRoot 'flutter-runtime.log'
$Port = if ($env:CRITERIVOX_BACKEND_PORT) { $env:CRITERIVOX_BACKEND_PORT } else { '8000' }
$WebPort = if ($env:CRITERIVOX_WEB_PORT) { $env:CRITERIVOX_WEB_PORT } else { '8080' }
$BackendUrl = "http://127.0.0.1:$Port"
$HealthUrl = "$BackendUrl/health"
$PresentationUrl = "http://127.0.0.1:$WebPort"

New-Item -ItemType Directory -Force -Path $DiagnosticsRoot | Out-Null
"[$(Get-Date -Format o)] Criterivox launcher starting." | Set-Content $RuntimeLog

$PythonProcess = $null
$FlutterProcess = $null

function Write-LauncherLog([string]$Message) {
    $line = "[$(Get-Date -Format o)] $Message"
    $line | Tee-Object -FilePath $RuntimeLog -Append
}

function New-Incident([string]$Stage, [string]$Expected, [string]$Observed, [string]$Recommendation) {
    $id = "CVX-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    $dir = Join-Path $DiagnosticsRoot "incident-$id"
    New-Item -ItemType Directory -Force -Path $dir | Out-Null

    $pythonVersion = (& python --version 2>&1 | Out-String).Trim()
    $flutterVersion = (& flutter --version 2>&1 | Select-Object -First 1 | Out-String).Trim()
    $payload = [ordered]@{
        incident_id = $id
        timestamp = (Get-Date).ToString('o')
        severity = 'critical'
        stage = $Stage
        component = 'criterivox_runtime_host'
        expected = $Expected
        observed = $Observed
        affected_boundary = 'local runtime host / Python / Flutter'
        user_visible_effect = 'Criterivox could not establish or maintain its local runtime.'
        runtime = [ordered]@{
            python = $pythonVersion
            flutter = $flutterVersion
            backend_url = $BackendUrl
            presentation_url = $PresentationUrl
            working_directory = $Root
        }
        evidence = [ordered]@{
            launcher_log = $RuntimeLog
            python_log = $BackendLog
            flutter_log = $FlutterLog
        }
        recommended_investigation = $Recommendation
    }
    $payload | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $dir 'incident.json') -Encoding UTF8

    @"
# Criterivox Runtime Incident

- **Incident ID:** $id
- **Time:** $($payload.timestamp)
- **Severity:** CRITICAL
- **Stage:** $Stage

## Expected
$Expected

## Observed
$Observed

## Failure story
The Criterivox runtime launcher started its managed startup sequence, but the expected runtime condition was not reached. The launcher recorded the failure so a developer or AI coding assistant can inspect the evidence without reconstructing the event from scattered terminal output.

## Affected boundary
`$($payload.affected_boundary)`

## User-visible consequence
$($payload.user_visible_effect)

## Evidence
- Launcher: `$RuntimeLog`
- Python: `$BackendLog`
- Flutter: `$FlutterLog`

## Recommended investigation
$Recommendation

## Runtime environment
- Python: `$pythonVersion`
- Flutter: `$flutterVersion`
- Backend: `$BackendUrl`
- Presentation: `$PresentationUrl`
"@ | Set-Content (Join-Path $dir 'incident.md') -Encoding UTF8

    Write-LauncherLog "Developer incident created: $dir"
}

try {
    Set-Location $Root
    $env:PYTHONPATH = Join-Path $Root 'src'

    if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
        throw 'Python executable was not found on PATH.'
    }
    if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
        throw 'Flutter executable was not found on PATH.'
    }

    Write-LauncherLog "Starting Python runtime on $BackendUrl."
    $PythonProcess = Start-Process -FilePath 'python' -ArgumentList '-m','uvicorn','criterivox.app:app','--host','127.0.0.1','--port',$Port -WorkingDirectory $Root -RedirectStandardOutput $BackendLog -RedirectStandardError $BackendLog -PassThru -WindowStyle Minimized

    $ready = $false
    for ($i = 0; $i -lt 30; $i++) {
        Start-Sleep -Milliseconds 500
        if ($PythonProcess.HasExited) {
            throw "Python runtime exited during startup with code $($PythonProcess.ExitCode)."
        }
        try {
            $response = Invoke-WebRequest -Uri $HealthUrl -UseBasicParsing -TimeoutSec 1
            if ($response.StatusCode -eq 200) {
                $ready = $true
                break
            }
        } catch {
            # Readiness is expected to fail briefly while Uvicorn starts.
        }
    }
    if (-not $ready) {
        throw "Python runtime did not become ready at $HealthUrl within 15 seconds."
    }

    Write-LauncherLog 'Python runtime is ready.'
    Write-LauncherLog "Starting Flutter presentation on $PresentationUrl."
    $FlutterProcess = Start-Process -FilePath 'flutter' -ArgumentList 'run','-d','chrome','--web-port',$WebPort -WorkingDirectory (Join-Path $Root 'presentation') -RedirectStandardOutput $FlutterLog -RedirectStandardError $FlutterLog -PassThru -WindowStyle Minimized

    Start-Sleep -Seconds 3
    if ($FlutterProcess.HasExited) {
        throw "Flutter presentation exited during startup with code $($FlutterProcess.ExitCode)."
    }

    Write-LauncherLog 'Criterivox runtime is running. Close this launcher window to stop the managed processes.'
    Write-LauncherLog "Presentation: $PresentationUrl"
    Write-LauncherLog "Backend health: $HealthUrl"

    while ($true) {
        Start-Sleep -Seconds 2
        if ($PythonProcess.HasExited) {
            throw "Python runtime stopped unexpectedly with code $($PythonProcess.ExitCode)."
        }
        if ($FlutterProcess.HasExited) {
            throw "Flutter presentation stopped unexpectedly with code $($FlutterProcess.ExitCode)."
        }
    }
}
catch {
    $message = $_.Exception.Message
    Write-LauncherLog "CRITICAL runtime failure: $message"
    New-Incident -Stage 'managed_startup_or_runtime' -Expected 'Python and Flutter remain running under the Criterivox runtime host.' -Observed $message -Recommendation 'Inspect the incident.md report and the referenced runtime logs. Verify Python/Flutter installation, ports, dependencies, and the failing process before changing application code.'
    exit 1
}
finally {
    if ($FlutterProcess -and -not $FlutterProcess.HasExited) {
        Write-LauncherLog 'Stopping Flutter presentation.'
        Stop-Process -Id $FlutterProcess.Id -Force -ErrorAction SilentlyContinue
    }
    if ($PythonProcess -and -not $PythonProcess.HasExited) {
        Write-LauncherLog 'Stopping Python runtime.'
        Stop-Process -Id $PythonProcess.Id -Force -ErrorAction SilentlyContinue
    }
    Write-LauncherLog 'Criterivox launcher stopped.'
}
