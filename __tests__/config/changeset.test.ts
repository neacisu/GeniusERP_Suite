import { readJsonFile, hasRequiredProperties, isValidUrl } from '../utils/validation';

describe('.changeset/config.json', () => {
  let changesetConfig: any;

  beforeAll(() => {
    changesetConfig = readJsonFile('.changeset/config.json');
  });

  describe('JSON Structure', () => {
    it('should be valid JSON', () => {
      expect(changesetConfig).toBeDefined();
      expect(typeof changesetConfig).toBe('object');
    });

    it('should have required top-level properties', () => {
      const requiredProps = [
        'changelog',
        'commit',
        'fixed',
        'linked',
        'access',
        'baseBranch',
        'updateInternalDependencies',
        'ignore',
      ];
      expect(hasRequiredProperties(changesetConfig, requiredProps)).toBe(true);
    });

    it('should have valid $schema reference', () => {
      expect(changesetConfig.$schema).toBeDefined();
      expect(typeof changesetConfig.$schema).toBe('string');
      expect(isValidUrl(changesetConfig.$schema)).toBe(true);
    });
  });

  describe('Changelog Configuration', () => {
    it('should have changelog as an array', () => {
      expect(Array.isArray(changesetConfig.changelog)).toBe(true);
    });

    it('should specify @changesets/changelog-github as the first element', () => {
      expect(changesetConfig.changelog[0]).toBe('@changesets/changelog-github');
    });

    it('should have changelog options with repo field', () => {
      expect(changesetConfig.changelog[1]).toBeDefined();
      expect(typeof changesetConfig.changelog[1]).toBe('object');
      expect(changesetConfig.changelog[1].repo).toBeDefined();
      expect(typeof changesetConfig.changelog[1].repo).toBe('string');
    });

    it('should have valid GitHub repo format', () => {
      const repo = changesetConfig.changelog[1].repo;
      expect(repo).toMatch(/^[\w-]+\/[\w-]+$/);
      expect(repo).toBe('neacisu/GeniusSuite');
    });
  });

  describe('Version Control Configuration', () => {
    it('should have commit set to false', () => {
      expect(changesetConfig.commit).toBe(false);
    });

    it('should have baseBranch as master', () => {
      expect(changesetConfig.baseBranch).toBe('master');
    });

    it('should have valid baseBranch value', () => {
      const validBranches = ['master', 'main', 'develop'];
      expect(validBranches).toContain(changesetConfig.baseBranch);
    });
  });

  describe('Package Configuration', () => {
    it('should have fixed as an array', () => {
      expect(Array.isArray(changesetConfig.fixed)).toBe(true);
    });

    it('should have linked as an array', () => {
      expect(Array.isArray(changesetConfig.linked)).toBe(true);
    });

    it('should have ignore as an array', () => {
      expect(Array.isArray(changesetConfig.ignore)).toBe(true);
    });

    it('should have valid access level', () => {
      expect(['public', 'restricted']).toContain(changesetConfig.access);
    });

    it('should be configured as public access', () => {
      expect(changesetConfig.access).toBe('public');
    });
  });

  describe('Update Strategy', () => {
    it('should have updateInternalDependencies configuration', () => {
      expect(changesetConfig.updateInternalDependencies).toBeDefined();
    });

    it('should use patch strategy for internal dependencies', () => {
      expect(changesetConfig.updateInternalDependencies).toBe('patch');
    });

    it('should have valid updateInternalDependencies value', () => {
      const validStrategies = ['patch', 'minor'];
      expect(validStrategies).toContain(changesetConfig.updateInternalDependencies);
    });
  });

  describe('Edge Cases', () => {
    it('should handle empty arrays correctly', () => {
      expect(changesetConfig.fixed).toEqual([]);
      expect(changesetConfig.linked).toEqual([]);
      expect(changesetConfig.ignore).toEqual([]);
    });

    it('should not have unexpected properties', () => {
      const knownProps = [
        '$schema',
        'changelog',
        'commit',
        'fixed',
        'linked',
        'access',
        'baseBranch',
        'updateInternalDependencies',
        'ignore',
      ];
      const actualProps = Object.keys(changesetConfig);
      actualProps.forEach((prop) => {
        expect(knownProps).toContain(prop);
      });
    });
  });
});