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

## Core Principles
1. **DRY** - Don't Repeat Yourself
   - Let Copilot suggest, but verify the logic
   - Reuse existing patterns in the codebase
   - Preserve valuable domain knowledge in comments

2. **Clean Code**
   - Follow existing formatting (2 spaces)
   - Use meaningful variable names
   - Break down complex functions
   - Maintain or improve existing documentation

## Best Practices
1. **Code Review**
   - Always review Copilot-generated code for correctness
   - Verify security implications of suggested code
   - Check for BC Government compliance and standards
   - Review suggestions carefully before accepting

2. **Security**
   - Never accept credentials or secrets from Copilot suggestions
   - Validate any external dependencies or imports
   - Follow project security guidelines in SECURITY.md
   - Validate all user inputs
   - Implement proper authentication and authorization
   - Use secure coding practices
   - Follow language-specific security best practices

3. **Documentation Quality**
   - Double-check Markdown formatting after Copilot suggestions
   - Watch for common issues:
     - Corrupted headers from merged text
     - Broken emoji characters
     - Unintended duplicated sections
     - Inconsistent list formatting
   - Verify documentation renders correctly before committing
   - Preserve existing documentation structure and tone
   - Include clear descriptions in comments for complex logic
   - Document assumptions and prerequisites
   - Add example usage for reusable functions
   - Keep API documentation current

4. **Code Style and Structure**
   - Follow consistent naming conventions (camelCase for variables/functions)
   - Use descriptive names that indicate purpose
   - Include JSDoc or similar comments for functions and classes
   - Keep functions focused and single-purpose
   - Add appropriate error handling
   - Write testable code
   - Follow DRY principles
   - Use modern language features appropriately
   - Consider performance implications

5. **Testing Standards**
   - Write unit tests for new functionality
   - Include edge case testing
   - Maintain high test coverage
   - Write clear test descriptions
   - Follow AAA (Arrange-Act-Assert) pattern

## Never Allow Copilot To
- Generate sensitive data or secrets
- Create duplicate files
- Modify source when fixing tests
- Add conflicting dependencies
- Bypass security checks
- Generate non-compliant code
- Remove existing documentation or comments
- Discard domain-specific logic without review
- Override carefully crafted error handling
