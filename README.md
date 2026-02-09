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
- **`metrics-tracker.sh`** - development metrics tracking

## Git and GitHub CLI Safety

The `git-safety.sh` script prevents accidental dangerous operations:

```bash
sudo cp scripts/git-safety.sh /etc/profile.d/git-safety.sh
sudo chmod +x /etc/profile.d/git-safety.sh
```

**Git:** Blocks `commit`, `push`, `merge` on the default branch. Safe operations like `status`, `log`, `diff`, `fetch`, `pull` are allowed.

**GitHub CLI:** Only explicitly safe commands (`pr create`, `pr list`, `issue create`, etc.) are permitted. Dangerous operations (`pr merge`, `repo delete`) are blocked.

Override when needed: `command git push origin main`

See [`scripts/git-safety.sh`](./scripts/git-safety.sh) for full details.

## Contributing

We welcome contributions! Submit issues or pull requests to improve these shared guidelines.

**Guidelines:**
- Keep instructions focused on universal principles and BC Government standards
- Prioritize clarity, safety, and applicability across projects
- Remove redundant or overly specific content during reviews
