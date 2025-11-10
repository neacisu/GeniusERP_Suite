import { readJsonFile, hasRequiredProperties } from '../utils/validation';

describe('.eslintrc.json', () => {
  let eslintConfig: any;

  beforeAll(() => {
    eslintConfig = readJsonFile('.eslintrc.json');
  });

  describe('JSON Structure', () => {
    it('should be valid JSON', () => {
      expect(eslintConfig).toBeDefined();
      expect(typeof eslintConfig).toBe('object');
    });

    it('should have required top-level properties', () => {
      const requiredProps = ['root', 'ignorePatterns', 'plugins', 'overrides'];
      expect(hasRequiredProperties(eslintConfig, requiredProps)).toBe(true);
    });

    it('should be marked as root configuration', () => {
      expect(eslintConfig.root).toBe(true);
    });
  });

  describe('Plugins Configuration', () => {
    it('should have plugins as an array', () => {
      expect(Array.isArray(eslintConfig.plugins)).toBe(true);
    });

    it('should include @nx plugin', () => {
      expect(eslintConfig.plugins).toContain('@nx');
    });

    it('should include prettier plugin', () => {
      expect(eslintConfig.plugins).toContain('prettier');
    });

    it('should have valid plugin names', () => {
      eslintConfig.plugins.forEach((plugin: string) => {
        expect(typeof plugin).toBe('string');
        expect(plugin.length).toBeGreaterThan(0);
      });
    });
  });

  describe('Ignore Patterns', () => {
    it('should have ignorePatterns as an array', () => {
      expect(Array.isArray(eslintConfig.ignorePatterns)).toBe(true);
    });

    it('should ignore all files by default (overridden in overrides)', () => {
      expect(eslintConfig.ignorePatterns).toContain('**/*');
    });
  });

  describe('Overrides Configuration', () => {
    it('should have overrides as an array', () => {
      expect(Array.isArray(eslintConfig.overrides)).toBe(true);
    });

    it('should have at least one override configuration', () => {
      expect(eslintConfig.overrides.length).toBeGreaterThan(0);
    });

    describe('TypeScript/JavaScript Override', () => {
      let tsOverride: any;

      beforeAll(() => {
        tsOverride = eslintConfig.overrides.find((override: any) =>
          override.files.some((file: string) => file.includes('.ts')),
        );
      });

      it('should have override for TypeScript and JavaScript files', () => {
        expect(tsOverride).toBeDefined();
      });

      it('should specify correct file patterns', () => {
        expect(tsOverride.files).toContain('*.ts');
        expect(tsOverride.files).toContain('*.tsx');
        expect(tsOverride.files).toContain('*.js');
        expect(tsOverride.files).toContain('*.jsx');
      });

      it('should extend required configurations', () => {
        expect(Array.isArray(tsOverride.extends)).toBe(true);
        expect(tsOverride.extends).toContain('plugin:@nx/typescript');
        expect(tsOverride.extends).toContain('plugin:@typescript-eslint/recommended');
        expect(tsOverride.extends).toContain('plugin:prettier/recommended');
      });

      it('should use TypeScript parser', () => {
        expect(tsOverride.parser).toBe('@typescript-eslint/parser');
      });

      it('should have valid parser options', () => {
        expect(tsOverride.parserOptions).toBeDefined();
        expect(tsOverride.parserOptions.ecmaVersion).toBe('latest');
        expect(tsOverride.parserOptions.sourceType).toBe('module');
      });

      it('should have rules configuration', () => {
        expect(tsOverride.rules).toBeDefined();
        expect(typeof tsOverride.rules).toBe('object');
      });

      it('should enforce prettier as error', () => {
        expect(tsOverride.rules['prettier/prettier']).toBe('error');
      });

      it('should have Nx module boundaries rule', () => {
        expect(tsOverride.rules['@nx/enforce-module-boundaries']).toBeDefined();
      });

      it('should configure module boundaries correctly', () => {
        const boundariesRule = tsOverride.rules['@nx/enforce-module-boundaries'];
        expect(Array.isArray(boundariesRule)).toBe(true);
        expect(boundariesRule[0]).toBe('error');
        expect(boundariesRule[1]).toBeDefined();
        expect(boundariesRule[1].enforceBuildableLibDependency).toBe(true);
      });
    });
  });

  describe('Edge Cases', () => {
    it('should not have circular references', () => {
      expect(() => JSON.stringify(eslintConfig)).not.toThrow();
    });

    it('should handle empty arrays in configuration', () => {
      const tsOverride = eslintConfig.overrides[0];
      if (tsOverride.rules['@nx/enforce-module-boundaries']) {
        const rule = tsOverride.rules['@nx/enforce-module-boundaries'];
        expect(Array.isArray(rule[1].allow)).toBe(true);
        expect(Array.isArray(rule[1].depConstraints)).toBe(true);
      }
    });
  });
});