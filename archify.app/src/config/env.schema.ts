/**
 * Archify Environment Configuration Schema
 * 
 * Zod schema for validating and type-checking Archify environment variables.
 * This ensures that all required variables are present and correctly formatted
 * before the application starts.
 * 
 * @example
 * // In archify.app/src/main.ts
 * import { EnvLoader, setupEnv } from '@shared/config/env-loader';
 * import { validateArchifyEnv } from './config/env.schema';
 * 
 * const config = setupEnv('archify', validateArchifyEnv, { 
 *   verbose: true,
 *   appDir: __dirname 
 * });
 * 
 * console.log(`Starting Archify on port ${config.PORT}`);
 */

import { z } from 'zod';

/**
 * Base schema with shared variables from root .env
 */
const sharedEnvSchema = z.object({
  NODE_ENV: z.enum(['development', 'production']),
  DATABASE_URL: z.string().url().or(z.string().startsWith('postgres://')).or(z.string().startsWith('postgresql://')),
  REDIS_URL: z.string().optional(),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']),
  OTEL_EXPORTER_OTLP_ENDPOINT: z.string().url(),
  OTEL_ENABLED: z.boolean(),
  ALLOWED_ORIGINS: z.string().optional(),
  API_GATEWAY_URL: z.string().optional(),
});

/**
 * Archify-specific schema
 */
const archifySpecificSchema = z.object({
  // ===== APPLICATION IDENTITY =====
  PORT: z.coerce.number().min(1024).max(65535),
  SERVICE_NAME: z.string(),

  // ===== DOCUMENT STORAGE =====
  ARCHIFY_MAX_FILE_SIZE: z.coerce.number().default(104857600), // 100MB
  ARCHIFY_STORAGE_TYPE: z.enum(['local', 's3', 'azure-blob', 'gcs']).default('local'),
  ARCHIFY_STORAGE_PATH: z.string().default('/data/archify/documents'),
  ARCHIFY_TEMP_PATH: z.string().default('/tmp/archify'),
  ARCHIFY_STORAGE_ENCRYPTION: z.boolean().default(true),

  // ===== S3 CONFIGURATION =====
  ARCHIFY_S3_BUCKET: z.string().optional(),
  ARCHIFY_S3_REGION: z.string().optional(),
  ARCHIFY_S3_ACCESS_KEY_ID: z.string().optional(),
  ARCHIFY_S3_SECRET_ACCESS_KEY: z.string().optional(),

  // ===== AZURE CONFIGURATION =====
  ARCHIFY_AZURE_STORAGE_ACCOUNT: z.string().optional(),
  ARCHIFY_AZURE_STORAGE_ACCOUNT_KEY: z.string().optional(),
  ARCHIFY_AZURE_CONTAINER_NAME: z.string().optional(),

  // ===== OCR CONFIGURATION =====
  ARCHIFY_OCR_ENABLED: z.boolean().default(false),
  ARCHIFY_OCR_PROVIDER: z.enum(['google-vision', 'aws-textract', 'azure-cv', 'tesseract']).optional(),
  ARCHIFY_OCR_API_KEY: z.string().optional(),
  ARCHIFY_OCR_CONFIDENCE_THRESHOLD: z.coerce.number().min(0).max(1).default(0.85),
  ARCHIFY_OCR_LANGUAGE: z.string().default('ro,en'),

  // ===== FULL-TEXT SEARCH =====
  ARCHIFY_SEARCH_ENABLED: z.boolean().default(true),
  ARCHIFY_SEARCH_ENGINE: z.enum(['postgres', 'elasticsearch', 'meilisearch']).default('postgres'),
  ARCHIFY_ELASTICSEARCH_URL: z.string().url().optional(),
  ARCHIFY_ELASTICSEARCH_USERNAME: z.string().optional(),
  ARCHIFY_ELASTICSEARCH_PASSWORD: z.string().optional(),

  // ===== DOCUMENT VERSIONING =====
  ARCHIFY_VERSIONING_ENABLED: z.boolean().default(true),
  ARCHIFY_MAX_VERSIONS_PER_DOC: z.coerce.number().default(10),
  ARCHIFY_VERSION_RETENTION_DAYS: z.coerce.number().default(365),

  // ===== DOCUMENT CLASSIFICATION =====
  ARCHIFY_AUTO_CLASSIFICATION_ENABLED: z.boolean().default(false),
  ARCHIFY_CLASSIFICATION_MODEL: z.string().optional(),
  ARCHIFY_CLASSIFICATION_CONFIDENCE_THRESHOLD: z.coerce.number().min(0).max(1).default(0.8),

  // ===== PERMISSIONS & SHARING =====
  ARCHIFY_SHARE_EXPIRY_DAYS: z.coerce.number().default(30),
  ARCHIFY_ENABLE_PUBLIC_SHARES: z.boolean().default(false),
  ARCHIFY_ENABLE_EXTERNAL_SHARING: z.boolean().default(true),
  ARCHIFY_SHARE_PASSWORD_PROTECTION: z.boolean().default(true),

  // ===== AUDIT & COMPLIANCE =====
  ARCHIFY_AUDIT_ENABLED: z.boolean().default(true),
  ARCHIFY_AUDIT_LOG_RETENTION_DAYS: z.coerce.number().default(2555), // 7 years
  ARCHIFY_ENABLE_GDPR_COMPLIANCE: z.boolean().default(true),

  // ===== SUITE INTEGRATION =====
  ARCHIFY_ENABLE_SUITE_INTEGRATION: z.boolean().default(true),
  SUITE_SHELL_URL: z.string().url().optional(),
  SUITE_LOGIN_URL: z.string().url().optional(),

  // ===== EXTERNAL APP INTEGRATIONS =====
  ARCHIFY_ENABLE_CERNIQ_INTEGRATION: z.boolean().default(false),
  CERNIQ_API_URL: z.string().url().optional(),

  ARCHIFY_ENABLE_FLOWXIFY_INTEGRATION: z.boolean().default(false),
  FLOWXIFY_API_URL: z.string().url().optional(),

  // ===== PERFORMANCE & CACHING =====
  ARCHIFY_CACHE_ENABLED: z.boolean().default(true),
  ARCHIFY_CACHE_TTL: z.coerce.number().default(3600),
  ARCHIFY_ENABLE_COMPRESSION: z.boolean().default(true),
  ARCHIFY_COMPRESSION_MIN_SIZE: z.coerce.number().default(1024),

  // ===== NOTIFICATIONS =====
  ARCHIFY_NOTIFICATIONS_ENABLED: z.boolean().default(true),
  ARCHIFY_NOTIFY_ON_DOCUMENT_UPLOAD: z.boolean().default(true),
  ARCHIFY_NOTIFY_ON_DOCUMENT_SHARE: z.boolean().default(true),
  ARCHIFY_NOTIFICATION_CHANNELS: z.string().default('email,in-app'),
});

/**
 * Combined schema: shared + archify-specific
 */
export const archifyEnvSchema = sharedEnvSchema.merge(archifySpecificSchema);

/**
 * TypeScript type derived from the schema
 */
export type ArchifyEnv = z.infer<typeof archifyEnvSchema>;

/**
 * Validate environment variables for Archify application
 * 
 * @param env - process.env object to validate
 * @returns Validated and typed configuration object
 * @throws ZodError if validation fails
 * 
 * @example
 * try {
 *   const config = validateArchifyEnv(process.env);
 *   console.log(`Starting Archify on port ${config.PORT}`);
 * } catch (error) {
 *   console.error('Configuration validation failed:', error);
 *   process.exit(1);
 * }
 */
export function validateArchifyEnv(env: NodeJS.ProcessEnv = process.env): ArchifyEnv {
  const result = archifyEnvSchema.safeParse(env);

  if (!result.success) {
    console.error('❌ Archify environment validation failed:\n');

    result.error.errors.forEach(error => {
      const path = error.path.join('.');
      const message = error.message;
      const code = error.code;

      console.error(`  ❌ ${path}`);
      console.error(`     ${message} (${code})`);
      
      if (error.code === 'invalid_type') {
        console.error(`     Expected: ${error.expected}, Got: ${typeof env[error.path[0] as string]}`);
      }
    });

    console.error(
      '\n💡 Tip: Make sure all required environment variables are set in:\n' +
      '   1. .env (root defaults)\n' +
      '   2. archify.app/.env.archify (app-specific)\n' +
      '   3. .env.local (local overrides, for development)\n' +
      '   4. archify.app/.env.production (production overrides)\n'
    );

    process.exit(1);
  }

  // Log successful validation (without sensitive values)
  console.log('✅ Archify environment configuration validated successfully\n');

  if (result.data.NODE_ENV === 'production') {
    console.log('🔒 Running in PRODUCTION mode');
    if (result.data.ARCHIFY_AUDIT_ENABLED) {
      console.log('📋 Audit logging: ENABLED');
    }
    if (result.data.ARCHIFY_ENABLE_GDPR_COMPLIANCE) {
      console.log('⚖️  GDPR compliance: ENABLED');
    }
  } else {
    console.log('🔧 Running in DEVELOPMENT mode');
  }

  console.log(`📦 Storage type: ${result.data.ARCHIFY_STORAGE_TYPE}`);
  console.log(`📍 Listening on port ${result.data.PORT}\n`);

  return result.data;
}

/**
 * Helper function to check if optional feature is enabled
 * Useful for feature flags
 * 
 * @example
 * if (isFeatureEnabled('OCR', config)) {
 *   setupOcrProcessing(config);
 * }
 */
export function isFeatureEnabled(
  feature: 'OCR' | 'SEARCH' | 'VERSIONING' | 'CLASSIFICATION' | 'AUDIT' | 'GDPR',
  config: ArchifyEnv
): boolean {
  switch (feature) {
    case 'OCR':
      return config.ARCHIFY_OCR_ENABLED;
    case 'SEARCH':
      return config.ARCHIFY_SEARCH_ENABLED;
    case 'VERSIONING':
      return config.ARCHIFY_VERSIONING_ENABLED;
    case 'CLASSIFICATION':
      return config.ARCHIFY_AUTO_CLASSIFICATION_ENABLED;
    case 'AUDIT':
      return config.ARCHIFY_AUDIT_ENABLED;
    case 'GDPR':
      return config.ARCHIFY_ENABLE_GDPR_COMPLIANCE;
    default:
      return false;
  }
}

export default archifyEnvSchema;
