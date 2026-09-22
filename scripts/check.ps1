$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$appDirectory = Join-Path $repositoryRoot 'app'
$pubspecPath = Join-Path $appDirectory 'pubspec.yaml'

$requiredFiles = @(
    'README.md',
    'AGENTS.md',
    '.gitignore',
    '.env.example',
    'docs/PRODUCT.md',
    'docs/ARCHITECTURE.md',
    'docs/DISCOVERY.md',
    'docs/ROADMAP.md',
    'docs/DECISIONS.md',
    'docs/HANDOFF.md',
    'assets/references/jevpet-room-concept-v1.png',
    'assets/references/README.md'
)

Write-Host 'Checking required project files...'
foreach ($relativePath in $requiredFiles) {
    $absolutePath = Join-Path $repositoryRoot $relativePath
    if (-not (Test-Path -LiteralPath $absolutePath)) {
        throw "Missing required file: $relativePath"
    }
}

Push-Location $repositoryRoot
try {
    Write-Host 'Checking Git whitespace errors...'
    git diff --check

    if (Test-Path -LiteralPath $pubspecPath) {
        if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
            throw 'Flutter project exists, but flutter was not found in PATH.'
        }

        Push-Location $appDirectory
        try {
            Write-Host 'Running Flutter analysis...'
            flutter analyze

            Write-Host 'Running Flutter tests...'
            flutter test
        }
        finally {
            Pop-Location
        }
    }
    else {
        Write-Host 'Flutter project is not initialized; skipping analyze and tests.'
    }
}
finally {
    Pop-Location
}

Write-Host 'Project checks passed.'
