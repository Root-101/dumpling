# Changelog

## 0.1.0-rc.1

The first release candidate: backups of PostgreSQL to S3-compatible storage, on a schedule.

- Workspaces with their defaults (schedule, compression, object key) and health stats.
- Sources: PostgreSQL by fields or connection URL, custom or plain dumps, a connection test that
  checks the server against the `pg_dump` of the image. MySQL, MariaDB, MongoDB and Redis listed as
  disabled.
- Destinations: S3-compatible storage with path-style addressing and optional folders, tested with
  an aborted multipart upload. Google Drive, Azure Blob, Dropbox and SFTP listed as disabled.
- The canvas: loaded and saved whole, in one transaction; a test run of every flow.
- The backup engine: cron schedules in UTC and Run now; `pg_dump` → gzip → S3 multipart, streamed
  without touching the disk; a failed run aborts its upload; one run per config at a time; runs
  cut by a stop are marked failed.
- Run log with filters by status, source type and destination type, and the log of each run.
- One admin from the environment, JWTs of 12 hours, failed logins limited per IP, a general rate
  limit per IP, credentials encrypted with AES-256-GCM and never returned.
- `pg_dump` gets its connection in its environment, without the secrets of the service.
- The port comes from `PORT`; `Referrer-Policy: no-referrer` on every response.
- One Docker image with the console and the `pg_dump` of `PG_VERSION` (PostgreSQL packages), and
  an end-to-end test in Docker (`tool/e2e/run.sh`).

## 0.0.1

- Serves the console (`console/build/web`) as static files, with `index.html` for any other route.
- Scheduler demo under `/api/tasks`.
