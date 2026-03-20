#!/bin/bash

set -euo pipefail

# -------------------------------
# PARAMETERS
# -------------------------------
: "${PGHOST:?PGHOST is required}"
: "${PGPORT:?PGPORT is required}"
: "${PGDATABASE:?PGDATABASE is required}"
: "${PGUSER:?PGUSER is required}"
: "${PGPASSWORD:?PGPASSWORD is required}"
: "${HDFS_DIR:?HDFS_DIR is required}"

# -------------------------------
# ENV
# -------------------------------
export PGPASSWORD="$PG_PASSWORD"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
FILENAME="${PG_DB}_${TIMESTAMP}.dump.gz"
HDFS_PATH="${HDFS_DIR}/${FILENAME}"

echo "Starting streaming backup: $FILENAME"

# -------------------------------
# ENSURE HDFS DIR EXISTS
# -------------------------------
$HDFS_BIN dfs -mkdir -p "$HDFS_DIR"

# -------------------------------
# STREAM DUMP → COMPRESS → HDFS
# -------------------------------
# -Fc already compressed
# pipefail ensures failure if any stage fails
pg_dump \
  -h "$PG_HOST" \
  -p "$PG_PORT" \
  -U "$PG_USER" \
  -d "$PG_DB" \
  -Fc \
| hdfs dfs -put -f - "$HDFS_PATH"

echo "Backup uploaded to HDFS: $HDFS_PATH"

echo "Backup process completed successfully"