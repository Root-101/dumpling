# The API

A tour of the HTTP API of the service, with real requests and responses (taken from a running
service). The console uses exactly these calls; [`console.md`](console.md) says which one each
screen makes.

Everything is under `/api`, on the same port as the console (8080 by default). Any other path is
the console; an unknown path under `/api` is a `404`. The API is always JSON: keys in
`snake_case`, times in ISO 8601 and UTC (`2026-10-30T05:16:13.000Z`), cron schedules in UTC too.

Most things live in a workspace, so most paths start with `/api/workspaces/{slug}`. Ids carry
their kind: `src_…` for sources, `dst_…` for destinations, `cfg_…` for configs, `run_…` for runs.

## Authentication

| Who                                          | How                                                                                          |
|----------------------------------------------|----------------------------------------------------------------------------------------------|
| The console (and anything else that logs in) | `Authorization: Bearer <access_token>`, from [`POST /api/auth/login`](#log-in)              |
| Nobody                                       | Only `POST /api/auth/login` (and the console's own files, outside `/api`)                   |

There is one user, the admin of the environment (`DUMPLING_ADMIN_USER`, `DUMPLING_ADMIN_PASSWORD`).
Its token lasts 12 hours, has every permission, and there is no refresh: then the console asks to
sign in again. The token goes in a header, never in a cookie, so CORS accepts any origin.

Each route needs a permission (`workspace.list`, `config.run`…), and the admin's token has all of
them. Without a token, or with an expired one:

```json
{"type": "about:blank", "title": "Unauthorized", "status": 401, "instance": "/api/workspaces"}
```

## Errors

Every error is a Problem Details (RFC 9457). The `detail` is in English, or in Spanish with
`Accept-Language: es`, and the `instance` is the path of the request:

```http
GET /api/workspaces/nope
Accept-Language: es
```

```json
{
  "type": "about:blank",
  "title": "Not Found",
  "status": 404,
  "detail": "El workspace \"nope\" no existe.",
  "instance": "/api/workspaces/nope"
}
```

A body that can't be read is a `400` naming the field, and one that breaks a rule a `422` with its
`violations` (the console shows each one under its field):

```json
{"type": "about:blank", "title": "Bad Request", "status": 400, "detail": "$.username: expected a string, got an integer", "instance": "/api/auth/login"}
```

```json
{
  "violations": [
    {"fieldName": "name", "message": "The minimum is 1", "code": "size.min", "params": {"value": 1}},
    {"fieldName": "defaults.schedule", "message": "Not a valid cron expression (minute hour day month weekday)"},
    {"fieldName": "defaults.compression", "message": "The value must be one of: gzip, none", "code": "isEnum", "params": {"values": ["gzip", "none"]}}
  ],
  "type": "about:blank",
  "title": "Unprocessable Content",
  "status": 422,
  "instance": "/api/workspaces"
}
```

Not every violation has a `code`: the rules of Dumpling itself (a cron expression, a folder of the
destination…) only bring the `message`.

Other common answers: `404` for a workspace, source, destination, config or run that doesn't exist
(in that workspace), `409` when something is in use or already running, and `429` above the rate
limit, with `Retry-After`. Every response carries the rate limit headers of the IETF draft
(`RateLimit-Policy: "default";q=600;w=60`, the limit and its window in seconds, and
`RateLimit: "default";r=599;t=60`, the requests left and the seconds until the window frees one).

---

## Log in

```http
POST /api/auth/login
Content-Type: application/json

{"username": "admin", "password": "<password>"}
```

```json
{"access_token": "eyJ…", "expires_in": 43200000, "expire_at": 1793381180834}
```

The token lasts 12 hours (`expires_in` in milliseconds, `expire_at` as epoch milliseconds). Wrong
credentials:

```json
{"type": "about:blank", "title": "Unauthorized", "status": 401, "detail": "Wrong username or password", "instance": "/api/auth/login"}
```

Every failure waits a second, and 10 in a row lock the IP for 15 minutes, even with the right
password afterward (`429` with `Retry-After`).

## Session

```http
GET /api/auth/session
```

```json
{"username": "admin", "expire_at": 1793381180000}
```

Who the token belongs to and when it expires (epoch milliseconds, to the second). A quick way to
check that a token still works; the console itself doesn't call it.

## Types of sources and destinations

The kinds the service knows, the disabled ones too (the console shows them as coming soon). Only an
enabled type can be created.

```http
GET /api/source-types
```

```json
[
  {"type": "postgres", "enabled": true},
  {"type": "mysql", "enabled": false},
  {"type": "mariadb", "enabled": false},
  {"type": "mongodb", "enabled": false},
  {"type": "redis", "enabled": false}
]
```

```http
GET /api/destination-types
```

```json
[
  {"type": "s3", "enabled": true},
  {"type": "gdrive", "enabled": false},
  {"type": "azure", "enabled": false},
  {"type": "dropbox", "enabled": false},
  {"type": "sftp", "enabled": false}
]
```

## Workspaces

Separate canvases, each one with its sources, destinations, configs and runs. A workspace is named
by its `slug`, made from its name when it is created and never changed after.

### List workspaces

```http
GET /api/workspaces
```

```json
[
  {
    "slug": "e2e",
    "name": "E2E",
    "description": null,
    "color": null,
    "defaults": {"schedule": "0 2 * * *", "compression": "none", "object_key": "{db}/{yyyy}-{MM}-{dd}-{run_id}"},
    "created_at": "2026-10-30T05:16:13.000Z",
    "updated_at": "2026-10-30T05:16:13.000Z",
    "stats": {
      "sources": 3, "destinations": 1, "configs": 3, "failing": 1, "running": 0,
      "last_run_at": "2026-10-30T05:16:17.000Z",
      "preview": [
        {"source": "src_2jk3yrajcjupgams", "destination": "dst_pohrlldk36tlyjd6", "failing": false},
        {"source": "src_qdih6ehueggett6m", "destination": "dst_pohrlldk36tlyjd6", "failing": true}
      ]
    }
  }
]
```

`stats` is only in the list: what the cards of the console show. `failing` counts the configs whose
last run failed, `running` the runs in progress, and `preview` holds the first three configs (the
oldest) with what they connect (trimmed here to two).

### Get a workspace

```http
GET /api/workspaces/e2e
```

The same as in the list, without `stats`.

### Create a workspace

```http
POST /api/workspaces
Content-Type: application/json

{"name": "Docs tour", "description": "Examples of api.md", "color": 4280391411, "defaults": {"schedule": "30 1 * * *"}}
```

`201`:

```json
{
  "slug": "docs-tour", "name": "Docs tour", "description": "Examples of api.md", "color": 4280391411,
  "defaults": {"schedule": "30 1 * * *", "compression": "none", "object_key": "{db}/{yyyy}-{MM}-{dd}-{run_id}"},
  "created_at": "2026-10-30T05:27:24.000Z", "updated_at": "2026-10-30T05:27:24.000Z"
}
```

`color` is an ARGB integer (`0xFF2196F3`), or `null`. The `defaults` are what a new config of the
workspace starts with; a missing one takes the service's: every day at 02:00 UTC, no compression
(the default dump is compressed already) and `{db}/{yyyy}-{MM}-{dd}-{run_id}`. A name whose slug is
taken gets `-2`, `-3`… (`docs-tour-2`).

### Edit a workspace

```http
PUT /api/workspaces/docs-tour
Content-Type: application/json

{"name": "Docs tour (renamed)", "color": null, "defaults": {"schedule": "0 3 * * *", "compression": "gzip", "object_key": "{db}/{run_id}"}}
```

Answers the workspace with the new values. The body replaces everything: a missing `description`
or `color` clears it, and a missing default goes back to the service's. The slug stays. Changing
the defaults doesn't change the configs that already exist.

### Delete a workspace

```http
DELETE /api/workspaces/docs-tour
```

`204`. Deletes the workspace with its sources, destinations, configs and runs. The backup files
already in the buckets stay where they are.

## Sources

The databases to back up. The `password` is write-only: it is stored encrypted and **never
returned**, neither here nor in the canvas. Today the only type is `postgres`.

### List sources

```http
GET /api/workspaces/e2e/sources
```

```json
[
  {
    "id": "src_2jk3yrajcjupgams",
    "workspace": "e2e",
    "name": "shop-custom",
    "type": "postgres",
    "settings": {
      "host": "e2e-postgres", "port": 5432, "database": "shop", "username": "dumpling_backup",
      "dump_format": "custom", "ssl_mode": "disable"
    },
    "last_check": {
      "status": "connected", "server_version": "18.6", "tool_version": "pg_dump 18.6", "message": null,
      "duration_ms": 52, "checked_at": "2026-10-30T05:16:13.373091Z"
    },
    "created_at": "2026-10-30T05:16:13.000Z",
    "updated_at": "2026-10-30T05:16:13.000Z"
  },
  …
]
```

`last_check` is the last [test of the saved source](#test-a-saved-source), `null` until the first
one. `dump_format` is `custom` (`pg_dump -Fc`, for `pg_restore`) or `plain` (SQL); `ssl_mode` is
`require` (the default: TLS without checking the certificate) or `disable`.

### Get a source

```http
GET /api/workspaces/e2e/sources/src_2jk3yrajcjupgams
```

One source, as in the list.

### Test a source before saving

What the form's **Test connection** does: the service connects with the data of the form, without
saving anything.

```http
POST /api/workspaces/docs-tour/sources/test
Content-Type: application/json

{"name": "shop", "type": "postgres", "settings": {"connection_url": "postgresql://dumpling_backup:<password>@e2e-postgres:5432/shop?sslmode=disable"}}
```

```json
{"status": "connected", "server_version": "18.6", "tool_version": "pg_dump 18.6", "message": null, "duration_ms": 65, "checked_at": "2026-10-30T05:27:39.632540Z"}
```

The connection goes by fields (`host`, `port`, `database`, `username`, `password`, `ssl_mode`) or
by a `connection_url` (`sslmode` in its query); a field given apart wins over the one of the URL.
The URL is never stored.

A test that doesn't connect is still a `200`; its `status` says what happened, and `message` has
the raw error of the server:

```json
{
  "status": "failed", "server_version": null, "tool_version": "pg_dump 18.6",
  "message": "password authentication failed for user \"dumpling_backup\"",
  "duration_ms": 26, "checked_at": "2026-10-30T05:27:39.860019Z"
}
```

`status` is `connected`, `incompatible` (the server is newer than the `pg_dump` of the image, which
would refuse it), `toolMissing` (no `pg_dump` where the service runs) or `failed`. The console waits
up to 90 seconds for an answer.

When editing a saved source, `?source=src_…` uses its stored password if the form sends none
(`POST /api/workspaces/docs-tour/sources/test?source=src_qnr4bf2dwuxtg3uz`).

### Create a source

```http
POST /api/workspaces/docs-tour/sources
Content-Type: application/json

{
  "name": "shop",
  "type": "postgres",
  "settings": {
    "host": "e2e-postgres", "port": 5432, "database": "shop", "username": "dumpling_backup",
    "password": "<password>", "dump_format": "custom", "ssl_mode": "disable"
  }
}
```

`201` with the source, without its password and with `"last_check": null` (saving doesn't test).
Without a password:

```json
{"violations": [{"fieldName": "settings.password", "message": "The field cannot be null", "code": "notNull"}], "type": "about:blank", "title": "Unprocessable Content", "status": 422, "instance": "/api/workspaces/docs-tour/sources"}
```

A disabled type answers `422` too, on `type`: `"This type of source is not available yet"`.

### Edit a source

```http
PUT /api/workspaces/docs-tour/sources/src_qnr4bf2dwuxtg3uz
Content-Type: application/json

{"name": "shop (plain)", "type": "postgres", "settings": {"host": "e2e-postgres", "database": "shop", "username": "dumpling_backup", "dump_format": "plain", "ssl_mode": "disable"}}
```

Answers the source. The body replaces it, except the password: without one, the saved one stays. An
edit that changes the connection clears `last_check`.

### Test a saved source

```http
POST /api/workspaces/docs-tour/sources/src_qnr4bf2dwuxtg3uz/test
```

Answers a check as [before saving](#test-a-source-before-saving), with the stored data, and keeps
it as the source's `last_check`.

### Delete a source

```http
DELETE /api/workspaces/docs-tour/sources/src_qnr4bf2dwuxtg3uz
```

`204`, only when no config backs it up:

```json
{"type": "about:blank", "title": "Conflict", "status": 409, "detail": "Configs back up this source (1): delete them or connect them to another source first.", "instance": "/api/workspaces/docs-tour/sources/src_qnr4bf2dwuxtg3uz"}
```

## Destinations

Where the backups go: an S3-compatible bucket. The `secret_access_key` is write-only: stored
encrypted and **never returned**.

### List destinations

```http
GET /api/workspaces/e2e/destinations
```

```json
[
  {
    "id": "dst_pohrlldk36tlyjd6",
    "workspace": "e2e",
    "name": "bucket",
    "type": "s3",
    "settings": {
      "endpoint": "http://e2e-s3:9000", "region": "us-east-1", "bucket": "e2e-backups",
      "access_key_id": "e2e-access", "path_style": true
    },
    "folders": ["nightly"],
    "last_check": {
      "status": "connected", "server_version": null, "tool_version": null, "message": null,
      "duration_ms": 6, "checked_at": "2026-10-30T05:16:13.474536Z"
    },
    "created_at": "2026-10-30T05:16:13.000Z",
    "updated_at": "2026-10-30T05:16:13.000Z"
  }
]
```

`folders` are the connection points of the destination on the canvas. With none, the root of the
bucket is the only one; once it has folders, configs write to one of them and the root is not a
choice. `path_style` puts the bucket in the path (`http://host/bucket/key`), as MinIO and most
self-hosted storage need.

### Get a destination

```http
GET /api/workspaces/e2e/destinations/dst_pohrlldk36tlyjd6
```

One destination, as in the list.

### Test a destination before saving

```http
POST /api/workspaces/docs-tour/destinations/test
Content-Type: application/json

{
  "name": "backups",
  "type": "s3",
  "settings": {"endpoint": "http://e2e-s3:9000", "bucket": "e2e-backups", "access_key_id": "e2e-access", "secret_access_key": "<secret>", "path_style": true},
  "folders": ["daily", "weekly"]
}
```

```json
{"status": "connected", "server_version": null, "tool_version": null, "message": null, "duration_ms": 24, "checked_at": "2026-10-30T05:28:07.676130Z"}
```

The test starts a multipart upload in each folder (or the root) and aborts it: it proves the
endpoint, the keys, the bucket and the permission to write where the backups will go, and leaves no
object. A failure is a `200` with `"status": "failed"` and the error of the storage:

```json
{"status": "failed", "server_version": null, "tool_version": null, "message": "NoSuchBucket: The specified bucket does not exist", "duration_ms": 4, "checked_at": "2026-10-30T05:28:14.896160Z"}
```

As for sources, `?destination=dst_…` uses the stored secret key of the destination being edited
when the form sends none.

### Create a destination

```http
POST /api/workspaces/docs-tour/destinations
Content-Type: application/json

{
  "name": "backups",
  "type": "s3",
  "settings": {"endpoint": "http://e2e-s3:9000", "bucket": "e2e-backups", "access_key_id": "e2e-access", "secret_access_key": "<secret>", "path_style": true},
  "folders": ["/daily/", "weekly"]
}
```

`201`:

```json
{
  "id": "dst_6zzbgd4gbnfidygl",
  "workspace": "docs-tour",
  "name": "backups",
  "type": "s3",
  "settings": {"endpoint": "http://e2e-s3:9000", "region": "us-east-1", "bucket": "e2e-backups", "access_key_id": "e2e-access", "path_style": true},
  "folders": ["daily", "weekly"],
  "last_check": null,
  "created_at": "2026-10-30T05:28:07.000Z",
  "updated_at": "2026-10-30T05:28:07.000Z"
}
```

`region` defaults to `us-east-1` and `path_style` to `false`. Folders lose the slashes around them
and come back sorted; they take lowercase letters, digits, `-`, `.`, `_` and `/` between them,
never `.` or `..` as a segment (`422` on `folders` otherwise).

### Edit a destination

```http
PUT /api/workspaces/docs-tour/destinations/dst_6zzbgd4gbnfidygl
Content-Type: application/json

{"name": "backups", "type": "s3", "settings": {"endpoint": "http://e2e-s3:9000", "bucket": "e2e-backups", "access_key_id": "e2e-access", "path_style": true}, "folders": ["daily", "weekly", "monthly"]}
```

Answers the destination (here with `"folders": ["daily", "monthly", "weekly"]`). The body replaces
it, `folders` included, except the secret key: without one, the saved one stays. Removing a folder a config writes to is refused:

```json
{"type": "about:blank", "title": "Conflict", "status": 409, "detail": "The config \"Shop daily\" writes to \"daily\": move it before removing that folder.", "instance": "/api/workspaces/docs-tour/destinations/dst_6zzbgd4gbnfidygl"}
```

### Test a saved destination

```http
POST /api/workspaces/docs-tour/destinations/dst_6zzbgd4gbnfidygl/test
```

Answers a check as [before saving](#test-a-destination-before-saving), with the stored data and
folders, and keeps it as its `last_check`.

### Delete a destination

```http
DELETE /api/workspaces/docs-tour/destinations/dst_6zzbgd4gbnfidygl
```

`204`, only when no config writes to it (`409` otherwise: `"Configs write to this destination (2):
delete them or connect them to another destination first."`). The backups already in the bucket
stay.

## Canvas

The whole workspace as the canvas draws it: every source, destination and config, each one with
its `position`.

### Get the canvas

```http
GET /api/workspaces/docs-tour/canvas
```

```json
{
  "sources": [
    {
      "id": "src_qnr4bf2dwuxtg3uz",
      "workspace": "docs-tour",
      "name": "shop (plain)",
      "type": "postgres",
      "settings": {"host": "e2e-postgres", "port": 5432, "database": "shop", "username": "dumpling_backup", "dump_format": "plain", "ssl_mode": "disable"},
      "last_check": {"status": "connected", "server_version": "18.6", "tool_version": "pg_dump 18.6", "message": null, "duration_ms": 37, "checked_at": "2026-10-30T05:27:58.379267Z"},
      "created_at": "2026-10-30T05:27:40.000Z",
      "updated_at": "2026-10-30T05:27:49.000Z",
      "position": {"x": 0.0, "y": 0.0}
    }
  ],
  "destinations": [ … ],
  "configs": [ … ],
  "ids": {}
}
```

Each node is what its own endpoint answers, plus `position` (world coordinates; `null` is off the
canvas, waiting in the toolbar). `ids` is only filled after a save.

### Save the canvas

```http
PUT /api/workspaces/docs-tour/canvas
Content-Type: application/json

{
  "sources": [
    {"id": "src_qnr4bf2dwuxtg3uz", "position": {"x": 0, "y": 0}, "name": "shop (plain)", "type": "postgres",
     "settings": {"host": "e2e-postgres", "database": "shop", "username": "dumpling_backup", "dump_format": "plain", "ssl_mode": "disable"}},
    {"id": "new_1", "position": {"x": 0, "y": 160}, "name": "shop (custom)", "type": "postgres",
     "settings": {"host": "e2e-postgres", "database": "shop", "username": "dumpling_backup", "password": "<password>", "ssl_mode": "disable"}}
  ],
  "destinations": [
    {"id": "dst_6zzbgd4gbnfidygl", "position": {"x": 480, "y": 80}, "name": "backups", "type": "s3",
     "settings": {"endpoint": "http://e2e-s3:9000", "bucket": "e2e-backups", "access_key_id": "e2e-access", "path_style": true},
     "folders": ["daily", "weekly"]}
  ],
  "configs": [
    {"id": "cfg_2revrjwd2kgwtv2d", "position": {"x": 240, "y": 0}, "name": "Shop daily", "source_id": "src_qnr4bf2dwuxtg3uz",
     "destination_id": "dst_6zzbgd4gbnfidygl", "folder": "daily", "schedule": "0 */6 * * *", "compression": "gzip",
     "object_key": "{db}/{yyyy}/{MM}/{dd}-{run_id}", "enabled": true},
    {"id": "new_2", "position": {"x": 240, "y": 160}, "name": "Shop weekly", "source_id": "new_1",
     "destination_id": "dst_6zzbgd4gbnfidygl", "folder": "weekly", "schedule": "0 4 * * 0"}
  ]
}
```

Answers the saved canvas, as [Get the canvas](#get-the-canvas), with the id each new node got:

```json
{
  "sources": [ … ],
  "destinations": [ … ],
  "configs": [
    …,
    {
      "id": "cfg_ad5z7chl3vvif6g4",
      "name": "Shop weekly",
      "source_id": "src_edygitml5at7vlev",
      "destination_id": "dst_6zzbgd4gbnfidygl",
      "folder": "weekly",
      "schedule": "0 4 * * 0",
      "next_run": "2026-11-01T04:00:00.000Z",
      …,
      "position": {"x": 240.0, "y": 160.0}
    }
  ],
  "ids": {"new_1": "src_edygitml5at7vlev", "new_2": "cfg_ad5z7chl3vvif6g4"}
}
```

The body is the whole workspace, saved in one transaction (a save that fails changes nothing):

- A node with a saved id replaces it, with the same body as its own `PUT` (a missing secret keeps
  the stored one).
- A node whose id starts with `new_` is created. The console makes those ids up, so a config can
  point at a source or destination that isn't saved yet (`"source_id": "new_1"`).
- What the body leaves out is deleted.

Each node is validated as in its own endpoint, with the path of the node in the field
(`configs[0].source_id`). A config must point at a source and a destination of the body, and a
saved id that isn't of the workspace is refused (`"Not a node of this workspace: a new one has an
id that starts with new_"`):

```json
{
  "violations": [
    {"fieldName": "configs[0].source_id", "message": "There is no such source in this workspace"},
    {"fieldName": "configs[0].destination_id", "message": "There is no such destination in this workspace"}
  ],
  "type": "about:blank", "title": "Unprocessable Content", "status": 422, "instance": "/api/workspaces/docs-tour/canvas"
}
```

### Test run

There is no endpoint of its own. The canvas's **Test run** calls, for the complete flows, the
[test of each saved source](#test-a-saved-source) and the
[test before saving of each destination](#test-a-destination-before-saving) with
`?destination=dst_…`, so the folders drawn on the canvas are the ones tested. Nothing is backed up.

## Configs

A config is a backup: a source, a destination (and one of its folders), a schedule and how the
file is named.

### List configs

```http
GET /api/workspaces/e2e/configs
```

```json
[
  {
    "id": "cfg_b2n23owtlcev45ue", "workspace": "e2e", "name": "Nightly custom",
    "source_id": "src_2jk3yrajcjupgams", "destination_id": "dst_pohrlldk36tlyjd6", "folder": "nightly",
    "schedule": "0 3 * * *", "compression": "gzip", "object_key": "{db}/{yyyy}-{MM}-{dd}-{run_id}", "enabled": true,
    "next_run": "2026-10-31T03:00:00.000Z",
    "last_run": {
      "id": "run_gmvky2okdbylpthe", "status": "success",
      "location": "e2e-backups/nightly/shop/2026-10-30-run_gmvky2okdbylpthe.dump.gz", "size_bytes": 140260,
      "error": null, "started_at": "2026-10-30T05:16:13.000Z", "finished_at": "2026-10-30T05:16:13.000Z", …
    },
    "created_at": "2026-10-30T05:16:13.000Z", "updated_at": "2026-10-30T05:16:13.000Z"
  },
  …
]
```

`next_run` is when its schedule runs next (UTC), `null` while it is disabled. `last_run` is its
newest run, as in the [run log](#run-log) (trimmed here), or `null` until it runs: the console tells
healthy from failing configs by it. `folder` is `null` for the root of the destination.

### Get a config

```http
GET /api/workspaces/e2e/configs/cfg_b2n23owtlcev45ue
```

One config, as in the list.

### Create a config

```http
POST /api/workspaces/docs-tour/configs
Content-Type: application/json

{"name": "Shop daily", "source_id": "src_qnr4bf2dwuxtg3uz", "destination_id": "dst_6zzbgd4gbnfidygl", "folder": "daily", "compression": "gzip", "enabled": true}
```

`201`:

```json
{
  "id": "cfg_2revrjwd2kgwtv2d", "workspace": "docs-tour", "name": "Shop daily",
  "source_id": "src_qnr4bf2dwuxtg3uz", "destination_id": "dst_6zzbgd4gbnfidygl", "folder": "daily",
  "schedule": "30 1 * * *", "compression": "gzip", "object_key": "{db}/{yyyy}-{MM}-{dd}-{run_id}", "enabled": true,
  "next_run": "2026-10-31T01:30:00.000Z", "last_run": null,
  "created_at": "2026-10-30T05:28:23.000Z", "updated_at": "2026-10-30T05:28:23.000Z"
}
```

A missing `schedule`, `compression` or `object_key` takes the [defaults of the
workspace](#create-a-workspace) (here its `30 1 * * *`), and a missing `folder` is the root. The
`object_key` is relative to the folder, with placeholders (`{db}`, `{yyyy}`, `{MM}`, `{dd}`,
`{run_id}`) and without extension: the service adds `.dump` or `.sql`, plus `.gz` with gzip. The
folder must be one of the destination's, or the root when it has none:

```json
{"violations": [{"fieldName": "folder", "message": "Choose one of the folders of the destination"}], "type": "about:blank", "title": "Unprocessable Content", "status": 422, "instance": "/api/workspaces/docs-tour/configs"}
```

### Edit a config

```http
PUT /api/workspaces/docs-tour/configs/cfg_2revrjwd2kgwtv2d
Content-Type: application/json

{
  "name": "Shop daily", "source_id": "src_qnr4bf2dwuxtg3uz", "destination_id": "dst_6zzbgd4gbnfidygl", "folder": "daily",
  "schedule": "0 */6 * * *", "compression": "gzip", "object_key": "{db}/{yyyy}/{MM}/{dd}-{run_id}", "enabled": false
}
```

Answers the config; disabled, its `next_run` is `null`. The body replaces it, with the same
defaults as on create.

### Delete a config

```http
DELETE /api/workspaces/docs-tour/configs/cfg_2revrjwd2kgwtv2d
```

`204`.

### Run now

```http
POST /api/workspaces/e2e/configs/cfg_b2n23owtlcev45ue/run
```

`202` with the run just started; it goes on in the background:

```json
{
  "id": "run_nxp6zspfy62edr5k", "workspace": "e2e",
  "config_id": "cfg_b2n23owtlcev45ue", "config_name": "Nightly custom",
  "source_name": "shop-custom", "source_type": "postgres",
  "destination_name": "bucket", "destination_type": "s3",
  "trigger": "manual", "status": "running",
  "location": null, "size_bytes": 0, "error": null,
  "started_at": "2026-10-30T05:26:56.000Z", "finished_at": null, "duration_ms": null
}
```

It runs the config as it is saved, enabled or not. The console follows it with
[its detail](#a-run-and-its-log) every 2 seconds until `status` is no longer `running`. A config
runs once at a time:

```json
{"type": "about:blank", "title": "Conflict", "status": 409, "detail": "This config is already running: wait for it to end.", "instance": "/api/workspaces/e2e/configs/cfg_b2n23owtlcev45ue/run"}
```

## Runs

Every run of the workspace, scheduled (`"trigger": "schedule"`) or Run now (`"manual"`). A run
keeps the names of its config, source and destination as they were, so it reads the same after
they change; deleting its config keeps the run, with `config_id` set to `null`. There is no list of
backups apart: the successful runs are it, and their `location` (bucket and key) is where each
backup is.

### Run log

```http
GET /api/workspaces/e2e/runs?status=failed&config=cfg_hleo4cvfwnc6tmtp&limit=1
```

```json
[
  {
    "id": "run_ity2nnvvzj62r7tf", "workspace": "e2e",
    "config_id": "cfg_hleo4cvfwnc6tmtp", "config_name": "Broken",
    "source_name": "shop-broken", "source_type": "postgres",
    "destination_name": "bucket", "destination_type": "s3",
    "trigger": "manual", "status": "failed",
    "location": null, "size_bytes": 0,
    "error": "Could not connect: password authentication failed for user \"dumpling_backup\"",
    "started_at": "2026-10-30T05:16:17.000Z", "finished_at": "2026-10-30T05:16:17.000Z", "duration_ms": 41
  }
]
```

`started_at` and `finished_at` are stored to the second; `duration_ms` is measured by the run itself
(a run cut by a stop of the service gets it from those times). Newest first. Every filter is optional: `status` (`running`, `success`, `failed`), `source_type`,
`destination_type`, `config` (an id) and `limit` (1 to 200, 200 by default). A value out of them is
a `400` (`"limit must be from 1 to 200"`):

```json
{"type": "about:blank", "title": "Bad Request", "status": 400, "detail": "status must be one of: running, success, failed", "instance": "/api/workspaces/e2e/runs"}
```

### A run and its log

```http
GET /api/workspaces/e2e/runs/run_nxp6zspfy62edr5k
```

```json
{
  "id": "run_nxp6zspfy62edr5k", "config_name": "Nightly custom", "status": "success",
  "location": "e2e-backups/nightly/shop/2026-10-30-run_nxp6zspfy62edr5k.dump.gz", "size_bytes": 140259,
  "error": null, "started_at": "2026-10-30T05:26:56.000Z", "finished_at": "2026-10-30T05:26:56.000Z", "duration_ms": 0,
  …,
  "log": [
    {"at": "2026-10-30T05:26:56.473057Z", "message": "Checking the connection to shop-custom"},
    {"at": "2026-10-30T05:26:56.540295Z", "message": "Connected: 18.6, pg_dump 18.6"},
    {"at": "2026-10-30T05:26:56.540858Z", "message": "Dumping into bucket: e2e-backups/nightly/shop/2026-10-30-run_nxp6zspfy62edr5k.dump.gz (gzip)"},
    {"at": "2026-10-30T05:26:56.732572Z", "message": "Uploaded 140259 bytes in 0 s"}
  ]
}
```

The run as in the log (trimmed here), plus its `log`: technical lines, in English, like the tools
it runs. The log is written when the run ends; while it runs, `size_bytes` and `location` already
show the progress. A failed run keeps the error of `pg_dump` or of the storage in `error`, which
names hosts and databases but never passwords:

```json
"log": [
  {"at": "2026-10-30T05:16:17.067286Z", "message": "Checking the connection to shop-broken"},
  {"at": "2026-10-30T05:16:17.086963Z", "message": "Failed: Could not connect: password authentication failed for user \"dumpling_backup\""}
]
```
