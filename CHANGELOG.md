# Changelog

What changes in each version of Dumpling, from 0.1.0. The detail of each package is in the
changelogs of [`service/`](service/CHANGELOG.md) and [`console/`](console/CHANGELOG.md); the
release candidates before 0.1.0 are summed up in the [roadmap](ROADMAP.md#010).

## 0.1.2

- **Export and import of workspaces.** Workspaces exports every workspace to a JSON file, and each
  card exports its own: the canvas (sources, destinations, configs and where they sit), the
  credentials encrypted as they are stored and the run log of the last month. *Import* opens a
  dialog where the file is dropped or chosen; it shows what it adds and adds it, a name already
  taken as `Prod (2)`. The credentials only decrypt with the same `SECRETS_ENCRYPTION_KEY` as the
  Dumpling that exported them. It is how the data crosses a version that changes the schema of
  the database (see [Upgrading](README.md#upgrading)).
- **The image is published** on each release, for amd64 and arm64:
  `ghcr.io/root-101/dumpling:<version>` (`latest`, the last one without `-rc`). The
  `docker-compose.yml` runs it instead of building the repo, so it and `.env.example` are all
  that is needed; `PG_VERSION` is only a build arg now (the published image carries 18).
- API: `GET /api/export` (`?workspace=<slug>` for one) and `POST /api/import`, with the
  permissions `workspace.export` and `workspace.import`.
- Console: the settings of a workspace behind a gear; in the delete confirmation the name to type
  stands out, and Enter deletes once it matches. In Backups, a next run days away reads
  `30 d 5 h`, and the clock at the foot of the table ticks on its own. In Spanish, the screens of
  sources and destinations say *origen* and *destino*. A disabled config shows *Disabled*
  instead of its cron, and its dialog turns the cron off with it.

## 0.1.1

- No changes in the service or the console: the README drops its Railway section, now that the
  [Railway template](https://railway.com/deploy/dumpling) explains the deploy in its overview.

## 0.1.0

The first version, built over the release candidates `0.1.0-rc.1` to `rc.8`. Since `rc.8`:

- Service: Winter 1.0.0, its first stable version; deleting a workspace cancels the schedules of
  its backups at once; the route table is no longer logged at start.
- Console: the source and destination forms in steps, with the connection test next to its
  fields; an ⓘ by the cron of a config; the next backup counts down by the second and reloads once
  due; the splash of the design; it starts in the language of the browser when it is Spanish;
  locations, logs, errors and connection values can be selected and copied.
