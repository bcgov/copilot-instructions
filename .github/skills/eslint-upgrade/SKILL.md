---
name: eslint-upgrade
description: Upgrade ESLint to v9+. Use when migrating from .eslintrc.* to flat config (eslint.config.mjs).
---

# ESLint 9+ Upgrade

Guide for upgrading to ESLint v9+ which requires migrating from `.eslintrc.*` to flat config (`eslint.config.mjs`).

## Overview

ESLint v9+ uses flat config (ESM `.mjs` files) instead of the legacy `.eslintrc.json` / `.eslintrc.js` format. This is a breaking change in ESLint v9.

## Example Reference

See `bcgov/quickstart-openshift` for the canonical example:
- https://github.com/bcgov/quickstart-openshift/blob/main/eslint-base.config.mjs

## Dependencies Required

```json
"devDependencies": {
  "eslint": "^9.0.0",
  "eslint-config-prettier": "^9.0.0",
  "typescript-eslint": "^8.0.0"
}
```

For React/Vite projects, add:
```json
"@eslint/js": "^9.0.0"
```

## Migration Steps

### 1. Create Flat Config

Create `eslint.config.mjs` in your project root:

```javascript
import tseslint from 'typescript-eslint'
import prettier from 'eslint-config-prettier'

export default [
  {
    ignores: ['dist/**', 'node_modules/**', 'coverage/**', 'vite.config.*', 'vitest.config.*'],
  },
  ...tseslint.configs['recommended'],
  {
    files: ['**/*.ts'],
    languageOptions: {
      parserOptions: {
        project: 'tsconfig.json',
      },
    },
  },
  prettier,
]
```

### 2. Framework-Specific Notes

#### React/Vite
For React projects using Vite, use the recommended config from `@eslint/js`:

```javascript
import tseslint from 'typescript-eslint'
import eslintPluginReact from 'eslint-plugin-react'
import eslintPluginReactHooks from 'eslint-plugin-react-hooks'
import prettier from 'eslint-config-prettier'

export default [
  {
    ignores: ['dist/**', 'node_modules/**', 'coverage/**'],
  },
  ...tseslint.configs['recommended'],
  {
    files: ['**/*.{ts,tsx}'],
    plugins: {
      react: eslintPluginReact,
      'react-hooks': eslintPluginReactHooks,
    },
    languageOptions: {
      parserOptions: {
        project: 'tsconfig.json',
      },
    },
    rules: {
      ...eslintPluginReact.configs.recommended.rules,
      ...eslintPluginReactHooks.configs.recommended.rules,
    },
  },
  prettier,
]
```

#### NestJS/Backend
NestJS projects may need additional rules disabled:

```javascript
import tseslint from 'typescript-eslint'
import prettier from 'eslint-config-prettier'

export default [
  {
    ignores: ['dist/**', 'node_modules/**', 'coverage/**'],
  },
  ...tseslint.configs['recommended'],
  {
    files: ['**/*.ts'],
    languageOptions: {
      parserOptions: {
        project: 'tsconfig.json',
        sourceType: 'module',
      },
    },
  },
  {
    rules: {
      '@typescript-eslint/explicit-function-return-type': 'off',
      '@typescript-eslint/explicit-module-boundary-types': 'off',
    },
  },
  prettier,
]
```

#### Angular
Angular requires `@angular-eslint` packages:

```json
"devDependencies": {
  "eslint": "^9.0.0",
  "eslint-config-prettier": "^9.0.0",
  "typescript-eslint": "^8.0.0",
  "@angular-eslint/eslint-plugin": "^18.0.0",
  "@angular-eslint/eslint-plugin-template": "^18.0.0",
  "@angular-eslint/template-parser": "^18.0.0"
}
```

```javascript
import tseslint from 'typescript-eslint'
import angular from '@angular-eslint/eslint-plugin'
import angularTemplate from '@angular-eslint/eslint-plugin-template'
import angularParser from '@angular-eslint/template-parser'
import prettier from 'eslint-config-prettier'

export default [
  {
    ignores: ['projects/**/*', 'dist/**', 'node_modules/**', 'coverage/**'],
  },
  ...tseslint.configs['recommended'],
  {
    files: ['**/*.ts'],
    plugins: { '@angular-eslint': angular },
    languageOptions: {
      parser: tseslint.parser,
      parserOptions: { project: 'tsconfig.json' },
    },
  },
  {
    files: ['**/*.html'],
    plugins: { '@angular-eslint/template': angularTemplate },
    languageOptions: { parser: angularParser },
  },
  prettier,
]
```

Update `angular.json` to use the new config:
```json
"lint": {
  "options": {
    "eslintConfig": "eslint.config.mjs"
  }
}
```

### 3. Handle Legacy Config

#### .eslintignore
Flat config uses `ignores` in the first config object instead of `.eslintignore`. Migrate patterns:

| .eslintignore | ignores in flat config |
|---------------|------------------------|
| `node_modules/` | `'node_modules/**'` |
| `dist/` | `'dist/**'` |
| `*.config.js` | `'*.config.js'` |

```javascript
export default [
  {
    ignores: [
      'dist/**',
      'node_modules/**',
      'coverage/**',
      'build/**',
      '*.config.js',
      '*.config.mjs',
    ],
  },
  // ... rest of config
]
```

#### Legacy Plugins (FlatCompat)
For plugins without flat config support, use `FlatCompat` from `@eslint/eslintrc`:

```bash
npm install --save-dev @eslint/eslintrc
```

```javascript
import { FlatCompat } from '@eslint/eslintrc'
import someLegacyPlugin from 'eslint-plugin-some-legacy'

const compat = new FlatCompat({
  baseDirectory: import.meta.dirname,
})

export default [
  // ... base config
  ...compat.plugins(someLegacyPlugin),
  {
    rules: {
      'some-legacy/some-rule': 'error',
    },
  },
]
```

### 4. Extending Multiple Configs

Combine base config with project-specific overrides:

```javascript
import tseslint from 'typescript-eslint'
import baseConfig from './eslint-base.config.mjs'
import prettier from 'eslint-config-prettier'

export default [
  {
    ignores: ['dist/**', 'node_modules/**', 'coverage/**'],
  },
  ...tseslint.configs['recommended'],
  ...baseConfig,  // import shared rules from another config
  {
    files: ['**/*.ts'],
    languageOptions: {
      parserOptions: {
        project: 'tsconfig.json',
      },
    },
  },
  {
    rules: {
      // Project-specific overrides
      '@typescript-eslint/no-unused-vars': 'warn',
    },
  },
  prettier,
]
```

### 5. Remove Legacy Config

Delete: `.eslintrc.json`, `.eslintrc.js`, `.eslintrc.*`, `.eslintignore`

### 6. Test

```bash
npm run lint
```

## Key Differences

| Legacy (.eslintrc) | Flat Config (eslint.config.mjs) |
|-------------------|--------------------------------|
| JSON/YAML format | JavaScript (ESM) |
| Hierarchical with overrides | Array of config objects |
| `extends` array | Import and spread configs |

## Troubleshooting

### "Cannot find module 'typescript-eslint'"
```bash
npm install --save-dev typescript-eslint
```

### "Flat Compat" not found
FlatCompat is in `@eslint/eslintrc`, not `@eslint/js`:
```bash
npm install --save-dev @eslint/eslintrc
```

### Legacy plugins without flat config
Use FlatCompat to wrap legacy plugins:
```javascript
import { FlatCompat } from '@eslint/eslintrc'
```

### Prettier conflicts
Ensure `eslint-config-prettier` is last in the config array.

### Common Errors

| Error | Solution |
|-------|----------|
| "Definition for rule ... was not found" | Plugin not loaded or rule doesn't exist in flat config |
| "Cannot find module" | Missing package in devDependencies |
| "ESLint is not a constructor" | Config file format issue; ensure ESM with `.mjs` extension |

### Deeper Troubleshooting

Search for specific error messages:
- "eslint-plugin-xxx flat config"
- "eslint v9 plugin migration"
- "typescript-eslint flat config" if you have issues with tsconfig parsing