#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${POSTGRES_MULTIPLE_DATABASES:-}" ]]; then
  echo "[initdb] POSTGRES_MULTIPLE_DATABASES not set; skipping extra database creation"
  exit 0
fi

IFS=',' read -ra DATABASES <<<"${POSTGRES_MULTIPLE_DATABASES}"

for raw in "${DATABASES[@]}"; do
  db="$(echo "$raw" | xargs)"
  if [[ -z "$db" ]]; then
    continue
  fi

  echo "[initdb] Ensuring database '$db' exists"
  psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB:-postgres}" <<-EOSQL
    SELECT 'CREATE DATABASE "${db}" OWNER "${POSTGRES_USER}"'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${db}')
    \gexec
EOSQL
done
