# Criterivox managed runtime launcher
$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$DiagnosticsRoot = Join-Path $Root 'diagnostics'
$RuntimeLog = Join-Path $DiagnosticsRoot 'runtime.log'
$BackendLog = Join-Path $DiagnosticsRoot 'python-runtime.log'
$BackendErrorLog = Join-Path $DiagnosticsRoot 'python-runtime-error.log'
$FlutterLog = Join-Path $DiagnosticsRoot 'flutter-runtime.log'
$FlutterErrorLog = Join-Path $DiagnosticsRoot 'flutter-runtime-error.log'
$BackendCommandFile = Join-Path $DiagnosticsRoot 'run-backend.cmd'
$BackendTerminal = $null
$FlutterProcess = $null

$Port = if ($env:CRITERIVOX_BACKEND_PORT) { [int]$env:CRITERIVOX_BACKEND_PORT } else { 8000 }
$WebPort = if ($env:CRITERIVOX_WEB_PORT) { [int]$env:CRITERIVOX_WEB_PORT } else { 8080 }
$StartupTimeoutSeconds = if ($env:CRITERIVOX_BACKEND_STARTUP_TIMEOUT_SECONDS) { [int]$env:CRITERIVOX_BACKEND_STARTUP_TIMEOUT_SECONDS } else { 90 }

$BackendUrl = "http://127.0.0.1:$Port"
$HealthUrl = "$BackendUrl/health"
$WebSocketUrl = "ws://127.0.0.1:$Port/runtime/characters"
$PresentationUrl = "http://127.0.0.1:$WebPort"
$PresentationRoot = Join-Path $Root 'presentation'
$FlutterEntryPoint = 'lib/app/main.dart'
$FlutterExecutable = $null
$PythonExecutable = Join-Path $Root '.venv\Scripts\python.exe'

New-Item -ItemType Directory -Force -Path $DiagnosticsRoot | Out-Null
foreach ($log in @($RuntimeLog,$BackendLog,$BackendErrorLog,$FlutterLog,$FlutterErrorLog)) {
    Remove-Item $log -Force -ErrorAction SilentlyContinue
}
"[$(Get-Date -Format o)] Criterivox launcher starting." | Set-Content $RuntimeLog -Encoding UTF8

function Write-LauncherLog {
    param([AllowEmptyString()][AllowNull()][string]$Message)
    if ($null -eq $Message) { $Message = '' }
    $line = "[$(Get-Date -Format o)] $Message"
    Add-Content -Path $RuntimeLog -Value $line -Encoding UTF8
    Write-Host $line
}

function Test-PortAvailable([int]$PortNumber) {
    $listener = $null
    try {
        $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback,$PortNumber)
        $listener.Start()
        return $true
    } catch { return $false }
    finally { if ($listener) { $listener.Stop() } }
}

function Stop-ProcessTree([int]$ProcessId) {
    if ($ProcessId -le 0) { return }
    try { & taskkill.exe /PID $ProcessId /T /F 2>$null | Out-Null } catch {}
}

function Write-ProcessDiagnostics {
    foreach ($log in @($BackendLog,$BackendErrorLog,$FlutterLog,$FlutterErrorLog)) {
        if (-not (Test-Path $log)) { continue }
        $lines = @(Get-Content $log -ErrorAction SilentlyContinue)
        if ($lines.Count -eq 0) {
            Write-LauncherLog "$(Split-Path $log -Leaf) is empty."
        } else {
            Write-LauncherLog "Captured $(Split-Path $log -Leaf) with $($lines.Count) line(s)."
            foreach ($line in ($lines | Select-Object -Last 60)) {
                Write-LauncherLog "DIAGNOSTIC: $line"
            }
        }
    }
}

function Get-RootCauseClassification([string]$Message,[string]$Stage) {
    if ($Stage -eq 'backend_readiness') { return 'BACKEND_STARTUP_FAILURE' }
    if ($Stage -eq 'flutter_startup') { return 'FLUTTER_RUNTIME_FAILURE' }
    $combined = $Message
    foreach ($log in @($BackendLog,$BackendErrorLog,$FlutterLog,$FlutterErrorLog)) {
        if (Test-Path $log) { $combined += [Environment]::NewLine + (Get-Content $log -Raw -ErrorAction SilentlyContinue) }
    }
    if ($combined -match 'SyntaxError|IndentationError|TabError') { return 'PYTHON_SYNTAX_FAILURE' }
    if ($combined -match 'ModuleNotFoundError|ImportError|cannot import name') { return 'PYTHON_IMPORT_FAILURE' }
    if ($combined -match 'Address already in use|Only one usage|port .* already') { return 'BACKEND_PORT_CONFLICT' }
    if ($combined -match 'Target file .*lib[\\/]main\.dart.*not found') { return 'FLUTTER_ENTRYPOINT_MISSING' }
    if ($combined -match 'version solving failed|pubspec\.yaml|flutter pub') { return 'FLUTTER_DEPENDENCY_FAILURE' }
    if ($combined -match 'Chrome.*not found|No devices found|unable to find a device') { return 'CHROME_RUNTIME_MISSING' }
    if ($combined -match 'WebSocket|websocket|handshake') { return 'WEBSOCKET_RUNTIME_FAILURE' }
    return 'UNCLASSIFIED_RUNTIME_FAILURE'
}

function New-Incident([string]$Stage,[string]$Expected,[string]$Observed,[string]$Recommendation) {
    $classification = Get-RootCauseClassification $Observed $Stage
    $id = "CVX-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    $dir = Join-Path $DiagnosticsRoot "incident-$id"
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    $pythonVersion = if (Test-Path $PythonExecutable) { (& $PythonExecutable --version 2>&1 | Out-String).Trim() } else { 'project .venv Python not found' }
    $flutterVersion = if ($FlutterExecutable) { (& $FlutterExecutable --version 2>&1 | Select-Object -First 1 | Out-String).Trim() } else { 'Flutter not found' }
    $payload = [ordered]@{
        incident_id=$id
        timestamp=(Get-Date).ToString('o')
        severity='critical'
        stage=$Stage
        component='criterivox_runtime_host'
        root_cause_classification=$classification
        expected=$Expected
        observed=$Observed
        runtime=[ordered]@{
            working_directory=$Root
            python=$pythonVersion
            flutter=$flutterVersion
            backend=$BackendUrl
            health=$HealthUrl
            websocket=$WebSocketUrl
            presentation=$PresentationUrl
            flutter_entrypoint=$FlutterEntryPoint
            backend_startup_timeout_seconds=$StartupTimeoutSeconds
        }
        process_state=[ordered]@{
            backend_terminal=if($BackendTerminal){"PID=$($BackendTerminal.Id)"}else{'not-started'}
            flutter=if($FlutterProcess){"PID=$($FlutterProcess.Id)"}else{'not-started'}
            backend_port_listening=(-not (Test-PortAvailable $Port))
        }
        evidence=[ordered]@{
            launcher_log=$RuntimeLog
            backend_stdout=$BackendLog
            backend_stderr=$BackendErrorLog
            flutter_stdout=$FlutterLog
            flutter_stderr=$FlutterErrorLog
        }
        recommendation=$Recommendation
    }
    $payload | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $dir 'incident.json') -Encoding UTF8
    Write-LauncherLog "Developer incident created: $dir"
}

try {
    Set-Location -LiteralPath $Root
    $env:PYTHONPATH = Join-Path $Root 'src'

    Write-LauncherLog "Project root: $Root"
    Write-LauncherLog "Python executable: $PythonExecutable"
    Write-LauncherLog "Presentation root: $PresentationRoot"
    Write-LauncherLog "Backend: $BackendUrl"
    Write-LauncherLog "WebSocket: $WebSocketUrl"
    Write-LauncherLog "Presentation: $PresentationUrl"

    if (-not (Test-Path $PythonExecutable)) { throw "Project Python environment was not found at $PythonExecutable." }

    $flutterCommand = Get-Command flutter -ErrorAction SilentlyContinue
    if (-not $flutterCommand) { throw 'Flutter executable was not found on PATH.' }
    $FlutterExecutable = $flutterCommand.Source
    Write-LauncherLog "Flutter executable: $FlutterExecutable"

    Write-LauncherLog 'START: Python syntax preflight'
    & $PythonExecutable -m compileall -q src
    if ($LASTEXITCODE -ne 0) { throw 'Python source preflight failed.' }
    Write-LauncherLog 'PASS: Python syntax preflight'

    if (-not (Test-PortAvailable $Port)) { throw "Backend port $Port is already occupied." }
    Write-LauncherLog "Backend port $Port is available."

    $PubspecPath = Join-Path $PresentationRoot 'pubspec.yaml'
    $entrypointPath = Join-Path $PresentationRoot $FlutterEntryPoint
    if (-not (Test-Path $PubspecPath)) { throw "Flutter pubspec.yaml was not found at $PubspecPath." }
    if (-not (Test-Path $entrypointPath)) { throw "Required Flutter entrypoint was not found: $entrypointPath" }
    Write-LauncherLog "Flutter entrypoint confirmed: $FlutterEntryPoint"

    Write-LauncherLog 'START: Resolve Flutter dependencies'
    Push-Location -LiteralPath $PresentationRoot
    try {
        & $FlutterExecutable pub get
        if ($LASTEXITCODE -ne 0) { throw 'flutter pub get failed.' }
        & $FlutterExecutable pub get --enforce-lockfile
        if ($LASTEXITCODE -ne 0) { throw 'flutter pub get --enforce-lockfile failed.' }
    } finally { Pop-Location }
    Write-LauncherLog 'PASS: Resolve Flutter dependencies'

    $backendCommand = @"
@echo off
cd /d "$Root"
set "PYTHONPATH=$(Join-Path $Root 'src')"
echo ============================================================
echo CRITERIVOX BACKEND
echo ============================================================
echo Starting Uvicorn...
echo.
"$PythonExecutable" -u -m uvicorn criterivox.app:app --host 127.0.0.1 --port $Port >> "$BackendLog" 2>&1
echo.
echo Criterivox backend process ended.
echo See "$BackendLog" for output.
pause
"@
    Set-Content -Path $BackendCommandFile -Value $backendCommand -Encoding ASCII

    Write-LauncherLog 'Starting FastAPI/Uvicorn in a visible backend terminal.'
    $BackendTerminal = Start-Process -FilePath 'cmd.exe' -ArgumentList @('/d','/k',$BackendCommandFile) -WorkingDirectory $Root -PassThru
    Write-LauncherLog "Backend terminal started. PID=$($BackendTerminal.Id)"
    Write-LauncherLog "Waiting for backend health: $HealthUrl"

    $ready = $false
    $deadline = [DateTime]::UtcNow.AddSeconds($StartupTimeoutSeconds)
    while ([DateTime]::UtcNow -lt $deadline) {
        Start-Sleep -Milliseconds 500
        if ($BackendTerminal.HasExited) {
            Write-ProcessDiagnostics
            throw "Backend terminal exited before /health became ready. ExitCode=$($BackendTerminal.ExitCode)."
        }
        try {
            $response = Invoke-WebRequest -Uri $HealthUrl -UseBasicParsing -TimeoutSec 1
            if ($response.StatusCode -eq 200) { $ready = $true; break }
        } catch {}
    }

    if (-not $ready) {
        Write-ProcessDiagnostics
        throw "Backend did not become ready at $HealthUrl within $StartupTimeoutSeconds seconds."
    }

    Write-LauncherLog 'PASS: Backend health is ready.'

    Write-LauncherLog "Starting Flutter presentation in Chrome using $FlutterEntryPoint"
    $FlutterCommandLine = """$FlutterExecutable"" run -d chrome --web-port $WebPort -t ""$FlutterEntryPoint"" > ""$FlutterLog"" 2> ""$FlutterErrorLog"""
    $FlutterProcess = Start-Process -FilePath 'cmd.exe' -ArgumentList @('/d','/c',$FlutterCommandLine) -WorkingDirectory $PresentationRoot -PassThru
    Write-LauncherLog "Flutter process started. PID=$($FlutterProcess.Id)"
    Write-LauncherLog "Presentation target: $PresentationUrl"

    Start-Sleep -Seconds 5
    if ($FlutterProcess.HasExited) {
        Write-ProcessDiagnostics
        throw "Flutter presentation exited during startup with code $($FlutterProcess.ExitCode)."
    }

    Write-LauncherLog '============================================================'
    Write-LauncherLog 'CRITERIVOX RUNTIME IS RUNNING'
    Write-LauncherLog '============================================================'
    Write-LauncherLog "Backend: $BackendUrl"
    Write-LauncherLog "Health: $HealthUrl"
    Write-LauncherLog "WebSocket: $WebSocketUrl"
    Write-LauncherLog "Presentation: $PresentationUrl"
    Write-LauncherLog "Flutter entrypoint: $FlutterEntryPoint"

    while ($true) {
        Start-Sleep -Seconds 3
        if ($BackendTerminal.HasExited) {
            Write-ProcessDiagnostics
            throw "Backend process stopped unexpectedly with exit code $($BackendTerminal.ExitCode)."
        }
        try {
            $health = Invoke-WebRequest -Uri $HealthUrl -UseBasicParsing -TimeoutSec 2
            if ($health.StatusCode -ne 200) { throw "Backend health returned HTTP $($health.StatusCode)." }
        } catch { throw "Backend health check failed while runtime was active: $($_.Exception.Message)" }
        if ($FlutterProcess.HasExited) {
            Write-ProcessDiagnostics
            throw "Flutter presentation stopped unexpectedly with code $($FlutterProcess.ExitCode)."
        }
    }
}
catch {
    $message = $_.Exception.Message
    Write-LauncherLog "CRITICAL runtime failure: $message"
    Write-ProcessDiagnostics
    $stage = if ($message -match 'Backend .*ready|Backend terminal exited|backend health') { 'backend_readiness' } elseif ($message -match 'Flutter presentation') { 'flutter_startup' } else { 'managed_startup_or_runtime' }
    New-Incident -Stage $stage -Expected 'Python backend reaches /health, WebSocket endpoint is available, and Flutter launches lib/app/main.dart in Chrome.' -Observed $message -Recommendation 'No Python import probe is used. Uvicorn itself imports criterivox.app. Stale runtime logs are cleared at startup, backend output is captured from the real Uvicorn process, and incident classification is based on the failed stage before log-content heuristics.'
    exit 1
}
finally {
    if ($FlutterProcess -and -not $FlutterProcess.HasExited) { Stop-ProcessTree $FlutterProcess.Id }
    if ($BackendTerminal -and -not $BackendTerminal.HasExited) { Stop-ProcessTree $BackendTerminal.Id }
}
