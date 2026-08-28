# OpenBao Backup & Disaster Recovery

## Overview

This document describes the backup and disaster recovery strategy for the OpenBao service in the GeniusERP Suite.

## Architecture

OpenBao is configured with the **File Storage Backend**, storing all encrypted data in the `gs_openbao_data` Docker volume (mounted at `/bao/file`).

### Backup Strategy

- **Method**: Automated sidecar container (`geniuserp-openbao-backup`)
- **Frequency**: Daily (every 24 hours)
- **Retention**: 7 days
- **Destination**: `./backups/openbao` (host directory)
- **Format**: `tar.gz` archive of the data directory

## Backup Process

The `openbao-backup` service runs a script (`scripts/compose/openbao-backup.sh`) that:

1. Creates a timestamped tarball of `/bao/file`.
2. Verifies the archive size.
3. Deletes backups older than 7 days.

## Restore Procedure

To restore OpenBao from a backup:

1. **Stop OpenBao services**:

   ```bash
   docker compose stop openbao openbao-backup
   ```

2. **Locate Backup**:
   Find the desired backup file in `backups/openbao/` (e.g., `openbao-20231123-120000.tar.gz`).

3. **Restore Data**:
   We need to extract the backup into the volume. We can use a temporary container for this.

   ```bash
   # Create a temporary container mounting the volume and backup directory
   docker run --rm -v gs_openbao_data:/restore -v $(pwd)/backups/openbao:/backup alpine \
     sh -c "rm -rf /restore/* && tar -xzf /backup/openbao-YYYYMMDD-HHMMSS.tar.gz -C /restore"
   ```

   *Note: Replace `YYYYMMDD-HHMMSS` with the actual timestamp.*

4. **Verify Permissions**:
   Ensure the restored files are owned by the OpenBao user (usually uid 100 or 1000).

   ```bash
   docker run --rm -v gs_openbao_data:/restore alpine chown -R 100:1000 /restore
   ```

5. **Start OpenBao**:

   ```bash
   docker compose start openbao
   ```

6. **Unseal OpenBao**:
   OpenBao will be sealed after restart. You must unseal it using the unseal keys.

   ```bash
   export BAO_ADDR=http://127.0.0.1:8200
   bao operator unseal <key1>
   bao operator unseal <key2>
   bao operator unseal <key3>
   ```

## Disaster Recovery Testing

Perform a restore test periodically (e.g., monthly) in a staging environment to ensure backup integrity.

1. Spin up a fresh OpenBao instance with an empty volume.
2. Restore the latest backup.
3. Unseal and verify access to secrets.
