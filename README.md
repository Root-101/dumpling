# Dumpling

Back up databases on a schedule and store the dumps in S3 (more databases and destinations later).

- `service/`: backend in [Winter](https://pub.dev/packages/winter); runs the schedules and serves the console.
- `console/`: web UI in Flutter Web, served by the service as static files (no separate deploy).

Version 0.0.1 is a proof of concept of the pipeline canvas. See each folder's README to run it.
