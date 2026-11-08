# Roadmap

What is still to do, numbered to talk about each item by its number and to do them in any order.
An item done is ticked (`[x]`) in the same change, and leaves this file once its version is
released: what each version brought is in the [changelog](CHANGELOG.md).

## Next

Already defined, what comes next. Not started.

1. [ ] **Dumpling as a source of each workspace:** a source type whose dump is the export of its
   own workspace, so it goes through the same backups as any database (schedule, compression,
   destination, run log) and the file lands in a bucket on its own.

   - **Goal:** recovering when the server is lost, above all around the versions that don't migrate
     the database.
   - **A source like the others:** added from the same place, only its type differs. No connection
     fields and no limit per workspace.
   - **Only its own workspace:** a source is configured inside a workspace, so it exports that one.
   - **The same file as the export**, reusing `TransferService.export`: the canvas, the credentials
     as stored (encrypted) and the runs of the last month. Its extension is `.json`, and `{db}` in
     the object key is the slug of the workspace. The file includes this source, so a workspace
     imported from it keeps backing itself up.
   - **Readable in the bucket** until *Encrypt the dump* exists: hosts, users, bucket names and run
     logs. Accepted.
   - **Restoring is the current Import.** It needs the credentials of the bucket, to fetch the file
     by hand, and the same `SECRETS_ENCRYPTION_KEY`: neither is in the file, so both are kept
     outside Dumpling. On an empty instance it just works. On a live one it adds `Prod (2)` with
     its schedules on, doubling the backups. API keys are not exported: pipelines need new ones.
   - **Before a version without migration:** the file in the bucket is the one of the last cron, so
     *Upgrading* in the README gets a step: **Run now** first.
   - **The version of the file:** the import asks for exactly the same `version`, and a new one
     would leave the backups in the bucket unreadable. So it isn't raised while the import can read
     the older files, and when it has to be, the import also accepts the older versions.
   - **API keys, no special case.** Running it sends the file where the admin chose. A key with
     `config.update` or `canvas.save` could point it to its own bucket, but it can already do that
     with a whole database, and this only adds credentials useless without
     `SECRETS_ENCRYPTION_KEY`. It doesn't leave its workspace, which is why a key never gets the
     export: add that distinction to DECISIONS §18.
   - **How the driver knows its workspace:** `dump()` gets it as a parameter from the engine. Not in
     `settings`: an import into `Prod (2)` changes the slug, and it would export another workspace.
   - **Console:** the lists of sources show *This Dumpling* as the host and its version as the
     server's.
   - **No schema change, so no 🔴:** `sources.type` is text, a new value of `SourceType`; `settings`
     is an empty JSON and `secrets_encrypted` an empty map, encrypted.
   - **In the same change:** the flow of a visual change (canvas first), the docs (`docs/console.md`,
     `docs/restore.md`, `README.md`, `DECISIONS.md`, changelogs) and the tests.
2. [ ] **Imports that keep working between versions:** an export of any earlier version can be
   imported, which is what *Upgrading* relies on. Today nothing guarantees it: the tests export and
   import with the same code, so a field renamed passes them and fails the user who already deleted
   the SQLite file.

   - **Additive changes:** a new field is optional or has a default, and `version` stays.
   - **Changes that break the file** (a rename, a new required field, another structure of
     `settings`, an enum value renamed or removed): `version` goes up, with a pure function that
     converts the JSON of the previous version, run before `ImportRequest.fromJson`. They chain: a
     file of 0.2.0 goes straight into 0.5.0. It isn't a migration of the SQLite file: that rule
     stays.
   - **The guarantee:** the tests keep a real export of each version of the format and import it,
     so a break fails in CI.
   - **Not supported:** a file of a newer version into an older Dumpling.

## Later

By priority, highest first. 🔴 changes the database schema (a version to export and import again).

3. [ ] **Live runs in the console:** the run log and its dialog follow each run's step, bytes and
   percentage as it goes, without Refresh. The service already streams one run as Server-Sent
   Events (`GET …/runs/{id}/events`, made for pipelines); the console can follow a run with it, or
   with a stream of the whole workspace. Until then a run in progress shows a generic bar and the
   bytes uploaded so far, and its log appears only when it ends. The same stream tells Backups
   when a scheduled run starts and ends and the next one is planned, so the countdown stays local
   and the screen updates without the reload it does once due (which stays, for a stream that is
   down). To design in detail when it starts.
4. [ ] 🔴 **Events feed** (changes, connection checks) and alerts.
5. [ ] 🔴 **Retention** (needs ListObjects and DeleteObject in the destination).
6. [ ] 🔴 **A restore that loses nothing:** when restoring exists, back up the target database
   first, rename it, create a new database and restore into that one.
7. [ ] **More sources** (MySQL, MariaDB, MongoDB) **and destinations** (Google Drive, SFTP, local
   download).
8. [ ] 🔴 **Encrypt the dump** before uploading it to the bucket. `To talk through how before
   implementing it.`
9. [ ] 🔴 **Download a backup** from the console.
10. [ ] **Hardening left by the security audit:** a new admin password ends the sessions already
    open; refuse to start with short secrets (today only a warning); pin the JWT algorithm and an
    audience; a retention for the run log; no redirects followed by the S3 client; the stored
    password dropped when a source's host changes; a `Content-Security-Policy` for the console.
11. [ ] **`verify-full` with a CA** for PostgreSQL sources (`require` and `disable` exist).
12. [ ] **Destination detail** with what is in the bucket (ListObjects): used space, objects, and
    the files, size and last write of each folder; and the history of its connection checks, not
    only the last (🔴 only this history).
13. [ ] **Source detail** with the size of the database, the copies stored and the success rate of
    its runs; and the history of its connection checks, not only the last (🔴 only this history).
14. [ ] **Copying connections between workspaces.**
15. [ ] **zstd compression.**
16. [ ] **Benchmarks**, with a script that repeats them and its results in the repo (like
    feather-io's): the memory of the service at rest, during a backup and after it, and how long a
    backup takes, by size of the database. Measured by hand on 0.1.0-rc.8 (the image, PostgreSQL 18
    and feather-io, a 200 MB database): ~15 MiB at rest, ~100 MiB at the peak of a backup (the
    16 MiB parts it uploads, plus ~11 MiB of `pg_dump`) and ~66 MiB minutes after it, memory Dart
    doesn't give back.

## After 1.0

17. [ ] **Source metadata:** the detail of a source shows what is in its database without reading
    any row: schemas, tables with their column count, estimated rows and size, and the types
    (enums, composites, domains). One more `SourceDriver` method each driver implements from its
    catalog (`pg_catalog` in PostgreSQL, `information_schema` in MySQL/MariaDB, `stats()` and a
    sample of documents in MongoDB, whose fields are only inferred). Row counts are estimates
    (`reltuples`, `TABLE_ROWS`, `estimatedDocumentCount`), never `count(*)`; what the user can't
    read shows as not available; the last result is kept with its time instead of querying on
    every visit.

## Random ideas

Loose ideas, not planned or weighed yet.

18. [ ] **Backup preview:** a "Preview" on a backup shows what it holds without restoring it. The
    service downloads the file from the bucket, `pg_restore --list` gives the tree of schemas and
    tables, and picking a table shows its first rows, parsed from its `COPY` block
    (`pg_restore -a -t <table> -n <schema> -f -`). A plain SQL backup is already text. To check
    first: that the image carries `pg_restore` next to `pg_dump`, and the cost of downloading a
    big backup whole just to preview it.
