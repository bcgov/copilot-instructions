<!--
�� UPSTREAM MANAGED - DO NOT MODIFY
⚙️ Standard instructions for GitHub Copilot (AI coding assistant)
See README.md for VS Code settings usage.
-->

You are a coding assistant for BC Government projects. Follow these instructions:

# Key Rules

- Always follow BC Government security and compliance standards.
- Never generate credentials, secrets, or non-compliant code.
- Remove all trailing whitespace and use LF (Unix-style) line endings.
- Use 2 spaces for indentation and consistent bracket placement.
- Use [Conventional Commits](https://www.conventionalcommits.org/) for PR titles.
- PR bodies must be in markdown, inside fenced code blocks (triple backticks).
- Never add change logs or release notes to documentation—use the designated changelog or release process.

# General Rules

## Formatting
- Use 2 spaces for indentation in all files
- Remove all trailing whitespace from lines
- Use LF (Unix-style) line endings consistently
- End all files with a single newline character
- Use consistent indentation (no mixing spaces and tabs)
- Use single quotes for strings in JavaScript/TypeScript
- Include semicolons at the end of statements
- Add proper spacing around operators and brackets
- Use consistent bracket placement

## Code Style
- Write variables and functions in camelCase
- Keep functions small, focused, and testable
- Preserve existing patterns in the codebase
- Use modern language features appropriately
- Prefer dynamic configuration over hardcoded values

## Quality
- Remove unused variables and imports
- Avoid long lines (prefer 80-100 character limit)
- Write unit tests using AAA pattern (Arrange-Act-Assert)

## Project Stability
- **Prove Before Polish**: Implement core functionality first, test with real data before adding features
- **Complexity Budget**: Each new abstraction must solve a proven problem; remove complexity before adding more
- **Debug-Ready Code**: Add logging before adding features; error messages should point to solutions
- **Environment Parity**: Test local changes in CI environment early; document environment differences explicitly
- **Incremental Fixes**: Fix one issue at a time; avoid large refactoring without clear benefits
- **User-Driven Simplification**: Recognize over-engineering and revert; focus on core functionality
- **Stable Foundation**: Keep core functionality intact; avoid breaking working features for "improvements"

## Security and Compliance
- Add error handling for all async operations
- Follow security guidelines in SECURITY.md
- Never generate credentials or secrets
- Always validate user inputs
- Use parameterized queries for databases
- Follow BC Government compliance standards
- Add input validation on public endpoints
- Check for performance impacts
- Review generated code for security implications

## Documentation
- Include JSDoc comments for functions and classes
- Keep JSDoc comments up to date
- Document complex logic clearly
- Preserve existing documentation structure
- Include usage examples for APIs
- Use consistent Markdown styling
- Use [Conventional Commits](https://www.conventionalcommits.org/) format for PR titles (e.g., feat:, fix:, docs:, chore:)
- Provide PR bodies or any markdown in a fenced code block (triple backticks) so it can be easily copied and pasted

## Linting and Automation
- Use appropriate linters and formatters to enforce the formatting and code quality rules defined above.
- Configure your editor or development environment to automatically remove trailing whitespace and use LF (Unix-style) line endings.
- For multi-language projects, consider adding a `.editorconfig` file to enforce basic formatting rules across editors and languages.
- Optionally, add pre-commit hooks to automatically lint and format code before commits.
- Example tools (choose those relevant to your language/environment):
  - JavaScript/TypeScript: ESLint, Prettier
  - Python: flake8, black
  - Shell: shellcheck
  - General: EditorConfig

**Example prompt for Copilot:**
> "Give me a command to lint and fix all files in this repo."

## Never
- Create duplicate files
- Remove existing documentation
- Override error handling
- Bypass security checks
- Generate non-compliant code
- Add change logs or release notes (use your project's designated changelog or release process instead)
- Hardcode configuration values in code

# Workflows

## Pull Requests
- Always use [Conventional Commits](https://www.conventionalcommits.org/) for PR titles.
- PR bodies must be formatted in markdown, using fenced code blocks (triple backticks).
- When asked for a PR command, respond with a single command block that stages, commits, pushes, and creates a PR using `gh cli`.

**Example prompt:**
> "Give me a command for PR body and title"

**Example response:**
```bash
git add .
git commit -m "feat: add quality section and reorganize copilot instructions for clarity"
git push origin HEAD
gh pr create --title "feat: add quality section and reorganize copilot instructions for clarity" --body '
## Summary

This PR refactors instructions for clarity and adds a quality section.

## Changes

- Added quality section
- Reorganized formatting and code style
'
```
```

## Collaboration Guardrails

- Never push directly to `main`. Always:
  - create a feature branch,
  - commit locally,
  - open a PR targeting `main`,
  - wait for review and merge.
- Never add or modify git hooks, repo settings, or branch protection via automation/instructions unless explicitly requested.
- Before any push/PR, verify a clean working tree and what will be pushed:
  - `git status --porcelain` is empty
  - `git branch --show-current` shows the feature branch
  - `git log --oneline @{u}..` lists the exact commits about to push
- Create PRs with a body file (avoid inline multi-line bodies that the shell can misinterpret):

```bash
BODY=$(mktemp)
cat >"$BODY" <<'EOF'
## Summary

<one-liner>

## Changes
- <bullets>
EOF

gh pr create --base main --head "$BRANCH" \
  --title "feat: <short title>" \
  --body-file "$BODY"
rm -f "$BODY"
```

## Never (Collaboration)
- Push directly to `main`
- Add/modify git hooks or branch protection
- Change repository-wide settings without explicit approval

## PR Feedback Automation
When Copilot provides feedback on PRs, consider implementing automatic feedback processing:

### **Implementation Pattern**
- Use GitHub Actions workflows that trigger on PR comments
- Apply mechanical fixes automatically (syntax, formatting, deprecations)
- Commit with conventional commit messages
- Always inform users what feedback can be dismissed after auto-fixes

### **Safety Guidelines**
- Focus on low-risk, mechanical fixes only
- Never auto-fix logic changes or security-related feedback without review
- Use standard GITHUB_TOKEN (no external secrets required)
- Test fixes in isolated environment first

### **Common Feedback Types**
- **Syntax errors**: JSON, YAML, code formatting
- **Deprecation warnings**: Tool updates, API changes
- **Best practices**: Linting, formatting, unused variables
- **Security issues**: Dependencies, configuration (review required)

### **Implementation**
Create a GitHub Actions workflow that triggers on PR comments and applies mechanical fixes automatically.

Perfect! Now all projects and Copilot will receive these project stability instructions. The key additions are:

## Project Stability Rules Added:
- **Prove Before Polish**: Test core functionality before adding features
- **Complexity Budget**: Remove complexity before adding more
- **Debug-Ready Code**: Add logging before features, clear error messages
- **Environment Parity**: Test local changes in CI early
- **Incremental Fixes**: One issue at a time, avoid large refactoring
- **User-Driven Simplification**: Recognize over-engineering and revert
- **Stable Foundation**: Keep working features intact

These rules will help prevent the over-engineering issues we encountered in the project board sync across all future projects!
