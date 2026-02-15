# Shared Copilot Instructions

Shared VS Code configuration to accelerate and guide the use of GitHub Copilot, an AI coding assistant.

## Installation

### Option 1: Global Context (Recommended for Chat)

Copy the instructions to your home directory and reference them in every chat:

```bash
curl -Lo ~/.copilot.md \
  https://raw.githubusercontent.com/bcgov/copilot-instructions/main/.github/copilot-instructions.md
```

Then start each chat with: `@~/.copilot.md`

This loads your standards into every conversation without per-project configuration.

### Option 2: Per-Project Instructions

For integrated project-level VS Code Copilot support:

```bash
mkdir -p .copilot
curl -Lo .copilot/instructions \
  https://raw.githubusercontent.com/bcgov/copilot-instructions/main/.github/copilot-instructions.md
```

Add project-specific rules to `.copilot/instructions` after downloading. Re-run the curl command to update with the latest shared standards.

## Scripts

Utility scripts in [`scripts/`](./scripts/):

- **`git-safety.sh`** - prevents dangerous git/gh operations
- **`install-hooks.sh`** - installs global git hooks (Gitleaks + main protection)
- **`metrics-tracker.sh`** - development metrics tracking

## Git and GitHub CLI Safety

The `git-safety.sh` script prevents accidental dangerous operations:

```bash
sudo cp scripts/git-safety.sh /etc/profile.d/git-safety.sh
sudo chmod +x /etc/profile.d/git-safety.sh
```

**Git:** Blocks `commit`, `push`, `merge` on the default branch. Safe operations like `status`, `log`, `diff`, `fetch`, `pull` are allowed.

**GitHub CLI:** Only explicitly safe commands (`pr create`, `pr list`, `issue create`, etc.) are permitted. Dangerous operations (`pr merge`, `repo delete`) are blocked.

Override git-safety.sh only: `command git push origin main` (hooks still apply)

See [`scripts/git-safety.sh`](./scripts/git-safety.sh) for full details.

## Global Git Hooks (Gitleaks)

Install global hooks for local secret blocking and default-branch protection:

```bash
bash scripts/install-hooks.sh
```

These hooks use Gitleaks to scan staged changes before commits and block pushes to the default branch. Hooks are enforced by Git itself; follow the feature-branch + PR workflow.

## Attribution

The Behavioral Guidelines section in our copilot instructions is adapted from [CLAUDE.md](https://github.com/forrestchang/andrej-karpathy-skills/blob/main/CLAUDE.md) by Forrest Chang, which provides foundational principles for reducing common LLM coding mistakes.

## Contributing

We welcome contributions! Submit issues or pull requests to improve these shared guidelines.

**Guidelines:**
- Keep instructions focused on universal principles and BC Government standards
- Prioritize clarity, safety, and applicability across projects
- Remove redundant or overly specific content during reviews
