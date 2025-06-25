# BC Government Copilot Configuration

Shared VS Code configuration intended to accelerate and guide the use of GitHub Copilot (AI coding assistant) across BC Government projects.

## Structure

The `.github` directory contains two key files:

- `copilot-instructions.md` - ✏️ **Project-specific instructions**
  - This is your team's file to customize
  - Add project-specific coding guidelines
  - Modify or remove references to upstream as needed
  - VS Code automatically uses this for Copilot suggestions

- `copilot-upstream.md` - 🔒 **BC Government managed guidelines**
  - Standard guidelines for BC Government projects
  - Maintained by the BC Government team
  - Do not modify this file directly
  - Updates will be managed through the upstream repository

## Required VS Code Settings

To enable Copilot instructions in your workspace, make sure you have the following setting enabled in your VS Code settings:

```jsonc
{
    "github.copilot.chat.codeGeneration.useInstructionFiles": true
}
```

You can add this to either:
- User Settings (applies to all projects)
- Workspace Settings (applies to just this project)

## Usage

1. For most projects, the default setup works well out of the box
2. To customize Copilot behavior for your project:
   - Edit `copilot-instructions.md`
   - Add your project-specific guidelines
   - Keep or remove the reference to upstream guidelines as needed
3. To update BC Government guidelines:
   - Pull the latest changes from the upstream repository
   - The `copilot-upstream.md` file will be updated automatically

## Additional Resources

- [VS Code Copilot Documentation](https://code.visualstudio.com/docs/copilot/overview)
- [Customizing Copilot](https://code.visualstudio.com/docs/copilot/copilot-customization)
- [Custom Instructions Documentation](https://code.visualstudio.com/docs/copilot/copilot-customization)
- [BC Government Development Guidelines](https://github.com/bcgov/vscode-settings)
