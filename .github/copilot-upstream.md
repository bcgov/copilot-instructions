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

### **Iterative Simplification & Code Reduction:**
After implementing a feature, always look for opportunities to simplify and reduce code.

**Simplification Principles:**
- Minimize code changes - every line added should be necessary
- Question every conditional: "Do we really need this branch?"
- Prefer unified code paths: if the same operation works for multiple cases, use it for all
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

**NEVER use repositories as databases or state stores:**

- ❌ Workflows that commit runtime data to repositories
- ❌ Mixing code and runtime state in version control
- ❌ Committing generated files that should be ephemeral
- ❌ Using git history to track application state changes

**ALWAYS maintain clean separation:**

- ✅ Repositories contain only source code and configuration
- ✅ Runtime data generated during build/deploy process
- ✅ Stateful information lives in deployment artifacts (GitHub Pages, containers, etc.)
- ✅ Workflows are stateless and idempotent

**Red flags to question:**
- "Should this workflow commit changes to the repo?"
- "Is this data or code?"
- "Why does this need to be in git history?"
- "What happens if we run this workflow multiple times?"

**Correct pattern:**
```
Repository (code) → Workflow (generates fresh data) → Deployment (current state)
```

**Anti-pattern:**
```
Repository (code + data) → Workflow (commits data) → Deployment (stale state)
```
