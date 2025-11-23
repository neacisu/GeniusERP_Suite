#!/bin/sh
#
# openbao-backup.sh - Automated backup for OpenBao file backend
#
# Usage: ./openbao-backup.sh [interval_seconds]
# Default interval: 86400 (24 hours)
#

INTERVAL=${1:-86400}
BACKUP_DIR="/backup"
DATA_DIR="/bao/file"
RETENTION_DAYS=7

echo "Starting OpenBao Backup Service..."
echo "Interval: $INTERVAL seconds"
echo "Retention: $RETENTION_DAYS days"

while true; do
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    BACKUP_FILE="$BACKUP_DIR/openbao-$TIMESTAMP.tar.gz"

    echo "[$TIMESTAMP] Creating backup..."
    
    # Create tarball of data directory
    if tar -czf "$BACKUP_FILE" -C "$DATA_DIR" .; then
        echo "[$TIMESTAMP] Backup created: $BACKUP_FILE"
        
        # Verify backup size
        SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
        echo "[$TIMESTAMP] Size: $SIZE"
    else
        echo "[$TIMESTAMP] Error: Backup failed!"
    fi

    # Cleanup old backups
    echo "[$TIMESTAMP] Cleaning up old backups..."
    find "$BACKUP_DIR" -name "openbao-*.tar.gz" -mtime +$RETENTION_DAYS -delete
    
    echo "[$TIMESTAMP] Sleeping for $INTERVAL seconds..."
    sleep "$INTERVAL"
done
