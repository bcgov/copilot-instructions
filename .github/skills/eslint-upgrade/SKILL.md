# ESLint 9+ Upgrade

Guide for upgrading to ESLint v9+ which requires migrating from `.eslintrc.*` to flat config (`eslint.config.mjs`).

## Overview

ESLint v9+ uses flat config (ESM `.mjs` files) instead of the legacy `.eslintrc.json` / `.eslintrc.js` format. This is a breaking change in ESLint v9.

## Example Reference

See `bcgov/quickstart-openshift` for a working example:
- https://github.com/bcgov/quickstart-openshift/blob/main/eslint-base.config.mjs

## Dependencies Required

### Frontend (Angular)
```json
"devDependencies": {
  "eslint": "^9.0.0",
  "eslint-config-prettier": "^9.0.0",
  "eslint-plugin-prettier": "^5.0.0",
  "prettier": "^3.0.0",
  "typescript-eslint": "^8.0.0",
  "@angular-eslint/eslint-plugin": "^18.0.0",
  "@angular-eslint/eslint-plugin-template": "^18.0.0",
  "@angular-eslint/template-parser": "^18.0.0"
}
```

### Backend (NestJS/Node)
```json
"devDependencies": {
  "eslint": "^9.0.0",
  "eslint-config-prettier": "^9.0.0",
  "eslint-plugin-prettier": "^5.0.0",
  "prettier": "^3.0.0",
  "typescript-eslint": "^8.0.0"
}
```

## Migration Steps

### 1. Create Project Config Files

#### Angular Frontend (`admin/eslint.config.mjs` or `public/eslint.config.mjs`):
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
    plugins: {
      '@angular-eslint': angular,
    },
    languageOptions: {
      parser: tseslint.parser,
      parserOptions: {
        project: 'tsconfig.json',
      },
    },
  },
  {
    files: ['**/*.html'],
    plugins: {
      '@angular-eslint/template': angularTemplate,
    },
    languageOptions: {
      parser: angularParser,
    },
  },
  {
    files: ['**/*.ts'],
    rules: {
      '@angular-eslint/component-selector': [
        'error',
        { prefix: 'app', style: 'kebab-case', type: 'element' },
      ],
      '@angular-eslint/directive-selector': [
        'error',
        { prefix: 'app', style: 'camelCase', type: 'attribute' },
      ],
    },
  },
  prettier,
]
```

#### Backend API (`api/eslint.config.mjs`):
```javascript
import tseslint from 'typescript-eslint'
import prettier from 'eslint-config-prettier'

export default [
  {
    ignores: ['dist/**', 'node_modules/**', 'coverage/**', '.eslintrc.js'],
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
      '@typescript-eslint/interface-name-prefix': 'off',
      '@typescript-eslint/explicit-function-return-type': 'off',
      '@typescript-eslint/explicit-module-boundary-types': 'off',
      '@typescript-eslint/no-explicit-any': 'off',
    },
  },
  prettier,
]
```

### 2. Update angular.json

Add `eslintConfig` option to the lint builder:

```json
"lint": {
  "builder": "@angular-eslint/builder:lint",
  "options": {
    "eslintConfig": "eslint.config.mjs",
    "lintFilePatterns": [
      "src/**/*.ts",
      "src/**/*.html"
    ]
  }
}
```

### 3. Remove Legacy Config Files

Delete:
- `.eslintrc.json`
- `.eslintrc.js`

### 4. Test the Migration

```bash
# Run lint to verify
npm run lint

# Or for Angular projects
ng lint
```

## Key Differences

| Legacy (.eslintrc) | Flat Config (eslint.config.mjs) |
|-------------------|--------------------------------|
| JSON/YAML format | JavaScript (ESM) |
| Hierarchical with overrides | Array of config objects |
| `extends` array | Import and spread configs |
| Parser in plugins | Uses `@typescript-eslint/parser` |

## Troubleshooting

### "Cannot find module '@angular-eslint/eslint-plugin'"
Install:
```bash
npm install --save-dev @angular-eslint/eslint-plugin @angular-eslint/eslint-plugin-template @angular-eslint/template-parser
```

### Prettier conflicts
Ensure `prettier` is last in the config array and `eslint-config-prettier` is in dependencies. Do not enable `prettier/prettier` rule unless using `eslint-plugin-prettier`.
