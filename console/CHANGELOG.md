# Changelog

## 0.0.1

Proof of concept of the pipeline canvas, with a demo pipeline (nothing is saved yet).

- Sources, configs and destinations as nodes: drag them, click to select a config.
- Drag from a source port to a folder or bucket to create a config, or onto a config to give it
  that source; from a config's out port to (re)connect it to a destination.
- Click a connection and remove it (its trash button or `Del`): sources, configs and destinations
  can be left unconnected. `Del` with no connection picked deletes the selected config.
- Only complete flows (database → config → destination) are kept: everything else (a config missing
  an end, a database or destination with no complete config, and their wires) is drawn in amber,
  and a warning says it is discarded when the pipeline is saved.
- The add toolbar, the warning and the view controls (with their popovers) sit on the left.
- Right click: on a connection or a node, remove / delete it; on empty space, add a database or a
  destination there. A click on empty space clears the selection.
- Pan only with Space + drag (or the middle button), scroll or arrow keys; zoom (Ctrl + scroll,
  `+` / `-`), center (`F`), reset (`0`), close the config (`Esc`).
- Shortcuts help (`?` or the keyboard button) and canvas settings open above the view controls,
  one at a time.
- Inspector of the selected config: frequency, object key and the path the next run writes.
