import { readFileSync } from 'fs';
import { join } from 'path';

/**
 * Read and parse a JSON file
 */
export function readJsonFile<T = any>(filePath: string): T {
  const fullPath = join(process.cwd(), filePath);
  const content = readFileSync(fullPath, 'utf-8');
  return JSON.parse(content);
}

/**
 * Read a file as string
 */
export function readFile(filePath: string): string {
  const fullPath = join(process.cwd(), filePath);
  return readFileSync(fullPath, 'utf-8');
}

/**
 * Validate JSON structure
 */
export function isValidJson(content: string): boolean {
  try {
    JSON.parse(content);
    return true;
  } catch {
    return false;
  }
}

/**
 * Check if an object has required properties
 */
export function hasRequiredProperties<T extends object>(
  obj: T,
  properties: (keyof T)[],
): boolean {
  return properties.every((prop) => prop in obj);
}

/**
 * Validate that a value is of expected type
 */
export function isOfType(value: any, expectedType: string): boolean {
  if (expectedType === 'array') {
    return Array.isArray(value);
  }
  return typeof value === expectedType;
}

/**
 * Validate URL format
 */
export function isValidUrl(url: string): boolean {
  try {
    new URL(url);
    return true;
  } catch {
    return false;
  }
}

/**
 * Validate semantic version format
 */
export function isValidSemver(version: string): boolean {
  const semverRegex = /^\d+\.\d+\.\d+(-[a-zA-Z0-9.-]+)?(\+[a-zA-Z0-9.-]+)?$/;
  return semverRegex.test(version);
}