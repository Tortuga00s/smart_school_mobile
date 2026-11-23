param([switch]$RunChrome, [string]$TestApi = 'http://127.0.0.1:8181')
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Push-Location (Join-Path $root 'apps/mobile')
try {
  flutter pub get; if ($LASTEXITCODE) { throw 'pub get failed' }
  flutter analyze; if ($LASTEXITCODE) { throw 'analyze failed' }
  flutter test; if ($LASTEXITCODE) { throw 'test failed' }
  flutter build web --release --no-web-resources-cdn --dart-define=DEMO_API_URL=http://127.0.0.1:8080
  if ($LASTEXITCODE) { throw 'web build failed' }
  if ($RunChrome) {
    # Start the demo backend with a NEW disposable state file first; see guide.
    $health = Invoke-RestMethod -Uri "$TestApi/health"
    if ($health.mode -ne 'DEMO_LOCAL_ONLY') { throw 'Refusing test writes outside the demo API' }
    flutter test --platform chrome test/browser/web_smoke_test.dart "--dart-define=DEMO_API_URL=$TestApi" "--dart-define=BROWSER_DEMO_API_URL=$TestApi" --reporter expanded
    if ($LASTEXITCODE) { throw 'Chrome tests failed' }
  }
} finally { Pop-Location }
