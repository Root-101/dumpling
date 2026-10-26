"""The end-to-end test of Dumpling, through its API, as the console uses it.

run.sh starts PostgreSQL (with a seeded `shop` database), an S3 server and the Dumpling image, then
runs this. It backs up the database to the bucket in both dump formats, downloads each file,
restores it into a new database and compares the rows; a source with a wrong password must fail
its test and its run. Only the standard library: python3 is all it needs.

Variables (run.sh sets them): DUMPLING_URL, ADMIN_USER, ADMIN_PASSWORD, PG_HOST (as Dumpling sees
it), PG_CONTAINER, PG_USER and PG_PASSWORD (the read-only role Dumpling uses), PG_ADMIN (the owner,
for the restores), S3_URL (from here), S3_ENDPOINT (as Dumpling sees it), S3_ACCESS, S3_SECRET,
S3_BUCKET.
"""

import datetime
import gzip
import hashlib
import hmac
import json
import os
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

E = os.environ
API = E['DUMPLING_URL'].rstrip('/') + '/api'
token = None


def call(method, path, body=None, expect=None):
    request = urllib.request.Request(
        API + path, method=method, data=None if body is None else json.dumps(body).encode())
    request.add_header('Content-Type', 'application/json')
    if token:
        request.add_header('Authorization', 'Bearer ' + token)
    try:
        with urllib.request.urlopen(request) as response:
            status, raw = response.status, response.read()
    except urllib.error.HTTPError as error:
        status, raw = error.code, error.read()
    data = json.loads(raw) if raw else None
    if expect is not None and status != expect:
        sys.exit(f'FAIL {method} {path}: {status} (expected {expect}) {data}')
    return data


def step(text):
    print(f'--- {text}', flush=True)


def check(condition, text):
    if not condition:
        sys.exit(f'FAIL {text}')
    print(f'ok  {text}', flush=True)


def s3_get(key):
    """GET of an object, signed with SigV4 (path style)."""
    url = urllib.parse.urlsplit(E['S3_URL'])
    path = '/' + E['S3_BUCKET'] + '/' + urllib.parse.quote(key)
    now = datetime.datetime.now(datetime.timezone.utc)
    amz_date, day = now.strftime('%Y%m%dT%H%M%SZ'), now.strftime('%Y%m%d')
    empty = hashlib.sha256(b'').hexdigest()
    headers = {'host': url.netloc, 'x-amz-content-sha256': empty, 'x-amz-date': amz_date}
    signed = ';'.join(sorted(headers))
    canonical = '\n'.join(
        ['GET', path, ''] + [f'{k}:{headers[k]}' for k in sorted(headers)] + ['', signed, empty])
    scope = f'{day}/us-east-1/s3/aws4_request'
    to_sign = '\n'.join(
        ['AWS4-HMAC-SHA256', amz_date, scope, hashlib.sha256(canonical.encode()).hexdigest()])
    key_ = ('AWS4' + E['S3_SECRET']).encode()
    for part in (day, 'us-east-1', 's3', 'aws4_request'):
        key_ = hmac.new(key_, part.encode(), hashlib.sha256).digest()
    signature = hmac.new(key_, to_sign.encode(), hashlib.sha256).hexdigest()
    request = urllib.request.Request(E['S3_URL'].rstrip('/') + path, headers={
        'x-amz-content-sha256': empty, 'x-amz-date': amz_date,
        'Authorization': f'AWS4-HMAC-SHA256 Credential={E["S3_ACCESS"]}/{scope}, '
                         f'SignedHeaders={signed}, Signature={signature}'})
    with urllib.request.urlopen(request) as response:
        return response.read()


def psql(database, sql):
    out = subprocess.run(
        ['docker', 'exec', E['PG_CONTAINER'], 'psql', '-U', E['PG_ADMIN'], '-d', database, '-Atc',
         sql], check=True, capture_output=True, text=True)
    return out.stdout.strip()


def restore(data, extension, database):
    """Restores [data] into a new [database], as docs/restore.md says."""
    if extension.endswith('.gz'):
        data = gzip.decompress(data)
    subprocess.run(['docker', 'exec', E['PG_CONTAINER'], 'createdb', '-U', E['PG_ADMIN'],
                    database], check=True)
    command = (['pg_restore', '--no-owner', '--no-privileges', '-d', database]
               if '.dump' in extension else
               ['psql', '-q', '-v', 'ON_ERROR_STOP=1', '--single-transaction', '-d', database])
    subprocess.run(['docker', 'exec', '-i', E['PG_CONTAINER'], *command[:1], '-U', E['PG_ADMIN'],
                    *command[1:]], input=data, check=True, capture_output=True)


def run_now(workspace, config):
    run = call('POST', f'/workspaces/{workspace}/configs/{config}/run', expect=202)
    deadline = time.time() + 120
    while run['status'] == 'running':
        if time.time() > deadline:
            sys.exit(f'FAIL run {run["id"]} still running after 2 minutes')
        time.sleep(1)
        run = call('GET', f'/workspaces/{workspace}/runs/{run["id"]}', expect=200)
    return run


def main():
    global token
    step('the service answers')
    deadline = time.time() + 60
    while True:
        try:
            call('GET', '/auth/session')
            break
        except OSError:
            if time.time() > deadline:
                sys.exit('FAIL the service did not answer in 60 s')
            time.sleep(1)

    step('login')
    call('POST', '/auth/login', {'username': E['ADMIN_USER'], 'password': 'wrong'}, expect=401)
    check(True, 'a wrong password is refused')
    token = call('POST', '/auth/login',
                 {'username': E['ADMIN_USER'], 'password': E['ADMIN_PASSWORD']},
                 expect=200)['access_token']

    step('workspace, sources and destination')
    ws = call('POST', '/workspaces', {'name': 'E2E'}, expect=201)['slug']
    postgres = {'host': E['PG_HOST'], 'port': 5432, 'database': 'shop',
                'username': E['PG_USER'], 'password': E['PG_PASSWORD']}
    sources = {}
    for name, fmt in (('shop-custom', 'custom'), ('shop-plain', 'plain')):
        source = call('POST', f'/workspaces/{ws}/sources', {
            'name': name, 'type': 'postgres', 'settings': {**postgres, 'dump_format': fmt}},
            expect=201)
        test = call('POST', f'/workspaces/{ws}/sources/{source["id"]}/test', expect=200)
        check(test['status'] == 'connected', f'{name} connects ({test.get("tool_version")})')
        sources[fmt] = source['id']
    broken = call('POST', f'/workspaces/{ws}/sources', {
        'name': 'shop-broken', 'type': 'postgres',
        'settings': {**postgres, 'password': 'not-the-password', 'dump_format': 'custom'}},
        expect=201)['id']
    test = call('POST', f'/workspaces/{ws}/sources/{broken}/test', expect=200)
    check(test['status'] == 'failed', 'a wrong database password fails its test')

    bucket = call('POST', f'/workspaces/{ws}/destinations', {
        'name': 'bucket', 'type': 's3', 'folders': ['nightly'],
        'settings': {'endpoint': E['S3_ENDPOINT'], 'region': 'us-east-1',
                     'bucket': E['S3_BUCKET'], 'access_key_id': E['S3_ACCESS'],
                     'secret_access_key': E['S3_SECRET'], 'path_style': True}},
        expect=201)['id']
    test = call('POST', f'/workspaces/{ws}/destinations/{bucket}/test', expect=200)
    check(test['status'] == 'connected', 'the bucket connects')
    listed = call('GET', f'/workspaces/{ws}/destinations/{bucket}', expect=200)
    check('secret_access_key' not in json.dumps(listed) and E['S3_SECRET'] not in json.dumps(
        listed), 'the API never returns the secret key')

    expected = psql('shop', 'select (select count(*) from customers), (select count(*) from orders)')
    cases = [('custom', 'gzip', '.dump.gz'), ('plain', 'none', '.sql')]
    for fmt, compression, extension in cases:
        step(f'backup and restore: {fmt} format, {compression}')
        config = call('POST', f'/workspaces/{ws}/configs', {
            'name': f'Nightly {fmt}', 'source_id': sources[fmt], 'destination_id': bucket,
            'folder': 'nightly', 'schedule': '0 3 * * *', 'compression': compression,
            'object_key': '{db}/{yyyy}-{MM}-{dd}-{run_id}'}, expect=201)
        check(config['next_run'] is not None, f'it is scheduled: {config["next_run"]}')
        run = run_now(ws, config['id'])
        check(run['status'] == 'success', f'the run succeeds ({run["size_bytes"]} bytes)')
        key = run['location'].split('/', 1)[1]
        check(key.startswith('nightly/shop/') and key.endswith(extension), f'it wrote {key}')
        data = s3_get(key)
        check(len(data) == run['size_bytes'], 'the object in the bucket has the size of the run')
        database = f'restored_{fmt}'
        restore(data, extension, database)
        got = psql(database, 'select (select count(*) from customers), '
                             '(select count(*) from orders)')
        check(got == expected, f'the restore has the rows of shop ({got})')

    step('a run that fails')
    config = call('POST', f'/workspaces/{ws}/configs', {
        'name': 'Broken', 'source_id': broken, 'destination_id': bucket, 'folder': 'nightly'},
        expect=201)
    run = run_now(ws, config['id'])
    check(run['status'] == 'failed' and run['error'], f'it fails and says why: {run["error"]}')
    check('not-the-password' not in json.dumps(run), 'the password is not in its log')

    step('run log')
    runs = call('GET', f'/workspaces/{ws}/runs', expect=200)
    check([r['status'] for r in runs] == ['failed', 'success', 'success'],
          'the run log has the three runs, newest first')
    failed = call('GET', f'/workspaces/{ws}/runs?status=failed', expect=200)
    check(len(failed) == 1, 'and filters them by status')

    step('the console')
    with urllib.request.urlopen(E['DUMPLING_URL']) as response:
        page = response.read().decode()
        check('flutter_bootstrap.js' in page, 'the service serves the console')
        check(response.headers['X-Frame-Options'] == 'DENY', 'with its security headers')

    print('\nPASSED', flush=True)


if __name__ == '__main__':
    main()
