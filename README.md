# Quan Ly Sinh Vien

## Chay app on dinh (local)

Yeu cau:
- Flutter stable channel
- Dart SDK theo Flutter stable

Chay nhanh:

```powershell
flutter pub get
flutter run -d chrome
```

Neu bi loi sau khi pull code:

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

## Script kiem tra truoc khi push

Da co script:

```powershell
./scripts/validate.ps1
```

Kiem tra muc release (co build web):

```powershell
./scripts/validate.ps1 -RunWebBuild
```

## Git workflow cho nhom

Tai lieu day du:
- [docs/TEAM_WORKFLOW.md](docs/TEAM_WORKFLOW.md)

Tom tat:
- Nhanh chinh: `main` (on dinh), `develop` (hop nhat)
- Moi thanh vien lam tren nhanh rieng: `feature/<member>-<topic>`
- Tao Pull Request vao `develop`, nguoi review xac nhan va moi merge
- Team lead merge `develop` -> `main` sau khi kiem thu

## Mau PR

Template PR da co tai:
- [.github/pull_request_template.md](.github/pull_request_template.md)
