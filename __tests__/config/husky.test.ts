import { readFile } from '../utils/validation';
import { existsSync, statSync } from 'fs';
import { join } from 'path';

const SHELL_SAFE_LINE_REGEX = /^[\w\s\-$./"'=]+$/;

describe('Husky Git Hooks', () => {
  describe('Hook Files Existence', () => {
    it('should have .husky directory', () => {
      const huskyDir = join(process.cwd(), '.husky');
      expect(existsSync(huskyDir)).toBe(true);
    });

    it('should have commit-msg hook', () => {
      const commitMsgPath = join(process.cwd(), '.husky/commit-msg');
      expect(existsSync(commitMsgPath)).toBe(true);
    });

    it('should have pre-commit hook', () => {
      const preCommitPath = join(process.cwd(), '.husky/pre-commit');
      expect(existsSync(preCommitPath)).toBe(true);
    });
  });

  describe('Hook File Permissions', () => {
    it('commit-msg should be executable', () => {
      const commitMsgPath = join(process.cwd(), '.husky/commit-msg');
      const stats = statSync(commitMsgPath);
      // Check if file has execute permission (any execute bit set)
      expect(stats.mode & 0o111).toBeGreaterThan(0);
    });

    it('pre-commit should be executable', () => {
      const preCommitPath = join(process.cwd(), '.husky/pre-commit');
      const stats = statSync(preCommitPath);
      // Check if file has execute permission (any execute bit set)
      expect(stats.mode & 0o111).toBeGreaterThan(0);
    });
  });

  describe('Commit Message Hook', () => {
    let commitMsgContent: string;

    beforeAll(() => {
      commitMsgContent = readFile('.husky/commit-msg');
    });

    it('should have proper shebang', () => {
      expect(commitMsgContent).toMatch(/^#!\/usr\/bin\/env sh/);
    });

    it('should run commitlint', () => {
      expect(commitMsgContent).toContain('commitlint');
    });

    it('should use pnpm exec', () => {
      expect(commitMsgContent).toContain('pnpm exec');
    });

    it('should pass commit message file as argument', () => {
      expect(commitMsgContent).toContain('--edit');
      expect(commitMsgContent).toContain('$1');
    });

    it('should be a valid shell script', () => {
      const lines = commitMsgContent.split('\n').filter((line) => line.trim().length > 0);
      expect(lines.length).toBeGreaterThan(0);
      lines.forEach((line) => {
        if (!line.startsWith('#')) {
          expect(line).toMatch(SHELL_SAFE_LINE_REGEX);
        }
      });
    });
  });

  describe('Pre-Commit Hook', () => {
    let preCommitContent: string;

    beforeAll(() => {
      preCommitContent = readFile('.husky/pre-commit');
    });

    it('should have proper shebang', () => {
      expect(preCommitContent).toMatch(/^#!\/usr\/bin\/env sh/);
    });

    it('should run lint-staged', () => {
      expect(preCommitContent).toContain('lint-staged');
    });

    it('should use pnpm exec', () => {
      expect(preCommitContent).toContain('pnpm exec');
    });

    it('should be a valid shell script', () => {
      const lines = preCommitContent.split('\n').filter((line) => line.trim().length > 0);
      expect(lines.length).toBeGreaterThan(0);
      lines.forEach((line) => {
        if (!line.startsWith('#')) {
          expect(line).toMatch(SHELL_SAFE_LINE_REGEX);
        }
      });
    });
  });

  describe('Hook Integration', () => {
    it('should integrate with commitlint config', () => {
      const commitMsgContent = readFile('.husky/commit-msg');
      const commitlintConfigExists = existsSync(join(process.cwd(), 'commitlint.config.js'));
      expect(commitMsgContent).toContain('commitlint');
      expect(commitlintConfigExists).toBe(true);
    });

    it('should integrate with lint-staged config', () => {
      const preCommitContent = readFile('.husky/pre-commit');
      const lintStagedConfigExists = existsSync(join(process.cwd(), '.lintstagedrc.json'));
      expect(preCommitContent).toContain('lint-staged');
      expect(lintStagedConfigExists).toBe(true);
    });
  });

  describe('Edge Cases', () => {
    it('should handle hook execution errors gracefully', () => {
      const commitMsgContent = readFile('.husky/commit-msg');
      const preCommitContent = readFile('.husky/pre-commit');

      // Hooks should not have explicit error suppression (|| true)
      expect(commitMsgContent).not.toContain('|| true');
      expect(preCommitContent).not.toContain('|| true');
    });

    it('should not have debug statements', () => {
      const commitMsgContent = readFile('.husky/commit-msg');
      const preCommitContent = readFile('.husky/pre-commit');

      expect(commitMsgContent.toLowerCase()).not.toContain('echo ');
      expect(preCommitContent.toLowerCase()).not.toContain('echo ');
    });
  });
});
