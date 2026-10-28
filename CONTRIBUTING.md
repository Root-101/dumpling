# Contributing

Thanks for helping. This is a monorepo with two packages that share nothing but the HTTP contract:
`service/` (Dart, on Winter) and `console/` (Flutter Web).

## Setup

Both packages pin their Flutter (and Dart) version with [FVM](https://fvm.app) in `.fvmrc`; the
`dart` on your PATH may be older, so prefix every command with `fvm`.

```bash
dart pub global activate fvm
cd service && fvm install && fvm dart pub get
cd ../console && fvm install && fvm flutter pub get
```

How to run each one locally is in the [README](README.md#locally). A `pg_dump` (any PostgreSQL
client) is needed to run backups locally, and Docker for the image and the end-to-end test.

## How the code is organized

- **Service**: a feature is `controller/` → `logic/service/` → `repo/` (drift), with its models in
  `logic/model/`; only controllers know about HTTP. Errors are Problem Details (RFC 9457) with
  translated messages (`lib/i18n/*.i18n.yaml`, both languages; `fvm dart run slang` after editing
  them). Variables of the environment are read only in `lib/config/extended_env.dart`.
- **Sources and destinations are drivers**: a new database is a `SourceDriver` (`testConnection`,
  `dump` as a byte stream) and a new storage a `DestinationDriver` (`testConnection`, `upload` from
  a stream), registered by type. Nothing else should need to change.
- **Console**: a feature is `data/rest` (client and DTOs) → `data/repo` → `logic/cubit` and
  `logic/model` → `view`, wired in its `<name>_init.dart`; views only call cubit methods. No
  user-visible text is hardcoded (`lib/l10n/*.i18n.yaml`, both languages, then
  `fvm dart run slang`).
- **Both**: JSON keys are `snake_case`, times are UTC. A field renamed in the service changes the
  console's DTO in the same change.
- Don't add a dependency for something Dart, Flutter or Winter already does.
- What a database or a bucket sends back is not trusted, even if the admin chose it: bound its size
  and its time, and don't let its bytes throw past a run (see [`DECISIONS.md`](DECISIONS.md#15-remote-servers-are-not-trusted)).
- A change to authentication, credentials, limits or what the logs show updates
  [`SECURITY.md`](SECURITY.md) in the same change.
- A non-obvious decision goes into [`DECISIONS.md`](DECISIONS.md), and a finished roadmap task is
  marked in [`ROADMAP.md`](ROADMAP.md), in the same change.

## Tests

Every change comes with its tests (`service/test/` mirrors `service/lib/`; each test file that
starts a server uses its own port).

| When                                                        | Run                                                                                                        | Time   |
|-------------------------------------------------------------|------------------------------------------------------------------------------------------------------------|--------|
| Every change                                                | `fvm dart analyze && fvm dart test` in `service/`, `fvm flutter analyze && fvm flutter test` in `console/` | ~1 min |
| Touching a run, a driver, the canvas save or the Dockerfile | also `service/tool/e2e/run.sh`: the image, PostgreSQL and S3 in Docker, a backup restored and compared     | ~3 min |

The unit tests run without Docker (an in-memory database, a fake S3); the end-to-end test is the
one that runs a real `pg_dump`, a real upload and a real `pg_restore`. A visual change is also
tried in the browser: the widget tests don't see what a user sees.

## Branches, commits and pull requests

- Work in a branch and open the pull request against `develop`; `main` gets the releases.
- Commit messages start with the part they touch, then what the change does, in the present:

  ```
  Service: the port comes from PORT
  Console: run log and run detail
  ```

- A user-visible change adds a line to the `CHANGELOG.md` of its package.
