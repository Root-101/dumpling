"""Exports the console design and the brand images from the files of the Claude Design canvas.

    python docs/design/tool/export.py <folder>

<folder> holds the canvas files as the artifact serves them: `project/canvas.json`,
`project/*.dc.html` and the uploaded assets the artboards use, each as `<asset id>.svg` (the logos
of the source and destination types). It renders the artboards listed in SCREENS and BRAND with
headless Chrome (support.js stands in for the canvas runtime) and rewrites `docs/design/screens/`,
`docs/design/brand/images/` and `docs/design/dumpling-console-design.pdf`. Needs Chrome and ffmpeg.
"""
import json
import re
import shutil
import subprocess
import sys
import tempfile
import threading
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

DESIGN = Path(__file__).resolve().parent.parent
CHROME = r'C:\Program Files\Google\Chrome\Application\chrome.exe' if sys.platform == 'win32' \
    else 'google-chrome'

# (section, file name, artboard, caption): the screens worth keeping, in reading order. A fifth
# item lists (text, replacement) pairs that put the artboard in another state for that shot
SCREENS = [
    ('Access', 'login', 'Login', 'Sign in'),
    ('Access', 'login-error', 'Login-Error', 'Sign in: wrong password'),
    ('Workspaces', 'workspaces', 'Workspaces-List', 'Workspaces'),
    ('Workspaces', 'new-workspace', 'Workspaces', 'New workspace'),
    ('Workspaces', 'workspace-settings', 'Settings', 'Workspace settings'),
    ('Workspaces', 'workspace-delete', 'Settings-Delete', 'Delete a workspace, confirmed with its name'),
    ('Pipeline editor', 'canvas', 'Proposal-A', 'The canvas: source, config and destination'),
    ('Pipeline editor', 'config', 'Proposal-A-Config', 'A config in its dialog in steps'),
    ('Pipeline editor', 'getting-started', 'Getting-Started', 'An empty workspace and its guide'),
    ('Backups', 'backups', 'Backups', 'Backups: health and every config'),
    ('Backups', 'backups-filters', 'Backups-Filters', 'Backups: filters'),
    ('Backups', 'backups-sort', 'Backups-Sort', 'Backups: sort'),
    ('Backups', 'backups-run', 'Backups-Run', 'The recent runs of a backup'),
    ('Sources', 'sources', 'Sources-List', 'Sources, list view'),
    ('Sources', 'sources-grid', 'Sources-Grid', 'Sources, grid view'),
    ('Sources', 'new-source', 'Sources', 'New source: the connection step'),
    ('Sources', 'source-menu', 'Sources-Menu', 'The options of a source'),
    ('Sources', 'source-delete', 'Sources-Confirm', 'Delete a source'),
    ('Sources', 'source-detail', 'Source-Detail', 'Source detail'),
    ('Destinations', 'destinations', 'Destinations-List', 'Destinations, list view with the folders of a bucket'),
    ('Destinations', 'destinations-grid', 'Destinations-Grid', 'Destinations, grid view'),
    ('Destinations', 'new-destination', 'Destinations', 'New destination: the connection step'),
    ('Destinations', 'destination-menu', 'Destinations-Menu', 'The options of a destination'),
    ('Destinations', 'destination-delete', 'Destinations-Confirm', 'Delete a destination'),
    ('Destinations', 'destination-detail', 'Destination-Detail', 'Destination detail'),
    ('Run log', 'run-log', 'Events', 'Run log'),
    ('Run log', 'run-log-filters', 'Events-Filters', 'Run log: filters'),
    ('Run log', 'run-failed', 'Events-Run', 'A failed run: the failed step, the error and the log'),
    ('Run log', 'run-running', 'Events-Run-Running', 'A run in progress'),
    ('Run log', 'run-succeeded', 'Events-Run-Success', 'A run that succeeded: where the file went'),
    ('Errors', 'not-found', 'Not-Found', 'Not found'),
    ('Errors', 'connection-lost', 'Offline', 'Connection lost'),
    ('Errors', 'session-expired', 'Session-Expired', 'Session expired'),
    ('Navigation', 'rail-expanded', 'Proposal-A', 'The rail, expanded from its notch',
     [('class="rail-t"', 'class="rail-t" checked')]),
    ('Loading', 'loading', 'Backups-Loading', 'A screen while it loads: a skeleton of itself'),
]

# (file name, artboard): the brand images, at their size on the canvas
BRAND = [
    ('logo.png', 'Logo-C8'),
    ('logo-white.png', 'Logo-C8-White'),
    ('logo-black.png', 'Logo-C8-Black'),
    ('logo-usage.png', 'Logo-Usage'),
    ('logo-meaning.png', 'Logo-Meaning'),
    ('identity.png', 'Identity-Final'),
    ('manifesto.png', 'Manifesto'),
]


class QuietHandler(SimpleHTTPRequestHandler):
    def log_message(self, *args):
        pass


def shot(port: int, page: str, w: int, h: int, out: Path) -> None:
    raw = out.with_suffix('.raw.png')
    # Headless Chrome takes ~96 px of the window height: render taller and crop
    subprocess.run([CHROME, '--headless=new', '--disable-gpu', '--hide-scrollbars',
                    '--force-device-scale-factor=1', f'--window-size={w},{h + 96}',
                    '--virtual-time-budget=8000', f'--screenshot={raw}',
                    f'http://127.0.0.1:{port}/{page}'], check=True, capture_output=True)
    subprocess.run(['ffmpeg', '-loglevel', 'error', '-y', '-i', str(raw),
                    '-vf', f'crop={w}:{h}:0:0', str(out)], check=True)
    raw.unlink()
    print(out.relative_to(DESIGN))


def fresh(folder: Path) -> Path:
    # Emptied rather than deleted: on Windows a folder open elsewhere can't be removed
    folder.mkdir(parents=True, exist_ok=True)
    for old in folder.glob('*.png'):
        old.unlink()
    return folder


def main(source: Path) -> None:
    canvas = json.loads((source / 'project/canvas.json').read_text(encoding='utf-8'))
    work = Path(tempfile.mkdtemp(prefix='dumpling-design-'))
    (work / '_blob').mkdir()
    for asset in source.glob('*.svg'):
        shutil.copy(asset, work / '_blob')
    for f in (source / 'project').glob('*.dc.html'):
        # The canvas serves its assets without an extension; here they need one for their type
        text = re.sub(r'/_blob/([0-9a-f]{32})', r'/_blob/\1.svg', f.read_text(encoding='utf-8'))
        (work / f.name).write_text(text, encoding='utf-8')
    shutil.copy(Path(__file__).parent / 'support.js', work)

    server = ThreadingHTTPServer(('127.0.0.1', 0), partial(QuietHandler, directory=work))
    threading.Thread(target=server.serve_forever, daemon=True).start()
    port = server.server_address[1]

    screens = fresh(DESIGN / 'screens')
    pages = []
    for i, (section, name, board, caption, *subs) in enumerate(SCREENS, 1):
        frame = canvas['boards'][f'{board}.dc.html']
        page = f'{board}.dc.html'
        if subs:
            text = (work / page).read_text(encoding='utf-8')
            for a, b in subs[0]:
                text = text.replace(a, b)
            page = f'{name}.dc.html'
            (work / page).write_text(text, encoding='utf-8')
        out = screens / f'{i:02d}-{name}.png'
        shot(port, page, frame['w'], frame['h'], out)
        pages.append(f'<div class="p"><div><div class="s">{section}</div><h1>{caption}</h1></div>'
                     f'<img src="{out.as_uri()}"></div>')

    images = fresh(DESIGN / 'brand/images')
    for name, board in BRAND:
        frame = canvas['boards'][f'{board}.dc.html']
        shot(port, f'{board}.dc.html', frame['w'], frame['h'], images / name)

    html = work / 'print.html'
    html.write_text(PRINT.replace('<!--pages-->', '\n'.join(pages)), encoding='utf-8')
    pdf = DESIGN / 'dumpling-console-design.pdf'
    subprocess.run([CHROME, '--headless=new', '--disable-gpu', '--no-pdf-header-footer',
                    '--virtual-time-budget=8000', f'--print-to-pdf={pdf}', html.as_uri()],
                   check=True, capture_output=True)
    server.shutdown()
    shutil.rmtree(work)
    print(pdf.name)


PRINT = """<!doctype html><html><head><meta charset="utf-8">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;700&display=swap">
<style>
@page{size:1520px 1060px;margin:0}
body{margin:0;background:#0d0c12;color:#fff;font-family:"DM Sans",system-ui,sans-serif}
.p{width:1520px;height:1060px;box-sizing:border-box;padding:36px 40px;page-break-after:always;
   display:flex;flex-direction:column;gap:18px}
.p img{width:1440px;border:1px solid #2c2939;border-radius:8px}
.s{color:#9d8fd0;font-size:16px;letter-spacing:1px;text-transform:uppercase}
h1{margin:0;font-size:28px}
.cover{justify-content:center;align-items:center;text-align:center}
.cover h1{font-size:72px}.cover h1 span{color:#e6b77e}
</style></head><body>
<div class="p cover"><h1>dump<span>·</span>ling</h1>
<p style="font-size:24px;color:#8c8a98">Console design · 0.1.0</p></div>
<!--pages-->
</body></html>"""

if __name__ == '__main__':
    main(Path(sys.argv[1]))
