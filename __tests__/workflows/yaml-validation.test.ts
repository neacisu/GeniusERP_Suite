import { readFile } from '../utils/validation';
import { readdirSync } from 'fs';
import { join } from 'path';

describe('GitHub Workflows YAML Validation', () => {
  let workflowFiles: string[];

  beforeAll(() => {
    const workflowsDir = join(process.cwd(), '.github/workflows');
    workflowFiles = readdirSync(workflowsDir).filter((file) => file.endsWith('.yml'));
  });

  describe('Workflow Files Existence', () => {
    it('should have at least one workflow file', () => {
      expect(workflowFiles.length).toBeGreaterThan(0);
    });

    it('should have ci.yml workflow', () => {
      expect(workflowFiles).toContain('ci.yml');
    });

    it('should have deployment workflows', () => {
      const deploymentWorkflows = workflowFiles.filter((file) => file.includes('deploy'));
      expect(deploymentWorkflows.length).toBeGreaterThan(0);
    });
  });

  describe('YAML Structure Validation', () => {
    workflowFiles.forEach((file) => {
      describe(`${file}`, () => {
        let content: string;

        beforeAll(() => {
          content = readFile(`.github/workflows/${file}`);
        });

        it('should not be empty', () => {
          expect(content.length).toBeGreaterThan(0);
        });

        it('should have proper YAML structure', () => {
          expect(content).toMatch(/^name:/m);
          expect(content).toMatch(/^on:/m);
          expect(content).toMatch(/^jobs:/m);
        });

        it('should have valid indentation', () => {
          const lines = content.split('\n');
          lines.forEach((line, index) => {
            if (line.trim().length > 0) {
              const leadingSpaces = line.match(/^ */)?.[0].length || 0;
              expect(leadingSpaces % 2).toBe(0); // Should be multiples of 2
            }
          });
        });

        it('should not have tabs', () => {
          expect(content).not.toContain('\t');
        });
      });
    });
  });

  describe('CI Workflow Specific Validation', () => {
    let ciContent: string;

    beforeAll(() => {
      ciContent = readFile('.github/workflows/ci.yml');
    });

    it('should have a descriptive name', () => {
      expect(ciContent).toMatch(/^name:\s*.+/m);
    });

    it('should trigger on pull requests', () => {
      expect(ciContent).toContain('pull_request');
    });

    it('should specify target branches', () => {
      expect(ciContent).toMatch(/branches:/);
      expect(ciContent).toContain('master');
      expect(ciContent).toContain('staging');
      expect(ciContent).toContain('dev');
    });

    it('should have checkout step', () => {
      expect(ciContent).toContain('actions/checkout');
    });

    it('should setup Node.js', () => {
      expect(ciContent).toContain('actions/setup-node');
      expect(ciContent).toMatch(/node-version:\s*24/);
    });

    it('should setup pnpm', () => {
      expect(ciContent).toContain('pnpm/action-setup');
    });

    it('should install dependencies', () => {
      expect(ciContent).toContain('pnpm install --frozen-lockfile');
    });

    it('should have Nx integration', () => {
      expect(ciContent).toContain('nrwl/nx-set-shas');
      expect(ciContent).toContain('nx affected');
    });

    it('should run formatting checks', () => {
      expect(ciContent).toMatch(/nx.*format:check/);
    });

    it('should run linting', () => {
      expect(ciContent).toMatch(/nx.*lint/);
    });

    it('should run tests', () => {
      expect(ciContent).toMatch(/nx.*test/);
    });

    it('should run builds', () => {
      expect(ciContent).toMatch(/nx.*build/);
    });
  });

  describe('Deployment Workflows Validation', () => {
    ['deploy-prod.yml', 'deploy-staging.yml'].forEach((file) => {
      if (workflowFiles.includes(file)) {
        describe(file, () => {
          let content: string;

          beforeAll(() => {
            content = readFile(`.github/workflows/${file}`);
          });

          it('should have a deployment job', () => {
            expect(content).toMatch(/jobs:/);
          });

          it('should use ubuntu runner', () => {
            expect(content).toContain('ubuntu-latest');
          });

          it('should have checkout step', () => {
            expect(content).toContain('actions/checkout');
          });

          it('should setup required tools', () => {
            expect(content).toContain('actions/setup-node');
          });
        });
      }
    });
  });

  describe('Changeset Workflow Validation', () => {
    if (workflowFiles.includes('changeset-bot.yml')) {
      let content: string;

      beforeAll(() => {
        content = readFile('.github/workflows/changeset-bot.yml');
      });

      it('should have changeset configuration', () => {
        expect(content).toBeDefined();
        expect(content.length).toBeGreaterThan(0);
      });

      it('should use changesets action', () => {
        expect(content).toContain('changesets/action');
      });
    }
  });

  describe('Auto PR Workflows Validation', () => {
    const autoPRWorkflows = workflowFiles.filter((file) => file.includes('auto-pr'));

    autoPRWorkflows.forEach((file) => {
      describe(file, () => {
        let content: string;

        beforeAll(() => {
          content = readFile(`.github/workflows/${file}`);
        });

        it('should have proper trigger configuration', () => {
          expect(content).toMatch(/on:/);
        });

        it('should use ubuntu runner', () => {
          expect(content).toContain('ubuntu-latest');
        });

        it('should have checkout step', () => {
          expect(content).toContain('actions/checkout');
        });
      });
    });
  });

  describe('Release Workflow Validation', () => {
    if (workflowFiles.includes('release.yml')) {
      let content: string;

      beforeAll(() => {
        content = readFile('.github/workflows/release.yml');
      });

      it('should have release configuration', () => {
        expect(content).toBeDefined();
        expect(content.length).toBeGreaterThan(0);
      });

      it('should trigger on push to master', () => {
        expect(content).toContain('push');
        expect(content).toContain('master');
      });
    }
  });

  describe('Security and Best Practices', () => {
    workflowFiles.forEach((file) => {
      describe(`${file}`, () => {
        let content: string;

        beforeAll(() => {
          content = readFile(`.github/workflows/${file}`);
        });

        it('should not contain hardcoded secrets', () => {
          const secretPatterns = [
            /password\s*:\s*['"][^'"]+['"]/i,
            /token\s*:\s*['"][^'"]+['"]/i,
            /api[_-]?key\s*:\s*['"][^'"]+['"]/i,
          ];

          secretPatterns.forEach((pattern) => {
            // Allow references to secrets context: ${{ secrets.X }}
            const withoutSecretRefs = content.replace(/\$\{\{\s*secrets\.\w+\s*\}\}/g, '');
            expect(withoutSecretRefs).not.toMatch(pattern);
          });
        });

        it('should use specific action versions', () => {
          const actionMatches = content.match(/uses:\s*([^\s@]+)@([^\s]+)/g) || [];
          actionMatches.forEach((match) => {
            expect(match).toMatch(/@v\d+/); // Should use versioned actions
          });
        });

        it('should not have excessive permissions', () => {
          if (content.includes('permissions:')) {
            expect(content).not.toContain('permissions: write-all');
          }
        });
      });
    });
  });
});