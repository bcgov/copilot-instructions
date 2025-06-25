<!--
🔒 BC GOVERNMENT MANAGED - DO NOT MODIFY
⚙️ Standard guidelines for BC Government projects
📦 VERSION: 1.0.0

Use this file by including it in VS Code settings (.vscode/settings.json):
```
{
  "github.copilot.chat.codeGeneration.useInstructionFiles": true,
  "github.copilot.chat.codeGeneration.instructions": [
    {
      "file": ".github/copilot-upstream.md"
    }
  ]
}
```
-->

# BC Government Copilot Guidelines

When generating code:
- Use 2 spaces for indentation in all files
- Write variables and functions in camelCase
- Break down complex functions into smaller, focused ones
- Add error handling for all async operations
- Follow security guidelines in SECURITY.md
- Include JSDoc comments for functions and classes
- Write unit tests using AAA pattern (Arrange-Act-Assert)
- Preserve existing patterns in the codebase
- Use modern language features appropriately

Always:
- Review generated code for security implications
- Validate all user inputs
- Follow BC Government compliance standards
- Include error handling
- Write testable code
- Check for performance impacts

Never:
- Generate credentials or secrets
- Create duplicate files
- Remove existing documentation
- Override error handling
- Bypass security checks
- Generate non-compliant code

Documentation:
- Keep JSDoc comments up to date
- Document complex logic clearly
- Preserve existing documentation structure
- Include usage examples for APIs
- Use consistent Markdown formatting
