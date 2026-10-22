# Dumpling Service

The backend of dumpling, on [Winter](https://pub.dev/packages/winter). It runs the backup schedules
and serves the console's web build as static files (every unknown route answers `index.html`, so
the console's routes work on reload).

```bash
cd console && fvm flutter build web && cd ..
cd service && fvm dart run lib/main.dart   # http://localhost:8080
```
