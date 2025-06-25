# BC Government Copilot Configuration

Shared VS Code configuration intended to accelerate and guide the use of GitHub Copilot (AI coding assistant) across BC Government projects.

## Structure

The `.github` directory contains:

- `copilot-upstream.md` - 🔒 **BC Government managed guidelines**
  - Standard guidelines for BC Government projects
  - Maintained by the BC Government team
  - Do not modify this file directly
  - Updates managed through releases

We also provide a template for your project-specific instructions:
- `copilot-instructions.md` - ✏️ **Template for project teams**
  - Basic structure for your team's customizations
  - Copy and modify freely for your needs
  - Standard location recognized by Copilot
  - Can reference or ignore upstream guidelines
  - Copy our file or create your own

## Required VS Code Settings

This repository uses two instruction files:
- `copilot-instructions.md` - Project-specific customizations
- `copilot-upstream.md` - BC Government guidelines

To ensure both files are used, configure your VS Code settings:

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
Note: `.github/copilot-instructions.md` is referenced by default and does not need to be included in the above config.

You can add these settings to either:
- User Settings (applies to all projects)
- Workspace Settings (applies to just this project)

Note: The workspace already includes these settings in `.vscode/settings.json`

## Installation

1. Copy the instruction files to your project:
```bash
# Download latest config
mkdir -p .github
curl -Lo .github/copilot-upstream.md https://github.com/bcgov/copilot-instructions/releases/latest/download/copilot-upstream.md
```

2. Update VS Code settings:

If you don't have a `.vscode/settings.json` file yet, create one. If you do, manually add these settings to the existing file:

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

You can add these settings at either the:
- User level: `~/Library/Application Support/Code/User/settings.json` (macOS)
- Workspace level: `.vscode/settings.json` in your project

Remember: Never overwrite your existing `.vscode/settings.json` file - always merge in new settings manually to preserve your existing configuration.

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
2. To customize Copilot behavior for your project:
   - Edit `copilot-instructions.md`
   - Add your project-specific guidelines
   - Keep or remove the reference to upstream guidelines as needed
3. To update BC Government guidelines:
   - Pull the latest changes from the upstream repository
   - The `copilot-upstream.md` file will be updated automatically

## Maintaining Instructions

### For BC Government Teams
- `copilot-upstream.md` is managed centrally
- Updates will flow to downstream repositories
- Do not modify this file in your projects

### For Project Teams
- Start with the provided `copilot-instructions.md` template
- Customize it for your project needs
- You can:
  - Add your own guidelines
  - Remove upstream references
  - Override specific guidelines

## Additional Resources

- [VS Code Copilot Documentation](https://code.visualstudio.com/docs/copilot/overview)
- [Customizing Copilot](https://code.visualstudio.com/docs/copilot/copilot-customization)
- [Custom Instructions Documentation](https://code.visualstudio.com/docs/copilot/copilot-customization)
- [BC Government Development Guidelines](https://github.com/bcgov/vscode-settings)
