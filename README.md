# Shared Copilot Instructions

Shared VS Code configuration to accelerate and guide the use of GitHub Copilot, an AI coding assistant.

## Installation

### All Workspaces (Recommended)

This configuration applies the upstream Copilot instructions globally across all VS Code workspaces.

1. **Download or update the upstream instructions centrally**

   Copy `.github/copilot-upstream.md` to your home directory manually or using the commands below (Linux, macOS).

   ```bash
   mkdir -p ~/.config
   curl -Lo ~/.config/copilot-upstream.md https://raw.githubusercontent.com/bcgov/copilot-instructions/main/.github/copilot-upstream.md
   ```

2. **Configure VS Code to use the instructions**

   Create or update `settings.json`, using an **absolute path** to your file.

   - **Manual method (Linux, macOS)**

     Suggested location: `~/.config/Code/User/settings.json`

     ```jsonc
     {
       "github.copilot.chat.codeGeneration.useInstructionFiles": true,
       "github.copilot.chat.codeGeneration.instructions": [
         {
           "file": "/home/<YOUR_USER_NAME>/.config/copilot-upstream.md"
         }
       ]
     }
     ```

   - **Manual method (Windows)**

     Suggested location: `%APPDATA%\Code\User\settings.json`

     ```jsonc
     {
       "github.copilot.chat.codeGeneration.useInstructionFiles": true,
       "github.copilot.chat.codeGeneration.instructions": [
         {
           "file": "C:\\Users\\<YOUR_USER_NAME>\\.config\\copilot-upstream.md"
         }
       ]
     }
     ```

   - **Programmatic method (Linux)**

     ```bash
     SETTINGS="$HOME/.config/Code/User/settings.json"
     mkdir -p "$(dirname "$SETTINGS")"
     [ -s "$SETTINGS" ] || echo '{}' > "$SETTINGS"

     jq --arg file "$HOME/.config/copilot-upstream.md" '
       . + {
         "github.copilot.chat.codeGeneration.useInstructionFiles": true,
         "github.copilot.chat.codeGeneration.instructions": [ { "file": $file } ]
       }
     ' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
     ```

   - **Programmatic method (macOS)**

     ```bash
     SETTINGS="$HOME/Library/Application\ Support/Code/User/settings.json"
     mkdir -p "$(dirname "$SETTINGS")"
     [ -s "$SETTINGS" ] || echo '{}' > "$SETTINGS"

     jq --arg file "$HOME/.config/copilot-upstream.md" '
       . + {
         "github.copilot.chat.codeGeneration.useInstructionFiles": true,
         "github.copilot.chat.codeGeneration.instructions": [ { "file": $file } ]
       }
     ' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
     ```

   **Note: Programmatic methods only work for properly formatted JSON in `settings.json`. VS Code allows inconsistencies, while `jq` does not.**

### Single Repository

This will affect only the current repository. It is useful when projects have conflicting or incompatible requirements.

1. **Download the upstream instructions to your repository**

   Copy `.github/copilot-upstream.md` manually or use the commands below (Linux, macOS). Make sure to commit this file to your repository.

   ```bash
   mkdir -p .github
   curl -Lo .github/copilot-upstream.md https://raw.githubusercontent.com/bcgov/copilot-instructions/main/.github/copilot-upstream.md
   ```

2. **Configure VS Code to use the instructions**

   Configure VS Code Workspace settings (`.vscode/settings.json`) manually **or** programmatically:

   - **Manual method (Linux, macOS)**

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

   - **Manual method (Windows)**

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

   - **Programmatic method (Linux, macOS)**

     Use `jq` to add or update the Copilot instruction settings:

     ```bash
     mkdir -p .vscode
     [ -s .vscode/settings.json ] || echo '{}' > .vscode/settings.json

     jq '.
       + {"github.copilot.chat.codeGeneration.useInstructionFiles": true}
       + {"github.copilot.chat.codeGeneration.instructions": [{"file": ".github/copilot-upstream.md"}]}
     ' .vscode/settings.json > .vscode/settings.tmp && mv .vscode/settings.tmp .vscode/settings.json
     ```

### Notes

**Absolute Paths:**

Only absolute paths work in global `settings.json`.

**Synchronization:**

If VS Code is synchronizing settings across devices, make sure this file is present on those devices.

**Safety/Reliability:**

If the path is not valid, there will be no effect. It is harmless.

**Updates:**

Replace your copy of this file periodically to receive updated configurations.

**Customization:**

Put your changes in a separate file. The default repo location is `.github/copilot-instructions.md`.

**Usage:**

For most projects, the default setup works well out of the box.

## Examples

### Creating Pull Requests with Copilot and GitHub CLI

To quickly create a pull request from the terminal, ask Copilot:

> "Give me a PR command using gh cli."



Copilot will generate a single command block that follows the shared instructions in `.github/copilot-upstream.md`, including a conventional commit title and a markdown-formatted PR body.

Just copy and paste the command block into your terminal—no manual editing required.

## Optimization Tips

If you experience inconsistent AI behavior, consider these common issues:

### Instruction Overload Symptoms
- Steps not followed reliably
- Critical safety rules ignored (e.g., accidental pushes to main)
- Previously working commands suddenly failing
- AI decision paralysis with conflicting rules

### Solutions
- **Safety rules first**: Put critical rules (like git workflow protections) at the top of your instructions
- **Hierarchical organization**: Use global rules + project-specific additions rather than duplicating everything
- **Keep it focused**: Aim for under 300 total lines of instructions per session
- **Move complexity to docs**: Put detailed workflows in documentation, keep instructions concise

The shared instructions in this repository follow these principles with safety-critical rules prioritized first.

## AI Safety and Command Protection

**CRITICAL**: AI tools can accidentally perform dangerous operations like pushing to the default branch or merging PRs, causing production issues. These functions prevent dangerous git and GitHub CLI operations while educating users about modern practices.

### Installation

**System-wide installation** (protects all users including AI tools):

1. **Copy the safety functions** from the version-controlled file:
   ```bash
   sudo cp git-safety.sh /etc/profile.d/git-safety.sh
   sudo chmod +x /etc/profile.d/git-safety.sh
   ```

2. **Or manually create** the file `/etc/profile.d/git-safety.sh` and copy the contents from [`git-safety.sh`](./git-safety.sh) in this repository.

> **Why `/etc/profile.d/` instead of `~/.bashrc`?**
> - **AI tools** often run in non-interactive shells that don't source `~/.bashrc`
> - **System-wide protection** ensures all users and processes are protected
> - **Automatic sourcing** - files in `/etc/profile.d/` are sourced by all bash sessions
> - **Root access required** - prevents accidental removal by individual users

> **Why version control the safety functions?**
> - **Track changes** and improvements to the safety logic
> - **Easy updates** when new safety features are added
> - **Documentation** of what the functions do and why
> - **Collaboration** on safety improvements

**Latest version** (see [`git-safety.sh`](./git-safety.sh) for the most current version):

```bash
#!/bin/bash

# Git Safety Function - Prevents dangerous operations by AI and all users
# This file is automatically sourced by all bash sessions on the system

git() {
    local args="$*"

    # Skip safety checks during tab completion only
    if [[ -n "$COMP_LINE" || -n "$COMP_POINT" ]]; then
        $(command which git) "$@"
        return
    fi

    local current_branch=$(command git branch --show-current 2>/dev/null)
    local default_branch=$(command git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' 2>/dev/null || echo main)

    if [[ "$current_branch" = "$default_branch" ]]; then
        local first_cmd=$(echo "$args" | awk '{print $1}')
        local allowed_commands="branch checkout config diff fetch help log pull restore show status switch version"

        if [[ " $allowed_commands " != *" $first_cmd "* ]]; then
            echo "🚨 BLOCKED: '$first_cmd' not allowed on default branch ($default_branch)! Use feature branches."
            return 1
        fi
    fi

    $(command which git) "$@"
}

# GitHub CLI Safety Function - Prevents dangerous operations by AI and all users
# Uses allowlist approach: only explicitly allowed commands are permitted
gh() {
    local args="$*"

    # Skip safety checks during tab completion only
    if [[ -n "$COMP_LINE" || -n "$COMP_POINT" ]]; then
        $(command which gh) "$@"
        return
    fi

    # Parse command more robustly - only look at the first two words
    local first_cmd=$(echo "$args" | awk '{print $1}')
    local second_cmd=$(echo "$args" | awk '{print $2}')
    local full_command="$first_cmd $second_cmd"

    # Define allowlist of safe commands
    local allowed_commands=(
        # Safe standalone commands
        "auth"
        "config"
        "version"
        "help"
        "browse"
        "search"
        "status"
        "completion"
        "extension"
        # Safe PR operations (close/reopen are easily reversible)
        "pr create"
        "pr list"
        "pr view"
        "pr status"
        "pr checkout"
        "pr diff"
        "pr close"
        "pr reopen"
        # Safe issue operations (close/reopen are easily reversible)
        "issue create"
        "issue list"
        "issue view"
        "issue status"
        "issue close"
        "issue reopen"
    )

    # Check if command is in allowlist
    local is_allowed=false
    for allowed in "${allowed_commands[@]}"; do
        if [[ "$full_command" == "$allowed" ]]; then
            is_allowed=true
            break
        fi
    done

    # Execute if allowed, block if not
    if [[ "$is_allowed" == true ]]; then
        $(command which gh) "$@"
    else
        echo "🚨 BLOCKED: 'gh $full_command' not in allowlist! Use GitHub UI for management."
        return 1
    fi
}

export -f git gh
```

### How It Works

**Git Protection:**
- **Only restricts operations on default branch** - other branches work normally
- **Uses allowlist approach** - only explicitly allowed commands work on the default branch
- **Blocks dangerous operations** like `commit`, `push`, `merge`

**GitHub CLI Protection:**
- **Allowlist approach** - only explicitly allowed commands are permitted
- **Future-proof** - new dangerous commands are automatically blocked
- **Blocks dangerous operations** like `gh pr merge`, `gh repo delete`, `gh secret list`
- **Allows safe operations** like `gh pr list`, `gh issue create`, `gh browse`

### Example Usage

```bash
# Git - On default branch - these are blocked
git commit -m "fix"        # → 🚨 BLOCKED: 'commit' not allowed on default branch!

# GitHub CLI - These are blocked
gh pr merge 123            # → 🚨 BLOCKED: 'gh pr merge' not in allowlist!
gh repo delete test-repo   # → 🚨 BLOCKED: 'gh repo delete' not in allowlist!
gh secret list             # → 🚨 BLOCKED: 'gh secret list' not in allowlist!

# These are allowed
gh pr list                 # → Works (allowed)
gh issue create --title "Test"  # → Works (allowed)
gh browse                  # → Works (allowed)

# Admin override (when needed)
command git push origin main  # → Bypasses all restrictions
```

This solution provides comprehensive protection against AI tools performing dangerous operations while educating users about modern practices.

## Additional Resources

- [VS Code Copilot Documentation](https://code.visualstudio.com/docs/copilot/overview)
- [Customizing Copilot](https://code.visualstudio.com/docs/copilot/copilot-customization)
- [Prompt Engineering Research](https://github.com/topics/prompt-engineering)
- [AI Instruction Best Practices](https://github.com/topics/ai-instructions)

## Contributing

We value your input! We want to make contributing as easy and transparent as possible, whether it's:

* Reporting a bug
* Discussing the current state of the guidelines
* Submitting a feature or fix
* Proposing new features
* Becoming a maintainer
