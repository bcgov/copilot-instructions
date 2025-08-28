# GitHub Action Repository - AI Coding Instructions

This repository follows BCGov AI coding standards with GitHub Actions specific enhancements.

## Repository Context
This is a GitHub Action that may be used by multiple teams across BCGov. Code quality and reliability are critical since issues affect downstream projects.

## Action-Specific Development Practices

### Workflow Testing
- Always include comprehensive workflow testing in `.github/workflows/`
- Test action in multiple scenarios (success, failure, edge cases)
- Use realistic test data that mirrors actual usage patterns
- Include both unit tests and integration tests with actual GitHub API

### Action Marketplace Considerations
- Follow GitHub Action naming conventions and best practices
- Include comprehensive README with usage examples
- Provide clear input/output documentation
- Consider backwards compatibility when updating action interfaces
- Tag releases properly for semantic versioning

### Action Architecture
- Keep action logic focused and single-purpose
- Separate complex logic into testable functions
- Handle errors gracefully with helpful error messages
- Support both required and optional inputs with sensible defaults
- Log important steps for debugging downstream usage

### Security for Actions
- Never log sensitive information (tokens, passwords, etc.)
- Validate all inputs thoroughly to prevent injection attacks
- Use minimal required permissions in action.yml
- Follow principle of least privilege for API access
- Consider security implications since actions run in other people's workflows

### Documentation Requirements
- Include usage examples for common scenarios
- Document all inputs, outputs, and environment variables
- Provide troubleshooting section for common issues
- Include contribution guidelines specific to the action
- Document any breaking changes clearly in releases

### BCGov Integration Patterns
- Follow BCGov naming conventions for actions (action-*)
- Consider integration with other BCGov tools and workflows
- Support both public and private repository usage patterns
- Include appropriate license and compliance information

## Example Usage in README
Always include a complete example that other teams can copy:

```yaml
name: Example Workflow
on: [push]
jobs:
  example:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: bcgov/your-action@v1
      with:
        required-input: "example-value"
        optional-input: "custom-value"
```

Remember: Other teams depend on this action - prioritize reliability and clear documentation.
