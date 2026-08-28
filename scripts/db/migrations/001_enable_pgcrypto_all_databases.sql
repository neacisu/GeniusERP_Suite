-- Migration: Enable pgcrypto extension for ALL GeniusERP Suite databases
-- Version: 1.0
-- Date: 2025-11-21
-- Description: Enables pgcrypto extension in all databases for encryption-at-rest capabilities

-- ============================================
-- Control Plane Databases
-- ============================================

-- 1. Identity DB
\c identity_db
CREATE EXTENSION IF NOT EXISTS pgcrypto;
COMMENT ON EXTENSION pgcrypto IS 'Cryptographic functions for identity management';

-- 2. Licensing DB
\c licensing_db
CREATE EXTENSION IF NOT EXISTS pgcrypto;
COMMENT ON EXTENSION pgcrypto IS 'Cryptographic functions for licensing management';

-- 3. Suite Shell DB
\c suite_shell_db
CREATE EXTENSION IF NOT EXISTS pgcrypto;
COMMENT ON EXTENSION pgcrypto IS 'Cryptographic functions for suite shell';

-- 4. Suite Admin DB
\c suite_admin_db
CREATE EXTENSION IF NOT EXISTS pgcrypto;
COMMENT ON EXTENSION pgcrypto IS 'Cryptographic functions for suite administration';

-- 5. Analytics Hub DB
\c analytics_hub_db
CREATE EXTENSION IF NOT EXISTS pgcrypto;
COMMENT ON EXTENSION pgcrypto IS 'Cryptographic functions for analytics data';

-- 6. AI Hub DB
\c ai_hub_db
CREATE EXTENSION IF NOT EXISTS pgcrypto;
COMMENT ON EXTENSION pgcrypto IS 'Cryptographic functions for AI/ML data';

-- ============================================
-- Application Databases
-- ============================================

-- 7. Numeriqo DB
\c numeriqo_db
CREATE EXTENSION IF NOT EXISTS pgcrypto;
COMMENT ON EXTENSION pgcrypto IS 'Cryptographic functions for accounting data';

-- 8. Archify DB
\c archify_db
CREATE EXTENSION IF NOT EXISTS pgcrypto;
COMMENT ON EXTENSION pgcrypto IS 'Cryptographic functions for document management';

-- 9. Cerniq DB
\c cerniq_db
CREATE EXTENSION IF NOT EXISTS pgcrypto;
COMMENT ON EXTENSION pgcrypto IS 'Cryptographic functions for BI data';

-- 10. Flowxify DB
\c flowxify_db
CREATE EXTENSION IF NOT EXISTS pgcrypto;
COMMENT ON EXTENSION pgcrypto IS 'Cryptographic functions for workflow data';

-- 11. i-WMS DB
\c iwms_db
CREATE EXTENSION IF NOT EXISTS pgcrypto;
COMMENT ON EXTENSION pgcrypto IS 'Cryptographic functions for warehouse management';

-- 12. Mercantiq DB
\c mercantiq_db
CREATE EXTENSION IF NOT EXISTS pgcrypto;
COMMENT ON EXTENSION pgcrypto IS 'Cryptographic functions for CRM/sales data';

-- 13. Triggerra DB
\c triggerra_db
CREATE EXTENSION IF NOT EXISTS pgcrypto;
COMMENT ON EXTENSION pgcrypto IS 'Cryptographic functions for automation data';

-- 14. Vettify DB
\c vettify_db
CREATE EXTENSION IF NOT EXISTS pgcrypto;
COMMENT ON EXTENSION pgcrypto IS 'Cryptographic functions for compliance/audit data';

-- 15. GeniusERP DB
\c geniuserp_db
CREATE EXTENSION IF NOT EXISTS pgcrypto;
COMMENT ON EXTENSION pgcrypto IS 'Cryptographic functions for main ERP data';

-- ============================================
-- Utility Functions (Applied to ALL databases)
-- ============================================

-- Create encryption/decryption helper functions in each database
DO $$
DECLARE
    db_name TEXT;
BEGIN
    FOR db_name IN 
        SELECT datname FROM pg_database 
        WHERE datname IN (
            'identity_db', 'licensing_db', 'suite_shell_db', 'suite_admin_db', 
            'analytics_hub_db', 'ai_hub_db', 'numeriqo_db', 'archify_db', 
            'cerniq_db', 'flowxify_db', 'iwms_db', 'mercantiq_db', 
            'triggerra_db', 'vettify_db', 'geniuserp_db'
        )
    LOOP
        EXECUTE format('
            CREATE OR REPLACE FUNCTION %I.encrypt_pii(plaintext TEXT, encryption_key TEXT)
            RETURNS BYTEA AS $func$
            BEGIN
                RETURN pgp_sym_encrypt(plaintext, encryption_key);
            END;
            $func$ LANGUAGE plpgsql IMMUTABLE;
            
            COMMENT ON FUNCTION %I.encrypt_pii IS ''Encrypt PII data using AES-256'';
        ', db_name, db_name);
        
        EXECUTE format('
            CREATE OR REPLACE FUNCTION %I.decrypt_pii(ciphertext BYTEA, encryption_key TEXT)
            RETURNS TEXT AS $func$
            BEGIN
                RETURN pgp_sym_decrypt(ciphertext, encryption_key);
            END;
            $func$ LANGUAGE plpgsql IMMUTABLE;
            
            COMMENT ON FUNCTION %I.decrypt_pii IS ''Decrypt PII data using AES-256'';
        ', db_name, db_name);
    END LOOP;
END $$;

-- Verification query
SELECT 
    d.datname AS database_name,
    e.extname AS extension_name,
    e.extversion AS version
FROM pg_database d
LEFT JOIN pg_extension e ON e.extname = 'pgcrypto'
WHERE d.datname IN (
    'identity_db', 'licensing_db', 'suite_shell_db', 'suite_admin_db',
    'analytics_hub_db', 'ai_hub_db', 'numeriqo_db', 'archify_db',
    'cerniq_db', 'flowxify_db', 'iwms_db', 'mercantiq_db',
    'triggerra_db', 'vettify_db', 'geniuserp_db'
)
ORDER BY d.datname;
