# Console design

The visual design of the console and the brand, exported from their Claude Design canvas so they
can be seen without access to it:

- [`dumpling-console-design.pdf`](dumpling-console-design.pdf): every screen worth keeping, one
  per page, grouped by section.
- [`screens/`](screens): the same screens as PNG (1440 × 900), used by
  [`../console.md`](../console.md) and the [README](../../README.md).
- [`brand/`](brand): the icon as SVG in its versions, and [`brand/images/`](brand/images), the
  logo sheets and presentation images, described in [`../brand.md`](../brand.md).

Most loading states (one is kept as an example), the intermediate states of the forms and the
screens planned for 0.2.0 (Account) stay only in the canvas.

## Source

One Claude Design canvas, "Dumpling": https://claude.ai/artifact/8ZG7z26F5hn1KMsV2a1wvN. Its
pages are **Screens** (a replica of every screen and state of the console), **Logo** (the icon,
its versions, its rules and the identity images) and **Later · 0.2.0**.

## Keeping it up to date

**When a change touches what the console looks like, update the canvas in the same change, and
before every release regenerate this export and review [`../console.md`](../console.md)** (a new
screen, URL or action gets its section there).

1. Download the canvas files into a folder, as the artifact serves them: `project/canvas.json`,
   `project/*.dc.html` and the uploaded assets the artboards use (the logos of the source and
   destination types), each saved as `<asset id>.svg`.
2. From the root of the repo, with Chrome and ffmpeg installed:

   ```bash
   python docs/design/tool/export.py <that folder>
   ```

   It renders the artboards listed in `SCREENS` and `BRAND` with headless Chrome
   (`tool/support.js` stands in for the canvas runtime: it runs each artboard's `renderVals()`
   with its default props) and rewrites `screens/`, `brand/images/` and the PDF. A new screen goes
   into `SCREENS`; a shot of an artboard in another state (the rail expanded) lists the text to
   replace in it.
3. Look at the result and commit it with the change.

The icon SVGs in `brand/` are kept by hand, with the values of the canvas's `Logo · Main`
artboard.
