# PGCrypto Integration Guide for GeniusERP Suite

> **Version**: 1.0  
> **Last Updated**: 2025-11-21  
> **Scope**: All 15 databases across CP modules and applications

## Overview

This guide explains how to use PostgreSQL's `pgcrypto` extension for encryption-at-rest of sensitive PII data within the GeniusERP Suite. The pgcrypto extension is now enabled in **all 15 databases**.

---

## Enabled Databases (15 Total)

### Control Plane Modules (6)

1. `identity_db` - User authentication and identity management
2. `licensing_db` - License management  
3. `suite_shell_db` - Suite shell/navigation
4. `suite_admin_db` - Administration and configuration
5. `analytics_hub_db` - Analytics and reporting
6. `ai_hub_db` - AI/ML operations

### Applications (9)

1. `numeriqo_db` - Accounting and financial management
2. `archify_db` - Document management system
3. `cerniq_db` - Business intelligence
4. `flowxify_db` - Workflow automation
5. `iwms_db` - Warehouse management
6. `mercantiq_db` - CRM and sales
7. `triggerra_db` - Automation and triggers
8. `vettify_db` - Compliance and auditing
9. `geniuserp_db` - Main ERP functions

---

## When to Use pgcrypto vs OpenBao Transit

| Use Case | Recommended Solution | Rationale |
|----------|---------------------|-----------|
| **Low-volume PII** (SSN, tax ID, credit card) | **pgcrypto** | Simpler integration, data stays in DB |
| **High-throughput encryption** (>1000 ops/sec) | **OpenBao Transit** | Dedicated crypto engine, better performance |
| **Key rotation required frequently** | **OpenBao Transit** | Automated rewrap operations |
| **Compliance audit trail needed** | **OpenBao Transit** | Built-in audit logging |
| **Simple column encryption** | **pgcrypto** | Minimal dependencies |

---

## Adding Encrypted Columns

### Step 1: Add Encrypted Column

```sql
-- Example: Add encrypted SSN column to users table
ALTER TABLE users 
ADD COLUMN ssn_encrypted BYTEA;

COMMENT ON COLUMN users.ssn_encrypted IS 'Encrypted Social Security Number (AES-256)';
```

### Step 2: Store Encryption Key in OpenBao

```bash
# Generate encryption key (256-bit)
ENCRYPTION_KEY=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)

# Store in OpenBao
bao kv put kv/data/encryption-keys/pii value="$ENCRYPTION_KEY"
```

### Step 3: Encrypt Data (TypeScript)

```typescript
import { Client } from 'pg';
import { encryptPII, getEncryptionKeyFromVault } from '@genius-suite/common/pgcrypto-utils';

const client = new Client({ /* connection config */ });
await client.connect();

// Retrieve key from OpenBao
const encryptionKey = await getEncryptionKeyFromVault('kv/data/encryption-keys/pii');

// Encrypt SSN
const plainSSN = '123-45-6789';
const encryptedSSN = await encryptPII(client, plainSSN, encryptionKey);

// Insert into database
await client.query(
  'INSERT INTO users (username, ssn_encrypted) VALUES ($1, $2)',
  ['john.doe', encryptedSSN]
);
```

### Step 4: Decrypt Data (TypeScript)

```typescript
import { decryptPII, getEncryptionKeyFromVault } from '@genius-suite/common/pgcrypto-utils';

// Retrieve encrypted data
const result = await client.query('SELECT ssn_encrypted FROM users WHERE id = $1', [userId]);
const encryptedSSN = result.rows[0].ssn_encrypted;

// Retrieve key from OpenBao
const encryptionKey = await getEncryptionKeyFromVault('kv/data/encryption-keys/pii');

// Decrypt
const plainSSN = await decryptPII(client, encryptedSSN, encryptionKey);
console.log(plainSSN); // "123-45-6789"
```

---

## Direct SQL Usage

### Encrypt in SQL

```sql
-- Retrieve key from application (injected as parameter)
INSERT INTO users (username, ssn_encrypted)
VALUES ('john.doe', pgp_sym_encrypt('123-45-6789', :encryption_key));
```

### Decrypt in SQL

```sql
-- Decrypt for display (key injected as parameter)
SELECT 
    username,
    pgp_sym_decrypt(ssn_encrypted, :encryption_key) AS ssn
FROM users
WHERE id = 123;
```

---

## Migration Strategy

### Phase 1: Add Encrypted Columns (Current - F0.5.9)

- ✅ pgcrypto enabled in all 15 databases
- ✅ Add encrypted columns (nullable, alongside plaintext)
- ✅ No existing data modified

```sql
-- Example migration
ALTER TABLE users ADD COLUMN ssn_encrypted BYTEA;
ALTER TABLE users ADD COLUMN tax_id_encrypted BYTEA;
```

### Phase 2: Dual-Write (Future)

- Write to both plaintext and encrypted columns
- Gradually backfill encrypted columns from plaintext
- Verify data integrity

```typescript
// Dual-write example
await client.query(
  'UPDATE users SET ssn_encrypted = pgp_sym_encrypt(ssn, $1) WHERE id = $2',
  [encryptionKey, userId]
);
```

### Phase 3: Switch to Encrypted (Future)

- Update application to read from encrypted columns only
- Drop plaintext columns after verification

```sql
-- After verification, drop plaintext column
ALTER TABLE users DROP COLUMN ssn;
```

---

## Performance Considerations

### Encryption Overhead

| Operation | Overhead | Impact |
|-----------|----------|--------|
| INSERT with encryption | ~2-5ms per row | Minimal for transactional workloads |
| SELECT with decryption | ~2-5ms per row | Consider caching for frequent reads |
| Bulk encrypt (1000 rows) | ~2-5 seconds | Acceptable for background jobs |

### Optimization Tips

1. **Cache Decrypted Values**: Store decrypted PII in application memory for session duration
2. **Batch Operations**: Encrypt/decrypt in bulk when possible
3. **Index Considerations**: Cannot index encrypted columns directly - use hash indexes on encrypted data if needed
4. **Use Views**: Create views with decryption for read-heavy scenarios

---

## Security Best Practices

### Key Management

- ✅ **ALWAYS** retrieve encryption keys from OpenBao
- ❌ **NEVER** hardcode keys in application code
- ✅ Rotate keys every 90 days (per crypto standards)
- ✅ Use separate keys for different data types (PII, financial, etc.)

### Access Control

```sql
-- Restrict access to encrypted columns
REVOKE SELECT ON users.ssn_encrypted FROM public;
GRANT SELECT ON users.ssn_encrypted TO pii_readers;
```

### Audit Logging

```sql
-- Log decryption access
CREATE TABLE pii_access_log (
    id SERIAL PRIMARY KEY,
    user_id INT,
    table_name TEXT,
    column_name TEXT,
    accessed_at TIMESTAMP DEFAULT NOW()
);

-- Trigger on decrypt (optional)
CREATE OR REPLACE FUNCTION log_pii_access()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO pii_access_log (user_id, table_name, column_name)
    VALUES (current_user_id(), TG_TABLE_NAME, TG_ARGV[0]);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

---

## TypeScript API Reference

### `encryptPII(client, plaintext, key)`

Encrypts plaintext using AES-256.

**Parameters**:

- `client` (Client): PostgreSQL client instance
- `plaintext` (string): Data to encrypt
- `key` (string): Encryption key (≥32 chars)

**Returns**: `Promise<Buffer>` - Encrypted data

**Throws**: Error if key < 256 bits

---

### `decryptPII(client, ciphertext, key)`

Decrypts ciphertext using AES-256.

**Parameters**:

- `client` (Client): PostgreSQL client instance
- `ciphertext` (Buffer): Encrypted data
- `key` (string): Encryption key (≥32 chars)

**Returns**: `Promise<string>` - Decrypted plaintext

**Throws**: Error if decryption fails or key invalid

---

### `getEncryptionKeyFromVault(path, token?, addr?)`

Retrieves encryption key from OpenBao KV.

**Parameters**:

- `path` (string): OpenBao path (e.g., 'kv/data/encryption-keys/pii')
- `token` (string, optional): OpenBao token (defaults to `BAO_TOKEN` env var)
- `addr` (string, optional): OpenBao address (defaults to `BAO_ADDR` or `http://openbao:8200`)

**Returns**: `Promise<string>` - Encryption key

**Throws**: Error if key not found or doesn't meet entropy requirements

---

## Troubleshooting

### Extension Not Found

```text
ERROR: type "bytea" does not exist
```

**Solution**: Run migration script

```bash
./scripts/db/apply-pgcrypto-migrations.sh
```

### Decryption Fails

```text
ERROR: Wrong key or corrupt data
```

**Causes**:

1. Using wrong encryption key
2. Data corrupted in database
3. Key rotated but ciphertext not updated

**Solution**: Verify key matches the one used for encryption

### Performance Degradation

Monitor query performance:

```sql
EXPLAIN ANALYZE 
SELECT pgp_sym_decrypt(ssn_encrypted, 'key') FROM users WHERE id = 123;
```

Consider caching or switching to OpenBao Transit for high-throughput scenarios.

---

## References

- [PostgreSQL pgcrypto Documentation](https://www.postgresql.org/docs/current/pgcrypto.html)
- [GeniusERP Crypto Standards](F0.5-Crypto-Standards-OpenBao.md)
- [OpenBao Documentation](https://openbao.org/docs/)

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-11-21 | Initial guide for all 15 databases |
