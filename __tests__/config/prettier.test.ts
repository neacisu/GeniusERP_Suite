import { readJsonFile, hasRequiredProperties } from '../utils/validation';

describe('.prettierrc', () => {
  let prettierConfig: any;

  beforeAll(() => {
    prettierConfig = readJsonFile('.prettierrc');
  });

  describe('JSON Structure', () => {
    it('should be valid JSON', () => {
      expect(prettierConfig).toBeDefined();
      expect(typeof prettierConfig).toBe('object');
    });

    it('should have core formatting properties', () => {
      const coreProps = [
        'singleQuote',
        'semi',
        'tabWidth',
        'useTabs',
        'trailingComma',
        'printWidth',
      ];
      expect(hasRequiredProperties(prettierConfig, coreProps)).toBe(true);
    });
  });

  describe('Quote and Semicolon Settings', () => {
    it('should use single quotes', () => {
      expect(prettierConfig.singleQuote).toBe(true);
    });

    it('should require semicolons', () => {
      expect(prettierConfig.semi).toBe(true);
    });
  });

  describe('Indentation Settings', () => {
    it('should use spaces instead of tabs', () => {
      expect(prettierConfig.useTabs).toBe(false);
    });

    it('should have tab width of 2', () => {
      expect(prettierConfig.tabWidth).toBe(2);
    });

    it('should have valid tab width', () => {
      expect(prettierConfig.tabWidth).toBeGreaterThan(0);
      expect(prettierConfig.tabWidth).toBeLessThanOrEqual(8);
    });
  });

  describe('Line and Comma Settings', () => {
    it('should have print width of 100', () => {
      expect(prettierConfig.printWidth).toBe(100);
    });

    it('should have valid print width', () => {
      expect(prettierConfig.printWidth).toBeGreaterThan(0);
      expect(prettierConfig.printWidth).toBeLessThanOrEqual(120);
    });

    it('should use trailing commas', () => {
      expect(prettierConfig.trailingComma).toBe('all');
    });

    it('should have valid trailingComma value', () => {
      const validValues = ['all', 'es5', 'none'];
      expect(validValues).toContain(prettierConfig.trailingComma);
    });
  });

  describe('Arrow Function Settings', () => {
    it('should always use parentheses for arrow functions', () => {
      expect(prettierConfig.arrowParens).toBe('always');
    });

    it('should have valid arrowParens value', () => {
      const validValues = ['always', 'avoid'];
      expect(validValues).toContain(prettierConfig.arrowParens);
    });
  });

  describe('Bracket Settings', () => {
    it('should use bracket spacing', () => {
      expect(prettierConfig.bracketSpacing).toBe(true);
    });

    it('should not put brackets on same line', () => {
      expect(prettierConfig.bracketSameLine).toBe(false);
    });
  });

  describe('Line Ending Settings', () => {
    it('should use LF line endings', () => {
      expect(prettierConfig.endOfLine).toBe('lf');
    });

    it('should have valid endOfLine value', () => {
      const validValues = ['lf', 'crlf', 'cr', 'auto'];
      expect(validValues).toContain(prettierConfig.endOfLine);
    });
  });

  describe('Prose Settings', () => {
    it('should preserve prose wrapping', () => {
      expect(prettierConfig.proseWrap).toBe('preserve');
    });

    it('should have valid proseWrap value', () => {
      const validValues = ['always', 'never', 'preserve'];
      expect(validValues).toContain(prettierConfig.proseWrap);
    });
  });

  describe('Configuration Consistency', () => {
    it('should have consistent formatting configuration', () => {
      // Check that related settings are consistent
      expect(prettierConfig.useTabs).toBe(false);
      expect(prettierConfig.tabWidth).toBeGreaterThan(0);
    });

    it('should not have conflicting settings', () => {
      // Tabs and spaces should not be mixed
      if (prettierConfig.useTabs) {
        expect(prettierConfig.tabWidth).toBeGreaterThan(0);
      }
    });
  });

  describe('Edge Cases', () => {
    it('should not have circular references', () => {
      expect(() => JSON.stringify(prettierConfig)).not.toThrow();
    });

    it('should have all boolean values as actual booleans', () => {
      const booleanProps = [
        'singleQuote',
        'semi',
        'useTabs',
        'bracketSpacing',
        'bracketSameLine',
      ];
      booleanProps.forEach((prop) => {
        expect(typeof prettierConfig[prop]).toBe('boolean');
      });
    });

    it('should have all numeric values as actual numbers', () => {
      const numericProps = ['tabWidth', 'printWidth'];
      numericProps.forEach((prop) => {
        expect(typeof prettierConfig[prop]).toBe('number');
        expect(Number.isInteger(prettierConfig[prop])).toBe(true);
      });
    });
  });
});