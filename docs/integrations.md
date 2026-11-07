# Integrations

Other systems use Dumpling through its API with an **API key** of a workspace: a deploy pipeline
that backs up its database before running a migration, a script, a dashboard that reads the run
log. This guide shows the most common one, a backup before a deploy; the whole API is in
[`api.md`](api.md).

## 1. Create a key

In the console, **API keys** in the rail of the workspace, then **New API key**:

- **Name:** what uses it (`deploy-key`). The run log shows it on the runs it starts.
- **Access:** *Run backups* is enough for a pipeline: it starts backups and follows their runs.
  The permissions can also be marked one by one; each one says what it allows.
- **Only some configs:** limit it to the backup of the database the pipeline deploys. It runs only
  those configs and sees only their runs (and can't create configs nor use the canvas).

The key (`dmp_…`) is shown once: copy it into a secret of your pipeline (`DUMPLING_KEY`). Keys
don't expire; to renew one, create another and delete the old one.

## 2. Start a backup and wait for it

The id of the config is in its URL in the console, or in
[`GET /api/workspaces/{slug}/configs`](api.md#list-configs).

```sh
#!/bin/sh
# Backs up before migrating: fails (and stops the deploy) if the backup fails
set -eu
URL="https://dumpling.example.com/api/workspaces/production"
CONFIG="cfg_b2n23owtlcev45ue"

run=$(curl -fsS -X POST "$URL/configs/$CONFIG/run" \
  -H "Authorization: Bearer $DUMPLING_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"label\": \"$VERSION\"}" | jq -r .id)

# Follows the run until it ends; its last event says how
curl -fsSN "$URL/runs/$run/events" -H "Authorization: Bearer $DUMPLING_KEY" \
  | grep -m1 -A1 '^event: end' | tail -1 | grep -q '"status":"success"'
```

- **The label** (`$VERSION`, a tag or a commit: letters, digits, `.`, `_` or `-`, up to 64) names
  the run in the run log: *API · deploy-key* with `v1.4.2` under it, and the search finds it, so the
  backup of before each version is easy to find.
- **A backup already running:** the run waits its turn (`queued`) and starts when that one ends, so
  the backup is always from right before the migration.
- **The events** come as [Server-Sent Events](api.md#follow-a-run): one with the run as it changes,
  and `end` with the run when it finishes. A comment every 15 s keeps proxies from closing the
  connection. If it drops, ask again: a run that ended answers `end` at once.

In GitHub Actions, the same as a step before the migration:

```yaml
- name: Back up the database
  env:
    DUMPLING_KEY: ${{ secrets.DUMPLING_KEY }}
    VERSION: ${{ github.ref_name }}
  run: ./scripts/backup-before-deploy.sh
```

## Basic auth

Tools that only take a user and a password can use the key that way: the user is the key's id
(`key_…`, in the list of keys) and the password the part of the key after its second `_`.

```sh
curl -u "key_7h2k9q4mxcd5fe3a:4fKq9ZtR2wLx8NvB1cHs6YpJ0eMa3UdG" \
  https://dumpling.example.com/api/workspaces/production/runs?trigger=api
```

## What a key can't do

A key reaches only its workspace and the permissions it was given; never the admin's session, other
workspaces, export, import or the keys themselves. A wrong key is a `401` and counts as a failed
login of its IP. Deleting a key cuts it at its next request; the runs it started stay in the run
log. More in [`SECURITY.md`](../SECURITY.md).
