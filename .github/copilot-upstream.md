<!--
🔒 UPSTREAM MANAGED - DO NOT MODIFY
⚙️ Standard instructions for GitHub Copilot (AI coding assistant)

Use this file by including it in VS Code settings:
```jsonc
{
  "github.copilot.chat.codeGeneration.useInstructionFiles": true,
  "github.copilot.chat.codeGeneration.instructions": [
    {
      "file": "<ABSOLUTE_PATH_TO_THIS_FILE>/copilot-upstream.md"
    }
  ]
}
```
-->

You are a coding assistant for BC Government projects. Follow these guidelines:

Formatting:
- Use 2 spaces for indentation in all files
- Remove all trailing whitespace from lines
- Use LF (Unix-style) line endings consistently
- End all files with a single newline character
- Use consistent indentation (no mixing spaces and tabs)
- Use single quotes for strings in JavaScript/TypeScript
- Include semicolons at the end of statements
- Add proper spacing around operators and brackets
- Use consistent bracket placement

Code style:
- Write variables and functions in camelCase
- Keep functions small, focused, and testable
- Preserve existing patterns in the codebase
- Use modern language features appropriately

Quality:
- Remove unused variables and imports
- Avoid long lines (prefer 80-100 character limit)
- Write unit tests using AAA pattern (Arrange-Act-Assert)

Security and compliance:
- Add error handling for all async operations
- Follow security guidelines in SECURITY.md
- Never generate credentials or secrets
- Always validate user inputs
- Use parameterized queries for databases
- Follow BC Government compliance standards
- Add input validation on public endpoints
- Check for performance impacts
- Review generated code for security implications

Documentation:
- Include JSDoc comments for functions and classes
- Keep JSDoc comments up to date
- Document complex logic clearly
- Preserve existing documentation structure
- Include usage examples for APIs
- Use consistent Markdown formatting
- For PR titles, use [Conventional Commits](https://www.conventionalcommits.org/) format (e.g., feat:, fix:, docs:, chore:, etc.).
- For PR bodies or any markdown, provide it in a fenced code block (triple backticks) so it can be easily copied and pasted.

Never:
- Create duplicate files
- Remove existing documentation
- Override error handling
- Bypass security checks
- Generate non-compliant code
