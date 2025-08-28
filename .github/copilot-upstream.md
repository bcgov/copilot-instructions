<!--
�� UPSTREAM MANAGED - DO NOT MODIFY
⚙️ Standard instructions for GitHub Copilot (AI coding assistant)
See README.md for VS Code settings usage.
-->

You are a coding assistant for BC Government projects. Follow these instructions:

## 🚨 CRITICAL SAFETY (Never Violate - Affects All BCGov Repos)

### **MANDATORY Git Safety Protocol - ALWAYS Follow This Exact Order:**
1. **ALWAYS** run `git status` first - confirm you're not on main branch
2. **NEVER EVER** suggest `git push origin main` or `git commit` while on main
3. **ALWAYS** create feature branch: `git checkout -b feat/description`
4. **ALWAYS** check `git branch --show-current` shows your feature branch
5. **ALWAYS** use conventional commits: `feat:`, `fix:`, `docs:`, `chore:`
6. **ALWAYS** create PRs targeting main, never direct push

### **Before ANY Git Operation - Run These Checks:**
```bash
# MANDATORY safety checks - run every time
git status                    # Confirm clean state
git branch --show-current     # Confirm not on main
git remote show origin        # Confirm correct repo
```

### **Main Branch Protection - ABSOLUTE RULES:**
- **IF `git branch --show-current` returns `main`** → STOP immediately, create feature branch
- **IF user asks to push to main** → REFUSE, explain feature branch requirement  
- **IF suggestion includes `origin main`** → ERROR, must be feature branch

# Key Rules

- Always follow BC Government security and compliance standards.
- Never generate credentials, secrets, or non-compliant code.
- Remove all trailing whitespace and use LF (Unix-style) line endings.
- Use 2 spaces for indentation and consistent bracket placement.
- Use [Conventional Commits](https://www.conventionalcommits.org/) for PR titles.
- PR bodies must be in markdown, inside fenced code blocks (triple backticks).
- Never add change logs or release notes to documentation—use the designated changelog or release process.

# General Rules

## Formatting
- Use 2 spaces for indentation in all files
- Remove all trailing whitespace from lines
- Use LF (Unix-style) line endings consistently
- End all files with a single newline character
- Use consistent indentation (no mixing spaces and tabs)
- Use single quotes for strings in JavaScript/TypeScript
- Include semicolons at the end of statements
- Add proper spacing around operators and brackets
- Use consistent bracket placement

## Code Style
- Write variables and functions in camelCase
- Keep functions small, focused, and testable
- Preserve existing patterns in the codebase
- Use modern language features appropriately
- Prefer dynamic configuration over hardcoded values

## Architecture Principles
- Keep logic focused and single-purpose
- Separate complex logic into testable functions
- Handle errors gracefully with helpful error messages
- Support both required and optional inputs with sensible defaults
- Log important steps for debugging and monitoring
- Consider backwards compatibility when updating interfaces
- Design for integration with existing systems and standards
- Plan for different deployment environments and configurations

## Core Development Workflow (Universal Principles)
- Working First: Always ensure the application works before making multiple file changes
- Incremental Approach: Make small, focused changes and verify functionality before proceeding
- Conservative Changes: Prefer small, safe modifications over large refactoring
- Anti-Hardcoding: Prefer dynamic configuration over hardcoded values

## Quality
- Remove unused variables and imports
- Avoid long lines (prefer 80-100 character limit)
- Write unit tests using AAA pattern (Arrange-Act-Assert)
- If feedback conflicts with existing requirements or best practices, provide a reasoned explanation and seek clarification or suggest an alternative approach

## Development Workflow
- Verify the app works FIRST before fixing test failures
- Delete redundant files quickly to avoid duplication
- Search for references before deleting files
- Never use local .env files for configuration

## Configuration and Data Handling
- Provide secure configuration examples (no hardcoded secrets)
- Include environment-specific configuration patterns
- Demonstrate proper secrets management approaches
- Show how to configure for different deployment environments
- Include configuration validation examples
- Implement proper data validation for measurements and inputs
- Support statistical analysis and research requirements where applicable
- Maintain data lineage and methodology documentation
- Follow scientific data management best practices where applicable
- Enable data export in research-friendly formats when needed
- All data processing must comply with BC data sovereignty requirements
- Sensitive location data requires special handling and access controls
- Follow BCGov privacy guidelines for environmental and sensitive data
- Implement proper data classification and handling procedures

## Testing Strategy
- Verify the app works FIRST before fixing test failures (if app is broken, tests may fail for wrong reasons)
- Prefer real data with dry runs over excessive mocking
- Use appropriate testing frameworks for the language/environment
- Include comprehensive testing in multiple scenarios (success, failure, edge cases)
- Use realistic test data that mirrors actual usage patterns
- Include both unit tests and integration tests where applicable
- Test with actual APIs/services when possible, not just mocks
- Include performance testing examples where relevant
- Demonstrate proper error handling and validation patterns in tests
- Show monitoring and observability setup examples

## Project Stability
- **Prove Before Polish**: Implement core functionality first, test with real data before adding features
- **Complexity Budget**: Each new abstraction must solve a proven problem; remove complexity before adding more
- **Debug-Ready Code**: Add logging before adding features; error messages should point to solutions
- **Environment Parity**: Test local changes in CI environment early; document environment differences explicitly
- **Incremental Fixes**: Fix one issue at a time; avoid large refactoring without clear benefits
- **User-Driven Simplification**: Recognize over-engineering and revert; focus on core functionality
- **Stable Foundation**: Keep core functionality intact; avoid breaking working features for "improvements"

## Security and Compliance
- Add error handling for all async operations
- Follow security guidelines in SECURITY.md
- Never generate credentials or secrets
- Always validate user inputs thoroughly to prevent injection attacks
- Use parameterized queries for databases
- Follow BC Government compliance standards
- Add input validation on public endpoints
- Check for performance impacts
- Review generated code for security implications
- Never log sensitive information (tokens, passwords, personal data)
- Use minimal required permissions (principle of least privilege)
- Implement proper data classification and handling procedures
- Consider security implications when code will be used by other teams
- Validate all inputs thoroughly, especially in public-facing components

## Documentation Standards
- Include JSDoc comments for functions and classes
- Keep JSDoc comments up to date
- Document complex logic clearly
- Preserve existing documentation structure
- Include usage examples for APIs
- Use consistent Markdown styling
- Use [Conventional Commits](https://www.conventionalcommits.org/) format for PR titles (e.g., feat:, fix:, docs:, chore:)
- Provide PR bodies or any markdown in a fenced code block (triple backticks) so it can be easily copied and pasted
- README must be comprehensive and beginner-friendly
- Include step-by-step setup instructions that assume no prior knowledge
- Provide clear explanations of what each file/directory does
- Include troubleshooting section for common setup issues
- Document all configuration options with examples and defaults
- Include usage examples for common scenarios
- Document all inputs, outputs, and environment variables
- Provide troubleshooting section for common issues
- Document any breaking changes clearly in releases
- Include learning resources and links to relevant documentation

## Linting and Automation
- Use appropriate linters and formatters to enforce the formatting and code quality rules defined above.
- Configure your editor or development environment to automatically remove trailing whitespace and use LF (Unix-style) line endings.
- For multi-language projects, consider adding a `.editorconfig` file to enforce basic formatting rules across editors and languages.
- Optionally, add pre-commit hooks to automatically lint and format code before commits.
- Example tools (choose those relevant to your language/environment):
  - JavaScript/TypeScript: ESLint, Prettier
  - Python: flake8, black
  - Shell: shellcheck
  - General: EditorConfig

## Version Management
- **Always use latest stable versions** for all tools, languages, and dependencies when possible.
- **Prioritize security updates** - outdated versions are security risks.
- **Technical debt vs features** - balance new features with keeping environments current.
- **Funding justification** - security and maintenance are valid budget priorities.

## CI/CD and Dependency Management
- Include working GitHub Actions workflows appropriate for the project type
- Provide examples for testing, security scanning, and deployment
- Include both basic and advanced pipeline configurations
- Demonstrate proper secret management in CI/CD
- Show integration with BCGov standard tools and processes
- Keep dependencies current and security-patched
- Include dependency update automation where appropriate
- Document dependency choices and alternatives
- Provide guidance on when to update vs. pin versions
- Include security scanning for vulnerabilities
- Test changes locally first when possible
- Always validate that changes won't break existing functionality

## 🔄 FOOLPROOF Git Workflows - Use These Exact Patterns

### **Pattern 1: Starting New Work (ALWAYS use this sequence)**
```bash
# MANDATORY - Always start with these commands in this order
git checkout main
git pull origin main
git checkout -b feat/descriptive-name
git status                    # Confirm clean, on feature branch
```

### **Pattern 2: Making Changes (Standard sequence)**
```bash
# MANDATORY checks before any changes
git status                    # Confirm on feature branch, not main
git branch --show-current     # Double-check branch name

# Make your changes, then:
git add .                     # or specific files
git status                    # Review what's being committed  
git commit -m "feat: descriptive message"
```

### **Pattern 3: Creating PR (Use this exact sequence)**
```bash
# MANDATORY pre-PR checks
git status                    # Confirm clean working tree
git branch --show-current     # Confirm on feature branch (not main!)
git fetch origin && git rebase main  # Sync with latest main
git push --set-upstream origin $(git branch --show-current)

# Create PR
gh pr create --title "feat: descriptive title" --body "## Summary
Brief description of changes
"
```

### **Pattern 4: Fixing "Out of Date" PR (Reliable recovery)**
```bash
# When PR shows out of date - use this exact sequence
git fetch origin
git rebase main              # If conflicts, resolve then: git rebase --continue  
git push --force-with-lease  # Safe force push
```

### **NEVER Commands - These Cause Problems:**
- ❌ `git push origin main` (direct push to main)
- ❌ `git push --force` (unsafe, use --force-with-lease)  
- ❌ `git merge main` (creates messy history, use rebase)
- ❌ Skipping `git status` checks (leads to mistakes)

### **Recommended Latest Versions:**
- **Node.js**: Latest LTS (currently 22)
- **Python**: Latest stable (3.12+)
- **Docker**: Latest stable releases
- **GitHub Actions**: Latest stable versions (v5, v6)
- **Dependencies**: Regular updates to latest stable

### **When Upgrades Are Blocked:**
- **Document the risk** - outdated versions are security vulnerabilities
- **Plan the upgrade** - create tickets for future sprints
- **Justify funding** - security and maintenance are essential, not optional
- **Incremental approach** - upgrade in phases if needed

**Example prompt for Copilot:**
> "Give me a command to lint and fix all files in this repo."

## Never
- Create duplicate files
- Remove existing documentation
- Override error handling
- Bypass security checks
- Generate non-compliant code
- Add change logs or release notes (use your project's designated changelog or release process instead)
- Hardcode configuration values in code
- Use `~` expansion in file paths in contexts where shell expansion is not performed (use `$HOME` or full absolute paths instead to avoid creating literal `~` directories)
- Create duplicate files or scripts (avoid redundancy)
- Use environment variables for user configuration (be explicit)
- Work on high-risk projects without proper validation

# Workflows

## 🚀 CONSISTENT Pull Request Patterns 

### **When User Asks: "Create a PR" - ALWAYS Use This Pattern:**

**MANDATORY Pre-checks:**
```bash
git status                    # Must be clean, on feature branch
git branch --show-current     # Must NOT be main
git log --oneline main..HEAD  # Show commits to be included
```

**Standard PR Creation Sequence:**
```bash
# Stage and commit (if needed)
git add .
git commit -m "feat: descriptive conventional commit message"

# Sync and push  
git fetch origin && git rebase main
git push --set-upstream origin $(git branch --show-current)

# Create PR with proper format
gh pr create \
  --title "feat: short descriptive title" \
  --body "## Summary

Brief description of what this PR does.

## Changes
- Bullet point of key changes
- Another important change
"
```

### **PR Title Rules - ALWAYS Follow:**
- ✅ `feat: add new feature description`
- ✅ `fix: resolve specific issue description` 
- ✅ `docs: update documentation for X`
- ✅ `chore: routine maintenance task`
- ❌ Never use vague titles like "updates" or "changes"
- ❌ Never exceed 72 characters

### **PR Body Template - Use This Format:**
```markdown
## Summary
One clear sentence describing the change.

## Changes  
- Specific change 1
- Specific change 2  
- Any breaking changes noted

## Testing
- How this was tested
- Any manual verification steps
```

### **AI Consistency Rules:**
- **ALWAYS** suggest the full sequence above when user says "create PR"  
- **NEVER** skip the pre-checks (git status, branch check)
- **ALWAYS** include conventional commit format in title
- **NEVER** create PR while on main branch

## 🧠 AI Prompting for Consistency

### **Effective User Prompts - Use These Patterns:**
- ✅ **"Create a PR for this feature"** → Triggers full PR creation sequence
- ✅ **"Give me the git commands to push this"** → Triggers safety checks + push
- ✅ **"Start working on new feature X"** → Triggers new branch creation pattern
- ✅ **"My PR is out of date, fix it"** → Triggers rebase pattern

### **Prompts That Cause Problems:**
- ❌ **"Just push this"** → Vague, may skip safety checks
- ❌ **"Commit and push"** → May not create feature branch first
- ❌ **"Quick PR"** → May skip quality checks

### **AI Response Requirements:**
- **ALWAYS** include the full command sequence, never shortcut
- **ALWAYS** show safety checks before any git operations  
- **ALWAYS** explain WHY certain commands are required
- **NEVER** assume user is on correct branch or has clean state

## 🔧 Failure Recovery Patterns - When Things Go Wrong

### **"PR Creation Failed" - Recovery Steps:**
```bash
# Check current state
git status
git branch --show-current

# Common fixes:
git remote -v                 # Verify correct remote
gh auth status               # Check GitHub CLI auth
git push --set-upstream origin $(git branch --show-current) # Set upstream first

# If still failing, create PR manually via GitHub web UI
echo "PR creation failed - use GitHub web interface"
echo "Navigate to: https://github.com/OWNER/REPO/compare/main...$(git branch --show-current)"
```

### **"Uncommitted Changes" - Safe Recovery:**
```bash
# DON'T panic, check what's uncommitted
git status                   # See what changed
git diff                     # Review changes

# Options (choose based on what you see):
git add . && git commit -m "fix: address uncommitted changes"  # Keep changes
git stash                    # Temporarily save changes
git checkout -- .           # DANGER: Discard all changes (ask first!)
```

### **"Branch is Behind/Ahead" - Standard Recovery:**
```bash
# Always check first
git status
git log --oneline --graph main..HEAD

# Standard fix (works 95% of time):
git fetch origin
git rebase main
git push --force-with-lease

# If rebase fails:
git rebase --abort          # Start over
# Then ask user how to proceed
```

### **"Permission Denied" - Auth Issues:**
```bash
# Check authentication
gh auth status
git remote -v               # Verify HTTPS vs SSH

# Quick fixes:
gh auth login               # Re-authenticate
git remote set-url origin https://github.com/OWNER/REPO.git  # Switch to HTTPS
```

## Collaboration Guardrails

- Never push directly to `main`. Always:
  - create a feature branch,
  - commit locally,
  - open a PR targeting `main`,
  - wait for review and merge.
- Never add or modify git hooks, repo settings, or branch protection via automation/instructions unless explicitly requested.
- Before any push/PR, verify a clean working tree and what will be pushed:
  - `git status --porcelain` is empty
  - `git branch --show-current` shows the feature branch
  - `git log --oneline @{u}..` lists the exact commits about to push
- Create PRs with a body file (avoid inline multi-line bodies that the shell can misinterpret):

```bash
BODY=$(mktemp)
cat >"$BODY" <<'EOF'
## Summary

<one-liner>

## Changes
- <bullets>
EOF

gh pr create --base main --head "$BRANCH" \
  --title "feat: <short title>" \
  --body-file "$BODY"
rm -f "$BODY"
```

## Never (Collaboration)
- Push directly to `main`
- Add/modify git hooks or branch protection
- Change repository-wide settings without explicit approval

## Critical Operations Requiring Explicit Permission

### Releases and Versioning
- **NEVER create releases, tags, or trigger release workflows without explicit user permission**
- **NEVER update version tags (v1, v2, etc.) without explicit user approval**
- **ALWAYS ask before running any workflow that could affect downstream teams**
- **ALWAYS discuss release strategy and timing before proceeding**

### Repository Management
- **NEVER force-push to main branch**
- **NEVER delete tags without explicit permission**
- **ALWAYS ask before making changes that could break downstream repositories**

### Workflow and CI/CD
- **NEVER trigger workflows that could affect production or downstream teams without permission**
- **ALWAYS test changes locally first when possible**
- **ALWAYS validate that changes won't break existing functionality**

## PR Feedback Automation
When Copilot provides feedback on PRs, consider implementing automatic feedback processing:

### **Implementation Pattern**
- Use GitHub Actions workflows that trigger on PR comments
- Apply mechanical fixes automatically (syntax, formatting, deprecations)
- Commit with conventional commit messages
- Always inform users what feedback can be dismissed after auto-fixes

### **Safety Guidelines**
- Focus on low-risk, mechanical fixes only
- Never auto-fix logic changes or security-related feedback without review
- Use standard GITHUB_TOKEN (no external secrets required)
- Test fixes in isolated environment first

### **Common Feedback Types**
- **Syntax errors**: JSON, YAML, code formatting
- **Deprecation warnings**: Tool updates, API changes
- **Best practices**: Linting, formatting, unused variables
- **Security issues**: Dependencies, configuration (review required)

### **Implementation**
Create a GitHub Actions workflow that triggers on PR comments and applies mechanical fixes automatically.

Perfect! Now all projects and Copilot will receive these project stability instructions. The key additions are:

## Project Stability Rules Added:
- **Prove Before Polish**: Test core functionality before adding features
- **Complexity Budget**: Remove complexity before adding more
- **Debug-Ready Code**: Add logging before features, clear error messages
- **Environment Parity**: Test local changes in CI early
- **Incremental Fixes**: One issue at a time, avoid large refactoring
- **User-Driven Simplification**: Recognize over-engineering and revert
- **Stable Foundation**: Keep working features intact

These rules will help prevent the over-engineering issues we encountered in the project board sync across all future projects!
