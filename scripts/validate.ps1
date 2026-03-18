param(
  [switch]$SkipClean,
  [switch]$RunWebBuild
)

$ErrorActionPreference = 'Stop'

if (-not $SkipClean) {
  flutter clean
}

flutter pub get
flutter analyze
flutter test

if ($RunWebBuild) {
  flutter build web --release
}

Write-Host "Validation passed." -ForegroundColor Green
