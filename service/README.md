# Dumpling Service

The backend of dumpling, on [Winter](https://pub.dev/packages/winter). It runs the backup schedules,
serves the API of the console under `/api` and, in the release image, the console's web build as
static files (every unknown route answers `index.html`, so the console's routes work on reload).

In development it reads a `service/.env` (gitignored) with at least `DUMPLING_ADMIN_USER`,
`DUMPLING_ADMIN_PASSWORD` and `JWT_SECRET` (see `../.env.example`):

```bash
cd service && fvm dart run lib/main.dart   # http://localhost:8080
fvm dart test
fvm dart run slang                         # after changing lib/i18n/*.i18n.yaml
```
