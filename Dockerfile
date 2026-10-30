# The whole of Dumpling in one image: the service, the console it serves and pg_dump. Build from the
# root of the repo (the console is built too):
#   docker build -t dumpling .              # or: docker compose up -d --build
# Run with the SQLite database in a volume:
#   docker run -p 8080:8080 -v dumpling-data:/data -e DUMPLING_ADMIN_USER=… \
#     -e DUMPLING_ADMIN_PASSWORD=… -e JWT_SECRET=… -e SECRETS_ENCRYPTION_KEY=… dumpling

# Major version of pg_dump: it dumps servers of this version or older
ARG PG_VERSION=18

#--------------- Console: the Flutter Web build ---------------#
FROM debian:trixie-slim AS console

# The Flutter of the project (console/.fvmrc), from its official tag
ARG FLUTTER_VERSION=3.47.1
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl git unzip xz-utils \
 && rm -rf /var/lib/apt/lists/* \
 && git clone --depth 1 --branch "${FLUTTER_VERSION}" https://github.com/flutter/flutter.git /flutter
ENV PATH=/flutter/bin:$PATH
RUN flutter config --no-analytics && flutter precache --web

WORKDIR /src
COPY console/pubspec.* ./
RUN flutter pub get --enforce-lockfile
COPY console/ .
# The console is served by the service: without SERVICE_URL it calls the origin of the page
RUN flutter build web --release && echo 'window.env = {};' > build/web/env.js

#--------------- Service: AOT compiled ---------------#
FROM dart:3.13.1 AS service

WORKDIR /src
COPY service/pubspec.* ./
RUN dart pub get --enforce-lockfile
# `dart build cli` also runs the build hook of sqlite3, which bundles SQLite:
# bundle/bin/main and bundle/lib/libsqlite3.so
COPY service/ .
RUN dart pub get --offline && dart build cli -t lib/main.dart -o /out

#--------------- Runtime: the service, the console and pg_dump ---------------#
FROM debian:trixie-slim
ARG PG_VERSION

# pg_dump from the PostgreSQL apt repository (PGDG): every supported major version, with fixes
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates postgresql-common \
 && /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y \
 && apt-get install -y --no-install-recommends "postgresql-client-${PG_VERSION}" \
 && rm -rf /var/lib/apt/lists/* \
 && useradd --system --uid 10001 --home-dir /app dumpling \
 && mkdir /data && chown dumpling /data

COPY --from=service /out/bundle/ /app/
# The service looks for the console in build/web, next to its working folder
COPY --from=console /src/build/web/ /app/build/web/

WORKDIR /app
USER dumpling
ENV DATA_PATH=/data \
    PG_DUMP_PATH=/usr/lib/postgresql/${PG_VERSION}/bin/pg_dump
VOLUME /data
EXPOSE 8080
CMD ["/app/bin/main"]
