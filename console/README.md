# Dumpling Console

The web UI of dumpling, in Flutter Web. It is not deployed on its own: the service serves its
build (`console/build/web`) as static files, on the same origin as the API.

```bash
fvm flutter pub get
fvm dart run slang                                  # after editing lib/i18n/*.i18n.yaml
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

Structure, the one of the Flutter app standard: `adapter/` (DI, the event bus, navigation,
dialogs, snackbars, the browser), `config/` (env, routes and the navigators of the sections),
`design_system/` (`tokens/`: `app.colors`, `app.dimensions`, `app.styles`; `theme/`; `icons/`;
`components/`), `exceptions/` (`GlobalException`, `ApiErrorCode`), `i18n/` (slang, `en` and `es`)
and `features/<name>/` with `data/rest` (client and DTOs), `data/repo`, `logic/cubit`,
`logic/model` (one model per file), `view` and its `<name>_init.dart`. `features/global/` holds the
splash, the error pages and the offline banner.

- Every screen and dialog opens through its navigator (`SourcesScreen.navigator.go(...)`,
  `SourceForm.navigator.open(...)`), never a path or a `showDialog` of its own.
- A cubit names its states after itself and the action (`SourcesSearchingState`,
  `SourcesDeletedOkState`, `SourcesDeletingErrorState` with the `GlobalException`). The OK states of
  writes travel on the `GlobalEventBus`: the lists that depend on them reload there, not from the
  view.
