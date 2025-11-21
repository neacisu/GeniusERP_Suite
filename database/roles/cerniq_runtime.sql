-- Cerniq analytics runtime
-- Managed by scripts/security/openbao-sync-app-roles.sh
CREATE ROLE "{{name}}" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';
GRANT CONNECT ON DATABASE cerniq_db TO "{{name}}";
GRANT USAGE ON SCHEMA public TO "{{name}}";
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO "{{name}}";
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO "{{name}}";
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO "{{name}}";
