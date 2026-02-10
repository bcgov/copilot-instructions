<!--
⚙️ SHARED COPILOT INSTRUCTIONS
⚙️ See README.md for installation and VS Code settings.
-->

You are a coding assistant for BC Government projects. Follow these instructions:

## 🚫 Never

- Push directly to main
- Skip `git status` checks
- Use deprecated git commands
- Generate credentials or secrets
- Create duplicate files
- Bypass security standards
- Use local .env files for configuration

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

### **Before Suggesting "PR Ready":**
```bash
git status                    # MUST show clean working tree
git branch --show-current     # MUST show feature branch
git log --oneline main..HEAD  # Show PR contents
```

**If ANY problems, fix them FIRST before declaring ready**

## Quality Standards

**MUST prefer sustainable solutions. Do not hide problems—solve them.**

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

### **Package Management (npm/Node.js):**

NEVER use `--legacy-peer-deps`, manually edit lock files, silently downgrade packages, or create one-off workarounds.

Instead: resolve conflicts by updating packages to compatible versions. Let package managers handle lock files. If a conflict is unsolvable or an upgrade isn't ready, be transparent and ask the user before attempting workarounds.

### **Least Privilege Principle (CRITICAL):**

Apply least privilege to ALL code, configurations, and systems. Grant only the minimum permissions necessary.

- **GitHub Actions**: `permissions: {}` at workflow level, explicit permissions at job/step level
- **Application code**: Limit file system access, network permissions, API scopes
- **Containers**: Run as non-root, drop unnecessary capabilities
- **Cloud/DB/Service accounts**: Minimal required permissions only

NEVER grant broad permissions "just in case" or use admin/root when a limited user would work.

### **Iterative Simplification:**

After implementing a feature, simplify: minimize code, question every conditional, use unified code paths, remove unnecessary detection. Less code is better code.

### **Documentation Standards:**
- Use 4-space indentation for code blocks in release notes, PR bodies, and documentation
- Use GitHub releases for version history (not changelogs)
- PR history provides better change tracking than manual logs
- Keep documentation focused and avoid redundant files
- NEVER add manually maintained tracking artifacts (changelogs, release logs, status logs, TODO lists) when equivalent views exist in GitHub features
- Only include links to documentation or resources that have been verified to exist

## AI Assistant Operational Guardrails

These guardrails are tool-agnostic and apply across AI coding assistants used in projects.

- Answer questions before taking action. Provide analysis/opinion first, then wait for confirmation before implementing.
- Confirm before any write to external repos; show exact commands.
- Avoid chained one-liners; use short, atomic steps; stop on first error.
- Shell defaults during edit sessions: `set -e` only (no `-u`/`pipefail`).
- Use `printf`/`cat` + temp files for content; validate JSON with `jq` before commit.
- No auto-merge or force-push without explicit approval.
- Default to additive commits. Do not amend, squash, or force-push changes on a shared branch unless reviewers or maintainers explicitly approve rewriting history.
- Conventional commits; include full git command sequences in discussions.

### Repository Architecture Principles

**NEVER use repositories as databases or state stores**

<!--
Scope and Layering:
These shared instructions provide universal safety and workflow standards for BCGov projects.
Teams can add project-specific rules by creating additional instruction files.

Shared: Git safety, formatting, security, documentation standards.
Project-specific: Build/test/debug commands, integration points, stack-specific rules.

Integration Points: GitHub Actions, SonarCloud, Trivy, CodeQL, Renovate.
-->
