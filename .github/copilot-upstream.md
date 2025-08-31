
<!--
⚙️ UPSTREAM MANAGED - DO NOT MODIFY
⚙️ Standard instructions for GitHub Copilot (AI coding assistant)
See README.md for VS Code settings usage.
-->

## Layering Guidance
These upstream instructions provide universal safety and workflow standards for BCGov projects. Teams should add project-specific rules in `.github/copilot-instructions.md`, which will complement (not override) these shared standards.

## Onboarding Checklist
- Confirm branch protection is enabled (see QuickStart template)
- Use feature branches and pull requests for all changes
- Follow conventional commit and PR formats
- Review security and compliance requirements

You are a coding assistant for BC Government projects. Follow these instructions:

## Scope
Upstream instructions cover:
- Git safety and workflow
- Formatting and code style
- Security and compliance
- Documentation standards
Project-specific instructions should cover:
- Build/test/debug commands
- Integration points and external dependencies
- Stack-specific rules and patterns

## Integration Points
- OpenShift for deployment (see QuickStart template)
- GitHub Actions for CI/CD automation
- SonarCloud, Trivy, CodeQL for code analysis and security
- Renovate for automated dependency updates

## References
- [QuickStart Template](https://github.com/bcgov/quickstart-openshift)
- [BCGov Developer Guide](https://developer.gov.bc.ca/)
- [Security and Compliance Docs](https://github.com/bcgov/quickstart-openshift/blob/main/SECURITY.md)

## Feedback and Iteration
Teams are encouraged to propose improvements to this upstream file via issues or pull requests.

## Example: Layered Instructions
Add a `.github/copilot-instructions.md` in your repo for local rules, e.g.:
```
# Local Copilot Instructions
- Add build/test commands for your stack
- Specify integration with external APIs or services
- Document any unique patterns or conventions
```

## 🚨 CRITICAL SAFETY - Always Follow

### **Git Safety Protocol:**
```bash
# ALWAYS run before any git operation
git status                    # Confirm clean state, not on main
git branch --show-current     # Must NOT be "main"
```

### **Main Branch Protection:**
- **IF on main branch** → STOP, create feature branch first
- **NEVER** suggest `git push origin main`
- **ALWAYS** use feature branches and PRs

## 🔄 Universal Git Workflow

### **Start Work:**
```bash
git fetch origin && git checkout main && git pull origin main
git switch -c feat/description
git status  # Confirm on feature branch
```

### **Commit Changes:**
```bash
git status  # Review changes
git add .
git commit -m "feat: descriptive message"  # Use conventional commits
```

### **Create PR:**
```bash
git status  # Must be clean
git fetch origin && git rebase main
git push --set-upstream origin $(git branch --show-current)
gh pr create --title "feat: descriptive title" --body "## Summary

Brief description
"
```

### **Fix Out-of-Date PR:**
```bash
git fetch origin && git rebase main && git push --force-with-lease
```

## 🚀 Key Standards

### **Conventional Commits (Required):**
- `feat: add new feature`
- `fix: resolve bug`
- `docs: update documentation`
- `chore: maintenance task`

### **Modern Git Commands:**
- Use `git restore .` not `git checkout -- .`
- Use `git switch branch` not `git checkout branch`
- Use `git switch -c new` not `git checkout -b new`

### **Formatting:**
- 2 spaces for indentation
- Remove trailing whitespace
- LF line endings
- Conventional commit format for PR titles

### **Development Priorities:**
- Verify app works FIRST before making multiple changes
- Small, focused changes over large refactoring
- Latest stable versions for all tools
- Never use local .env files for configuration

### **Documentation Standards:**
- Use GitHub releases for version history (not changelogs)
- PR history provides better change tracking than manual logs
- Keep documentation focused and avoid redundant files
- Prefer automated tracking over manual maintenance

## 🚫 Never

- Push directly to main
- Skip `git status` checks
- Use deprecated git commands
- Generate credentials or secrets
- Create duplicate files
- Bypass security standards

## 📋 Before Suggesting "PR Ready"

```bash
git status                    # MUST show clean working tree
git branch --show-current     # MUST show feature branch
git log --oneline main..HEAD  # Show PR contents
```

**If ANY problems, fix them FIRST before declaring ready**
