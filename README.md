# BC Government Copilot Configuration

Shared VS Code configuration intended to accelerate and guide the use of GitHub Copilot (AI coding assistant) across BC Government projects.

## Structure

The `.github` directory contains:
- `copilot-upstream.md` - 🔒 **Managed guidelines**
  - Maintained and versioned upstream
  - Non-default, needs to be referenced in VS Code settings
- `copilot-instructions.md` - ✏️ **Template only**
  - Basic structure for your team's customizations
  - Standard location recognized by Copilot

## Installation

Download the instructions to your repository:
```bash
mkdir -p .github
curl -Lo .github/copilot-upstream.md https://github.com/bcgov/copilot-instructions/releases/latest/download/copilot-upstream.md
```

Add the instructions to your VS Code configuration:
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

VS Code settings are available:
- Workspace, applying to just this project
  - `.vscode/settings.json` in your repository
- User, applying to all projects
  - Linux: `~/.config/Code/User/settings.json`
  - macOS: `~/Library/Application Support/Code/User/settings.json`
  - Windows: `%APPDATA%\Code\User\settings.json`

## Versioning

This repository uses GitHub releases for versioning. The `copilot-upstream.md` file is versioned through releases and can be tracked in your repository's dependencies through Renovate.

## Automatic Updates

To receive automatic updates to `copilot-upstream.md` visit [bcgov/renovate-config](https://github.com/bcgov/renovate-config) to onboard with Mend Renovate.

Renovate will:
- Monitor for new releases of these guidelines
- Create PRs to update your copy of `copilot-upstream.md`
- Respect your repository's merge requirements and schedule

To opt out of updates, simply delete `.github/copilot-upstream.md` from your repository.  Continue with `.github/copilot-instructions.md` as normal.

## Usage

1. For most projects, the default setup works well out of the box
2. Put your changes in `.github/copilot-instructions.md`
3. Recommend upstream changes at https://github.com/bcgov/copilot-instructions

## Additional Resources

- [VS Code Copilot Documentation](https://code.visualstudio.com/docs/copilot/overview)
- [Customizing Copilot](https://code.visualstudio.com/docs/copilot/copilot-customization)
- [Custom Instructions Documentation](https://code.visualstudio.com/docs/copilot/copilot-customization)
- [BC Government Development Guidelines](https://github.com/bcgov/vscode-settings)
