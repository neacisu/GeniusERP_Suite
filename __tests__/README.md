# GeniusSuite Configuration Tests

This directory contains comprehensive unit tests for all configuration files in the GeniusSuite monorepo.

## Test Structure

- `config/` - Configuration file validation tests (7 files)
- `workflows/` - GitHub Actions workflow tests (2 files)  
- `utils/` - Test utilities (1 file)

## Running Tests

First install dependencies:
```bash
pnpm install
```

Then run tests:
```bash
# Run all tests
pnpm test

# Run tests in watch mode
pnpm test:watch

# Run tests with coverage
pnpm test:coverage

# Run specific test file
pnpm test commitlint

# Run tests for a specific config
pnpm test config/eslint
```

## Test Coverage

The test suite validates:

### Configuration Files
- **commitlint.config.js**: Conventional commit configuration
- **.changeset/config.json**: Changeset configuration and schema
- **.eslintrc.json**: ESLint rules and plugin configuration
- **.prettierrc**: Code formatting rules
- **.lintstagedrc.json**: Pre-commit hook commands
- **nx.json**: Nx monorepo configuration and caching
- **tsconfig.base.json**: TypeScript compiler options

### GitHub Workflows
- **YAML structure validation**: Proper indentation, no tabs
- **Security checks**: No hardcoded secrets, versioned actions
- **CI pipeline**: All required steps present
- **Deployment strategy**: Separate prod/staging workflows
- **Branch strategy**: Auto-PR workflows for branch progression
- **Consistency**: Node.js version, pnpm setup across workflows

### Husky Git Hooks
- **File permissions**: Executable hooks
- **Script validity**: Proper shebang, valid syntax
- **Integration**: Correct tool execution (commitlint, lint-staged)

## Test Philosophy

These tests follow a comprehensive validation approach:

1. **Structure Validation**: Ensure files are valid JSON/YAML/JS
2. **Schema Validation**: Verify required properties and types
3. **Value Validation**: Check valid ranges and allowed values
4. **Integration Validation**: Ensure tools work together correctly
5. **Edge Case Testing**: Handle empty values, unexpected inputs
6. **Security Testing**: No hardcoded secrets or vulnerabilities

## Adding New Tests

When adding new configuration files:

1. Create a test file in the appropriate directory
2. Import validation utilities from `../utils/validation`
3. Follow the existing test structure
4. Cover happy paths, edge cases, and failure conditions
5. Validate both structure and values

## CI Integration

These tests run automatically in the CI pipeline:
- On every pull request to `dev`, `staging`, `master`
- Using `nx affected` for efficient testing
- With caching enabled for faster execution

## Dependencies

- **jest**: Test runner and assertion library
- **ts-jest**: TypeScript support for Jest
- **@types/jest**: TypeScript type definitions

## Test Statistics

Total test suites: 9
- Configuration tests: 7 files
- Workflow tests: 2 files
- Utility functions: 1 file

Estimated test count: 200+ individual test cases