import { readJsonFile, hasRequiredProperties, isValidUrl } from '../utils/validation';

describe('nx.json', () => {
  let nxConfig: any;

  beforeAll(() => {
    nxConfig = readJsonFile('nx.json');
  });

  describe('JSON Structure', () => {
    it('should be valid JSON', () => {
      expect(nxConfig).toBeDefined();
      expect(typeof nxConfig).toBe('object');
    });

    it('should have required top-level properties', () => {
      const requiredProps = ['$schema', 'defaultBase', 'packageManager'];
      expect(hasRequiredProperties(nxConfig, requiredProps)).toBe(true);
    });

    it('should have valid $schema reference', () => {
      expect(nxConfig.$schema).toBeDefined();
      expect(typeof nxConfig.$schema).toBe('string');
      expect(nxConfig.$schema).toContain('nx-schema.json');
    });
  });

  describe('Base Configuration', () => {
    it('should have defaultBase set to dev', () => {
      expect(nxConfig.defaultBase).toBe('dev');
    });

    it('should use pnpm as package manager', () => {
      expect(nxConfig.packageManager).toBe('pnpm');
    });

    it('should have valid package manager', () => {
      const validManagers = ['npm', 'yarn', 'pnpm'];
      expect(validManagers).toContain(nxConfig.packageManager);
    });
  });

  describe('Plugins Configuration', () => {
    it('should have plugins array', () => {
      expect(Array.isArray(nxConfig.plugins)).toBe(true);
    });

    it('should have at least one plugin', () => {
      expect(nxConfig.plugins.length).toBeGreaterThan(0);
    });

    it('should configure ESLint plugin', () => {
      const eslintPlugin = nxConfig.plugins.find(
        (p: any) => p.plugin === '@nx/eslint/plugin',
      );
      expect(eslintPlugin).toBeDefined();
    });

    it('should have valid plugin structure', () => {
      nxConfig.plugins.forEach((plugin: any) => {
        expect(plugin).toHaveProperty('plugin');
        expect(typeof plugin.plugin).toBe('string');
        if (plugin.options) {
          expect(typeof plugin.options).toBe('object');
        }
      });
    });

    it('should configure ESLint plugin with targetName', () => {
      const eslintPlugin = nxConfig.plugins.find(
        (p: any) => p.plugin === '@nx/eslint/plugin',
      );
      expect(eslintPlugin.options).toBeDefined();
      expect(eslintPlugin.options.targetName).toBe('lint');
    });
  });

  describe('Target Defaults', () => {
    it('should have targetDefaults configuration', () => {
      expect(nxConfig.targetDefaults).toBeDefined();
      expect(typeof nxConfig.targetDefaults).toBe('object');
    });

    describe('Build Target', () => {
      it('should have build target configuration', () => {
        expect(nxConfig.targetDefaults.build).toBeDefined();
      });

      it('should enable caching for build', () => {
        expect(nxConfig.targetDefaults.build.cache).toBe(true);
      });

      it('should have dependsOn configuration', () => {
        expect(nxConfig.targetDefaults.build.dependsOn).toBeDefined();
        expect(Array.isArray(nxConfig.targetDefaults.build.dependsOn)).toBe(true);
      });

      it('should depend on ^build', () => {
        expect(nxConfig.targetDefaults.build.dependsOn).toContain('^build');
      });

      it('should have inputs configuration', () => {
        expect(Array.isArray(nxConfig.targetDefaults.build.inputs)).toBe(true);
      });

      it('should have outputs configuration', () => {
        expect(Array.isArray(nxConfig.targetDefaults.build.outputs)).toBe(true);
      });

      it('should output to dist directory', () => {
        expect(nxConfig.targetDefaults.build.outputs).toContain('{projectRoot}/dist');
      });
    });

    describe('Lint Target', () => {
      it('should have lint target configuration', () => {
        expect(nxConfig.targetDefaults.lint).toBeDefined();
      });

      it('should enable caching for lint', () => {
        expect(nxConfig.targetDefaults.lint.cache).toBe(true);
      });

      it('should have inputs configuration', () => {
        expect(Array.isArray(nxConfig.targetDefaults.lint.inputs)).toBe(true);
      });
    });

    describe('Test Target', () => {
      it('should have test target configuration', () => {
        expect(nxConfig.targetDefaults.test).toBeDefined();
      });

      it('should enable caching for test', () => {
        expect(nxConfig.targetDefaults.test.cache).toBe(true);
      });

      it('should have inputs configuration', () => {
        expect(Array.isArray(nxConfig.targetDefaults.test.inputs)).toBe(true);
      });

      it('should have outputs for coverage', () => {
        expect(Array.isArray(nxConfig.targetDefaults.test.outputs)).toBe(true);
        expect(nxConfig.targetDefaults.test.outputs).toContain('{projectRoot}/coverage');
      });
    });

    describe('Format Check Target', () => {
      it('should have format:check target configuration', () => {
        expect(nxConfig.targetDefaults['format:check']).toBeDefined();
      });

      it('should enable caching for format:check', () => {
        expect(nxConfig.targetDefaults['format:check'].cache).toBe(true);
      });
    });

    describe('Docker Build Target', () => {
      it('should have docker-build target configuration', () => {
        expect(nxConfig.targetDefaults['docker-build']).toBeDefined();
      });

      it('should enable caching for docker-build', () => {
        expect(nxConfig.targetDefaults['docker-build'].cache).toBe(true);
      });

      it('should depend on build', () => {
        expect(nxConfig.targetDefaults['docker-build'].dependsOn).toContain('build');
      });
    });
  });

  describe('Caching Strategy', () => {
    it('should enable caching for all configured targets', () => {
      Object.values(nxConfig.targetDefaults).forEach((target: any) => {
        expect(target.cache).toBe(true);
      });
    });

    it('should have inputs for cacheable targets (recommended)', () => {
      Object.entries(nxConfig.targetDefaults).forEach(([name, target]: [string, any]) => {
        if (target.cache && target.inputs) {
          // If inputs are defined, they should be valid
          expect(Array.isArray(target.inputs)).toBe(true);
        }
        // Note: inputs are recommended but not required for caching
      });
    });
  });

  describe('Edge Cases', () => {
    it('should not have circular references', () => {
      expect(() => JSON.stringify(nxConfig)).not.toThrow();
    });

    it('should have valid dependency notation', () => {
      Object.values(nxConfig.targetDefaults).forEach((target: any) => {
        if (target.dependsOn) {
          target.dependsOn.forEach((dep: string) => {
            expect(typeof dep).toBe('string');
            // Dependencies can be "^build" or "build"
            expect(dep).toMatch(/^(\^)?[a-z-]+$/);
          });
        }
      });
    });

    it('should have valid input patterns', () => {
      Object.values(nxConfig.targetDefaults).forEach((target: any) => {
        if (target.inputs) {
          target.inputs.forEach((input: string) => {
            expect(typeof input).toBe('string');
          });
        }
      });
    });

    it('should have valid output patterns', () => {
      Object.values(nxConfig.targetDefaults).forEach((target: any) => {
        if (target.outputs) {
          target.outputs.forEach((output: string) => {
            expect(typeof output).toBe('string');
            expect(output).toContain('{projectRoot}');
          });
        }
      });
    });
  });
});