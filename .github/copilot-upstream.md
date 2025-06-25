<!--
🔒 BC GOVERNMENT MANAGED - DO NOT MODIFY
⚙️ Standard guidelines for BC Government projects
📦 VERSION: 1.0.0
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

3. **Documentation Quality**
   - Double-check Markdown formatting after Copilot suggestions
   - Watch for common issues:
     - Corrupted headers from merged text
     - Broken emoji characters
     - Unintended duplicated sections
     - Inconsistent list formatting
   - Verify documentation renders correctly before committing
   - Preserve existing documentation structure and tone

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
