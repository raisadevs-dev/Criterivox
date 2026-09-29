param(
  [switch]$NoFlutter,
  [switch]$Fixtures
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

Write-Host 'CRITERIVOX — S8 EVIDENCE RESEARCH BUREAU' -ForegroundColor Cyan
Write-Host 'Standalone research environment. Main Criterivox shell is not started.' -ForegroundColor DarkGray

$env:PYTHONPATH = Join-Path $Root 'src'

if ($Fixtures) {
  python (Join-Path $Root 'scripts/s8_fixtures_lab.py')
  exit $LASTEXITCODE
}

if (-not $NoFlutter) {
  Push-Location (Join-Path $Root 'presentation')
  try {
    flutter run -t lib/s8_main.dart
  } finally {
    Pop-Location
  }
} else {
  python -m criterivox.s8.standalone
}
