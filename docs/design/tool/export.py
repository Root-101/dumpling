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
from urllib.parse import quote

DESIGN = Path(__file__).resolve().parent.parent
CHROME = r'C:\Program Files\Google\Chrome\Application\chrome.exe' if sys.platform == 'win32' \
    else 'google-chrome'

# (section, file name, artboard, caption, tweaks): the screens worth keeping, in reading order. The
# tweaks (a query string, read by support.js) put the artboard in the state of that shot
SCREENS = [
    ('Access', 'login', 'Login', 'Sign in'),
    ('Access', 'login-error', 'Login', 'Sign in: wrong password', 'state=Wrong password'),
    ('Workspaces', 'workspaces', 'Workspaces-List', 'Workspaces'),
    ('Workspaces', 'new-workspace', 'Workspaces', 'New workspace'),
    ('Workspaces', 'workspace-settings', 'Settings', 'Workspace settings'),
    ('Workspaces', 'workspace-delete', 'Settings', 'Delete a workspace, confirmed with its name', 'state=Delete · typed'),
    ('Workspaces', 'import', 'Workspaces-Import', 'Import workspaces: drop or choose an exported file', 'step=Drop'),
    ('Workspaces', 'import-file', 'Workspaces-Import', 'Import workspaces: what the file adds, a taken name as Name (2)',
     'step=File chosen'),
    ('Pipeline editor', 'canvas', 'Proposal-A', 'The canvas: source, config and destination'),
    ('Pipeline editor', 'config', 'Proposal-A-Config', 'A config in its dialog in steps'),
    ('Pipeline editor', 'getting-started', 'Proposal-A', 'An empty workspace and its guide', 'state=Empty'),
    ('Backups', 'backups', 'Backups', 'Backups: health and every config'),
    ('Backups', 'backups-filters', 'Backups', 'Backups: filters', 'panel=Filters'),
    ('Backups', 'backups-sort', 'Backups', 'Backups: sort', 'panel=Sort'),
    ('Backups', 'backups-run', 'Backups', 'The recent runs of a backup', 'panel=Recent runs'),
    ('Sources', 'sources', 'Sources-List', 'Sources, list view'),
    ('Sources', 'sources-grid', 'Sources-List', 'Sources, grid view', 'view=Grid'),
    ('Sources', 'new-source', 'Sources', 'New source: the connection step', 'step=Connection'),
    ('Sources', 'source-menu', 'Sources-List', 'The options of a source', 'dialog=Row menu'),
    ('Sources', 'source-delete', 'Sources-List', 'Delete a source', 'dialog=Delete'),
    ('Sources', 'source-detail', 'Source-Detail', 'Source detail'),
    ('Destinations', 'destinations', 'Destinations-List', 'Destinations, list view with the folders of a bucket'),
    ('Destinations', 'destinations-grid', 'Destinations-List', 'Destinations, grid view', 'view=Grid'),
    ('Destinations', 'new-destination', 'Destinations', 'New destination: the connection step', 'step=Connection'),
    ('Destinations', 'destination-menu', 'Destinations-List', 'The options of a destination', 'dialog=Row menu'),
    ('Destinations', 'destination-delete', 'Destinations-List', 'Delete a destination', 'dialog=Delete'),
    ('Destinations', 'destination-detail', 'Destination-Detail', 'Destination detail'),
    ('Run log', 'run-log', 'Events', 'Run log'),
    ('Run log', 'run-log-filters', 'Events', 'Run log: filters', 'panel=Filters'),
    ('Run log', 'run-failed', 'Events-Run', 'A failed run: the failed step, the error and the log', 'run=Failed'),
    ('Run log', 'run-running', 'Events-Run', 'A run in progress', 'run=Running'),
    ('Run log', 'run-succeeded', 'Events-Run', 'A run that succeeded: where the file went', 'run=Succeeded'),
    ('API keys', 'api-keys', 'ApiKeys', 'API keys: what each one may do, on which configs, its last use'),
    ('API keys', 'api-keys-filters', 'ApiKeys', 'API keys: filters by access, config and permission', 'panel=Filters'),
    ('API keys', 'new-api-key', 'ApiKeys-New', 'New API key: a template, and the permissions one by one'),
    ('API keys', 'api-key-created', 'ApiKeys-Created', 'A new key, shown once, and how to use it'),
    ('Errors', 'not-found', 'Errors', 'Not found', 'error=Not found'),
    ('Errors', 'connection-lost', 'Backups', 'Connection lost', 'state=Offline'),
    ('Errors', 'session-expired', 'Errors', 'Session expired', 'error=Session expired'),
    ('Navigation', 'rail-expanded', 'Proposal-A', 'The rail, expanded', 'menu=Expanded'),
    ('Loading', 'loading', 'Backups', 'A screen while it loads: a skeleton of itself', 'state=Loading'),
    ('Loading', 'splash', 'Splash', 'The console while it starts'),
    ('Loading', 'init-error', 'Splash', 'The console when it could not start', 'state=Couldn’t start'),
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
    for i, (section, name, board, caption, *tweaks) in enumerate(SCREENS, 1):
        frame = canvas['boards'][f'{board}.dc.html']
        page = f'{board}.dc.html' + (f'?{quote(tweaks[0], safe="=&")}' if tweaks else '')
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
