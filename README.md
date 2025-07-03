# Shared Copilot Instructions

Shared VS Code configuration intended to accelerate and guide the use of GitHub Copilot (AI coding assistant).

## Installation - All Workspaces (Recommended)

This configuration applies the upstream Copilot instructions globally across all VS Code workspaces. Separate `.github/copilot-upstream.md` files would not be required.

**Steps:**

1. **Download or update the upstream instructions centrally (e.g. home directory):**

  Copy `.github/copilot-upstream.md` to your home directory manually or using the commands below (Linux, macOS):

  ```bash
  mkdir -p ~/.git
  curl -Lo ~/.git/copilot-upstream.md https://raw.githubusercontent.com/bcgov/copilot-instructions/main/.github/copilot-upstream.md
  ```

2. **Configure VS Code to use the instructions:**

  File locations:

  - Linux: `~/.config/Code/User/settings.json`
  - macOS: `~/Library/Application Support/Code/User/settings.json`
  - Windows: `%APPDATA%\Code\User\settings.json`

  Add (or update) the following settings, using the **absolute path** to your central file:

  - **Manual method (Linux, macOS):**

    ```jsonc
    {
      "github.copilot.chat.codeGeneration.useInstructionFiles": true,
      "github.copilot.chat.codeGeneration.instructions": [
        {
          "file": "/home/<YOUR_USER_NAME>/.git/copilot-upstream.md"
        }
      ]
    }
    ```

  - **Manual method (Windows):**
    Edit your settings file manually and use double backslashes in the path, for example:

    ```jsonc
    {
      "github.copilot.chat.codeGeneration.useInstructionFiles": true,
      "github.copilot.chat.codeGeneration.instructions": [
        {
          "file": "C:\\Users\\<YOUR_USER_NAME>\\.git\\copilot-upstream.md"
        }
      ]
    }
    ```

  - **Programmatic method (Linux, macOS):**

    ```bash
    # Ensure your user settings file exists and is valid JSON
    SETTINGS="$HOME/.config/Code/User/settings.json"
    mkdir -p "$(dirname "$SETTINGS")"
    [ -s "$SETTINGS" ] || echo '{}' > "$SETTINGS"

    # Add or update Copilot instruction settings using jq with absolute path
    jq --arg file "$HOME/.git/copilot-upstream.md" '
      . + {
        "github.copilot.chat.codeGeneration.useInstructionFiles": true,
        "github.copilot.chat.codeGeneration.instructions": [ { "file": $file } ]
      }
    ' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
    ```

    **Note: this will fail if there are any non-standard JSON misconfigurations, like a trailing comma.**

**Caveats:**

- Only an absolute path can be used successfully.
- The absolute path must exist and be accessible from your machine.
- If you sync your VS Code settings across devices, ensure the path is valid on each device.
- If the path is not valid there will be no effect. It is harmless, but useless.

**Result:**

- Copilot will use your central `.github/copilot-upstream.md` instructions for every workspace you open in VS Code.

## Installation - Single Repository (Project-Specific)

This will affect only the current repository.  It is useful when projects have conflicting or incompatible requirements.

1. **Download the upstream instructions to your repository:**

  Copy `.github/copilot-upstream.md` manually or use the commands below (Linux, macOS).  Make sure to commit this file to your repository.

  ```bash
  mkdir -p .github
  curl -Lo .github/copilot-upstream.md https://raw.githubusercontent.com/bcgov/copilot-instructions/main/.github/copilot-upstream.md
  ```

2. **Configure VS Code to use the instructions:**

  Configure VS Code Workspace settings (`.vscode/settings.json`) manually **or** programmatically:

  - **Manual method (Linux, macOS):**

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

  - **Manual method (Windows):**

    ```jsonc
    {
      "github.copilot.chat.codeGeneration.useInstructionFiles": true,
      "github.copilot.chat.codeGeneration.instructions": [
        {
          "file": ".github\\copilot-upstream.md"
        }
      ]
    }
    ```

  - **Programmatic method (Linux, macOS):**
    Use `jq` to add or update the Copilot instruction settings:

    ```bash
    # Ensure .vscode/settings.json exists and is valid JSON
    mkdir -p .vscode
    [ -s .vscode/settings.json ] || echo '{}' > .vscode/settings.json

    # Add or update Copilot instruction settings using jq
    jq '.
      + {"github.copilot.chat.codeGeneration.useInstructionFiles": true}
      + {"github.copilot.chat.codeGeneration.instructions": [{"file": ".github/copilot-upstream.md"}]}
    ' .vscode/settings.json > .vscode/settings.tmp && mv .vscode/settings.tmp .vscode/settings.json
    ```
## Usage

1. For most projects, the default setup works well out of the box.
2. Put your custom changes in `.github/copilot-instructions.md`.
3. Recommend upstream changes at https://github.com/bcgov/copilot-instructions.

## Additional Resources

- [VS Code Copilot Documentation](https://code.visualstudio.com/docs/copilot/overview)
- [Customizing Copilot](https://code.visualstudio.com/docs/copilot/copilot-customization)
