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

## Contributing

We value your input! We want to make contributing as easy and transparent as possible, whether it's:

* Reporting a bug
* Discussing the current state of the guidelines
* Submitting a feature or fix
* Proposing new features
* Becoming a maintainer

## AI Safety and Git Protection

**For BCGov AI Test Group Teams Only**

As AI coding assistants become more common in government development, protecting against accidental repository damage becomes critical. This section documents a git safety solution specifically designed for government DevOps teams working with AI.

### The Problem

AI coding assistants (GitHub Copilot and similar tools) operate with your credentials and can:
- **Push directly to main branches** (bypassing PR requirements)
- **Force push** to any branch (potentially losing work)
- **Delete branches** without understanding the consequences
- **Override branch protection rules** using your admin access

Traditional solutions like git hooks are impractical for teams managing 80+ repositories across multiple organizations.

### The Solution: Git Safety Function

A bash function that intercepts dangerous git operations while maintaining full functionality for normal development work.

#### Features

- **Dynamic default branch detection** - works on `main`, `master`, `develop`, or any naming convention
- **Lazy performance optimization** - only checks when needed (push operations)
- **Portable across repos** - no per-repository configuration required
- **Admin override available** - emergency access when needed

#### Implementation

Add this to your `~/.bashrc` or centralized bash configuration:

```bash
git() {
    local args="$*"
    local current_branch=$(command git branch --show-current 2>/dev/null)

    # Only apply restrictions when on main branch
    if [[ "$current_branch" = "main" ]]; then
        local first_cmd=$(echo "$args" | awk '{print $1}')

        # Define allowed commands on main branch
        local allowed_commands="status log diff show switch pull help"

        # Define deprecated commands with warnings
        local deprecated_commands="checkout branch"

        # Check for deprecated commands first
        if [[ " $deprecated_commands " == *" $first_cmd "* ]]; then
            echo "⚠️  DEPRECATED: '$first_cmd' is deprecated. Use modern alternatives:"
            case "$first_cmd" in
                "checkout") echo "   → Use 'git switch' instead" ;;
                "branch") echo "   → Use 'git switch' instead" ;;
            esac
            echo "   Proceeding anyway, but consider updating your workflow..."
        fi

        # Check if command is in allowlist
        if [[ " $allowed_commands " != *" $first_cmd "* ]]; then
            echo "🚨 BLOCKED: '$first_cmd' not allowed on main branch! Use feature branches."
            echo "💡 Try: git switch -c feat/your-feature"
            return 1
        fi
    fi

    # Run the normal git command
    $(command which git) "$@"
}
```

#### How It Works

1. **Intercepts all `git` commands** via function override
2. **Detects default branch dynamically** only when needed (push operations)
3. **Blocks dangerous operations** with clear error messages
4. **Allows safe operations** to pass through normally
5. **Uses `$(command which git)`** to call the real git binary

#### Admin Override: The `command` Workaround

When you need to perform admin operations (push to main, force push, etc.), use the `command` prefix:

```bash
# Normal git command (gets blocked)
git push origin main
# → 🚨 BLOCKED: Never push to default branch (main)! Use feature branches and PRs.

# Admin override (bypasses protection)
command git push origin main
# → Executes normally
```

**Why This Works:**
- **`command`** bypasses shell functions and aliases
- **`command git`** calls the real git binary directly
- **Your function never runs** when using `command`
- **Full admin access** when you need it

#### Installation

1. **Add the function** to your bashrc or centralized bash configuration
2. **Reload your shell** or source the file
3. **Test the protection** with `git push origin main` (should be blocked)
4. **Test admin override** with `command git push origin main` (should work)

#### Benefits for Government Teams

- **No per-repo configuration** - works immediately on all repositories
- **Performance optimized** - minimal overhead for normal operations
- **Portable** - works on any Linux/macOS system
- **Secure** - prevents AI from using your credentials destructively
- **Maintainable** - single function handles all protection logic

#### When to Use

- **AI coding assistants** (GitHub Copilot and similar tools)
- **Large repository portfolios** (50+ repos)
- **Cross-organizational development** (BCGov, multiple teams)
- **DevOps automation** (scripts, CI/CD, etc.)

#### Security Notes

- **This is credential-level protection** - prevents AI from bypassing your access
- **Not a replacement for branch protection rules** - use both for defense in depth
- **Personal use only** - don't share credentials with AI tools
- **Regular review** - periodically check what AI tools have access to

### Example Usage

```bash
# Setup
source ~/.bashrc  # or wherever you store the function

# Test protection
git push origin main
# → 🚨 BLOCKED: Never push to default branch (main)! Use feature branches and PRs.

# Test admin override
command git push origin main
# → Executes normally

# Normal development
git status          # → Works normally
git checkout -b feature  # → Works normally
git commit -m "feat: new feature"  # → Works normally
```

This solution provides the safety needed for AI-assisted development while maintaining the flexibility required for government DevOps operations.

## Additional Resources

- [VS Code Copilot Documentation](https://code.visualstudio.com/docs/copilot/overview)
- [Customizing Copilot](https://code.visualstudio.com/docs/copilot/copilot-customization)
- [Prompt Engineering Research](https://github.com/topics/prompt-engineering)
- [AI Instruction Best Practices](https://github.com/topics/ai-instructions)
