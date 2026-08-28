#!/usr/bin/env ts-node
/**
 * inject.ts - Secret Injection Fallback Script
 *
 * Provides fallback mechanism for scenarios where Process Supervisor pattern
 * cannot be used directly (CLI commands, migrations, workers).
 *
 * Usage:
 *   ./scripts/security/inject.ts <app-name> <command>
 *
 * Example:
 *   ./scripts/security/inject.ts numeriqo "npm run migrate"
 *   ./scripts/security/inject.ts archify "node dist/cli/seed.js"
 */

import * as fs from 'fs';
import * as path from 'path';
import { execSync } from 'child_process';

interface DbCredentials {
  username: string;
  password: string;
  lease_id: string;
  lease_duration: number;
  renewable: boolean;
}

interface AppSecrets {
  jwt_secret: string;
  api_key: string;
  encryption_key: string;
}

interface SecretValidationResult {
  valid: boolean;
  missing: string[];
  errors: string[];
}

class SecretInjector {
  private appName: string;
  private secretsPath: string;
  private dbCredsPath: string;
  private appSecretsPath: string;
  private envPath: string;

  constructor(appName: string) {
    this.appName = appName;
    this.secretsPath = '/app/secrets';
    this.dbCredsPath = path.join(this.secretsPath, 'db-creds.json');
    this.appSecretsPath = path.join(this.secretsPath, 'app-secrets.json');
    this.envPath = path.join(this.secretsPath, '.env');
  }

  /**
   * Validate that all required secrets are present and valid
   */
  validateSecrets(): SecretValidationResult {
    const result: SecretValidationResult = {
      valid: true,
      missing: [],
      errors: [],
    };

    // Check if secrets directory exists
    if (!fs.existsSync(this.secretsPath)) {
      result.valid = false;
      result.errors.push(`Secrets directory not found: ${this.secretsPath}`);
      return result;
    }

    // Check DB credentials
    if (!fs.existsSync(this.dbCredsPath)) {
      result.valid = false;
      result.missing.push('db-creds.json');
    } else {
      try {
        const dbCreds: DbCredentials = JSON.parse(fs.readFileSync(this.dbCredsPath, 'utf8'));
        if (!dbCreds.username || !dbCreds.password) {
          result.valid = false;
          result.errors.push('DB credentials incomplete (missing username or password)');
        }
        if (!dbCreds.lease_id) {
          result.errors.push('Warning: DB credentials missing lease_id');
        }
      } catch (error) {
        result.valid = false;
        const errorMessage = error instanceof Error ? error.message : String(error);
        result.errors.push(`Failed to parse db-creds.json: ${errorMessage}`);
      }
    }

    // Check app secrets
    if (!fs.existsSync(this.appSecretsPath)) {
      result.valid = false;
      result.missing.push('app-secrets.json');
    } else {
      try {
        const appSecrets: AppSecrets = JSON.parse(fs.readFileSync(this.appSecretsPath, 'utf8'));
        if (!appSecrets.jwt_secret) {
          result.valid = false;
          result.errors.push('App secrets incomplete (missing jwt_secret)');
        }
      } catch (error) {
        result.valid = false;
        const errorMessage = error instanceof Error ? error.message : String(error);
        result.errors.push(`Failed to parse app-secrets.json: ${errorMessage}`);
      }
    }

    // Check .env file
    if (!fs.existsSync(this.envPath)) {
      result.valid = false;
      result.missing.push('.env');
    }

    return result;
  }

  /**
   * Load secrets into environment variables
   */
  loadSecrets(): void {
    console.log(`[SecretInjector] Loading secrets for ${this.appName}...`);

    // Load .env file
    if (fs.existsSync(this.envPath)) {
      const envContent = fs.readFileSync(this.envPath, 'utf8');
      const lines = envContent.split('\n');

      for (const line of lines) {
        const trimmed = line.trim();
        if (trimmed && !trimmed.startsWith('#')) {
          const [key, ...valueParts] = trimmed.split('=');
          const value = valueParts.join('=');
          if (key && value) {
            process.env[key] = value;
            // Don't log secret values
            console.log(`[SecretInjector]   ✓ Loaded ${key}`);
          }
        }
      }
    }

    console.log(`[SecretInjector] ✓ Secrets loaded successfully`);
  }

  /**
   * Execute command with injected secrets
   */
  executeCommand(command: string): void {
    console.log(`[SecretInjector] Executing: ${command}`);
    console.log(`[SecretInjector] ----------------------------------------`);

    try {
      execSync(command, {
        stdio: 'inherit',
        env: process.env,
        cwd: '/app',
      });
      console.log(`[SecretInjector] ----------------------------------------`);
      console.log(`[SecretInjector] ✓ Command completed successfully`);
    } catch (error: any) {
      const exitCode = error?.status || 1;
      console.error(`[SecretInjector] ✗ Command failed with exit code ${exitCode}`);
      process.exit(exitCode);
    }
  }

  /**
   * Main injection workflow
   */
  run(command: string): void {
    console.log(`[SecretInjector] ========================================`);
    console.log(`[SecretInjector] Secret Injection Fallback`);
    console.log(`[SecretInjector] App: ${this.appName}`);
    console.log(`[SecretInjector] ========================================`);
    console.log('');

    // Validate secrets
    console.log(`[SecretInjector] [1/3] Validating secrets...`);
    const validation = this.validateSecrets();

    if (!validation.valid) {
      console.error(`[SecretInjector] ✗ Secret validation failed!`);
      if (validation.missing.length > 0) {
        console.error(`[SecretInjector]   Missing files: ${validation.missing.join(', ')}`);
      }
      if (validation.errors.length > 0) {
        validation.errors.forEach((err) => console.error(`[SecretInjector]   ${err}`));
      }
      console.error('');
      console.error(
        `[SecretInjector] Ensure OpenBao Agent has rendered secrets to ${this.secretsPath}`,
      );
      process.exit(1);
    }

    console.log(`[SecretInjector] ✓ All secrets validated`);
    console.log('');

    // Load secrets
    console.log(`[SecretInjector] [2/3] Loading secrets into environment...`);
    this.loadSecrets();
    console.log('');

    // Execute command
    console.log(`[SecretInjector] [3/3] Executing command...`);
    this.executeCommand(command);
  }
}

// Main execution
if (require.main === module) {
  const args = process.argv.slice(2);

  if (args.length < 2) {
    console.error('Usage: inject.ts <app-name> <command>');
    console.error('Example: inject.ts numeriqo "npm run migrate"');
    process.exit(1);
  }

  const [appName, command] = args;
  const injector = new SecretInjector(appName);
  injector.run(command);
}

export { SecretInjector, DbCredentials, AppSecrets, SecretValidationResult };
