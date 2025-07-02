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

## Installation - Single Repository

Download the upstream instructions to your repository:
```bash
mkdir -p .github
curl -Lo .github/copilot-upstream.md https://raw.githubusercontent.com/bcgov/copilot-instructions/main/.github/copilot-upstream.md
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

## Installation - Across All Workspaces (User Level)

If you want to use the same upstream Copilot instructions for all your projects, you can reference the file by absolute path in your **VS Code user settings**. This way, you don’t need to copy `.github/copilot-upstream.md` into every repository.

**Steps for Linux and macOS:**

1. Download or update the upstream instructions in a central location (e.g., your home directory):

    ```bash
    mkdir -p ~/.git
    curl -Lo ~/.git/copilot-upstream.md https://raw.githubusercontent.com/bcgov/copilot-instructions/main/.github/copilot-upstream.md
    ```

2. Open your VS Code **user settings** file:

    - Linux: `~/.config/Code/User/settings.json`
    - macOS: `~/Library/Application Support/Code/User/settings.json`
    - Windows: `%APPDATA%\Code\User\settings.json`

3. Add (or update) the following settings, using the **absolute path** to your central file:

    ```jsonc
    "github.copilot.chat.codeGeneration.useInstructionFiles": true,
    "github.copilot.chat.codeGeneration.instructions": [
        {
            "file": "<ABSOLUTE_PATH>/.github/copilot-upstream.md"
        }
    ]
    ```

**Steps for Windows:**

1. Install Linux

2. See [Steps for Linux and macOS](#steps-for-linux-and-macos)

**Notes:**
- Windows paths require double backslashes (`\\`), since they are being escaped.
    
**Caveats:**
- Only an absolute path can be used successfully.
- The absolute path must exist and be accessible from your machine.
- If you sync your VS Code settings across devices, ensure the path is valid on each device.
- If the path is not valid there will be no effect.  It is harmless, but useless.

**Result:**  
- Copilot will use your central `.github/copilot-upstream.md` instructions for every workspace you open in VS Code.

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

## Release Process for Upstream Maintainers

To ensure downstream repositories receive automatic updates via Renovate:

1. **Always use the `release-create.yml` workflow to create a new release.**
    - This workflow will automatically:
      - Determine the next semantic version using Conventional Commits.
      - Copy the entire contents of `.github/copilot-upstream.md` as the release notes body.
      - Tag and title the release with the new version.
    - **Do _not_ create releases manually or with any other workflow.**
    - Do **not** add extra headings or text—only the raw Markdown content of the file is used.
2. **Publish the release using the workflow.**

> **Warning:**
> Manual releases or releases created by other workflows will be detected and flagged. Only releases created by the designated workflow are valid.

> **Note:**
> Downstream repositories will receive a Renovate PR that fully replaces their `.github/copilot-upstream.md` file with the content from your release notes.

## Additional Resources

- [VS Code Copilot Documentation](https://code.visualstudio.com/docs/copilot/overview)
- [Customizing Copilot](https://code.visualstudio.com/docs/copilot/copilot-customization)
