param(
  [switch]$SkipVersionCheck
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$PinnedFlutterMajorMinor = "3.27."

Write-Host "[bootstrap] Checking Flutter version..."
$flutterVersionOutput = flutter --version
if (-not $flutterVersionOutput) {
  throw "[bootstrap] Flutter not found in PATH."
}

$firstLine = ($flutterVersionOutput | Select-Object -First 1)
if (-not $SkipVersionCheck -and $firstLine -notlike "*Flutter $PinnedFlutterMajorMinor*") {
  throw "[bootstrap] Expected Flutter 3.27.x, got: $firstLine"
}

Write-Host "[bootstrap] Ensuring .env exists..."
if (-not (Test-Path ".env")) {
  Copy-Item ".env.example" ".env"
  Write-Host "[bootstrap] .env created from .env.example"
}

Write-Host "[bootstrap] Resolving dependencies from lockfile..."
flutter pub get --enforce-lockfile

Write-Host "[bootstrap] Generating l10n..."
flutter gen-l10n

Write-Host "[bootstrap] Running codegen..."
dart run build_runner build --delete-conflicting-outputs

Write-Host "[bootstrap] Running static analysis..."
flutter analyze --no-fatal-infos

Write-Host "[bootstrap] Running tests..."
flutter test

Write-Host "[bootstrap] Done."
