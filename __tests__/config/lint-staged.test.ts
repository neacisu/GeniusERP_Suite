import { readFile, readJsonFile } from '../utils/validation';

const TS_PATTERN = '*.{ts,tsx,js,jsx}';
const NX_AFFECTED_SCRIPT = 'scripts/lint-staged/nx-affected.sh';

const getCommandHead = (command: string): string => command.trim().split(' ')[0] ?? '';

const isScriptCommand = (command: string): boolean => {
  const normalized = getCommandHead(command);
  return normalized.endsWith('.sh');
};

const readScriptForCommand = (command: string): string => {
  const scriptPath = getCommandHead(command);
  if (!scriptPath) {
    throw new Error(`Command "${command}" does not contain an executable`);
  }
  return readFile(scriptPath);
};

const isLintCommand = (command: string): boolean =>
  command.includes('lint') || command.includes('nx-affected');

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
      expect(lintStagedConfig[TS_PATTERN]).toBeDefined();
    });

    it('should have commands as an array', () => {
      expect(Array.isArray(lintStagedConfig[TS_PATTERN])).toBe(true);
    });

    it('should include format command', () => {
      const commands = lintStagedConfig[TS_PATTERN];
      const formatCommand = commands.find((cmd: string) => cmd.includes('format:write'));
      expect(formatCommand).toBeDefined();
      expect(formatCommand).toContain('nx format:write --files');
    });

    it('should include lint fix command', () => {
      const commands = lintStagedConfig[TS_PATTERN];
      const lintCommand = commands.find((cmd: string) => isLintCommand(cmd));
      expect(lintCommand).toBeDefined();
      if (!lintCommand) {
        return;
      }

      if (lintCommand.includes('nx affected:lint')) {
        expect(lintCommand).toContain('--fix');
        expect(lintCommand).toContain('--files');
      } else if (lintCommand.includes(NX_AFFECTED_SCRIPT)) {
        const scriptContent = readScriptForCommand(lintCommand);
        expect(scriptContent).toContain('nx affected:lint');
        expect(scriptContent).toContain('--fix');
        expect(scriptContent).toContain('--files');
      } else {
        throw new Error('Unknown lint command configured in lint-staged');
      }
    });

    it('should run format before lint', () => {
      const commands = lintStagedConfig[TS_PATTERN];
      const formatIndex = commands.findIndex((cmd: string) => cmd.includes('format'));
      const lintIndex = commands.findIndex((cmd: string) => isLintCommand(cmd));
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
      const commands = lintStagedConfig[TS_PATTERN];
      commands.forEach((cmd: string) => {
        if (cmd.includes('nx')) {
          expect(cmd).toContain('nx');
          return;
        }

        if (isScriptCommand(cmd)) {
          const scriptContent = readScriptForCommand(cmd);
          expect(scriptContent).toContain('nx');
          return;
        }

        throw new Error(`Command ${cmd} does not reference nx tooling`);
      });
    });

    it('should pass files to commands', () => {
      const commands = lintStagedConfig[TS_PATTERN];
      commands.forEach((cmd: string) => {
        if (cmd.includes('--files')) {
          expect(cmd).toContain('--files');
          return;
        }

        if (isScriptCommand(cmd)) {
          const scriptContent = readScriptForCommand(cmd);
          expect(scriptContent).toContain('--files');
          return;
        }

        throw new Error(`Command ${cmd} does not receive file arguments`);
      });
    });
  });

  describe('Pattern Coverage', () => {
    it('should cover TypeScript files', () => {
      expect(TS_PATTERN).toContain('ts');
      expect(TS_PATTERN).toContain('tsx');
    });

    it('should cover JavaScript files', () => {
      expect(TS_PATTERN).toContain('js');
      expect(TS_PATTERN).toContain('jsx');
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
