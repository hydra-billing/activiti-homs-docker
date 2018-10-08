#!/bin/bash

set -e

export PGHOST=$BPM_DB_HOST
export PGUSER=$BPM_DB_USER
export PGPASSWORD=$BPM_DB_PASSWORD

until psql -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up"
