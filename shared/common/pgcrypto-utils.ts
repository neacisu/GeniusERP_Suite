// Type-only import - pg package should be installed in consuming applications
import type { Client } from 'pg';

/**
 * PGCrypto Utilities for GeniusERP Suite
 * Provides encryption/decryption functions using PostgreSQL pgcrypto extension
 */

export interface EncryptionConfig {
  encryptionKey: string;
  algorithm?: 'aes256' | 'aes128';
}

/**
 * Encrypt plaintext using PostgreSQL pgp_sym_encrypt
 * @param client PostgreSQL client
 * @param plaintext Data to encrypt
 * @param encryptionKey Encryption key (retrieve from OpenBao)
 * @returns Encrypted data as Buffer
 */
export async function encryptPII(
  client: Client,
  plaintext: string,
  encryptionKey: string,
): Promise<Buffer> {
  if (!plaintext) {
    throw new Error('Plaintext cannot be empty');
  }

  if (!encryptionKey || encryptionKey.length < 32) {
    throw new Error('Encryption key must be at least 32 characters (256 bits)');
  }

  const result = await client.query('SELECT pgp_sym_encrypt($1::text, $2::text) AS encrypted', [
    plaintext,
    encryptionKey,
  ]);

  return result.rows[0].encrypted;
}

/**
 * Decrypt ciphertext using PostgreSQL pgp_sym_decrypt
 * @param client PostgreSQL client
 * @param ciphertext Encrypted data (Buffer or Uint8Array)
 * @param encryptionKey Encryption key (retrieve from OpenBao)
 * @returns Decrypted plaintext string
 */
export async function decryptPII(
  client: Client,
  ciphertext: Buffer | Uint8Array,
  encryptionKey: string,
): Promise<string> {
  if (!ciphertext || ciphertext.length === 0) {
    throw new Error('Ciphertext cannot be empty');
  }

  if (!encryptionKey || encryptionKey.length < 32) {
    throw new Error('Encryption key must be at least 32 characters (256 bits)');
  }

  const result = await client.query('SELECT pgp_sym_decrypt($1::bytea, $2::text) AS decrypted', [
    ciphertext,
    encryptionKey,
  ]);

  return result.rows[0].decrypted;
}

/**
 * Retrieve encryption key from OpenBao KV
 * @param vaultPath Path to secret in OpenBao (e.g., 'kv/data/encryption-keys/pii')
 * @param vaultToken OpenBao token (from environment)
 * @param vaultAddr OpenBao address (from environment)
 * @returns Encryption key string
 */
export async function getEncryptionKeyFromVault(
  vaultPath: string,
  vaultToken?: string,
  vaultAddr?: string,
): Promise<string> {
  const token = vaultToken || process.env.BAO_TOKEN;
  const addr = vaultAddr || process.env.BAO_ADDR || 'http://openbao:8200';

  if (!token) {
    throw new Error('OpenBao token not provided (BAO_TOKEN environment variable)');
  }

  const response = await fetch(`${addr}/v1/${vaultPath}`, {
    headers: {
      'X-Vault-Token': token,
    },
  });

  if (!response.ok) {
    throw new Error(`Failed to retrieve key from OpenBao: ${response.statusText}`);
  }

  const data = (await response.json()) as { data?: { data?: { value?: string } } };

  // KV v2 structure: data.data.value
  const key = data?.data?.data?.value;

  if (!key) {
    throw new Error(`Key not found at path: ${vaultPath}`);
  }

  if (key.length < 32) {
    throw new Error('Retrieved key does not meet minimum 256-bit entropy requirement');
  }

  return key;
}

/**
 * Example: Encrypt SSN with key from OpenBao
 */
export async function encryptSSNExample(client: Client, ssn: string): Promise<Buffer> {
  // Retrieve encryption key from OpenBao
  const encryptionKey = await getEncryptionKeyFromVault('kv/data/encryption-keys/pii');

  // Encrypt SSN
  return encryptPII(client, ssn, encryptionKey);
}

/**
 * Example: Decrypt SSN with key from OpenBao
 */
export async function decryptSSNExample(client: Client, encryptedSSN: Buffer): Promise<string> {
  // Retrieve encryption key from OpenBao
  const encryptionKey = await getEncryptionKeyFromVault('kv/data/encryption-keys/pii');

  // Decrypt SSN
  return decryptPII(client, encryptedSSN, encryptionKey);
}
