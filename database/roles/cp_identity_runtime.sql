DO $$
BEGIN
	IF NOT EXISTS (
		SELECT 1
		FROM pg_roles
		WHERE rolname = 'cp_identity_runtime_rw'
	) THEN
		CREATE ROLE cp_identity_runtime_rw NOLOGIN;
	END IF;
END
$$;

GRANT CONNECT ON DATABASE identity_db TO cp_identity_runtime_rw;
GRANT USAGE ON SCHEMA public TO cp_identity_runtime_rw;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO cp_identity_runtime_rw;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO cp_identity_runtime_rw;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO cp_identity_runtime_rw;

CREATE ROLE "{{name}}" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' IN ROLE cp_identity_runtime_rw;
