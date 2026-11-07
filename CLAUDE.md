# Dumpling

Self-hosted backups of databases to storages, set up by drawing them on a canvas. A monorepo with two
packages that share nothing but the HTTP contract:

- `service/`: Dart on [Winter](https://pub.dev/packages/winter), SQLite through drift. It runs the
  schedules and the backups, serves the API (`/api/…`) and the console's web build (any other
  path answers `index.html`). Entry point `service/lib/main.dart`, everything exported from
  `service/lib/dumpling.dart`.
- `console/`: Flutter Web, flutter_bloc. The service serves it on the same origin; in development
  `console/web/env.js` points it to the service.
- One image (`Dockerfile`): the console built once on the build platform, the service AOT
  compiled per arch (`dart build cli`, which bundles SQLite), and `pg_dump` from PGDG.

Read before changing behavior: [`CONTRIBUTING.md`](CONTRIBUTING.md) (layers, docs to keep in step,
tests), [`DECISIONS.md`](DECISIONS.md) (the why of every non-obvious choice: streaming runs, the
canvas saved whole, UTC, credentials bound to their row, remote servers not trusted…) and
[`SECURITY.md`](SECURITY.md).

## Architecture

**Service** (`service/lib/features/<feature>/`): `controller/` → `logic/service/` → `repo/` (drift),
models in `logic/model/`. Only controllers know HTTP; routes and their permission keys are in
`features/api_controller.dart` and `security/permissions.dart`. Request bodies are `Validatable`
and their `Deserializer` is registered in `main.dart`; errors are Problem Details with translated
messages (`lib/i18n/*.i18n.yaml`). The environment is read only in `lib/config/extended_env.dart`.

- Sources and destinations are drivers (`SourceDriver`, `DestinationDriver`), registered by type: a
  new database or storage touches nothing else.
- `CanvasService.save` is the one way sources, destinations and configs change (new ids come as
  `new_…`): validation, encryption and scheduling live there. The import (`features/transfer/`)
  reuses it.
- Credentials: AES-256-GCM with the row id as associated data (`SecretCipher`): a value moved to
  another row doesn't decrypt. Never returned by the API.

**Console** (`console/lib/features/<feature>/`): `data/rest` (client, DTOs) → `data/repo` →
`logic/cubit` + `logic/model` → `view`, wired in `<feature>_init.dart`. Views only call cubits.
Shared widgets, colors (`app.colors`), icons (`app.assets.icons`, SVGs in `assets/icons/`) and text
styles are in `lib/design_system/`; use them before writing a new one. Browser APIs (download, file
pick, drop) go through `lib/adapter/browser_window_web.dart`, with stubs in `browser_window_vm.dart`; a function
passed through `toJS` must not be `async`.

**Both**: JSON keys `snake_case`, times UTC. A field renamed in the service changes the console's
DTO in the same change.

## Commands

Prefix everything with `fvm` (versions pinned in `.fvmrc`; the `dart` on the PATH is older).

| What                     | Where      | Command                                              |
|--------------------------|------------|------------------------------------------------------|
| Check a change           | `service/` | `fvm dart analyze && fvm dart test`                  |
| Check a change           | `console/` | `fvm flutter analyze && fvm flutter test`            |
| After editing i18n yaml  | either     | `fvm dart run slang`                                 |
| After editing drift      | `service/` | `fvm dart run build_runner build`                    |
| Runs, drivers, image     | `service/` | `tool/e2e/run.sh` (Docker: image, PostgreSQL, S3)    |
| Regenerate the design    | root       | `python docs/design/tool/export.py <canvas folder>`  |

- The one known analyzer info (`MaterialUiCompatibilityBridge` in `console/lib/main.dart`) is on
  purpose.
- `dart format` on a folder reformats unrelated files: format only the files you touched.
- Each service test file that starts a server uses its own port.

## Running it locally

- Service on **8180** with the repo's `data/`, from `service/`:
  `PORT=8180 DATA_PATH=../data DUMPLING_ADMIN_USER=admin DUMPLING_ADMIN_PASSWORD=some-long-password JWT_SECRET=some-jwt-secret SECRETS_ENCRYPTION_KEY=some-secrets-key fvm dart run lib/main.dart`
- Console on **8181**: `fvm flutter build web` in `console/`, then `python -m http.server 8181` from
  `console/build/web` (the debug `flutter run` can hang on the splash). Hard reload
  (Ctrl+Shift+R) after each build; the browser caches the SVG icons.
- Sign in with `admin` / `some-long-password`. `data/` is the user's own data: create anything to
  test in a throwaway workspace and delete it afterwards. Stop both servers when done.

## Rules

- **No migrations in 0.x.** A schema change edits the tables in place (no `schemaVersion` bump, no
  `onUpgrade`); the SQLite file is created again. That version gets 🔴 in the upgrade table of the
  README (*Upgrading*: export, upgrade, import) and a line in the changelog; tell the user to delete
  their local `data/dumpling.sqlite`.
- **No user-visible text hardcoded**, in English and Spanish (`console/lib/l10n/*.i18n.yaml`,
  `service/lib/i18n/*.i18n.yaml`). Spanish says *origen* and *destino*, never *source* or
  *destination*.
- **A visual change to the console**, in the same change: the Claude Design canvas first
  (https://claude.ai/artifact/8ZG7z26F5hn1KMsV2a1wvN, read its files before publishing them),
  then `docs/design/` regenerated (screens and PDF), `docs/console.md` updated, and what was built
  compared in the browser with the canvas until they match. The PNGs are referenced by number in
  `README.md` and `docs/console.md`: a screen added in `SCREENS` renumbers those after it.
- **Docs in the same change**: a route → `docs/api.md`; a screen, URL or action →
  `docs/console.md`; auth, credentials, limits or logs → `SECURITY.md`; a non-obvious decision →
  `DECISIONS.md`; a user-visible change → the `CHANGELOG.md` of its package and the root one; a
  roadmap item done → `ROADMAP.md`.
- Every change comes with its tests. Don't add a dependency for what Dart, Flutter or Winter
  already do.
- Write docs and code comments in English, short and plain.

## Git

- Branches from `develop`; `main` only gets releases. Ask before pushing.
- Once a branch is merged into `develop` and pushed, delete it, locally (`git branch -d`) and on
  the remote (`git push github --delete <branch>`, if it was pushed).
- Commit messages start with the part they touch, then what the change does: `Service: …`,
  `Console: …`, `Docs: …`, `Design: …`, `CI: …`, `Release: …`, `Roadmap: …`.
- **Never** add `Co-Authored-By` or any other attribution to Claude in commits or pull requests.

## Releasing a version

1. A `Version X.Y.Z` commit: `service/pubspec.yaml`, `console/pubspec.yaml`,
   `console/lib/main.dart` (`version`), the status line of `README.md`, the supported version in
   `SECURITY.md`, the image tag in `docker-compose.yml` and in the README examples, a column and row
   in the README's upgrade table, and the version in the three changelogs.
2. Merge the branch into `develop` (`Merge <branch> into develop`), then `develop` into `main`
   (`Merge develop into main: X.Y.Z`), `--no-ff`.
3. Push `develop`, `main` and the tag `X.Y.Z` on the merge of `main`, one right after the other:
   the README of `main` names an image that only exists once the tag is built.
4. `.github/workflows/release.yml` runs the CI and publishes `ghcr.io/root-101/dumpling:X.Y.Z`
   (amd64 and arm64); `latest` moves only for versions without `-rc`. A `-rc` tag tries the
   workflow without touching `latest`. Then pull the image logged out and run the compose from an
   empty folder to check it.
