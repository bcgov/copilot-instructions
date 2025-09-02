# AI Instruction Standards Repository

This repository contains standardized AI instruction sets for BC Government projects, ensuring consistency, security, and best practices across development teams.

## Purpose

- **Centralized Standards**: Single source of truth for AI coding assistant instructions
- **BCGov Compliance**: Built-in security and compliance requirements
- **Team Efficiency**: Reduced onboarding time and improved code quality
- **Consistency**: Uniform AI behavior across all projects

## Structure

- `.github/copilot-upstream.md` - Universal safety and workflow standards
- `.github/copilot-instructions.md` - Project-specific guidance
- Scripts for analyzing instruction complexity and performance

## AI Instruction Standards

### Core Principles
- **Verify app works FIRST** before making multiple changes
- **Small, focused changes** over large refactoring
- **Incremental improvements** with verification at each step
- **Never use local .env files** for configuration

### Git Workflow Standards
- Use feature branches and pull requests for all changes
- Follow conventional commit format: `feat:`, `fix:`, `docs:`, `chore:`
- Use modern Git commands: `git switch -c`, `git restore`
- Set upstream before PR creation: `git push --set-upstream origin $(git branch --show-current)`

### Performance Standards
- Monitor instruction complexity to prevent bloat
- Use metrics tracking for optimization decisions
- Implement caching and parallel processing where appropriate
- Maintain readability and maintainability

## Usage

1. **Clone this repository** to your local development environment
2. **Reference the standards** in your AI coding assistant configuration
3. **Follow the workflow** for all code changes
4. **Contribute improvements** via pull requests following the established standards

## Contributing

See `.github/copilot-upstream.md` for detailed contribution guidelines and workflow standards.

---

*This repository serves as the foundation for consistent AI-assisted development across BC Government projects.*
