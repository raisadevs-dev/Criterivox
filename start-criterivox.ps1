# Criterivox managed runtime launcher
$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$DiagnosticsRoot = Join-Path $Root 'diagnostics'
$RuntimeLog = Join-Path $DiagnosticsRoot 'runtime.log'
$BackendLog = Join-Path $DiagnosticsRoot 'python-runtime.log'
$BackendErrorLog = Join-Path $DiagnosticsRoot 'python-runtime-error.log'
$FlutterLog = Join-Path $DiagnosticsRoot 'flutter-runtime.log'
$FlutterErrorLog = Join-Path $DiagnosticsRoot 'flutter-runtime-error.log'
$BackendTerminalScript = Join-Path $DiagnosticsRoot 'run-backend.ps1'
$ImportProbeScript = Join-Path $DiagnosticsRoot 'python-import-probe.py'
$BackendTerminal = $null
$FlutterProcess = $null

$Port = if ($env:CRITERIVOX_BACKEND_PORT) { $env:CRITERIVOX_BACKEND_PORT } else { '8000' }
$WebPort = if ($env:CRITERIVOX_WEB_PORT) { $env:CRITERIVOX_WEB_PORT } else { '8080' }
$StartupTimeoutSeconds = if ($env:CRITERIVOX_BACKEND_STARTUP_TIMEOUT_SECONDS) { [int]$env:CRITERIVOX_BACKEND_STARTUP_TIMEOUT_SECONDS } else { 90 }
$ImportTimeoutSeconds = if ($env:CRITERIVOX_BACKEND_IMPORT_TIMEOUT_SECONDS) { [int]$env:CRITERIVOX_BACKEND_IMPORT_TIMEOUT_SECONDS } else { 45 }

$BackendUrl = "http://127.0.0.1:$Port"
$HealthUrl = "$BackendUrl/health"
$WebSocketUrl = "ws://127.0.0.1:$Port/runtime/characters"
$PresentationUrl = "http://127.0.0.1:$WebPort"
$PresentationRoot = Join-Path $Root 'presentation'
$FlutterEntryPoint = 'lib/app/main.dart'
$FlutterExecutable = $null
$PythonExecutable = Join-Path $Root '.venv\Scripts\python.exe'

New-Item -ItemType Directory -Force -Path $DiagnosticsRoot | Out-Null
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
        $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $PortNumber)
        $listener.Start()
        return $true
    } catch {
        return $false
    } finally {
        if ($listener) { $listener.Stop() }
    }
}

function Stop-ProcessTree([int]$ProcessId) {
    if ($ProcessId -le 0) { return }
    try { & taskkill.exe /PID $ProcessId /T /F 2>$null | Out-Null } catch {}
}

function Write-ProcessDiagnostics {
    foreach ($log in @($BackendLog, $BackendErrorLog)) {
        if (Test-Path $log) {
            $lines = @(Get-Content $log -ErrorAction SilentlyContinue)
            if ($lines.Count -gt 0) {
                Write-LauncherLog "Captured $(Split-Path $log -Leaf) with $($lines.Count) line(s)."
                foreach ($line in ($lines | Select-Object -Last 40)) { Write-LauncherLog "PYTHON: $line" }
            } else {
                Write-LauncherLog "$(Split-Path $log -Leaf) is empty."
            }
        }
    }
}

function Get-RootCauseClassification([string]$Message) {
    $backendText = ''
    $flutterText = ''
    if (Test-Path $BackendLog) { $backendText += Get-Content $BackendLog -Raw -ErrorAction SilentlyContinue }
    if (Test-Path $BackendErrorLog) { $backendText += Get-Content $BackendErrorLog -Raw -ErrorAction SilentlyContinue }
    if (Test-Path $FlutterErrorLog) { $flutterText = Get-Content $FlutterErrorLog -Raw -ErrorAction SilentlyContinue }
    $combined = $Message + [Environment]::NewLine + $backendText + [Environment]::NewLine + $flutterText

    if ($combined -match 'SyntaxError|IndentationError|TabError') { return 'PYTHON_SYNTAX_FAILURE' }
    if ($combined -match 'ModuleNotFoundError|ImportError|cannot import name') { return 'PYTHON_IMPORT_FAILURE' }
    if ($combined -match 'Address already in use|Only one usage|port .* already') { return 'BACKEND_PORT_CONFLICT' }
    if ($combined -match 'uvicorn|Python runtime|backend') { return 'BACKEND_STARTUP_FAILURE' }
    if ($combined -match 'Target file .*lib[\\/]main\.dart.*not found') { return 'FLUTTER_ENTRYPOINT_MISSING' }
    if ($combined -match 'Flutter dependency|version solving failed|pubspec\.yaml') { return 'FLUTTER_DEPENDENCY_FAILURE' }
    if ($combined -match 'Chrome.*not found|No devices found|unable to find a device') { return 'CHROME_RUNTIME_MISSING' }
    if ($combined -match 'WebSocket|websocket|handshake') { return 'WEBSOCKET_RUNTIME_FAILURE' }
    return 'UNCLASSIFIED_RUNTIME_FAILURE'
}

function New-Incident([string]$Stage, [string]$Expected, [string]$Observed, [string]$Recommendation) {
    $classification = Get-RootCauseClassification $Observed
    $id = "CVX-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    $dir = Join-Path $DiagnosticsRoot "incident-$id"
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    $pythonVersion = if (Test-Path $PythonExecutable) { (& $PythonExecutable --version 2>&1 | Out-String).Trim() } else { 'project .venv Python not found' }
    $flutterVersion = if ($FlutterExecutable) { (& $FlutterExecutable --version 2>&1 | Select-Object -First 1 | Out-String).Trim() } else { 'Flutter not found' }

    $payload = [ordered]@{
        incident_id = $id
        timestamp = (Get-Date).ToString('o')
        severity = 'critical'
        stage = $Stage
        component = 'criterivox_runtime_host'
        root_cause_classification = $classification
        expected = $Expected
        observed = $Observed
        runtime = [ordered]@{
            working_directory = $Root
            python = $pythonVersion
            flutter = $flutterVersion
            backend = $BackendUrl
            health = $HealthUrl
            websocket = $WebSocketUrl
            presentation = $PresentationUrl
            flutter_entrypoint = $FlutterEntryPoint
            import_timeout_seconds = $ImportTimeoutSeconds
            backend_startup_timeout_seconds = $StartupTimeoutSeconds
        }
        evidence = [ordered]@{
            launcher_log = $RuntimeLog
            backend_stdout = $BackendLog
            backend_stderr = $BackendErrorLog
            flutter_stdout = $FlutterLog
            flutter_stderr = $FlutterErrorLog
            import_probe = $ImportProbeScript
        }
        recommendation = $Recommendation
    }
    $payload | ConvertTo-Json -Depth 8 | Set-Content (Join-Path $dir 'incident.json') -Encoding UTF8
    Write-LauncherLog "Developer incident created: $dir"
}

try {
    Set-Location $Root
    $env:PYTHONPATH = Join-Path $Root 'src'

    if (-not (Test-Path $PythonExecutable)) { throw "Project Python environment was not found at $PythonExecutable." }

    $flutterCommand = Get-Command flutter -ErrorAction SilentlyContinue
    if (-not $flutterCommand) { throw 'Flutter executable was not found on PATH.' }
    $FlutterExecutable = $flutterCommand.Source
    Write-LauncherLog "Flutter executable: $FlutterExecutable"

    Write-LauncherLog 'START: Python syntax preflight'
    & $PythonExecutable -m compileall -q src
    if ($LASTEXITCODE -ne 0) { throw 'Python source preflight failed.' }
    Write-LauncherLog 'PASS: Python syntax preflight'

    Write-LauncherLog 'START: Python application import preflight'
    $ImportProbeLog = Join-Path $DiagnosticsRoot 'python-import-probe.log'
    $ImportProbeErrorLog = Join-Path $DiagnosticsRoot 'python-import-probe-error.log'
    Remove-Item $ImportProbeLog,$ImportProbeErrorLog -Force -ErrorAction SilentlyContinue

    @"
import criterivox.app
print("CRITERIVOX_APP_IMPORT_OK")
"@ | Set-Content $ImportProbeScript -Encoding UTF8

    $probe = Start-Process -FilePath $PythonExecutable -ArgumentList @('-u', $ImportProbeScript) -WorkingDirectory $Root -RedirectStandardOutput $ImportProbeLog -RedirectStandardError $ImportProbeErrorLog -PassThru

    if (-not $probe.WaitForExit($ImportTimeoutSeconds * 1000)) {
        Stop-ProcessTree $probe.Id
        throw "Python application import did not finish within $ImportTimeoutSeconds seconds. See $ImportProbeLog and $ImportProbeErrorLog."
    }

    $probeOutput = if (Test-Path $ImportProbeLog) { Get-Content $ImportProbeLog -Raw -ErrorAction SilentlyContinue } else { '' }
    $probeError = if (Test-Path $ImportProbeErrorLog) { Get-Content $ImportProbeErrorLog -Raw -ErrorAction SilentlyContinue } else { '' }
    if ($probe.ExitCode -ne 0) { throw "Python application import failed with exit code $($probe.ExitCode). stdout=$probeOutput stderr=$probeError" }
    if ($probeOutput -notmatch 'CRITERIVOX_APP_IMPORT_OK') { throw "Python application import completed without its success marker. stdout=$probeOutput stderr=$probeError" }
    Write-LauncherLog 'PASS: Python application import preflight'

    if (-not (Test-PortAvailable ([int]$Port))) { throw "Backend port $Port is already occupied." }

    if (-not (Test-Path (Join-Path $PresentationRoot 'pubspec.yaml'))) { throw "Flutter pubspec.yaml was not found under $PresentationRoot." }
    $entrypointPath = Join-Path $PresentationRoot $FlutterEntryPoint
    if (-not (Test-Path $entrypointPath)) { throw "Required Flutter entrypoint $FlutterEntryPoint was not found." }
    Write-LauncherLog "Flutter entrypoint fixed to $FlutterEntryPoint."

    Write-LauncherLog 'START: Resolve Flutter dependencies'
    Push-Location $PresentationRoot
    try {
        & $FlutterExecutable pub get
        if ($LASTEXITCODE -ne 0) { throw 'flutter pub get failed.' }
        & $FlutterExecutable pub get --enforce-lockfile
        if ($LASTEXITCODE -ne 0) { throw 'flutter pub get --enforce-lockfile failed.' }
    } finally { Pop-Location }
    Write-LauncherLog 'PASS: Resolve Flutter dependencies'

    @"
Set-Location -LiteralPath '$Root'
& '$PythonExecutable' -u -m uvicorn criterivox.app:app --host 127.0.0.1 --port $Port 2>&1 |
    Tee-Object -FilePath '$BackendLog' -Append
Write-Host ''
Write-Host 'Criterivox backend process ended. The terminal remains open for diagnosis.'
"@ | Set-Content $BackendTerminalScript -Encoding UTF8

    Write-LauncherLog "Starting FastAPI backend in a visible terminal: $BackendUrl"
    $BackendTerminal = Start-Process -FilePath 'pwsh.exe' -ArgumentList @('-NoLogo','-NoExit','-ExecutionPolicy','Bypass','-File',$BackendTerminalScript) -WorkingDirectory $Root -PassThru
    Write-LauncherLog "Backend terminal started. PID=$($BackendTerminal.Id)"
    Write-LauncherLog "Waiting for backend health: $HealthUrl"

    $ready = $false
    $deadline = [DateTime]::UtcNow.AddSeconds($StartupTimeoutSeconds)
    while ([DateTime]::UtcNow -lt $deadline) {
        Start-Sleep -Milliseconds 500
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
    $FlutterProcess = Start-Process -FilePath $FlutterExecutable -ArgumentList @('run','-d','chrome','--web-port',$WebPort,'-t',$FlutterEntryPoint) -WorkingDirectory $PresentationRoot -RedirectStandardOutput $FlutterLog -RedirectStandardError $FlutterErrorLog -PassThru
    Write-LauncherLog "Flutter process started. PID=$($FlutterProcess.Id)"
    Write-LauncherLog "Presentation target: $PresentationUrl"

    Start-Sleep -Seconds 5
    if ($FlutterProcess.HasExited) { throw "Flutter presentation exited during startup with code $($FlutterProcess.ExitCode)." }

    Write-LauncherLog 'Criterivox runtime is running. Chrome presentation is being served by Flutter.'
    Write-LauncherLog "Backend: $BackendUrl"
    Write-LauncherLog "Health: $HealthUrl"
    Write-LauncherLog "WebSocket: $WebSocketUrl"
    Write-LauncherLog "Presentation: $PresentationUrl"
    Write-LauncherLog "Entrypoint: $FlutterEntryPoint"

    while ($true) {
        Start-Sleep -Seconds 3
        try {
            $health = Invoke-WebRequest -Uri $HealthUrl -UseBasicParsing -TimeoutSec 2
            if ($health.StatusCode -ne 200) { throw "Backend health returned HTTP $($health.StatusCode)." }
        } catch { throw "Backend health check failed while runtime was active: $($_.Exception.Message)" }
        if ($FlutterProcess.HasExited) { throw "Flutter presentation stopped unexpectedly with code $($FlutterProcess.ExitCode)." }
    }
}
catch {
    $message = $_.Exception.Message
    Write-LauncherLog "CRITICAL runtime failure: $message"
    Write-ProcessDiagnostics
    New-Incident -Stage 'managed_startup_or_runtime' -Expected 'Python backend reaches /health, WebSocket endpoint is available, and Flutter launches lib/app/main.dart in Chrome.' -Observed $message -Recommendation 'The launcher uses a file-based bounded application-import probe, fixes the Flutter entrypoint to lib/app/main.dart, keeps the backend terminal visible, captures backend output, and records the exact failed boundary.' 
    exit 1
}
finally {
    if ($FlutterProcess -and -not $FlutterProcess.HasExited) { Stop-ProcessTree $FlutterProcess.Id }
    if ($BackendTerminal) { Stop-ProcessTree $BackendTerminal.Id }
}
