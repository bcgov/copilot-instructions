
<!--
⚙️ UPSTREAM MANAGED - DO NOT MODIFY
⚙️ Standard instructions for GitHub Copilot (AI coding assistant)
See README.md for VS Code settings usage.
-->

## Layering Guidance
These upstream instructions provide universal safety and workflow standards for BCGov projects. Teams should add project-specific rules in `.github/copilot-instructions.md`, which will complement (not override) these shared standards.

## Onboarding Checklist
- Confirm branch protection is enabled
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
- GitHub Actions for CI/CD automation
- SonarCloud, Trivy, CodeQL for code analysis and security
- Renovate for automated dependency updates

## Documentation and References
- No external links required for standard onboarding and workflow. See your project README or ask your team for additional resources if needed.
- Only include links to documentation or resources that have been verified to exist. Never add unverified, broken, or placeholder links.

## Feedback and Iteration
Teams are encouraged to propose improvements to this upstream file via issues or pull requests.
- Specify integration with external APIs or services
- Document any unique patterns or conventions

### **Git Safety Protocol:**
```


## 🔄 Universal Git Workflow

### **Create Feature Branch (CRITICAL - Follow This Order):**
```bash
git status                    # MUST show clean working tree
git branch                    # MUST show you're on main
git pull                      # MUST update main to latest
git switch -c feat/description
git status                    # Confirm on feature branch
```

**NEVER create branches without first:**
- Confirming current branch is main
- Confirming main is up to date  
- Confirming no uncommitted changes
```
```

### **Create PR:**
```bash
git status  # Must be clean
git fetch origin && git rebase main
# REQUIRED: Set and verify upstream before PR creation
git push --set-upstream origin $(git branch --show-current)
git branch -vv  # MUST show origin/feature-branch as upstream
gh pr create --title "feat: descriptive title" --body "## Summary

Brief description
- Always run `git push --set-upstream origin $(git branch --show-current)` after creating or rebasing a feature branch.
- Run `git branch -vv` and confirm your branch is tracked by origin before creating a PR or pushing further changes.
- If upstream is not set, repeat the push command until it is.
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
- Remove trailing whitespace and unnecessary blank lines
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
