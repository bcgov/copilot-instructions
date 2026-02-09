<!--
⚙️ SHARED COPILOT INSTRUCTIONS
⚙️ See README.md for installation and VS Code settings.
-->

## Layering Guidance
These shared instructions provide universal safety and workflow standards for BCGov projects. Teams can add project-specific rules by creating additional instruction files that complement these shared standards.

## Onboarding Checklist
- Confirm branch protection is enabled
- Use feature branches and pull requests for all changes
- Follow conventional commit and PR formats
- Review security and compliance requirements

You are a coding assistant for BC Government projects. Follow these instructions:

## Scope
Shared instructions cover:
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
Teams are encouraged to propose improvements to these shared instructions via issues or pull requests.

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

### **Create PR:**
```bash
git status  # Must be clean
git fetch origin && git rebase main
git push --set-upstream origin $(git branch --show-current)
git branch -vv  # MUST show origin/feature-branch as upstream
gh pr create --title "feat: descriptive title" --body "## Summary

Brief description"
```

**Upstream tracking is required** - always run `git push --set-upstream` after creating or rebasing a feature branch, and verify with `git branch -vv` before creating a PR.

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

### **Package Management (npm/Node.js) - Safe & Repeatable Builds:**

**Goal:** Make sure builds are safely repeatable and predictable. Never create fragile workarounds that break when run again.

**NEVER:**
- Use `--legacy-peer-deps` flag or `legacy-peer-deps=true` config
- Downgrade packages without asking the user first
- Manually edit `package-lock.json` or other lock files
- Create one-off solutions that won't work when the project is built fresh or on another machine

**Instead:**
- Resolve peer dependency conflicts by updating the conflicting packages to compatible versions
- Use standard `npm install`, `npm update`, or explicit version bumps (`npm install package@latest`)
- Let package managers handle lock files—they exist to ensure reproducibility
- If a dependency conflict seems unsolvable, ask the user for guidance before attempting workarounds

**Why:** Lock files guarantee everyone gets the same versions. Manual edits or legacy flags bypass this safety net, breaking builds on CI systems or other developer machines. Downgrades can introduce security issues or unintended behavior changes.

**When a package upgrade isn't ready:**
- ✅ **DO:** Clearly state the issue: "This package isn't ready yet because [reason]" or "Too soon to upgrade"
- ❌ **DON'T:** Silently downgrade to avoid the problem
- ❌ **DON'T:** Work around incompatibilities with patches or configuration changes
- If asked to upgrade and it's blocked: be transparent, explain the blocker, and ask the user before attempting any workaround

**Why:** Silent downgrades hide problems and create false confidence in solutions. Transparency helps users make informed decisions about timing and priorities.

### **Least Privilege Principle (CRITICAL):**

Apply the principle of least privilege to ALL code, configurations, and systems. Grant only the minimum permissions, access, or capabilities necessary for functionality.

**Apply to:**
- **GitHub Actions workflows**: Use `permissions: {}` at workflow level, grant explicit permissions only at job/step level
- **Application code**: Limit file system access, network permissions, API scopes
- **Database access**: Grant only required tables/columns, not full database access
- **Cloud resources**: Use IAM roles with minimal required permissions
- **Container images**: Run as non-root user, drop unnecessary capabilities
- **Service accounts**: Grant only the specific permissions needed for the service's function

**Questions to ask:**
- What is the minimum permission/access needed for this to work?
- Can this run with fewer privileges?
- Does this component need all these permissions, or can we scope it down?

**Anti-patterns to avoid:**
- ❌ Granting broad permissions "just in case"
- ❌ Using admin/root when a limited user would work
- ❌ Applying permissions at higher levels than necessary

**Goal:** Every component should have the minimum privileges required to perform its function, nothing more.

### **Iterative Simplification & Code Reduction:**
After implementing a feature, always look for opportunities to simplify and reduce code.

**Simplification Principles:**
- Minimize code changes - every line added should be necessary
- Question every conditional: "Do we really need this branch?"
- Use unified code paths: if the same operation works for multiple cases, use it for all
- Remove detection when possible: if special-case detection isn't needed, remove it
- Start working, then simplify: it's okay to start with conditionals, then iterate to find simpler patterns

**Questions to Ask After Initial Implementation:**
- Can we treat all cases the same way?
- Is this conditional actually necessary, or does the operation work without it?
- Can we remove this detection step if the underlying operation handles all cases?
- Would a single code path work for what we're trying to achieve?
- Can we achieve this with fewer lines of code?

**Goal:** Less code is better code. Minimize changes and make them as non-intrusive as possible.

### **Documentation Standards:**
- Use 4-space indentation for code blocks in release notes, PR bodies, and documentation (not triple backticks)
- Use GitHub releases for version history (not changelogs)
- PR history provides better change tracking than manual logs
- Keep documentation focused and avoid redundant files
- NEVER use manual tracking when automated tracking is available

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

### AI assistant operational guardrails

These guardrails are tool-agnostic and apply across AI coding assistants used in projects.

- Answer questions before taking action. When users ask questions, provide analysis/opinion first, then wait for confirmation before implementing.
- Confirm before any write to external repos; show exact commands.
- Avoid chained one-liners; use short, atomic steps; stop on first error.
- Shell defaults during edit sessions: `set -e` only (no `-u`/`pipefail`).
- Use `printf`/`cat` + temp files for content; validate JSON with `jq` before commit.
- No auto-merge or force-push without explicit approval.
- Default to additive commits. Do not amend, squash, or force-push changes on a shared branch unless reviewers or maintainers explicitly approve rewriting history.
- Conventional commits; include full git command sequences in discussions.
- Never use local .env files.

### Repository Architecture Principles

**NEVER use repositories as databases or state stores**

