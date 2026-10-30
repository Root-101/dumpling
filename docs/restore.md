# Restoring a backup

Dumpling writes each backup as one file in your bucket; restoring it is plain PostgreSQL tooling:
`pg_restore` or `psql`. Dumpling itself doesn't restore (yet), so the steps below run on any
machine that can reach the bucket and the database.

## 1. Find the file

Open the **Run log** of the workspace and expand the run you want: **File** shows where it went,
as `bucket/key` (e.g. `backups/shop/orders/2026-10-20-run_xkq3….dump.gz`). The key comes from
the object key of the config; its extension tells you how to restore it:

| Extension  | What it is                           | Restore with                |
|------------|--------------------------------------|-----------------------------|
| `.dump`    | `pg_dump` custom format (`-Fc`)      | `pg_restore`                |
| `.dump.gz` | custom format, gzipped by the config | `gunzip`, then `pg_restore` |
| `.sql`     | plain SQL                            | `psql`                      |
| `.sql.gz`  | plain SQL, gzipped                   | `gunzip -c … \| psql`       |

## 2. Download it

With the AWS CLI (any S3-compatible endpoint works; for MinIO, feather-io and similar add
`--endpoint-url` and path-style addressing):

```bash
aws configure set default.s3.addressing_style path      # only for S3-compatible servers
aws s3 cp s3://backups/shop/orders/2026-10-20-run_xkq3.dump.gz . \
  --endpoint-url https://s3.example.com                 # leave it out for AWS
```

`rclone copy`, `mc cp` or the web console of your storage work just as well.

## 3. Restore it

Use a `pg_restore` / `psql` of the **same major version as the `pg_dump` that wrote the file, or
newer**: the Run log shows it in the log of the run (`Connected: 18.3, pg_dump 18.2`). Restoring
into a **new, empty database** is the safe default: you can compare it with the live one before
switching.

### Custom format (`.dump`, `.dump.gz`)

```bash
gunzip -k 2026-10-20-run_xkq3.dump.gz             # only if it ends in .gz

pg_restore --list 2026-10-20-run_xkq3.dump | head   # optional: what it contains

createdb -h db.internal -U postgres orders_restored
pg_restore -h db.internal -U postgres -d orders_restored \
  --no-owner --no-privileges -j 4 2026-10-20-run_xkq3.dump
```

- `--no-owner --no-privileges`: the objects belong to the user that restores, not to the roles of
  the original server (which may not exist here). Leave them out to keep the original owners and
  grants when the roles exist.
- `-j 4`: restores 4 tables at a time; it needs the file on disk (not a pipe).
- To overwrite an **existing** database instead, add `--clean --if-exists`: it drops each object of
  the dump before creating it again. Objects that aren't in the dump are left alone.

### Plain SQL (`.sql`, `.sql.gz`)

```bash
createdb -h db.internal -U postgres orders_restored
gunzip -c 2026-10-20-run_xkq3.sql.gz \
  | psql -h db.internal -U postgres -d orders_restored -v ON_ERROR_STOP=1 --single-transaction
```

For a `.sql` file, `psql … -f 2026-10-20-run_xkq3.sql` with the same options. A plain dump has no
`DROP` statements: restore it into an empty database. `ON_ERROR_STOP` and `--single-transaction`
make a failure leave the database as it was, instead of half restored.

### Without PostgreSQL tools installed

The official image has them; mount the folder with the file:

```bash
docker run --rm -it -v "$PWD:/backup" postgres:18 \
  pg_restore -h db.internal -U postgres -d orders_restored --no-owner --no-privileges \
  /backup/2026-10-20-run_xkq3.dump
```

## 4. Check it

Count the rows of a few tables in both databases, or let your application read from the restored
one before you switch:

```bash
psql -h db.internal -U postgres -d orders_restored -c "select count(*) from orders"
```

A backup you never restored is a guess: try this once with a recent file before you need it.
