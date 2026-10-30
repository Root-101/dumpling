# Security

## Reporting a vulnerability

Please **don't open a public issue**. Report it privately through GitHub: the repository's
**Security** tab → **Report a vulnerability**. Include what is affected (service or console, and
the version or commit), how to reproduce it and what an attacker gains.

You'll get an answer within a week. Once it is fixed, the advisory is published with credit to you,
unless you'd rather not.

## Supported versions

Only the latest release gets security fixes (today `0.1.0-rc.3`).

## Security model

Dumpling holds the keys to your databases and your bucket, so the service guards them first. The
reasons behind each decision are in [`DECISIONS.md`](DECISIONS.md).

**Authentication**

- One user, the admin (`DUMPLING_ADMIN_USER` / `DUMPLING_ADMIN_PASSWORD`), signs in to the console
  and gets a JWT (HS256, `JWT_SECRET`) that expires in 12 hours; tokens without an expiry are
  rejected. Every route of the API but the login needs it, in the `Authorization` header: never a
  cookie, so there is no CSRF.
- The username and password are compared in constant time. Each failed login waits 1 second, and
  10 in a row lock the client IP for 15 minutes, even with the right password afterward
  (`LOGIN_MAX_FAILURES`, `LOGIN_LOCK_SECONDS`, `LOGIN_FAILURE_DELAY_MS`).
- A general rate limit per IP (600 requests per minute by default, `RATE_LIMIT_REQUESTS` and
  `RATE_LIMIT_WINDOW_SECONDS`) stops floods before a body is read or a token checked.

**Credentials of sources and destinations**

- Database passwords and S3 secret keys are stored encrypted with AES-256-GCM (key derived from
  `SECRETS_ENCRYPTION_KEY`), each with its own random nonce and bound to its row: a value copied
  to another source doesn't decrypt. They are never returned by the API nor shown again in the
  console; an edit without a new password keeps the saved one.
- The connection to PostgreSQL uses TLS by default (`ssl_mode` `require`, which doesn't check the
  certificate) and never sends the password in clear. A source set to `disable` sends the password
  (if the server asks for it in clear) and the data unencrypted: only for a database on a network
  you trust.
- `pg_dump` gets the connection in its environment (`PGHOST`, `PGPASSWORD`…), never in its
  arguments, which any user of the machine can list. That environment doesn't carry the secrets
  of the service nor any other `PG*` variable of the machine.
- A destination only writes: `PutObject` (multipart included) and `AbortMultipartUpload`. It never
  lists, reads nor deletes objects.

**Input and output**

- Every request body is validated before it is used (sizes, ports, hosts, cron expressions,
  folder paths without `.` or `..`, object keys); a violation answers `422` with the field.
- Errors never include internal details; unexpected ones are logged with a request id and
  answered generically. A failed run keeps the error of `pg_dump` or of the storage, which name
  hosts and databases but not passwords.
- Logs hold method, path, status and time of each request, ids and client IPs. Never bodies,
  passwords, tokens nor secrets; a failed login logs the IP, not what was typed.
- Every response carries `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY` and
  `Referrer-Policy: no-referrer`. CORS accepts any origin without credentials (the console in
  development runs on another origin), which is safe because authentication is a header.

## Deploying it safely

- **TLS**: the service speaks HTTP. Put it behind a proxy that terminates TLS, and set
  `TRUSTED_PROXIES` to the number of your own proxies so the login lock and the rate limit see the
  client IP, not the proxy's. `X-Forwarded-For` only counts when the connection comes from a
  private address (loopback, `10/8`, `172.16/12`, `192.168/16`, `fc00::/7`), where a proxy of your
  own sits, so a client that reaches the port from outside can't pick its IP; still, publish the
  port only to the proxy (`127.0.0.1:8080:8080`). A request lasts at most 2 minutes, so a client
  that sends its body slowly can't hold it. A `Content-Security-Policy` for the console, if you want one, goes in
  that proxy (Flutter Web needs `'wasm-unsafe-eval'` and its inline bootstrap script).
- **Secrets**: use long random values for `DUMPLING_ADMIN_PASSWORD`, `JWT_SECRET` and
  `SECRETS_ENCRYPTION_KEY` (e.g. `openssl rand -hex 32`) and keep them out of the repository. The
  service warns at start-up when the password has fewer than 12 characters or the other two fewer
  than 32. Rotating `JWT_SECRET` signs everyone out. Changing `DUMPLING_ADMIN_PASSWORD` does not:
  the tokens already given work until they expire, so after a leak change both. Changing
  `SECRETS_ENCRYPTION_KEY` makes every stored credential unreadable, and each source and
  destination needs its password again.
- **Least privilege for the database**: connect with a role that can only read, e.g. one granted
  `pg_read_all_data` (PostgreSQL 14+). `pg_dump` needs nothing else.
- **Least privilege for the bucket**: an access key limited to `s3:PutObject` and
  `s3:AbortMultipartUpload` on the bucket (or its prefix). Turn on versioning or object lock in the
  bucket if a leaked key must not be able to overwrite older backups. A run cut by a stop has its
  upload aborted on the next start; if that fails (the key changed, the bucket is unreachable), an
  `AbortIncompleteMultipartUpload` lifecycle rule in the bucket drops the parts it left.
- **The data volume** (`/data`) holds the SQLite database with the encrypted credentials; protect
  its backups like the secrets themselves, and keep `SECRETS_ENCRYPTION_KEY` apart from them.
- **The backups** contain your data: restrict who can read the bucket, and enable encryption at
  rest in the storage.
