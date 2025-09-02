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

- Reporting a bug
- Discussing the current state of the guidelines
- Submitting a feature or fix
- Proposing new features
- Becoming a maintainer

## AI Instruction Complexity Analysis

This repository includes a metrics tool (`metrics-tracker.sh`) that analyzes AI instruction complexity based on research-backed principles.

### Research Basis for Metrics

#### Line Count Thresholds (200/300 lines)
- **Cognitive Load Management**: Research shows humans can effectively process ~7±2 chunks of information at once
- **Instruction Maintenance**: Longer files become harder to maintain and update effectively
- **AI Processing**: Large instruction sets can overwhelm AI context windows and reduce effectiveness

#### Section Count Thresholds (15/25 sections)
- **Information Architecture**: Cognitive science research indicates optimal organization limits
- **Navigation Efficiency**: Too many sections can make instructions hard to navigate and reference
- **Maintenance Burden**: Over-organization increases update complexity without proportional benefits

#### Decision Point Thresholds (5/10 rules)
- **AI Flexibility**: Too many rigid rules can reduce AI adaptability and creativity
- **Human Comprehension**: Complex rule sets become harder for teams to understand and maintain
- **Instruction Effectiveness**: Research shows focused, principle-based guidance outperforms rigid constraints

### Academic Sources

- **Prompt Engineering Research**: Studies on LLM instruction effectiveness and complexity management
- **Cognitive Load Theory**: Research on human information processing and organization
- **AI-Human Interaction**: Studies on effective communication between humans and AI systems
- **Software Engineering**: Research on documentation complexity and maintainability

### Industry Standards

- **Microsoft Copilot Research**: Studies on effective AI coding assistance
- **GitHub AI Guidelines**: Best practices for AI instruction management
- **Prompt Engineering Frameworks**: Industry standards for AI instruction design

### Using the Metrics Tool

```bash
# Analyze instruction complexity
./metrics-tracker.sh .github/copilot-upstream.md

# Get actionable insights and recommendations
# Tool provides warnings for excessive complexity
# Helps maintain instruction quality and effectiveness
```

## Additional Resources

- [VS Code Copilot Documentation](https://code.visualstudio.com/docs/copilot/overview)
- [Customizing Copilot](https://code.visualstudio.com/docs/copilot/copilot-customization)
- [Prompt Engineering Research](https://github.com/topics/prompt-engineering)
- [AI Instruction Best Practices](https://github.com/topics/ai-instructions)
