#!/usr/bin/env bash
set -euo pipefail

# Use vaultwarden's built-in backup subcommand (Online Backup API).
# Output lands in /data inside the container, then we relocate to ~/backups.

BACKUP_DIR="$HOME/backups/vaultwarden"
DATA_DIR="$HOME/VaultWarden/vw-data"
mkdir -p "$BACKUP_DIR"
TS=$(date +%Y%m%d-%H%M%S)

docker exec vaultwarden /vaultwarden backup

LATEST_DB=$(ls -t "$DATA_DIR"/db_*.sqlite3 2>/dev/null | head -1)
if [ -n "${LATEST_DB:-}" ]; then
    cp "$LATEST_DB" "$BACKUP_DIR/db-$TS.sqlite3"
    rm "$LATEST_DB"
    gzip "$BACKUP_DIR/db-$TS.sqlite3"
fi

tar czf "$BACKUP_DIR/data-$TS.tar.gz" \
    -C "$DATA_DIR" \
    attachments sends rsa_key.pem rsa_key.pub.pem config.json 2>/dev/null || true

find "$BACKUP_DIR" -name "*.gz" -mtime +14 -delete

echo "[$TS] backup complete -> $BACKUP_DIR"
