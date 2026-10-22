# Dumpling Console

The web UI of dumpling, in Flutter Web. It is not deployed on its own: the service serves its
build (`console/build/web`) as static files.

```bash
fvm flutter pub get
fvm flutter build web     # then start the service
fvm flutter run -d chrome # or alone, for UI work
```

Structure (same as the rest of the project): `config/` (theme, routes), `design_system/` (tokens and
shared widgets), `features/<name>/{logic,view}` (cubit + model, screens + widgets).
