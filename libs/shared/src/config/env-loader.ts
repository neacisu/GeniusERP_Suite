/**
 * Environment Variables Loader
 *
 * Hierarchical environment configuration loader with support for:
 * - Multiple .env files with priority levels
 * - Application-specific overrides
 * - Environment-specific settings (dev/prod)
 * - Validation with Zod schemas
 *
 * Loading priority (lowest to highest):
 * 1. .env (root base defaults)
 * 2. .env.{appName} (app-specific)
 * 3. .env.local (local overrides - dev only)
 * 4. .env.{environment} (environment overrides)
 * 5. process.env (runtime environment variables - highest)
 *
 * @example
 * // In your application's main.ts
 * import { EnvLoader } from '@shared/config/env-loader';
 *
 * // For applications in root-level directories
 * EnvLoader.loadEnv('archify', process.env.NODE_ENV);
 *
 * // For Control Plane services in subdirectories
 * EnvLoader.loadEnv('geniussuite', process.env.NODE_ENV, __dirname);
 *
 * // Then validate:
 * import { validateArchifyEnv } from '@archify/config/env.schema';
 * const config = validateArchifyEnv();
 */

import * as fs from 'fs';
import * as path from 'path';
import dotenv from 'dotenv';

export interface EnvLoaderOptions {
  /**
   * Set to false to skip loading .env.local
   * Useful for strict production builds
   * @default true
   */
  allowLocal?: boolean;

  /**
   * Set to true to log which files are loaded
   * @default false
   */
  verbose?: boolean;

  /**
   * Throw error if required files are missing
   * @default false
   */
  strict?: boolean;

  /**
   * Directory to search for .env files
   * If not provided, uses current working directory
   * @default process.cwd()
   */
  baseDir?: string;
}

export class EnvLoader {
  private static loadedFiles: Map<string, string[]> = new Map();
  private static loadedVars: Map<string, string> = new Map();

  /**
   * Load environment variables with hierarchical priority
   *
   * @param appName - Application name (e.g., 'archify', 'geniussuite')
   * @param environment - 'development' or 'production'
   * @param appDir - Optional: specific directory for app-specific .env files
   * @param options - Optional: loading options
   */
  static loadEnv(
    appName: string,
    environment: 'development' | 'production' = 'development',
    appDir?: string,
    options: EnvLoaderOptions = {},
  ): void {
    const { allowLocal = true, verbose = false, strict = false, baseDir = process.cwd() } = options;

    if (verbose) {
      console.log(`\n📚 [EnvLoader] Loading environment for: ${appName} (${environment})`);
    }

    // Build list of files to load in priority order (low to high)
    const filesToLoad = this.buildFileList(appName, environment, baseDir, appDir, allowLocal);

    // Load files in order, with later files overriding earlier ones
    for (const filePath of filesToLoad) {
      if (fs.existsSync(filePath)) {
        if (verbose) {
          console.log(`  ✓ Loading: ${path.relative(baseDir, filePath)}`);
        }

        try {
          const envConfig = dotenv.parse(fs.readFileSync(filePath, 'utf-8')) as Record<
            string,
            string
          >;

          // Merge into loadedVars and process.env
          // Only set if not already set by higher-priority source
          Object.entries(envConfig).forEach(([key, value]) => {
            // Don't override if already set by process.env or higher priority file
            if (!process.env[key] && !this.loadedVars.has(key)) {
              process.env[key] = value;
              this.loadedVars.set(key, value);
            }
          });

          // Track loaded files for debugging
          if (!this.loadedFiles.has(appName)) {
            this.loadedFiles.set(appName, []);
          }
          this.loadedFiles.get(appName)!.push(filePath);
        } catch (error) {
          const errorMsg = `Failed to parse ${filePath}: ${error instanceof Error ? error.message : String(error)}`;
          if (strict) {
            throw new Error(errorMsg);
          } else if (verbose) {
            console.warn(`  ⚠ ${errorMsg}`);
          }
        }
      } else if (verbose && path.basename(filePath).includes('.example')) {
        // Don't warn about missing .example files
        continue;
      } else if (
        verbose &&
        (path.basename(filePath) === '.env.local' || path.basename(filePath) === '.env.production')
      ) {
        // Don't warn about optional local/production files
        continue;
      }
    }

    if (verbose) {
      const loadedCount = this.loadedFiles.get(appName)?.length || 0;
      console.log(`  ✅ Loaded ${loadedCount} file(s) with ${this.loadedVars.size} variable(s)\n`);
    }
  }

  /**
   * Build the list of .env files to load in priority order
   * @private
   */
  private static buildFileList(
    appName: string,
    environment: 'development' | 'production',
    baseDir: string,
    appDir?: string,
    allowLocal: boolean = true,
  ): string[] {
    const files: string[] = [];

    // 1. Root .env (base defaults - lowest priority)
    files.push(path.join(baseDir, '.env'));

    // 2. App-specific in root (for monorepo structure)
    files.push(path.join(baseDir, `.env.${appName}`));

    // 3. App-specific in app directory (if provided)
    if (appDir) {
      files.push(path.join(appDir, `.env.${appName}`));
    }

    // 4. Local overrides (only in development, not committed)
    if (allowLocal) {
      files.push(path.join(baseDir, '.env.local'));
      if (appDir) {
        files.push(path.join(appDir, '.env.local'));
      }
    }

    // 5. Environment-specific (highest priority before process.env)
    files.push(path.join(baseDir, `.env.${environment}`));
    if (appDir) {
      files.push(path.join(appDir, `.env.${environment}`));
    }

    return files;
  }

  /**
   * Get all variables that were loaded from .env files
   * (Does not include process.env variables not from .env files)
   *
   * @returns Map of loaded variable name to value
   */
  static getLoadedVars(): Record<string, string> {
    return Object.fromEntries(this.loadedVars);
  }

  /**
   * Get the list of files that were loaded for an app
   *
   * @param appName - Application name
   * @returns List of file paths that were loaded
   */
  static getLoadedFiles(appName: string): string[] {
    return this.loadedFiles.get(appName) || [];
  }

  /**
   * Reset loader state (useful for testing)
   * @private
   */
  static reset(): void {
    this.loadedFiles.clear();
    this.loadedVars.clear();
  }

  /**
   * Get a required environment variable or throw error
   *
   * @param key - Variable name
   * @param appName - Application name (for error message)
   * @returns Variable value
   * @throws Error if variable not found
   */
  static getRequired(key: string, appName: string = 'unknown'): string {
    const value = process.env[key];
    if (!value) {
      throw new Error(
        `❌ Required environment variable missing: ${key} (app: ${appName})\n` +
          `Please set ${key} in one of the .env files or in process.env`,
      );
    }
    return value;
  }

  /**
   * Get an optional environment variable with default
   *
   * @param key - Variable name
   * @param defaultValue - Default value if not set
   * @returns Variable value or default
   */
  static getOptional(key: string, defaultValue: string = ''): string {
    return process.env[key] || defaultValue;
  }

  /**
   * Get a numeric environment variable
   *
   * @param key - Variable name
   * @param defaultValue - Default value if not set
   * @returns Parsed number
   * @throws Error if value cannot be parsed
   */
  static getNumber(key: string, defaultValue?: number): number {
    const value = process.env[key];
    if (value === undefined) {
      if (defaultValue !== undefined) {
        return defaultValue;
      }
      throw new Error(`❌ Required number environment variable missing: ${key}`);
    }
    const num = parseInt(value, 10);
    if (isNaN(num)) {
      throw new Error(`❌ Invalid number for ${key}: "${value}"`);
    }
    return num;
  }

  /**
   * Get a boolean environment variable
   * Recognizes: 'true', '1', 'yes', 'on' as true (case-insensitive)
   * Everything else is false
   *
   * @param key - Variable name
   * @param defaultValue - Default value if not set
   * @returns Parsed boolean
   */
  static getBoolean(key: string, defaultValue: boolean = false): boolean {
    const value = process.env[key];
    if (value === undefined) {
      return defaultValue;
    }
    return ['true', '1', 'yes', 'on'].includes(value.toLowerCase());
  }

  /**
   * Get a comma-separated list as array
   *
   * @param key - Variable name
   * @param defaultValue - Default value if not set
   * @returns Array of strings
   */
  static getArray(key: string, defaultValue: string[] = []): string[] {
    const value = process.env[key];
    if (!value) {
      return defaultValue;
    }
    return value
      .split(',')
      .map((v) => v.trim())
      .filter(Boolean);
  }
}

/**
 * Setup function to load env and validate schema
 * Use this as a convenient wrapper in your app
 *
 * @example
 * import { setupEnv } from '@shared/config/env-loader';
 * import { validateArchifyEnv } from '@archify/config/env.schema';
 *
 * const config = setupEnv('archify', validateArchifyEnv, { verbose: true });
 */
export function setupEnv<T>(
  appName: string,
  validator: (env: NodeJS.ProcessEnv) => T,
  options?: EnvLoaderOptions & { appDir?: string },
): T {
  const { appDir, ...loaderOptions } = options || {};

  // Load .env files
  EnvLoader.loadEnv(appName, (process.env.NODE_ENV as any) || 'development', appDir, loaderOptions);

  // Validate and return typed config
  return validator(process.env);
}

export default EnvLoader;
