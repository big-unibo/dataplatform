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
export PGPASSWORD="$PGPASSWORD"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
FILENAME="${PGDATABASE}_${TIMESTAMP}.dump.gz"
HDFS_PATH="${HDFS_DIR}/${FILENAME}"

echo "Starting streaming backup: $FILENAME"

# -------------------------------
# ENSURE HDFS DIR EXISTS
# -------------------------------
hdfs dfs -mkdir -p "$HDFS_DIR"

# -------------------------------
# STREAM DUMP → COMPRESS → HDFS
# -------------------------------
# -Fc already compressed
# pipefail ensures failure if any stage fails
pg_dump \
  -h "$PGHOST" \
  -p "$PGPORT" \
  -U "$PGUSER" \
  -d "$PGDATABASE" \
  -Fc \
| hdfs dfs -put -f - "$HDFS_PATH"

echo "Backup uploaded to HDFS: $HDFS_PATH"

# -------------------------------
# CLEAN OLD BACKUPS IN HDFS
# -------------------------------
RETENTION_DAYS=30
echo "Cleaning HDFS backups older than $RETENTION_DAYS days"

NOW=$(date +%s)

hdfs dfs -ls "$HDFS_DIR" | while read -r perms repl owner group size date time path; do
    [ -z "${path:-}" ] && continue
    FILE_TS=$(date -d "$date $time" +%s 2>/dev/null || echo 0)
    [ "$FILE_TS" -eq 0 ] && continue

    AGE_DAYS=$(( (NOW - FILE_TS) / 86400 ))

    if [ "$AGE_DAYS" -gt "$RETENTION_DAYS" ]; then
        echo "Deleting old backup: $path"
        hdfs dfs -rm -- "$path"
    fi
done

echo "Backup process completed successfully"