# Shared Copilot Instructions

Shared VS Code configuration to accelerate and guide the use of GitHub Copilot, an AI coding assistant.

## Installation

### VS Code Copilot (Per-Project)

**Important:** VS Code Copilot only supports project-level instructions, not global settings. Each repository needs its own `.copilot/instructions` file.

#### Download Instructions to Your Project

⚠️ **Warning:** This will replace any existing `.copilot/instructions` file in your project.

```bash
mkdir -p .copilot
curl -Lo .copilot/instructions \
  https://raw.githubusercontent.com/bcgov/copilot-instructions/main/.github/copilot-instructions.md
```

**To update:** Re-run the curl command to get the latest version.

**To customize:** After downloading, edit `.copilot/instructions` to add project-specific rules. The shared instructions will be replaced on the next update, so keep customizations in a separate section or file if you need to preserve them.

#### Alternative: Clone Repository (For Easy Updates)

If you prefer to manage updates with git:


```bash
git clone https://github.com/bcgov/copilot-instructions.git ~/Repos/copilot-instructions
```

Then copy to each project:

```bash
mkdir -p .copilot
cp ~/Repos/copilot-instructions/.github/copilot-instructions.md .copilot/instructions
```

**To update:** `cd ~/Repos/copilot-instructions && git pull`, then copy to projects as needed.

### Notes

- **VS Code limitation:** Global Copilot instructions via `settings.json` are not supported. Each project must have its own `.copilot/instructions` file.
- **File replacement:** The curl command will overwrite existing `.copilot/instructions` files. Back up customizations before updating.
- **Customization:** Add project-specific rules to `.copilot/instructions` after downloading, but be aware they'll be replaced on updates.

## Examples

### Creating Pull Requests with Copilot and GitHub CLI

Ask Copilot: "Give me a PR command using gh cli."

Copilot will generate a command block following the shared instructions, including conventional commit format and markdown-formatted PR body. Copy and paste directly into your terminal.

## Optimization Tips

If you experience inconsistent AI behavior:

- **Safety rules first** - put critical rules at the top of instructions
- **Hierarchical organization** - use global rules + project-specific additions
- **Keep it focused** - aim for under 300 lines of instructions per session
- **Move complexity to docs** - keep instructions concise

## Scripts

Utility scripts in [`scripts/`](./scripts/):

- **`git-safety.sh`** - prevents dangerous git/gh operations
- **`metrics-tracker.sh`** - development metrics tracking

## AI Safety and Command Protection

AI tools can accidentally perform dangerous operations. The `git-safety.sh` script prevents dangerous git and GitHub CLI operations.

### Installation

```bash
sudo cp scripts/git-safety.sh /etc/profile.d/git-safety.sh
sudo chmod +x /etc/profile.d/git-safety.sh
```

See [`scripts/git-safety.sh`](./scripts/git-safety.sh) for the full implementation and documentation.

### How It Works

**Git Protection:** Blocks dangerous operations (`commit`, `push`, `merge`) on the default branch. Safe operations (`status`, `log`, `diff`, `fetch`, `pull`) are allowed.

**GitHub CLI Protection:** Allowlist approach - only explicitly safe commands (`pr create`, `pr list`, `issue create`, etc.) are permitted. Dangerous operations (`pr merge`, `repo delete`) are blocked.

**Override when needed:** `command git push origin main` bypasses restrictions.

## Additional Resources

- [VS Code Copilot Documentation](https://code.visualstudio.com/docs/copilot/overview)
- [Customizing Copilot](https://code.visualstudio.com/docs/copilot/copilot-customization)

## Contributing

We welcome contributions! Submit issues or pull requests to improve these shared guidelines.

### Repository Structure

- `.github/copilot-instructions.md` - shared coding standards
- `README.md` - documentation and examples
- `.github/workflows/` - automation
- `scripts/` - utility scripts

**Guidelines:**
- Keep instructions focused on universal principles
- Regular review to prevent bloat
- Prioritize clarity, safety, and universal applicability
