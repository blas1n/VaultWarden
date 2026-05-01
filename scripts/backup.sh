#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="$HOME/backups/vaultwarden"
mkdir -p "$BACKUP_DIR"
TS=$(date +%Y%m%d-%H%M%S)

# SQLite Online Backup API (no downtime)
docker exec vaultwarden sqlite3 /data/db.sqlite3 ".backup '/data/db.backup-$TS'"
docker cp "vaultwarden:/data/db.backup-$TS" "$BACKUP_DIR/db-$TS.sqlite3"
docker exec vaultwarden rm "/data/db.backup-$TS"
gzip "$BACKUP_DIR/db-$TS.sqlite3"

# Attachments + RSA keys + config bundle
tar czf "$BACKUP_DIR/data-$TS.tar.gz" \
    -C "$HOME/VaultWarden/vw-data" \
    attachments sends rsa_key.pem rsa_key.pub.pem config.json 2>/dev/null || true

# Retain 14 days
find "$BACKUP_DIR" -name "*.gz" -mtime +14 -delete

echo "[$TS] backup complete -> $BACKUP_DIR"
