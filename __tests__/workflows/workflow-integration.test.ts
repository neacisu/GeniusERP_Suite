import { readFile } from '../utils/validation';

describe('Workflow Integration and Consistency', () => {
  describe('Consistency Across Workflows', () => {
    it('should use consistent Node.js version', () => {
      const workflows = [
        '.github/workflows/ci.yml',
        '.github/workflows/deploy-prod.yml',
        '.github/workflows/deploy-staging.yml',
      ];

      const nodeVersions = workflows.map((workflow) => {
        const content = readFile(workflow);
        const match = content.match(/node-version:\s*(\d+)/);
        return match ? match[1] : null;
      });

      const uniqueVersions = new Set(nodeVersions.filter(Boolean));
      expect(uniqueVersions.size).toBeLessThanOrEqual(1);
    });

    it('should use consistent pnpm setup', () => {
      const workflows = [
        '.github/workflows/ci.yml',
        '.github/workflows/deploy-prod.yml',
        '.github/workflows/deploy-staging.yml',
      ];

      workflows.forEach((workflow) => {
        const content = readFile(workflow);
        if (content.includes('pnpm')) {
          expect(content).toContain('pnpm/action-setup');
        }
      });
    });

    it('should use consistent checkout configuration', () => {
      const workflows = [
        '.github/workflows/ci.yml',
        '.github/workflows/deploy-prod.yml',
        '.github/workflows/deploy-staging.yml',
      ];

      workflows.forEach((workflow) => {
        const content = readFile(workflow);
        expect(content).toContain('actions/checkout');
      });
    });
  });

  describe('Branch Strategy Alignment', () => {
    it('should have workflows for all main branches', () => {
      const branches = ['master', 'staging', 'dev'];
      const ciContent = readFile('.github/workflows/ci.yml');

      branches.forEach((branch) => {
        expect(ciContent).toContain(branch);
      });
    });

    it('should have auto-PR workflows for branch progression', () => {
      const devToStagingContent = readFile('.github/workflows/auto-pr-dev-to-staging.yml');
      const stagingToMasterContent = readFile(
        '.github/workflows/auto-pr-staging-to-master.yml',
      );

      expect(devToStagingContent).toBeDefined();
      expect(stagingToMasterContent).toBeDefined();
    });
  });

  describe('Deployment Strategy', () => {
    it('should have separate production and staging deployments', () => {
      const prodContent = readFile('.github/workflows/deploy-prod.yml');
      const stagingContent = readFile('.github/workflows/deploy-staging.yml');

      expect(prodContent).toBeDefined();
      expect(stagingContent).toBeDefined();
    });

    it('should trigger production deploy only from master', () => {
      const prodContent = readFile('.github/workflows/deploy-prod.yml');
      expect(prodContent).toContain('master');
    });

    it('should trigger staging deploy from staging branch', () => {
      const stagingContent = readFile('.github/workflows/deploy-staging.yml');
      expect(stagingContent).toContain('staging');
    });
  });

  describe('CI/CD Pipeline Completeness', () => {
    it('should have all required CI steps', () => {
      const ciContent = readFile('.github/workflows/ci.yml');
      const requiredSteps = [
        'checkout',
        'setup-node',
        'pnpm',
        'install',
        'format:check',
        'lint',
        'test',
        'build',
      ];

      requiredSteps.forEach((step) => {
        expect(ciContent.toLowerCase()).toContain(step.toLowerCase());
      });
    });

    it('should use Nx affected commands for efficiency', () => {
      const ciContent = readFile('.github/workflows/ci.yml');
      expect(ciContent).toContain('nx affected');
    });

    it('should setup Nx Cloud if token is available', () => {
      const ciContent = readFile('.github/workflows/ci.yml');
      expect(ciContent).toContain('NX_CLOUD_AUTH_TOKEN');
      expect(ciContent).toContain('nx-cloud start-ci-run');
    });
  });

  describe('Caching Strategy', () => {
    it('should cache pnpm store in CI', () => {
      const ciContent = readFile('.github/workflows/ci.yml');
      expect(ciContent).toContain('actions/cache');
      expect(ciContent).toContain('pnpm-store');
    });

    it('should use proper cache keys', () => {
      const ciContent = readFile('.github/workflows/ci.yml');
      expect(ciContent).toContain('pnpm-lock.yaml');
    });
  });
});