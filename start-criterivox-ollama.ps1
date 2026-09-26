# Criterivox managed runtime launcher
$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$DiagnosticsRoot = Join-Path $Root 'diagnostics'
$RuntimeLog = Join-Path $DiagnosticsRoot 'runtime.log'
$BackendLog = Join-Path $DiagnosticsRoot 'python-runtime.log'
$BackendErrorLog = Join-Path $DiagnosticsRoot 'python-runtime-error.log'
$FlutterLog = Join-Path $DiagnosticsRoot 'flutter-runtime.log'
$FlutterErrorLog = Join-Path $DiagnosticsRoot 'flutter-runtime-error.log'

$Port = if ($env:CRITERIVOX_BACKEND_PORT) { $env:CRITERIVOX_BACKEND_PORT } else { '8000' }
$WebPort = if ($env:CRITERIVOX_WEB_PORT) { $env:CRITERIVOX_WEB_PORT } else { '8080' }
$StartupTimeoutSeconds = if ($env:CRITERIVOX_BACKEND_STARTUP_TIMEOUT_SECONDS) { [int]$env:CRITERIVOX_BACKEND_STARTUP_TIMEOUT_SECONDS } else { 60 }

$BackendUrl = "http://127.0.0.1:$Port"
$HealthUrl = "$BackendUrl/health"
$PresentationUrl = "http://127.0.0.1:$WebPort"
$PythonExecutable = Join-Path $Root '.venv\Scripts\python.exe'
$OllamaModel = if ($env:CRITERIVOX_LOCAL_LLM_MODEL) { $env:CRITERIVOX_LOCAL_LLM_MODEL } else { 'llama3.2:3b' }
$OllamaUrl = if ($env:CRITERIVOX_LOCAL_LLM_URL) { $env:CRITERIVOX_LOCAL_LLM_URL } else { 'http://127.0.0.1:11434/api/chat' }
$OllamaTagsUrl = 'http://127.0.0.1:11434/api/tags'
$OllamaInstallScript = 'https://ollama.com/install.ps1'

New-Item -ItemType Directory -Force -Path $DiagnosticsRoot | Out-Null
"[$(Get-Date -Format o)] Criterivox launcher starting." | Set-Content $RuntimeLog
$PythonProcess = $null
$FlutterProcess = $null

function Write-LauncherLog([string]$Message) {
    "[$(Get-Date -Format o)] $Message" | Tee-Object -FilePath $RuntimeLog -Append
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


function Test-OllamaApi() {
    try {
        $response = Invoke-WebRequest -Uri $OllamaTagsUrl -UseBasicParsing -TimeoutSec 2
        return ($response.StatusCode -eq 200)
    } catch {
        return $false
    }
}

function Test-OllamaModel([string]$Model) {
    try {
        $response = Invoke-WebRequest -Uri $OllamaTagsUrl -UseBasicParsing -TimeoutSec 3
        if ($response.StatusCode -ne 200) { return $false }
        $payload = $response.Content | ConvertFrom-Json
        foreach ($item in @($payload.models)) {
            if ([string]$item.name -eq $Model) { return $true }
        }
        return $false
    } catch {
        return $false
    }
}

function Ensure-OllamaRuntime() {
    Write-LauncherLog "Checking local model runtime: Ollama."
    $ollamaCommand = Get-Command ollama -ErrorAction SilentlyContinue

    if (-not $ollamaCommand) {
        Write-LauncherLog 'Ollama is not installed. Attempting automatic installation from the official Ollama installer.'
        $winget = Get-Command winget -ErrorAction SilentlyContinue

        if ($winget) {
            & $winget.Source install --id Ollama.Ollama --exact --accept-package-agreements --accept-source-agreements
            if ($LASTEXITCODE -ne 0) {
                throw "Automatic Ollama installation through winget failed with exit code $LASTEXITCODE."
            }
        } else {
            Write-LauncherLog 'winget is unavailable. Falling back to the official Ollama PowerShell installer.'
            $install = Invoke-RestMethod -Uri $OllamaInstallScript -UseBasicParsing
            if (-not $install) {
                throw 'The official Ollama installer returned no content.'
            }
            & ([scriptblock]::Create($install))
            if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) {
                throw "The official Ollama installer failed with exit code $LASTEXITCODE."
            }
        }

        $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')
        $ollamaCommand = Get-Command ollama -ErrorAction SilentlyContinue
        if (-not $ollamaCommand) {
            throw 'Ollama installation completed but the ollama executable is not available on PATH yet.'
        }

        Write-LauncherLog "Ollama installed: $($ollamaCommand.Source)"
    } else {
        Write-LauncherLog "Ollama already installed: $($ollamaCommand.Source)"
    }

    if (-not (Test-OllamaApi)) {
        Write-LauncherLog 'Ollama service is not ready. Starting the local Ollama service.'
        $ollamaProcess = Start-Process -FilePath $ollamaCommand.Source -ArgumentList @('serve') -WorkingDirectory $Root -RedirectStandardOutput (Join-Path $DiagnosticsRoot 'ollama-runtime.log') -RedirectStandardError (Join-Path $DiagnosticsRoot 'ollama-runtime-error.log') -PassThru -WindowStyle Minimized

        $ollamaDeadline = [DateTime]::UtcNow.AddSeconds(45)
        while ([DateTime]::UtcNow -lt $ollamaDeadline) {
            Start-Sleep -Milliseconds 500
            if ($ollamaProcess.HasExited) {
                throw "Ollama service exited during startup with code $($ollamaProcess.ExitCode)."
            }
            if (Test-OllamaApi) { break }
        }

        if (-not (Test-OllamaApi)) {
            throw "Ollama did not become ready at $OllamaTagsUrl within 45 seconds."
        }
    }

    Write-LauncherLog "Ollama service is ready. Checking model '$OllamaModel'."

    if (-not (Test-OllamaModel $OllamaModel)) {
        Write-LauncherLog "Model '$OllamaModel' is missing. Pulling it automatically. This may take a while on the first launch."
        & $ollamaCommand.Source pull $OllamaModel 2>&1 | Tee-Object -FilePath (Join-Path $DiagnosticsRoot 'ollama-model-pull.log')
        if ($LASTEXITCODE -ne 0) {
            throw "Ollama model '$OllamaModel' could not be downloaded. See diagnostics/ollama-model-pull.log."
        }
    }

    if (-not (Test-OllamaModel $OllamaModel)) {
        throw "Ollama reported a successful model pull, but '$OllamaModel' is not available through $OllamaTagsUrl."
    }

    Write-LauncherLog "Local model '$OllamaModel' is ready."
}
 
function Write-ProcessDiagnostics([System.Diagnostics.Process]$Process) {
    if (-not $Process) { return }

    try {
        if ($Process.HasExited) {
            Write-LauncherLog "Python process exited with code $($Process.ExitCode)."
        } else {
            Write-LauncherLog "Python process is still running after readiness timeout. PID=$($Process.Id)."
        }
    } catch {
        Write-LauncherLog "Unable to inspect Python process state: $($_.Exception.Message)"
    }

    foreach ($log in @($BackendLog, $BackendErrorLog)) {
        if (Test-Path $log) {
            $lines = @(Get-Content $log -ErrorAction SilentlyContinue)
            if ($lines.Count -gt 0) {
                Write-LauncherLog "Captured $(Split-Path $log -Leaf) with $($lines.Count) line(s)."
                foreach ($line in ($lines | Select-Object -Last 30)) {
                    Write-LauncherLog "PYTHON: $line"
                }
            } else {
                Write-LauncherLog "$(Split-Path $log -Leaf) is empty."
            }
        }
    }
}

function New-Incident([string]$Stage, [string]$Expected, [string]$Observed, [string]$Recommendation) {
    $id = "CVX-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    $dir = Join-Path $DiagnosticsRoot "incident-$id"
    New-Item -ItemType Directory -Force -Path $dir | Out-Null

    $pythonVersion = if (Test-Path $PythonExecutable) { (& $PythonExecutable --version 2>&1 | Out-String).Trim() } else { 'project .venv Python not found' }
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
            backend_startup_timeout_seconds = $StartupTimeoutSeconds
        }
        evidence = [ordered]@{
            launcher_log = $RuntimeLog
            python_log = $BackendLog
            python_error_log = $BackendErrorLog
            flutter_log = $FlutterLog
            flutter_error_log = $FlutterErrorLog
        }
        recommended_investigation = $Recommendation
    }

    $payload | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $dir 'incident.json') -Encoding UTF8

    @"
# Criterivox Runtime Incident

- Incident ID: $id
- Time: $($payload.timestamp)
- Severity: CRITICAL
- Stage: $Stage

## Expected
$Expected

## Observed
$Observed

## Failure story
The managed runtime startup sequence did not reach its expected readiness condition. The launcher captured process state and available stdout/stderr for diagnosis.

## Affected boundary
$($payload.affected_boundary)

## User-visible consequence
$($payload.user_visible_effect)

## Evidence
- Launcher: $RuntimeLog
- Python stdout: $BackendLog
- Python stderr: $BackendErrorLog
- Flutter stdout: $FlutterLog
- Flutter stderr: $FlutterErrorLog

## Recommended investigation
$Recommendation

## Runtime environment
- Python: $pythonVersion
- Flutter: $flutterVersion
- Backend: $BackendUrl
- Presentation: $PresentationUrl
- Backend startup timeout: $StartupTimeoutSeconds seconds
"@ | Set-Content (Join-Path $dir 'incident.md') -Encoding UTF8

    Write-LauncherLog "Developer incident created: $dir"
}

try {
    Set-Location $Root
    $env:PYTHONPATH = Join-Path $Root 'src'

    if (-not (Test-Path $PythonExecutable)) {
        throw "Project Python environment was not found at $PythonExecutable. Run the documented environment setup first."
    }

    if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
        throw 'Flutter executable was not found on PATH.'
    }

    Write-LauncherLog 'Preparing the local intelligence runtime before starting Criterivox.'
    if (-not $env:CRITERIVOX_LLM_PROVIDER) { $env:CRITERIVOX_LLM_PROVIDER = 'local' }
    if (-not $env:CRITERIVOX_LOCAL_LLM_URL) { $env:CRITERIVOX_LOCAL_LLM_URL = $OllamaUrl }
    if (-not $env:CRITERIVOX_LOCAL_LLM_MODEL) { $env:CRITERIVOX_LOCAL_LLM_MODEL = $OllamaModel }
    Ensure-OllamaRuntime

    Write-LauncherLog 'Running Python syntax preflight before starting the backend.'
    & $PythonExecutable -m compileall -q src
    if ($LASTEXITCODE -ne 0) {
        throw 'Python source preflight failed. The backend was not started.'
    }

    Write-LauncherLog 'Python source preflight passed.'

    if (-not (Test-PortAvailable ([int]$Port))) {
        throw "Backend port $Port is already occupied. Stop the process using $BackendUrl or set CRITERIVOX_BACKEND_PORT to another free port."
    }

    Write-LauncherLog "Backend port $Port is available."
    Write-LauncherLog "Starting Python runtime on $BackendUrl using project .venv."
    Write-LauncherLog "Backend readiness timeout: $StartupTimeoutSeconds seconds."

    $PythonProcess = Start-Process -FilePath $PythonExecutable -ArgumentList @('-u','-m','uvicorn','criterivox.app:app','--host','127.0.0.1','--port',$Port) -WorkingDirectory $Root -RedirectStandardOutput $BackendLog -RedirectStandardError $BackendErrorLog -PassThru -WindowStyle Minimized

    $ready = $false
    $deadline = [DateTime]::UtcNow.AddSeconds($StartupTimeoutSeconds)

    while ([DateTime]::UtcNow -lt $deadline) {
        Start-Sleep -Milliseconds 500

        if ($PythonProcess.HasExited) {
            Write-ProcessDiagnostics $PythonProcess
            throw "Python runtime exited during startup with code $($PythonProcess.ExitCode)."
        }

        try {
            $response = Invoke-WebRequest -Uri $HealthUrl -UseBasicParsing -TimeoutSec 1
            if ($response.StatusCode -eq 200) {
                $ready = $true
                break
            }
        } catch {
        }
    }

    if (-not $ready) {
        Write-ProcessDiagnostics $PythonProcess
        throw "Python runtime did not become ready at $HealthUrl within $StartupTimeoutSeconds seconds."
    }

    Write-LauncherLog 'Python runtime is ready.'
    Write-LauncherLog "Starting Flutter presentation on $PresentationUrl."

    $FlutterProcess = Start-Process -FilePath 'flutter' -ArgumentList @('run','-d','chrome','--web-port',$WebPort) -WorkingDirectory (Join-Path $Root 'presentation') -RedirectStandardOutput $FlutterLog -RedirectStandardError $FlutterErrorLog -PassThru -WindowStyle Minimized

    Start-Sleep -Seconds 3

    if ($FlutterProcess.HasExited) {
        throw "Flutter presentation exited during startup with code $($FlutterProcess.ExitCode)."
    }

    Write-LauncherLog 'Criterivox runtime is running. Flutter will open the presentation in Chrome.'
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

    New-Incident -Stage 'managed_startup_or_runtime' -Expected 'Python and Flutter remain running under the Criterivox runtime host.' -Observed $message -Recommendation 'Inspect incident.md first. The launcher records Python process state and stdout/stderr, uses unbuffered Python output, checks backend-port conflicts before startup, and measures the actual readiness deadline.'

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