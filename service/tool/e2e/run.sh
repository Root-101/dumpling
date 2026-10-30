#!/usr/bin/env bash
# End-to-end test of the Dumpling image: PostgreSQL, an S3 server and Dumpling in Docker, on a
# network of their own, driven through the API by e2e.py (python3, standard library). Usage, from
# any folder:
#
#   service/tool/e2e/run.sh
#
# Variables (with their defaults):
#   DUMPLING_IMAGE=dumpling:e2e   built from the repo first unless SKIP_BUILD=1
#   PG_IMAGE=postgres:18          the server to back up (the image's pg_dump must be this or newer)
#   S3_IMAGE=feather-io:1.0.0-rc.7  the S3 server: feather-io (built from its repo) or, with
#                                 S3_KIND=minio, a MinIO image (tested with elestio/minio)
#   KEEP=1                        leaves the containers running to look at them
set -u

DIR=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$DIR/../../.." && pwd)
DUMPLING_IMAGE=${DUMPLING_IMAGE:-dumpling:e2e}
PG_IMAGE=${PG_IMAGE:-postgres:18}
S3_IMAGE=${S3_IMAGE:-feather-io:1.0.0-rc.7}
S3_KIND=${S3_KIND:-feather}
NET=dumpling-e2e
# Ports on the host, away from the usual ones
DUMPLING_PORT=${DUMPLING_PORT:-18080}
S3_PORT=${S3_PORT:-19000}

# In Git Bash (Windows) the paths given to Docker must not be converted, and Windows tools get
# them in their own form
export MSYS_NO_PATHCONV=1
host_path() { if command -v cygpath >/dev/null; then cygpath -w "$1"; else echo "$1"; fi; }
# python3, or python where that is it (on Windows python3 may be a stub of the Store)
for PY in python3 python ''; do "$PY" -c 'import sys; assert sys.version_info >= (3, 8)' 2>/dev/null && break; done
[ -n "$PY" ] || { echo "python3 is needed"; exit 1; }

cleanup() {
  if [ "${KEEP:-0}" = 1 ]; then
    echo "Kept: docker rm -f e2e-dumpling e2e-postgres e2e-s3 && docker network rm $NET"
    return
  fi
  docker rm -f e2e-dumpling e2e-postgres e2e-s3 >/dev/null 2>&1
  docker network rm "$NET" >/dev/null 2>&1
}
trap cleanup EXIT
cleanup

if [ "${SKIP_BUILD:-0}" != 1 ]; then
  echo "===== building $DUMPLING_IMAGE"
  docker build -q -t "$DUMPLING_IMAGE" "$ROOT" || exit 1
fi

docker network create "$NET" >/dev/null || exit 1

echo "===== PostgreSQL ($PG_IMAGE) with a seeded shop database"
docker run -d --name e2e-postgres --network "$NET" \
  -e POSTGRES_USER=shop_owner -e POSTGRES_PASSWORD=e2e-pg-password -e POSTGRES_DB=shop \
  "$PG_IMAGE" >/dev/null || exit 1

echo "===== S3 ($S3_IMAGE)"
S3_ACCESS=e2e-access
S3_SECRET=e2e-secret-key-0123456789
S3_BUCKET=e2e-backups
if [ "$S3_KIND" = minio ]; then
  docker run -d --name e2e-s3 --network "$NET" -p "$S3_PORT:9000" \
    -e MINIO_ROOT_USER=$S3_ACCESS -e MINIO_ROOT_PASSWORD=$S3_SECRET \
    "$S3_IMAGE" server /data >/dev/null || exit 1
  S3_INNER=http://e2e-s3:9000
else
  docker run -d --name e2e-s3 --network "$NET" -p "$S3_PORT:8080" \
    -e FEATHER_ACCESS=$S3_ACCESS -e FEATHER_SECRET=$S3_SECRET \
    -e JWT_SECRET=e2e-jwt-secret-0123456789abcdef0123456789 \
    -e KEYS_ENCRYPTION_SECRET=e2e-keys-secret-0123456789abcdef01234567 \
    "$S3_IMAGE" >/dev/null || exit 1
  S3_INNER=http://e2e-s3:8080
fi

echo "===== Dumpling ($DUMPLING_IMAGE)"
docker run -d --name e2e-dumpling --network "$NET" -p "$DUMPLING_PORT:8080" \
  -e DUMPLING_ADMIN_USER=admin -e DUMPLING_ADMIN_PASSWORD=e2e-admin-password \
  -e JWT_SECRET=e2e-dumpling-jwt-secret-0123456789abcdef \
  -e SECRETS_ENCRYPTION_KEY=e2e-dumpling-secrets-key-0123456789abcd \
  "$DUMPLING_IMAGE" >/dev/null || exit 1

# The database: a backup role that can only read, as SECURITY.md advises, and two tables
for _ in $(seq 60); do
  docker exec e2e-postgres pg_isready -U shop_owner -d shop >/dev/null 2>&1 && break
  sleep 1
done
sleep 2 # the entrypoint restarts the server once after its init scripts
for _ in $(seq 30); do
  docker exec e2e-postgres pg_isready -U shop_owner -d shop >/dev/null 2>&1 && break
  sleep 1
done
docker exec -i e2e-postgres psql -q -U shop_owner -d shop -v ON_ERROR_STOP=1 <<'SQL' || exit 1
CREATE TABLE customers (id serial PRIMARY KEY, name text NOT NULL);
CREATE TABLE orders (id serial PRIMARY KEY, customer_id int REFERENCES customers, total numeric);
INSERT INTO customers (name) SELECT 'customer ' || n FROM generate_series(1, 2000) n;
INSERT INTO orders (customer_id, total)
  SELECT 1 + n % 2000, round((random() * 500)::numeric, 2) FROM generate_series(1, 20000) n;
CREATE ROLE dumpling_backup LOGIN PASSWORD 'e2e-backup-password';
GRANT pg_read_all_data TO dumpling_backup;
SQL

# The bucket: a signed PUT (curl 7.75+)
for _ in $(seq 60); do
  code=$(curl -s -o /dev/null -w '%{http_code}' --aws-sigv4 "aws:amz:us-east-1:s3" \
    --user "$S3_ACCESS:$S3_SECRET" -X PUT "http://localhost:$S3_PORT/$S3_BUCKET")
  [ "$code" = 200 ] && break
  sleep 1
done
[ "$code" = 200 ] || { echo "Could not create the bucket ($code)"; exit 1; }

echo "===== test"
DUMPLING_URL=http://localhost:$DUMPLING_PORT ADMIN_USER=admin ADMIN_PASSWORD=e2e-admin-password \
PG_HOST=e2e-postgres PG_CONTAINER=e2e-postgres PG_USER=dumpling_backup \
PG_PASSWORD=e2e-backup-password PG_ADMIN=shop_owner \
S3_URL=http://localhost:$S3_PORT S3_ENDPOINT=$S3_INNER S3_ACCESS=$S3_ACCESS S3_SECRET=$S3_SECRET \
S3_BUCKET=$S3_BUCKET \
  "$PY" -I "$(host_path "$DIR/e2e.py")"
status=$?
[ $status = 0 ] || { echo "===== logs of Dumpling"; docker logs --tail 50 e2e-dumpling; }
exit $status
