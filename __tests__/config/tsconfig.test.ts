import { readJsonFile, hasRequiredProperties } from '../utils/validation';

describe('tsconfig.base.json', () => {
  let tsconfigBase: any;

  beforeAll(() => {
    tsconfigBase = readJsonFile('tsconfig.base.json');
  });

  describe('JSON Structure', () => {
    it('should be valid JSON', () => {
      expect(tsconfigBase).toBeDefined();
      expect(typeof tsconfigBase).toBe('object');
    });

    it('should have compilerOptions', () => {
      expect(tsconfigBase.compilerOptions).toBeDefined();
      expect(typeof tsconfigBase.compilerOptions).toBe('object');
    });

    it('should have exclude array', () => {
      expect(Array.isArray(tsconfigBase.exclude)).toBe(true);
    });
  });

  describe('Compiler Options - Target and Module', () => {
    const compilerOptions = () => tsconfigBase.compilerOptions;

    it('should target ESNext', () => {
      expect(compilerOptions().target).toBe('ESNext');
    });

    it('should use ESNext module system', () => {
      expect(compilerOptions().module).toBe('ESNext');
    });

    it('should use bundler module resolution', () => {
      expect(compilerOptions().moduleResolution).toBe('bundler');
    });
  });

  describe('Compiler Options - Strict Type Checking', () => {
    const compilerOptions = () => tsconfigBase.compilerOptions;

    it('should enable strict mode', () => {
      expect(compilerOptions().strict).toBe(true);
    });

    it('should enable noImplicitAny', () => {
      expect(compilerOptions().noImplicitAny).toBe(true);
    });

    it('should enable strictNullChecks', () => {
      expect(compilerOptions().strictNullChecks).toBe(true);
    });

    it('should enable strictFunctionTypes', () => {
      expect(compilerOptions().strictFunctionTypes).toBe(true);
    });

    it('should enable strictBindCallApply', () => {
      expect(compilerOptions().strictBindCallApply).toBe(true);
    });

    it('should enable strictPropertyInitialization', () => {
      expect(compilerOptions().strictPropertyInitialization).toBe(true);
    });

    it('should enable noImplicitThis', () => {
      expect(compilerOptions().noImplicitThis).toBe(true);
    });

    it('should enable alwaysStrict', () => {
      expect(compilerOptions().alwaysStrict).toBe(true);
    });

    it('should enable noUncheckedIndexedAccess', () => {
      expect(compilerOptions().noUncheckedIndexedAccess).toBe(true);
    });

    it('should enable exactOptionalPropertyTypes', () => {
      expect(compilerOptions().exactOptionalPropertyTypes).toBe(true);
    });
  });

  describe('Compiler Options - Additional Checks', () => {
    const compilerOptions = () => tsconfigBase.compilerOptions;

    it('should enable noUnusedLocals', () => {
      expect(compilerOptions().noUnusedLocals).toBe(true);
    });

    it('should enable noUnusedParameters', () => {
      expect(compilerOptions().noUnusedParameters).toBe(true);
    });

    it('should enable noImplicitReturns', () => {
      expect(compilerOptions().noImplicitReturns).toBe(true);
    });

    it('should enable noFallthroughCasesInSwitch', () => {
      expect(compilerOptions().noFallthroughCasesInSwitch).toBe(true);
    });
  });

  describe('Compiler Options - Module Resolution', () => {
    const compilerOptions = () => tsconfigBase.compilerOptions;

    it('should skip lib check', () => {
      expect(compilerOptions().skipLibCheck).toBe(true);
    });

    it('should allow JS', () => {
      expect(compilerOptions().allowJs).toBe(true);
    });

    it('should enable esModuleInterop', () => {
      expect(compilerOptions().esModuleInterop).toBe(true);
    });

    it('should allow synthetic default imports', () => {
      expect(compilerOptions().allowSyntheticDefaultImports).toBe(true);
    });

    it('should resolve JSON modules', () => {
      expect(compilerOptions().resolveJsonModule).toBe(true);
    });

    it('should force consistent casing in file names', () => {
      expect(compilerOptions().forceConsistentCasingInFileNames).toBe(true);
    });

    it('should enable isolated modules', () => {
      expect(compilerOptions().isolatedModules).toBe(true);
    });
  });

  describe('Compiler Options - JSX', () => {
    it('should use react-jsx transform', () => {
      expect(tsconfigBase.compilerOptions.jsx).toBe('react-jsx');
    });

    it('should have valid jsx value', () => {
      const validJsx = ['react', 'react-jsx', 'react-jsxdev', 'preserve', 'react-native'];
      expect(validJsx).toContain(tsconfigBase.compilerOptions.jsx);
    });
  });

  describe('Compiler Options - Output', () => {
    const compilerOptions = () => tsconfigBase.compilerOptions;

    it('should enable declarations', () => {
      expect(compilerOptions().declaration).toBe(true);
    });

    it('should enable source maps', () => {
      expect(compilerOptions().sourceMap).toBe(true);
    });

    it('should enable incremental compilation', () => {
      expect(compilerOptions().incremental).toBe(true);
    });

    it('should disable composite', () => {
      expect(compilerOptions().composite).toBe(false);
    });
  });

  describe('Compiler Options - Paths', () => {
    const compilerOptions = () => tsconfigBase.compilerOptions;

    it('should have baseUrl set to current directory', () => {
      expect(compilerOptions().baseUrl).toBe('.');
    });

    it('should have paths configuration', () => {
      expect(compilerOptions().paths).toBeDefined();
      expect(typeof compilerOptions().paths).toBe('object');
    });

    it('should define workspace packages in paths', () => {
      const expectedPaths = [
        '@genius-suite/ui-design-system',
        '@genius-suite/feature-flags',
        '@genius-suite/auth-client',
        '@genius-suite/types',
        '@genius-suite/common',
        '@genius-suite/integrations',
        '@genius-suite/observability',
      ];

      expectedPaths.forEach((path) => {
        expect(compilerOptions().paths[path]).toBeDefined();
        expect(Array.isArray(compilerOptions().paths[path])).toBe(true);
      });
    });

    it('should have valid path mappings', () => {
      Object.entries(compilerOptions().paths).forEach(([key, value]: [string, any]) => {
        expect(key).toMatch(/^@[\w-]+\/[\w-]+$/);
        expect(Array.isArray(value)).toBe(true);
        expect(value.length).toBeGreaterThan(0);
        value.forEach((p: string) => {
          expect(typeof p).toBe('string');
          expect(p.length).toBeGreaterThan(0);
        });
      });
    });
  });

  describe('Exclude Configuration', () => {
    it('should exclude node_modules', () => {
      expect(tsconfigBase.exclude).toContain('node_modules');
    });

    it('should exclude tmp directory', () => {
      expect(tsconfigBase.exclude).toContain('tmp');
    });

    it('should have valid exclude patterns', () => {
      tsconfigBase.exclude.forEach((pattern: string) => {
        expect(typeof pattern).toBe('string');
        expect(pattern.length).toBeGreaterThan(0);
      });
    });
  });

  describe('Monorepo Configuration', () => {
    it('should support monorepo structure with paths', () => {
      const paths = tsconfigBase.compilerOptions.paths;
      expect(Object.keys(paths).length).toBeGreaterThan(0);
    });

    it('should use consistent package naming convention', () => {
      const paths = Object.keys(tsconfigBase.compilerOptions.paths);
      paths.forEach((path) => {
        expect(path).toMatch(/^@genius-suite\//);
      });
    });

    it('should map to shared directories', () => {
      const paths = Object.values(tsconfigBase.compilerOptions.paths) as string[][];
      paths.forEach((pathArray) => {
        pathArray.forEach((path) => {
          expect(path).toContain('shared/');
        });
      });
    });
  });

  describe('Edge Cases', () => {
    it('should not have circular references', () => {
      expect(() => JSON.stringify(tsconfigBase)).not.toThrow();
    });

    it('should have all boolean options as actual booleans', () => {
      const booleanProps = [
        'strict',
        'skipLibCheck',
        'allowJs',
        'esModuleInterop',
        'allowSyntheticDefaultImports',
        'forceConsistentCasingInFileNames',
        'isolatedModules',
        'noImplicitAny',
        'strictNullChecks',
        'strictFunctionTypes',
        'strictBindCallApply',
        'strictPropertyInitialization',
        'noImplicitThis',
        'alwaysStrict',
        'noUncheckedIndexedAccess',
        'exactOptionalPropertyTypes',
        'noUnusedLocals',
        'noUnusedParameters',
        'noImplicitReturns',
        'noFallthroughCasesInSwitch',
        'resolveJsonModule',
        'composite',
        'declaration',
        'sourceMap',
        'incremental',
      ];

      booleanProps.forEach((prop) => {
        if (prop in tsconfigBase.compilerOptions) {
          expect(typeof tsconfigBase.compilerOptions[prop]).toBe('boolean');
        }
      });
    });
  });
});