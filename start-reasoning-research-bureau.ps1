$ErrorActionPreference = 'Stop'

# Standalone Sprint 7 launcher.
# This intentionally does NOT start the normal Criterivox runtime, Syvax, or the main presentation shell.
# WebSocket control is managed here as a launcher/runtime concern: the S7 backend remains the
# authoritative computational service, while this script verifies that its WebSocket endpoint is reachable.

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$DiagnosticsRoot = Join-Path $Root 'diagnostics'
$RuntimeLog = Join-Path $DiagnosticsRoot 's7-runtime.log'
$BackendLog = Join-Path $DiagnosticsRoot 's7-python-runtime.log'
$BackendErrorLog = Join-Path $DiagnosticsRoot 's7-python-runtime-error.log'
$FlutterLog = Join-Path $DiagnosticsRoot 's7-flutter-runtime.log'
$FlutterErrorLog = Join-Path $DiagnosticsRoot 's7-flutter-runtime-error.log'

$Port = if ($env:CRITERIVOX_S7_BACKEND_PORT) { $env:CRITERIVOX_S7_BACKEND_PORT } else { '8017' }
$WebPort = if ($env:CRITERIVOX_S7_WEB_PORT) { $env:CRITERIVOX_S7_WEB_PORT } else { '8018' }
$BackendUrl = "http://127.0.0.1:$Port"
$HealthUrl = "$BackendUrl/health"
$WebSocketUrl = "ws://127.0.0.1:$Port/api/s7/ws"
$PresentationUrl = "http://127.0.0.1:$WebPort"
$PythonExecutable = Join-Path $Root '.venv\Scripts\python.exe'
$FlutterProject = Join-Path $Root 'presentation'

New-Item -ItemType Directory -Force -Path $DiagnosticsRoot | Out-Null
"[$(Get-Date -Format o)] S7 Reasoning Research Bureau launcher starting." | Set-Content $RuntimeLog
$PythonProcess = $null
$FlutterProcess = $null

function Write-LauncherLog([string]$Message) {
    "[$(Get-Date -Format o)] $Message" | Tee-Object -FilePath $RuntimeLog -Append
}

function Test-WebSocketEndpoint([string]$Uri) {
    # PowerShell's WebSocket client is used only as a control-channel preflight.
    # No reasoning or application state is implemented in the launcher.
    $socket = $null
    try {
        $socket = [System.Net.WebSockets.ClientWebSocket]::new()
        $cts = [System.Threading.CancellationTokenSource]::new(3000)
        $socket.ConnectAsync([System.Uri]$Uri, $cts.Token).GetAwaiter().GetResult()
        if ($socket.State -ne [System.Net.WebSockets.WebSocketState]::Open) {
            return $false
        }
        $bytes = [System.Text.Encoding]::UTF8.GetBytes('{"type":"ping"}')
        $segment = [System.ArraySegment[byte]]::new($bytes)
        $socket.SendAsync($segment, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, $cts.Token).GetAwaiter().GetResult()
        return $true
    }
    catch {
        return $false
    }
    finally {
        if ($socket) {
            try { $socket.Dispose() } catch { }
        }
    }
}

function New-Incident([string]$Stage, [string]$Expected, [string]$Observed, [string]$Recommendation) {
    $id = "CVX-S7-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    $dir = Join-Path $DiagnosticsRoot "incident-$id"
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    $pythonVersion = if (Test-Path $PythonExecutable) { (& $PythonExecutable --version 2>&1 | Out-String).Trim() } else { 'project .venv Python not found' }
    $flutterVersion = if (Get-Command flutter -ErrorAction SilentlyContinue) { (& flutter --version 2>&1 | Select-Object -First 1 | Out-String).Trim() } else { 'Flutter executable not found' }
    $payload = [ordered]@{
        incident_id = $id
        timestamp = (Get-Date).ToString('o')
        severity = 'critical'
        stage = $Stage
        component = 's7_reasoning_research_bureau'
        expected = $Expected
        observed = $Observed
        affected_boundary = 'standalone S7 local runtime / Python / Flutter / WebSocket control channel'
        user_visible_effect = 'The standalone S7 Reasoning Research Bureau could not establish or maintain its local runtime.'
        runtime = [ordered]@{ python = $pythonVersion; flutter = $flutterVersion; backend_url = $BackendUrl; websocket_url = $WebSocketUrl; presentation_url = $PresentationUrl; working_directory = $Root }
        evidence = [ordered]@{ launcher_log = $RuntimeLog; python_log = $BackendLog; python_error_log = $BackendErrorLog; flutter_log = $FlutterLog; flutter_error_log = $FlutterErrorLog }
        recommended_investigation = $Recommendation
    }
    $payload | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $dir 'incident.json') -Encoding UTF8
    @"
# S7 Runtime Incident

- **Incident ID:** $id
- **Time:** $($payload.timestamp)
- **Severity:** CRITICAL
- **Stage:** $Stage

## Expected
$Expected

## Observed
$Observed

## Affected boundary
`$($payload.affected_boundary)`

## User-visible consequence
$($payload.user_visible_effect)

## Evidence
- Launcher: `$RuntimeLog`
- Python stdout: `$BackendLog`
- Python stderr: `$BackendErrorLog`
- Flutter stdout: `$FlutterLog`
- Flutter stderr: `$FlutterErrorLog`

## Recommended investigation
$Recommendation

## Runtime environment
- Python: `$pythonVersion`
- Flutter: `$flutterVersion`
- Backend: `$BackendUrl`
- WebSocket: `$WebSocketUrl`
- Presentation: `$PresentationUrl`
"@ | Set-Content (Join-Path $dir 'incident.md') -Encoding UTF8
    Write-LauncherLog "Developer incident created: $dir"
}

try {
    Set-Location $Root
    $env:PYTHONPATH = Join-Path $Root 'src'

    if (-not (Test-Path $PythonExecutable)) {
        throw "Project Python environment was not found at $PythonExecutable. Create/activate the project's documented .venv first."
    }
    if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
        throw 'Flutter executable was not found on PATH.'
    }
    if (-not (Test-Path (Join-Path $FlutterProject 'pubspec.yaml'))) {
        throw "Flutter project was not found at $FlutterProject."
    }
    if (-not (Test-Path (Join-Path $FlutterProject 'lib\s7_main.dart'))) {
        throw 'Standalone S7 Flutter entrypoint presentation/lib/s7_main.dart was not found.'
    }

    Write-LauncherLog 'Running Python syntax preflight for the S7 package.'
    & $PythonExecutable -m compileall -q (Join-Path $Root 'src\criterivox\s7')
    if ($LASTEXITCODE -ne 0) {
        throw 'S7 Python source preflight failed. The backend was not started.'
    }

    Write-LauncherLog 'Fetching Flutter dependencies for the presentation project.'
    Push-Location $FlutterProject
    & flutter pub get
    if ($LASTEXITCODE -ne 0) {
        throw 'Flutter dependency resolution failed. The S7 presentation was not started.'
    }
    Pop-Location

    Write-LauncherLog "Starting standalone S7 Python backend on $BackendUrl."
    $PythonProcess = Start-Process -FilePath $PythonExecutable -ArgumentList '-m','uvicorn','criterivox.s7.app:app','--host','127.0.0.1','--port',$Port -WorkingDirectory $Root -RedirectStandardOutput $BackendLog -RedirectStandardError $BackendErrorLog -PassThru -WindowStyle Minimized

    $ready = $false
    for ($i = 0; $i -lt 30; $i++) {
        Start-Sleep -Milliseconds 500
        if ($PythonProcess.HasExited) {
            throw "S7 Python backend exited during startup with code $($PythonProcess.ExitCode)."
        }
        try {
            $response = Invoke-WebRequest -Uri $HealthUrl -UseBasicParsing -TimeoutSec 1
            if ($response.StatusCode -eq 200) {
                $ready = $true
                break
            }
        } catch { }
    }
    if (-not $ready) {
        throw "S7 Python backend did not become ready at $HealthUrl within 15 seconds."
    }

    Write-LauncherLog 'S7 Python backend is ready.'
    Write-LauncherLog "Verifying S7 WebSocket control endpoint at $WebSocketUrl."
    if (-not (Test-WebSocketEndpoint $WebSocketUrl)) {
        throw "S7 WebSocket control endpoint could not be established at $WebSocketUrl. The presentation was not started."
    }
    Write-LauncherLog 'S7 WebSocket control endpoint is reachable.'

    Write-LauncherLog "Starting standalone S7 Flutter presentation on $PresentationUrl."
    $FlutterProcess = Start-Process -FilePath 'flutter' -ArgumentList 'run','-d','chrome','-t','lib/s7_main.dart','--web-port',$WebPort -WorkingDirectory $FlutterProject -RedirectStandardOutput $FlutterLog -RedirectStandardError $FlutterErrorLog -PassThru -WindowStyle Minimized
    Start-Sleep -Seconds 5
    if ($FlutterProcess.HasExited) {
        throw "S7 Flutter presentation exited during startup with code $($FlutterProcess.ExitCode)."
    }

    Write-LauncherLog 'Standalone S7 Reasoning Research Bureau is running.'
    Write-LauncherLog "Presentation: $PresentationUrl"
    Write-LauncherLog "Backend health: $HealthUrl"
    Write-LauncherLog "WebSocket control: $WebSocketUrl"
    Write-LauncherLog 'This launcher does not start the normal Criterivox shell or Syvax.'

    while ($true) {
        Start-Sleep -Seconds 2
        if ($PythonProcess.HasExited) {
            throw "S7 Python backend stopped unexpectedly with code $($PythonProcess.ExitCode)."
        }
        if ($FlutterProcess.HasExited) {
            throw "S7 Flutter presentation stopped unexpectedly with code $($FlutterProcess.ExitCode)."
        }
    }
}
catch {
    $message = $_.Exception.Message
    Write-LauncherLog "CRITICAL S7 runtime failure: $message"
    New-Incident -Stage 's7_managed_startup_or_runtime' -Expected 'The standalone S7 Python backend, WebSocket control endpoint, and Flutter presentation remain available.' -Observed $message -Recommendation 'Inspect incident.md first, then the referenced logs. Verify .venv, Python dependencies, Flutter installation, ports 8017/8018, the S7 entrypoints, and the WebSocket endpoint before changing application code.'
    exit 1
}
finally {
    if ($FlutterProcess -and -not $FlutterProcess.HasExited) {
        Stop-Process -Id $FlutterProcess.Id -Force -ErrorAction SilentlyContinue
    }
    if ($PythonProcess -and -not $PythonProcess.HasExited) {
        Stop-Process -Id $PythonProcess.Id -Force -ErrorAction SilentlyContinue
    }
}
