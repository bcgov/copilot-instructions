# Shared Copilot Instructions

Shared VS Code configuration intended to accelerate and guide the use of GitHub Copilot (AI coding assistant).

## Structure

The `.github` directory contains:
- `copilot-upstream.md` - 🔒 **Managed guidelines**
  - Maintained and versioned upstream
  - Non-default, needs to be referenced in VS Code settings
- `copilot-instructions.md` - ✏️ **Template only**
  - Basic structure for your team's customizations
  - Standard location recognized by Copilot

## Installation

Download the upstream instructions to your repository:
```bash
mkdir -p .github
curl -Lo .github/copilot-upstream.md https://raw.githubusercontent.com/bcgov/copilot-instructions/main/.github/copilot-upstream.md
```

Optionally, download the local instructions template to your repository:
```bash
mkdir -p .github
curl -Lo .github/copilot-instructions.md https://raw.githubusercontent.com/bcgov/copilot-instructions/main/.github/copilot-instructions.md
```

Add the upstream instructions to VS Code Workspace settings (`.vscode/settings.json`):
```jsonc
{
    "github.copilot.chat.codeGeneration.useInstructionFiles": true,
    "github.copilot.chat.codeGeneration.instructions": [
        {
            "file": ".github/copilot-upstream.md"
        }
    ]
}
```

This can be done programmatically with jq:
```
# Ensure .vscode/settings.json exists and is valid JSON
mkdir -p .vscode
[ -s .vscode/settings.json ] || echo '{}' > .vscode/settings.json

# Add or update Copilot instruction settings using jq
jq '. 
  + {"github.copilot.chat.codeGeneration.useInstructionFiles": true}
  + {"github.copilot.chat.codeGeneration.instructions": [{"file": ".github/copilot-upstream.md"}]}
' .vscode/settings.json > .vscode/settings.tmp && mv .vscode/settings.tmp .vscode/settings.json
```


Optionally, enable these settings across all projects:
- Linux: `~/.config/Code/User/settings.json`
- macOS: `~/Library/Application Support/Code/User/settings.json`
- Windows: `%APPDATA%\Code\User\settings.json`

## Versioning and Automatic Updates

Onboard with [Mend Renovate](https://github.com/bcgov/renovate-config) to receive automatic updates to `copilot-upstream.md`.

Renovate will:
- Monitor for new releases of these guidelines
- Create PRs to update your copy of `copilot-upstream.md`
- Respect your repository's merge requirements and schedule
- Provide dependency updates for all other packages

To stop using upstream config simply delete `.github/copilot-upstream.md` and continue with `.github/copilot-instructions.md` as normal.

## Usage

1. For most projects, the default setup works well out of the box
2. Put your changes in `.github/copilot-instructions.md`
3. Recommend upstream changes at https://github.com/bcgov/copilot-instructions

## Additional Resources

- [VS Code Copilot Documentation](https://code.visualstudio.com/docs/copilot/overview)
- [Customizing Copilot](https://code.visualstudio.com/docs/copilot/copilot-customization)
