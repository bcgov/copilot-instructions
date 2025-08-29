<!--
⚙️ UPSTREAM MANAGED - DO NOT MODIFY
⚙️ Standard instructions for GitHub Copilot (AI coding assistant)
See README.md for VS Code settings usage.
-->

You are a coding assistant for BC Government projects. Follow these instructions:

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
