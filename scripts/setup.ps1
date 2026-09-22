$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$appDirectory = Join-Path $repositoryRoot 'app'
$pubspecPath = Join-Path $appDirectory 'pubspec.yaml'

Write-Host 'Checking Git...'
git --version

$flutterCommand = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterCommand) {
    throw 'Flutter was not found in PATH. Install Flutter stable and reopen the terminal.'
}

Write-Host 'Checking Flutter...'
flutter --version

if (Test-Path -LiteralPath $pubspecPath) {
    Write-Host 'Installing Flutter dependencies...'
    Push-Location $appDirectory
    try {
        flutter pub get
    }
    finally {
        Pop-Location
    }
}
else {
    Write-Host 'The Flutter app is not initialized yet.'
    Write-Host 'Next command:'
    Write-Host '  cd app'
    Write-Host '  flutter create --platforms=android,windows,web --org com.xiongzhenglong .'
}

Write-Host 'Environment check finished.'
