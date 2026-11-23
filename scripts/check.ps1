$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
foreach ($project in @('packages/school_data','apps/admin_windows','apps/mobile')) {
  Push-Location (Join-Path $root $project)
  try {
    flutter pub get; if ($LASTEXITCODE) { throw 'pub get failed' }
    flutter analyze; if ($LASTEXITCODE) { throw 'analyze failed' }
    flutter test; if ($LASTEXITCODE) { throw 'test failed' }
  } finally { Pop-Location }
}
Push-Location (Join-Path $root 'services/demo_api')
try { py -3 -m unittest -v; if ($LASTEXITCODE) { throw 'API tests failed' } } finally { Pop-Location }
