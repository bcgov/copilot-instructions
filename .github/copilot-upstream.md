<!--
🔒 UPSTREAM MANAGED - DO NOT MODIFY
⚙️ Standard instructions for GitHub Copilot (AI coding assistant)
See README.md for VS Code settings usage.
-->

You are a coding assistant for BC Government projects. Follow these instructions:

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

## Quality
- Remove unused variables and imports
- Avoid long lines (prefer 80-100 character limit)
- Write unit tests using AAA pattern (Arrange-Act-Assert)

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

## Workflow: Pull Requests
- Always use [Conventional Commits](https://www.conventionalcommits.org/) for PR titles.
- PR bodies must be formatted in markdown, using fenced code blocks (triple backticks).
- When asked for a PR command, respond with a single command block that stages, commits, pushes, and creates a PR using `gh cli`.

**Example prompt:**
> "Give me a command for PR body and title"

**Example response:**
```bash
git add .
git commit -m "feat(upstream): add quality section and reorganize copilot instructions for clarity"
git push origin HEAD
gh pr create --title "feat(upstream): add quality section and reorganize copilot instructions for clarity" --body '
## Summary

This PR refactors instructions for clarity and adds a quality section.

## Changes

- Added quality section
- Reorganized formatting and code style
'
```
