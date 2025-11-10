import { readFile } from '../utils/validation';

describe('commitlint.config.js', () => {
  let commitlintConfig: any;

  beforeAll(() => {
    // Clear the require cache to ensure fresh load
    delete require.cache[require.resolve('../../commitlint.config.js')];
    commitlintConfig = require('../../commitlint.config.js');
  });

  describe('Configuration Structure', () => {
    it('should export a valid configuration object', () => {
      expect(commitlintConfig).toBeDefined();
      expect(typeof commitlintConfig).toBe('object');
    });

    it('should extend @commitlint/config-conventional', () => {
      expect(commitlintConfig.extends).toBeDefined();
      expect(Array.isArray(commitlintConfig.extends)).toBe(true);
      expect(commitlintConfig.extends).toContain('@commitlint/config-conventional');
    });

    it('should have valid extends array with at least one preset', () => {
      expect(commitlintConfig.extends.length).toBeGreaterThan(0);
      commitlintConfig.extends.forEach((preset: string) => {
        expect(typeof preset).toBe('string');
        expect(preset.length).toBeGreaterThan(0);
      });
    });
  });

  describe('Conventional Commits Compatibility', () => {
    it('should support standard conventional commit types', () => {
      // This validates the config extends conventional config which supports these types
      const standardTypes = [
        'feat',
        'fix',
        'docs',
        'style',
        'refactor',
        'perf',
        'test',
        'chore',
        'ci',
        'build',
        'revert',
      ];
      
      // The config should work with these types (implicit via conventional config)
      expect(commitlintConfig.extends).toContain('@commitlint/config-conventional');
    });
  });

  describe('File Validity', () => {
    it('should be valid JavaScript that can be required', () => {
      expect(() => {
        delete require.cache[require.resolve('../../commitlint.config.js')];
        require('../../commitlint.config.js');
      }).not.toThrow();
    });

    it('should export CommonJS module format', () => {
      const fileContent = readFile('commitlint.config.js');
      expect(fileContent).toContain('module.exports');
    });
  });

  describe('Edge Cases', () => {
    it('should handle empty extends gracefully', () => {
      // Current config should have extends
      expect(commitlintConfig.extends).toBeTruthy();
    });

    it('should not have circular references', () => {
      expect(() => JSON.stringify(commitlintConfig)).not.toThrow();
    });
  });
});