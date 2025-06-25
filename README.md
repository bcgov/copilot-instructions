# BC Government Copilot Configuration

Shared VS Code configuration intended to accelerate and guide the use of GitHub Copilot (AI coding assistant) across BC Government projects.

## Structure

The `.github` directory contains two key files:

- `copilot-instructions.md` - ✏️ **Project-specific instructions**
  - This is your team's file to customize
  - Standard location recognized by all Copilot-enabled editors
  - Automatically included in every Copilot chat request
  - Add project-specific coding guidelines
  - Modify or remove references to upstream as needed

- `copilot-upstream.md` - 🔒 **BC Government managed guidelines**
  - Standard guidelines for BC Government projects
  - Maintained by the BC Government team
  - Do not modify this file directly
  - Updates will be managed through the upstream repository

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
