# Changelog

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
