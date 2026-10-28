# Design decisions

Why Dumpling behaves the way it does where that is not obvious from the code. When a decision
changes, update it here.

## 1. One image, one server

The service serves the console's web build as static files, on the same origin as the API
(`/api/…`; any other path answers the console's `index.html`, so its routes survive a reload).

| Decision                                  | Why                                                                                                                      |
|-------------------------------------------|--------------------------------------------------------------------------------------------------------------------------|
| No separate server for the console        | One container, one port, one thing to update. Unlike feather-io, nothing else is served that must be kept off its origin |
| The console calls the origin it came from | No URL to configure in the release; in development `web/env.js` points it to the service                                 |
| `pg_dump` inside the image, from PGDG     | The official packages of PostgreSQL, with fixes for every supported major; `PG_VERSION` (a build arg) chooses which one  |

## 2. The service connects, never the console

Connection tests, dumps and uploads all run in the service. The browser only talks to the API.

The databases worth backing up usually live in a private network the browser can't reach, and
credentials that never travel to the browser can't leak from it.

## 3. Credentials encrypted, bound to their row

Database passwords and S3 secret keys are stored with AES-256-GCM, the key derived from
`SECRETS_ENCRYPTION_KEY`, a random nonce per value and the id of the source or destination as
associated data.

| Decision                      | Why                                                                                                  |
|-------------------------------|------------------------------------------------------------------------------------------------------|
| Encrypted, not hashed         | They are needed back in plain text to connect                                                        |
| The row id as associated data | A value copied onto another row (by hand in SQLite, or a bug) fails to decrypt instead of being used |
| Never returned by the API     | The console only needs to know there is one; an edit without a new password keeps the saved one      |

## 4. `pg_dump` gets its connection in the environment

`pg_dump` runs with `PGHOST`, `PGPORT`, `PGUSER`, `PGDATABASE` and `PGPASSWORD`, and only
`--format`, `--no-password` and `--lock-wait-timeout` (1 minute: a table locked by a migration
fails the run instead of leaving it running forever) as arguments. Its environment is the service's without its secrets
and without any other `PG*` variable.

- The arguments of a process are visible to every user of the machine (`ps`); the environment is
  not.
- libpq reads a `--dbname` that contains `=` as a whole connection string, so a database name could
  change the host or the TLS files. `PGDATABASE` is always just a name.
- A `PGSERVICE` or `PGPASSFILE` of the machine must not change where a backup goes, and `pg_dump`
  has no reason to see `JWT_SECRET`.

## 5. Compatibility of `pg_dump` and the server

The test of a source reads `server_version_num` and compares its major with the `pg_dump` of the
image: a server **newer** than `pg_dump` is reported as not compatible, before any run tries. The
check is repeated before every run.

`pg_dump` refuses servers newer than itself, and its error says little to someone who only sees a
failed backup. Older servers are fine: `pg_dump` dumps them all.

## 6. A run streams from end to end

`pg_dump` → gzip (when the config asks for it) → parts of 16 MiB → S3 multipart upload; a dump that
fits in one part is a single `PutObject`.

| Decision                                 | Why                                                                                                                                 |
|------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------|
| Never on disk                            | A database can be bigger than the free disk of the container, and a dump on disk is one more copy of the data to protect            |
| 16 MiB parts                             | Memory stays at a few parts. S3 allows 10 000 parts, so a backup can reach ~156 GiB; bigger ones would need bigger parts            |
| A failed run aborts its multipart upload | No half file stays in the bucket looking like a backup, nor parts that cost storage                                                 |
| Our own S3 client (SigV4)                | Only `PutObject` and multipart are needed; `minio` (the package) can't abort an upload by its id, which the previous point requires |
| The extension comes from the engine      | `.dump` or `.sql` by the dump format, plus `.gz` by the compression: an object key with its own extension could lie about the file  |

## 7. Tests that leave nothing behind

The test of a destination starts a multipart upload in each of its folders (or the root) and aborts
it. That proves the endpoint, the credentials, the bucket and the **write** permission where the
backups will go, and leaves no object: a bucket used for backups shouldn't fill with test files.

The **Test run** of the canvas does the same for every complete flow, without backing anything up.

## 8. The canvas is saved whole

`PUT /api/workspaces/{slug}/canvas` receives every source, destination and config of the workspace
and saves them in one transaction; what it leaves out is deleted. New nodes carry an id made up by
the console (`new_…`), which the response maps to the saved one.

- The canvas is edited as a whole (move, connect, delete, undo by not saving) and one **Save**
  is what the user expects; saving node by node would leave half-edited pipelines live.
- One transaction: a save that fails changes nothing.
- Only complete flows (source → config → destination) are sent: an orphan config can't run, and
  the service rejects it.

## 9. Folders of a destination

A bucket without folders has one connection point, its root. Once it has a folder, each folder is a
connection point and the root is not; adding the first one disconnects the configs on the root.

Mixing both would make it easy to scatter backups at the root of a bucket meant to be organized
by folders; the object key of a config is relative to the folder it writes to.

## 10. Time is UTC

Every time is stored and sent in UTC, and schedules are cron expressions in UTC. The console shows
the UTC time with the local one smaller next to it.

A server, its database and its users can be in three time zones; a schedule in UTC means the same
for all of them and has no daylight-saving jumps (a local 02:30 can happen twice, or never).

## 11. Runs

| Decision                                                  | Why                                                                                                       |
|-----------------------------------------------------------|-----------------------------------------------------------------------------------------------------------|
| One run per config at a time (`409` for a second Run now) | Two dumps of the same database at once double its load and race to write the same key                     |
| Runs left running by a stop are marked failed at start-up | Their process is gone: "running" forever would hide that the backup didn't happen                         |
| The log of a run is written when it ends                  | One write per run instead of one per line; while it runs, its size and location already show the progress |
| The run log lists the 200 newest runs                     | Enough for months of daily backups in a workspace, in one request; paging when someone needs more         |

## 12. Authentication: one admin, a 12 h token

The only user is the admin from the environment (`DUMPLING_ADMIN_USER`, `DUMPLING_ADMIN_PASSWORD`).
The login returns a JWT of 12 hours, with no refresh: then the console asks to sign in again.

| Decision                                                                                             | Why                                                                                                                                            |
|------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------|
| One user from the environment                                                                        | Dumpling is run by whoever runs the databases; users and roles are out of 0.1.0                                                                |
| The token in a header, never a cookie                                                                | No CSRF, and CORS can accept any origin (the console in development runs on another one)                                                       |
| No refresh token                                                                                     | One less secret to store and rotate; signing in twice a day is acceptable for an admin tool                                                    |
| 1 s per failed login, 10 failures lock the IP for 15 minutes, even with the right password afterward | Slows guessing to about one try per second and connection, and stops parallel attacks; a lock that ends on success would invite waiting it out |

## 13. General request limit: 600 per minute and IP

Winter's `RateLimiterFilter` is the first global filter (`RATE_LIMIT_REQUESTS`,
`RATE_LIMIT_WINDOW_SECONDS`; `0` disables it).

Only the console calls the service, a few requests per screen and one every 2 seconds while a Run
now is followed: far below 600. Above it, something is wrong, and stopping it before bodies are
read or tokens checked is cheap. Behind your own proxies, `TRUSTED_PROXIES` makes it count the
client's IP, not the proxy's.
