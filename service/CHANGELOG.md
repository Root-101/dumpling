# Changelog

## 0.1.8

- A stored password or secret key is only reused for the place it was saved for: an edit, a
  test or a canvas save that changes the host, port, database, user or TLS of a source (the
  endpoint, region, bucket, access key or path style of a destination) without the secret is a
  `422` that asks for it. An API key allowed to test or edit could send it to its own server.
- A single upload (a dump under 16 MiB), the start and the completion of a multipart upload are
  tried again like its parts: one `503 SlowDown` no longer fails the backup.
- A queued run that can't start because the database fails (a full disk) is marked failed and
  frees its config; the config used to stop running until a restart.
- An UploadId over 2000 characters or an ETag over 1024 is refused, and a run that ends clears
  the upload id it kept.
- Built with Dart 3.14 (Flutter 3.50.1, like the console) and the latest version of every
  dependency (winter 1.0.1, postgres 3.7, sqlite3 3.9.2, drift 2.35.4…).
- CORS exposes `Retry-After`, so the console (on another origin in development) can say how long
  a locked sign-in waits.
- The check each run makes before dumping is kept as the source's last check: its detail no
  longer says *Connected* after a run that couldn't connect.
- A test with TLS required against a server without TLS says *The server doesn't accept TLS:
  turn TLS off if it is on a network you trust*, not the driver's text.
- Every error of Dumpling carries a stable `code` (`sources.inUse`, `workspaces.notFound`…) and
  every violation of its own rules too (`validations.cron`): clients decide on it, never on the text.
- `expire_at` of the sign-in and the session is ISO 8601 in UTC, like every other time of the API
  (it was epoch milliseconds); every time is written with milliseconds and `Z`.
- `/api/health` answers the health check format (`application/health+json`, `pass` / `fail`), not
  `{"status": "up"}`: a monitor that read `up` reads `pass` now.
- A create answers `201` with a `Location` header (the path of what was created).
- `limit` out of 1–200 in the run log is a `422` naming `limit` (a `limit` that is not a number,
  and a filter that is none of its values, stay `400`).
- A sign-in without `username` or `password` is a `422` naming the field, like every other body
  (it was a `400`).

## 0.1.7

- Nothing in the service; the version follows the console.

## 0.1.6

- The schema changes: a table `api_key`, and `label`, `key_id` and `key_name` in `run`; the SQLite
  file is created again (export before upgrading, import after).
- API keys: `GET`, `POST /api/workspaces/{slug}/keys`, `PUT …/keys/{id}`, `PUT …/keys/order` and
  `DELETE …/keys/{id}` (permissions `apikey.*`, the admin's only). A key is
  `dmp_<id>_<secret>`, sent as Bearer or with Basic auth (`key_<id>` and the secret); only the
  sha256 of the secret is kept. It reaches its workspace with the permissions it was given (never
  the session, other workspaces, export, import nor the keys), optionally only some configs and
  their runs (404 for the others); a limited key needs a permission on configs or runs and can't have
  `config.create` nor `canvas.*` (422). A wrong key counts as a failed login of its IP.
- Run now takes an optional `{"label": "…"}` (up to 64 of `A-Z a-z 0-9 . _ -`). A run asked for
  while its config runs is `queued` and starts when that one ends (the 409 is gone); a stop fails
  the queued ones too. A run started with a key has `trigger` `api`, `key_id` and `key_name`.
- `GET …/runs` filters by `trigger` and `label`; `GET …/runs/{id}/events` streams the run as
  Server-Sent Events until it ends.
- The admin's token gets every permission of the running version, whatever list it was signed with.
- The error of an S3 server is read as text: `"` instead of `&quot;`.

## 0.1.5

- Nothing in the service; the version follows the console.

## 0.1.4

- `GET /api/health`, without a token: `200` `{"status": "up"}` when the service and its
  database answer, `503` `{"status": "down"}` when the database doesn't.

## 0.1.3

- The schema changes: `source`, `destination`, `destination_folder` and `config` get a `position`;
  the SQLite file is created again (export before upgrading, import after).
- Order by hand: the lists answer in `position`, a new one last. `PUT
  /api/workspaces/{slug}/{sources,destinations,configs}/order` takes `{"ids": [...]}`, every id of
  the workspace each once (a 422 on `ids` otherwise), with the permission `*.update` of each. The
  canvas save and the import keep the order of their lists, and the folders of a destination keep
  the order they come in (they were alphabetical).

## 0.1.2

- Export and import of workspaces: `GET /api/export` (`?workspace=<slug>` for one) answers a JSON
  file with the canvas of each workspace, the credentials encrypted as stored and the runs of the
  last 30 days; `POST /api/import` adds the workspaces of that file, all or none, a taken name as
  `Name (2)` and with new ids. The credentials are decrypted with this `SECRETS_ENCRYPTION_KEY`
  and encrypted again bound to their new rows: another key is a 422 that names them. New
  permissions `workspace.export` and `workspace.import`.
- The image is published to `ghcr.io/root-101/dumpling` on each version tag, for amd64 and arm64,
  once the checks pass (`release.yml`); its console stage is built once, on the platform of the
  builder.
- An S3 endpoint ending in `/` writes to the same place as without it (it already did; a test
  keeps it so).

## 0.1.1

- No changes in the service: the README drops its Railway section, now that the
  [Railway template](https://railway.com/deploy/dumpling) explains the deploy in its overview.

## 0.1.0

- Winter 1.0.0, its first stable version (it was on `1.0.0-rc.6`).
- Deleting a workspace cancels the schedules of its backups at once (before, each one still fired
  once, found its config gone and cancelled itself).
- The route table is no longer logged at start.

## 0.1.0-rc.7

- A backup over TLS works again in the image: since rc.5 the service ran as `dumpling` with the
  `HOME` of root, and `pg_dump` failed looking for a client certificate there
  (`could not open certificate file "/root/.postgresql/postgresql.crt": Permission denied`). It
  now runs with `HOME=/app`.

## 0.1.0-rc.6

- No changes in the service: the version follows the console's.

## 0.1.0-rc.5

- The image starts on a Railway Volume: Railway mounts `/data` owned by root and the service, as
  `dumpling`, couldn't open the database (`SqliteException(14)`). The container starts as root,
  gives `/data` to `dumpling` and runs the service as `dumpling`.

## 0.1.0-rc.4

- The image has no `VOLUME /data`, which Railway rejects: mount the volume on `/data` where it
  runs (`docker run -v`, compose or a Railway Volume).

## 0.1.0-rc.3

- The console is served with `Cache-Control: no-cache`: the browser revalidates every file (a 304
  when it didn't change), so a new version shows on reload without clearing the cache.

## 0.1.0-rc.2

- No changes in the service: the version follows the console's.

## 0.1.0-rc.1

The first release candidate: backups of PostgreSQL to S3-compatible storage, on a schedule.

- Workspaces with their defaults (schedule, compression, object key) and health stats; no
  compression by default (the custom dump is compressed already).
- Sources: PostgreSQL by fields or connection URL, custom or plain dumps, TLS by default
  (`ssl_mode` `require`, or `disable`; also `sslmode` in the URL), a connection test that checks
  the server against the `pg_dump` of the image. MySQL, MariaDB, MongoDB and Redis listed as
  disabled.
- Destinations: S3-compatible storage with path-style addressing and optional folders, tested with
  an aborted multipart upload. Google Drive, Azure Blob, Dropbox and SFTP listed as disabled.
- The canvas: loaded and saved whole, in one transaction; a test run of every flow.
- Configs: a cron that never fires (`0 0 30 2 *`) and object keys with `.` or `..` folders are
  refused; without a schedule, the workspace's.
- The backup engine: cron schedules in UTC and Run now; `pg_dump` → gzip → S3 multipart, streamed
  without touching the disk; a failed run aborts its upload, and a run cut by a stop has its
  upload aborted on the next start; a part that fails for a moment is retried; `pg_dump` waits at
  most a minute for a locked table; one run per config at a time; runs cut by a stop are marked
  failed.
- Run log with filters by status, source type and destination type, the log of each run and how
  long it took, measured (the times of a run are stored to the second).
- One admin from the environment, JWTs of 12 hours, failed logins limited per IP, a general rate
  limit per IP (`X-Forwarded-For` counted only from private addresses), requests of 2 minutes at
  most, credentials encrypted with AES-256-GCM and never returned (and asked again when they no
  longer decrypt).
- What PostgreSQL and S3 servers send is bounded: the connection test runs in an isolate killed
  after 35 s, errors are cut to 2000 characters, S3 answers to 1 MiB, and only the end of
  `pg_dump`'s stderr is kept.
- `pg_dump` gets its connection in its environment, without the secrets of the service.
- The port comes from `PORT`; `Referrer-Policy: no-referrer` on every response.
- One Docker image with the console and the `pg_dump` of `PG_VERSION` (PostgreSQL packages),
  built by the `Dockerfile` at the root of the repo, and an end-to-end test in Docker
  (`tool/e2e/run.sh`).

## 0.0.1

- Serves the console (`console/build/web`) as static files, with `index.html` for any other route.
- Scheduler demo under `/api/tasks`.
