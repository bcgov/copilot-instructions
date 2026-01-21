# Shared Copilot Instructions

Shared VS Code configuration to accelerate and guide the use of GitHub Copilot, an AI coding assistant.

## Installation

### All Workspaces (Recommended)

Apply the shared Copilot instructions globally across all VS Code workspaces.

#### Option 1: Clone Repository (Recommended)

Clone once, then update anytime with `git pull`:

```bash
git clone https://github.com/bcgov/copilot-instructions.git ~/Repos/copilot-instructions
```

Configure VS Code `settings.json` with the path to the cloned file:

1. Open VS Code
2. Press `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (macOS)
3. Type "Preferences: Open User Settings (JSON)" and select it
4. Add the following (replace `<USERNAME>` with your actual username):

```jsonc
{
  "github.copilot.chat.codeGeneration.useInstructionFiles": true,
  "github.copilot.chat.codeGeneration.instructions": [
    { "file": "/home/<USERNAME>/Repos/copilot-instructions/.github/copilot-instructions.md" }
  ]
}
```

**Path examples by OS:**
- Linux: `/home/<USERNAME>/Repos/copilot-instructions/.github/copilot-instructions.md`
- macOS: `/Users/<USERNAME>/Repos/copilot-instructions/.github/copilot-instructions.md`
- Windows: `C:\\Users\\<USERNAME>\\Repos\\copilot-instructions\\.github\\copilot-instructions.md`

**To update:** Navigate to the cloned repo and run `git pull`

#### Option 2: Download with curl

Quick one-time download (re-run manually to update):

```bash
mkdir -p ~/.config
curl -Lo ~/.config/copilot-instructions.md \
  https://raw.githubusercontent.com/bcgov/copilot-instructions/main/.github/copilot-instructions.md
```

Configure VS Code `settings.json` (use command palette as described above):

```jsonc
{
  "github.copilot.chat.codeGeneration.useInstructionFiles": true,
  "github.copilot.chat.codeGeneration.instructions": [
    { "file": "/home/<USERNAME>/.config/copilot-instructions.md" }
  ]
}
```

**Path examples by OS:**
- Linux: `/home/<USERNAME>/.config/copilot-instructions.md`
- macOS: `/Users/<USERNAME>/.config/copilot-instructions.md`
- Windows: `C:\\Users\\<USERNAME>\\.config\\copilot-instructions.md`

### Single Repository

For projects with specific requirements, download the instructions directly into your repository:

```bash
mkdir -p .github
curl -Lo .github/copilot-instructions.md \
  https://raw.githubusercontent.com/bcgov/copilot-instructions/main/.github/copilot-instructions.md
```

Configure `.vscode/settings.json`:

```jsonc
{
  "github.copilot.chat.codeGeneration.useInstructionFiles": true,
  "github.copilot.chat.codeGeneration.instructions": [
    { "file": ".github/copilot-instructions.md" }
  ]
}
```

### Notes

- **Absolute paths required** for global `settings.json`
- **Invalid paths are harmless** - if the file doesn't exist, there's no effect
- **VS Code sync** - ensure the file exists on all synced devices
- **Customization** - add project-specific rules in your own `.github/copilot-instructions.md`

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

- `.github/copilot-instructions.md` - shared BCGov coding standards (distributed to teams)
- `README.md` - documentation and examples
- `.github/workflows/` - automation
- `scripts/` - utility scripts

**Guidelines:**
- Keep instructions focused on universal principles
- Regular review to prevent bloat
- Prioritize clarity, safety, and universal applicability
