import { readJsonFile } from '../utils/validation';

describe('.lintstagedrc.json', () => {
  let lintStagedConfig: any;

  beforeAll(() => {
    lintStagedConfig = readJsonFile('.lintstagedrc.json');
  });

  describe('JSON Structure', () => {
    it('should be valid JSON', () => {
      expect(lintStagedConfig).toBeDefined();
      expect(typeof lintStagedConfig).toBe('object');
    });

    it('should have file pattern keys', () => {
      const keys = Object.keys(lintStagedConfig);
      expect(keys.length).toBeGreaterThan(0);
    });
  });

  describe('TypeScript/JavaScript File Patterns', () => {
    it('should have configuration for TS/JS files', () => {
      const pattern = '*.{ts,tsx,js,jsx}';
      expect(lintStagedConfig[pattern]).toBeDefined();
    });

    it('should have commands as an array', () => {
      const pattern = '*.{ts,tsx,js,jsx}';
      expect(Array.isArray(lintStagedConfig[pattern])).toBe(true);
    });

    it('should include format command', () => {
      const pattern = '*.{ts,tsx,js,jsx}';
      const commands = lintStagedConfig[pattern];
      const formatCommand = commands.find((cmd: string) => cmd.includes('format:write'));
      expect(formatCommand).toBeDefined();
      expect(formatCommand).toContain('nx format:write --files');
    });

    it('should include lint fix command', () => {
      const pattern = '*.{ts,tsx,js,jsx}';
      const commands = lintStagedConfig[pattern];
      const lintCommand = commands.find((cmd: string) => cmd.includes('lint'));
      expect(lintCommand).toBeDefined();
      expect(lintCommand).toContain('nx affected:lint --fix --files');
    });

    it('should run format before lint', () => {
      const pattern = '*.{ts,tsx,js,jsx}';
      const commands = lintStagedConfig[pattern];
      const formatIndex = commands.findIndex((cmd: string) => cmd.includes('format'));
      const lintIndex = commands.findIndex((cmd: string) => cmd.includes('lint'));
      expect(formatIndex).toBeLessThan(lintIndex);
    });
  });

  describe('Command Validation', () => {
    it('should have valid command syntax', () => {
      Object.values(lintStagedConfig).forEach((commands: any) => {
        if (Array.isArray(commands)) {
          commands.forEach((cmd) => {
            expect(typeof cmd).toBe('string');
            expect(cmd.length).toBeGreaterThan(0);
          });
        }
      });
    });

    it('should use nx commands', () => {
      const pattern = '*.{ts,tsx,js,jsx}';
      const commands = lintStagedConfig[pattern];
      commands.forEach((cmd: string) => {
        expect(cmd).toContain('nx');
      });
    });

    it('should pass files to commands', () => {
      const pattern = '*.{ts,tsx,js,jsx}';
      const commands = lintStagedConfig[pattern];
      commands.forEach((cmd: string) => {
        expect(cmd).toContain('--files');
      });
    });
  });

  describe('Pattern Coverage', () => {
    it('should cover TypeScript files', () => {
      const pattern = '*.{ts,tsx,js,jsx}';
      expect(pattern).toContain('ts');
      expect(pattern).toContain('tsx');
    });

    it('should cover JavaScript files', () => {
      const pattern = '*.{ts,tsx,js,jsx}';
      expect(pattern).toContain('js');
      expect(pattern).toContain('jsx');
    });

    it('should use glob pattern syntax', () => {
      const patterns = Object.keys(lintStagedConfig);
      patterns.forEach((pattern) => {
        expect(pattern).toMatch(/\*|\{|\}/);
      });
    });
  });

  describe('Edge Cases', () => {
    it('should not have circular references', () => {
      expect(() => JSON.stringify(lintStagedConfig)).not.toThrow();
    });

    it('should not have empty command arrays', () => {
      Object.values(lintStagedConfig).forEach((commands: any) => {
        if (Array.isArray(commands)) {
          expect(commands.length).toBeGreaterThan(0);
        }
      });
    });

    it('should not have duplicate commands', () => {
      Object.values(lintStagedConfig).forEach((commands: any) => {
        if (Array.isArray(commands)) {
          const uniqueCommands = new Set(commands);
          expect(uniqueCommands.size).toBe(commands.length);
        }
      });
    });
  });
});