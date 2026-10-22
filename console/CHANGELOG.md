# Changelog

## 0.0.1

Proof of concept of the pipeline canvas, with a demo pipeline (nothing is saved yet).

- Sources, configs and destinations as nodes: drag them, click to select a config.
- Drag from a source port to a folder or bucket to create a config; from a config's out port to
  move it to another destination. A source keeps at least one config.
- Pan (drag the background, Space + drag, scroll, arrow keys), zoom (Ctrl + scroll, `+` / `-`),
  center (`F`), reset (`0`), close the config (`Esc`) and the shortcuts help (`?`).
- Inspector of the selected config: frequency, object key and the path the next run writes.
