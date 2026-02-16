# Copilot Instructions

Guidelines and tooling to help developers effectively use GitHub Copilot while maintaining security and quality standards.

## What's Included

- **[Copilot Instructions](/.github/copilot-instructions.md)** - Behavioral guidelines and coding standards that you can load into Copilot Chat
- **Safety Tooling** (optional) - Git hooks and CLI wrappers that enforce the instructions' safety rules
- **Git Configuration Setup** (optional) - Recommended settings, global gitignore, and user configuration

## Quick Start: Install Copilot Instructions

### Option 1: Global Context (Recommended for Chat)

Copy the instructions to your home directory and reference them in every chat:

```bash
curl -Lo ~/.copilot.md \
  https://raw.githubusercontent.com/bcgov/copilot-instructions/main/.github/copilot-instructions.md
```

Then start each chat with: `@~/.copilot.md`

This loads your standards into every Copilot conversation without per-project configuration.

### Option 2: Per-Project Instructions

For integrated project-level VS Code Copilot support:

```bash
mkdir -p .copilot
curl -Lo .copilot/instructions \
  https://raw.githubusercontent.com/bcgov/copilot-instructions/main/.github/copilot-instructions.md
```

Add project-specific rules to `.copilot/instructions` after downloading. Re-run the curl command to update with the latest shared standards.

## Safety Setup (Recommended)

The Copilot instructions tell the AI "never push to main" and "never merge PRs." This installer enforces those rules with Git hooks and GitHub CLI protection:

**Option 1: Quick Install (curl)**
```bash
curl -sSL https://raw.githubusercontent.com/bcgov/copilot-instructions/main/scripts/install-hooks.sh | bash
```

**Option 2: Clone and Run**
```bash
git clone https://github.com/bcgov/copilot-instructions.git
cd copilot-instructions
./scripts/install-hooks.sh
```

**What it installs:**

1. **Global Git Hooks** (all repos on your machine)
   - Pre-commit: Gitleaks secret scanner (blocks secrets before commit)
   - Pre-push: Blocks pushes to `main`/`master` branches
   - Installs Gitleaks to `~/.local/bin`
   - Sets `git config --global core.hooksPath ~/.githooks`
   - Backs up existing hooks and prompts before overriding a different `core.hooksPath`

2. **GitHub CLI Safety** (appends to `~/.bashrc`)
   - Blocklist wrapper for `gh` commands (source in [`scripts/git-safety.sh`](./scripts/git-safety.sh))
   - Blocks dangerous operations (`gh pr merge`, `gh repo delete`, `gh secret`)
   - AI policy comments visible in your bashrc

**After install:** Restart terminal or `source ~/.bashrc`

**Emergency overrides:**
- Git hooks: `git commit --no-verify` or `git push --no-verify`
- gh wrapper: `command gh pr merge ...` (use GitHub UI instead)

See [`scripts/hooks/`](./scripts/hooks/) for hook source code.

## Optional Enhancements

### Git Configuration Setup

Configure Git with recommended settings from core Git developers:

**Option 1: Quick Install (curl)**
```bash
curl -sSL https://raw.githubusercontent.com/bcgov/copilot-instructions/main/scripts/git-setup.sh | bash
```

**Option 2: Clone and Run**
```bash
git clone https://github.com/bcgov/copilot-instructions.git
cd copilot-instructions
./scripts/git-setup.sh
```

**What it configures:**

1. **User Information** (interactive prompts if not set)
   - `user.name` - Your full name
   - `user.email` - Your email address

2. **Global .gitignore** (from bcgov/quickstart-openshift)
   - Downloads comprehensive patterns for Node, Java, Python, Go
   - Sets `core.excludesfile = ~/.gitignore_global`
   - Offers to append patterns if you already have a global gitignore

3. **Recommended Git Settings** (based on [GitButler blog](https://blog.gitbutler.com/how-git-core-devs-configure-git))
   - Better defaults for branch, diff, push, merge, and rebase workflows
   - Improved conflict resolution with `zdiff3`
   - Auto-stashing and auto-squashing for cleaner workflows
   - Enhanced diff output with histogram algorithm and color-moved detection

**Safety:** The script never overwrites existing settings. Run it multiple times safely.

## Attribution

The Behavioral Guidelines section in our copilot instructions is adapted from [CLAUDE.md](https://github.com/forrestchang/andrej-karpathy-skills/blob/main/CLAUDE.md) by Forrest Chang, which provides foundational principles for reducing common LLM coding mistakes.

## Contributing

We welcome contributions! Submit issues or pull requests to improve these shared guidelines.

**Guidelines:**
- Keep instructions focused on universal principles and shared standards
- Prioritize clarity, safety, and applicability across projects
- Remove redundant or overly specific content during reviews
