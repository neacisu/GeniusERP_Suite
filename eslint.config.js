import js from '@eslint/js';

export default [
  {
    ignores: ['commitlint.config.js', 'eslint.config.js', '.lintstagedrc.json', '.husky/**'],
  },
  js.configs.recommended,
  {
    files: ['**/*.ts', '**/*.tsx'],
    rules: {},
  },
];
