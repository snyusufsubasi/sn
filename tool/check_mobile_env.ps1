$ErrorActionPreference = "Continue"

function Section($title) {
  Write-Host ""
  Write-Host "== $title =="
}

function Run($label, $command) {
  Write-Host ""
  Write-Host "[$label]"
  Invoke-Expression $command
}

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

$androidSdk = $env:ANDROID_HOME
if (-not $androidSdk) {
  $androidSdk = Join-Path $env:LOCALAPPDATA "Android\Sdk"
}

$paths = @(
  "C:\Program Files\GitHub CLI",
  "C:\Program Files\Android\Android Studio\jbr\bin",
  "$androidSdk\platform-tools",
  "$androidSdk\emulator",
  "$androidSdk\cmdline-tools\latest\bin",
  "$env:USERPROFILE\tools\supabase"
)

$env:Path = (($paths | Where-Object { Test-Path $_ }) -join ";") + ";" + $env:Path

Section "Repo"
Run "git status" "git status --short --branch"
Run "git remote" "git remote -v"

Section "Tools"
Run "GitHub CLI" "gh --version; gh auth status"
Run "Supabase CLI" "supabase --version"
Run "Java" "java -version"
Run "ADB" "adb version; adb devices"
Run "Emulator" "emulator -list-avds"
Run "SDK Manager" "sdkmanager --version"

Section "Android Build"
Run "assembleDebug" ".\android\gradlew.bat -p native\android assembleDebug"

Write-Host ""
Write-Host "Done."
