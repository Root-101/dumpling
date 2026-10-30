# Dumpling Service

The backend of dumpling, on [Winter](https://pub.dev/packages/winter). It runs the backup schedules,
serves the API of the console under `/api` and, in the release image, the console's web build as
static files (every unknown route answers `index.html`, so the console's routes work on reload).

In development it reads a `service/.env` (gitignored) with at least `DUMPLING_ADMIN_USER`,
`DUMPLING_ADMIN_PASSWORD` and `JWT_SECRET` (see `../.env.example`):

```bash
cd service && fvm dart run lib/main.dart   # http://localhost:8080
fvm dart test
fvm dart run slang                         # after changing lib/i18n/*.i18n.yaml
```

## End-to-end test

`tool/e2e/run.sh` builds the image (the `Dockerfile` at the root of the repo) and runs it
next to PostgreSQL and an S3 server in Docker. Through the API it backs up a seeded database in
both dump formats, downloads each file from the bucket, restores it as
[`docs/restore.md`](../docs/restore.md) says and compares the rows; a wrong password must fail.
It needs Docker, `curl` 7.75+ and `python3`:

```bash
service/tool/e2e/run.sh                     # SKIP_BUILD=1 to reuse dumpling:e2e, KEEP=1 to look after
```

The S3 server is [feather-io](https://github.com/Root-101/feather-io) by default
(`S3_IMAGE=feather-io:1.0.0-rc.7`, built from its repo); `S3_KIND=minio` with a MinIO image in
`S3_IMAGE` uses MinIO instead (tested with `elestio/minio`).
