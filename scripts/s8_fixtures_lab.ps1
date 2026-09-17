$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location (Split-Path -Parent $Root)
$env:PYTHONPATH = Join-Path (Get-Location) 'src'
python (Join-Path (Get-Location) 'scripts/s8_fixtures_lab.py')
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
