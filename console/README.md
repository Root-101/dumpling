# Dumpling Console

The web UI of dumpling, in Flutter Web. It is not deployed on its own: the service serves its
build (`console/build/web`) as static files, on the same origin as the API.

```bash
fvm flutter pub get
fvm dart run slang                                  # after editing lib/l10n/*.i18n.yaml
fvm flutter build web                               # then start the service: http://localhost:8080 (the release image does both)
fvm flutter run -d chrome --web-port=8081           # or apart, for UI work
fvm flutter analyze
fvm flutter test                                    # on the VM, no browser
```

Run apart, the console needs to know where the service is: `web/env.js` (gitignored) sets it.

```js
window.env = {
  SERVICE_URL: 'http://localhost:8080',
};
```

Without it, the console calls the origin it was served from (the release).

Structure, the same as feather-io's console: `adapter/` (DI, navigation, dialogs, snackbars, the
browser), `config/` (env, routes, theme), `design_system/` (tokens and shared widgets),
`exceptions/`, `l10n/` (slang, `es` and `en`), `shared/` (loading, error and empty pages) and
`features/<name>/` with `data/rest` (client and DTOs), `data/repo`, `logic/cubit`, `logic/model`,
`view` and its `<name>_init.dart`.
