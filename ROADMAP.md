# Roadmap

What is still to do, numbered to talk about each item by its number and to do them in any order.
An item done is ticked (`[x]`) in the same change, and leaves this file once its version is
released: what each version brought is in the [changelog](CHANGELOG.md).

## Pending

1. [ ] **A restore that loses nothing:** when restoring exists, back up the target database
   first, rename it, create a new database and restore into that one.
2. [ ] **Encrypt the dump** before uploading it to the bucket. `To talk through how before
   implementing it.`
3. [ ] **Dumpling as a source of each workspace:** its export goes through the same backups as any
   database (schedule, compression, destination, run log), so the file lands in a bucket on its
   own. `To talk through.`

## 0.2.0

4. [ ] **Benchmarks**, with a script that repeats them and its results in the repo (like
   feather-io's): the memory of the service at rest, during a backup and after it, and how long a
   backup takes, by size of the database. Measured by hand on 0.1.0-rc.8 (the image, PostgreSQL 18
   and feather-io, a 200 MB database): ~15 MiB at rest, ~100 MiB at the peak of a backup (the
   16 MiB parts it uploads, plus ~11 MiB of `pg_dump`) and ~66 MiB minutes after it, memory Dart
   doesn't give back.
5. [ ] **Retention** (needs ListObjects and DeleteObject in the destination).
6. [ ] **Destination detail** with what is in the bucket (ListObjects): used space, objects, and
   the files, size and last write of each folder; and the history of its connection checks, not
   only the last.
7. [ ] **Source detail** with the size of the database, the copies stored and the success rate of
   its runs; and the history of its connection checks, not only the last.
8. [ ] **`verify-full` with a CA** for PostgreSQL sources (`require` and `disable` exist).
9. [ ] **Download a backup** from the console.
10. [ ] **Events feed** (changes, connection checks) and alerts.
11. [ ] **Live runs in the console:** the run log and its dialog follow each run's step, bytes and
    percentage as it goes, without Refresh. The service already streams one run as Server-Sent
    Events (`GET …/runs/{id}/events`, made for pipelines); the console can follow a run with it, or
    with a stream of the whole workspace. Until then a run in progress shows a generic bar and the
    bytes uploaded so far, and its log appears only when it ends. The same stream tells Backups
    when a scheduled run starts and ends and the next one is planned, so the countdown stays local
    and the screen updates without the reload it does once due (which stays, for a stream that is
    down). To design in detail when it starts.
12. [ ] **Hardening left by the security audit:** a new admin password ends the sessions already
    open; refuse to start with short secrets (today only a warning); pin the JWT algorithm and an
    audience; a retention for the run log; no redirects followed by the S3 client; the stored
    password dropped when a source's host changes; a `Content-Security-Policy` for the console.
13. [ ] **Copying connections between workspaces.**
14. [ ] **zstd compression.**
15. [ ] **More sources** (MySQL, MariaDB, MongoDB) **and destinations** (Google Drive, SFTP, local
    download).

## After 1.0

16. [ ] **Source metadata:** the detail of a source shows what is in its database without reading
    any row: schemas, tables with their column count, estimated rows and size, and the types
    (enums, composites, domains). One more `SourceDriver` method each driver implements from its
    catalog (`pg_catalog` in PostgreSQL, `information_schema` in MySQL/MariaDB, `stats()` and a
    sample of documents in MongoDB, whose fields are only inferred). Row counts are estimates
    (`reltuples`, `TABLE_ROWS`, `estimatedDocumentCount`), never `count(*)`; what the user can't
    read shows as not available; the last result is kept with its time instead of querying on
    every visit.

## Random ideas

Loose ideas, not planned or weighed yet.

17. [ ] **Backup preview:** a "Preview" on a backup shows what it holds without restoring it. The
    service downloads the file from the bucket, `pg_restore --list` gives the tree of schemas and
    tables, and picking a table shows its first rows, parsed from its `COPY` block
    (`pg_restore -a -t <table> -n <schema> -f -`). A plain SQL backup is already text. To check
    first: that the image carries `pg_restore` next to `pg_dump`, and the cost of downloading a
    big backup whole just to preview it.
