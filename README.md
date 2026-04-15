# Copilot Instructions

Guidelines and tooling to help developers effectively use GitHub Copilot while maintaining security and quality standards.

> [!IMPORTANT]
> GitHub enforces a **4,000 character limit** for global Copilot Instructions. All changes to the shared `.github/copilot-instructions.md` MUST stay within this limit to remain compatible with GitHub's organizational settings.

## What's Included

- **[Copilot Instructions](/.github/copilot-instructions.md)** - Behavioral guidelines and coding standards that you can load into Copilot Chat.
- **[Skills](/.github/skills)** - Autonomous workflow playbooks loaded on-demand by VS Code Copilot.
- **[Personalized Profiles](/.github/profiles)** (optional) - Templates to merge your personal style with shared standards.
- **Safety Tooling** (optional) - Git hooks and shell wrappers that enforce the instructions' safety rules.
- **Git Configuration Setup** (optional) - Recommended settings, global gitignore, and user configuration.

## Quick Start: Install Copilot Instructions

### Option 1: Global Context (Recommended for Chat)

Copy the instructions to your home directory and reference them in every chat:

```bash
curl -Lo ~/.copilot.md \
  https://raw.githubusercontent.com/bcgov/copilot-instructions/main/.github/copilot-instructions.md
```

Then start each chat with: `@~/.copilot.md`

### Option 2: Personalized Profiles (Highly Recommended)

If you want to maintain your own personality settings or technical preferences without polluting the shared standards, use a personalized profile.

1.  **Clone this repo** locally.
2.  **Create your profile:** Create a file in `.github/profiles/your-GITHUB-id.md` (use `DerekRoberts.md` as a template).
3.  **Bundle and install:** Run the bundle script:
    ```bash
    ./scripts/bundle.sh ~/.copilot.md
    ```
    *The script automatically detects your GitHub ID, validates Org-compliance, and bundles everything into your destination file.*

### Option 3: Per-Project Instructions

For integrated project-level VS Code Copilot support:

```bash
mkdir -p .copilot
curl -Lo .copilot/instructions \
  https://raw.githubusercontent.com/bcgov/copilot-instructions/main/.github/copilot-instructions.md
```

## How Skills Work

Copy skills into your project's `.github/skills/` folder. VS Code Copilot discovers and loads them on-demand when relevant:

```bash
curl -Lo .github/skills/issue-worktree/SKILL.md --create-dirs \
   https://raw.githubusercontent.com/bcgov/copilot-instructions/main/.github/skills/issue-worktree/SKILL.md
```

**Instructions** and **skills** are both placed under `.github/` but behave differently:

| | Instructions | Skills |
|---|---|---|
| **Loading** | Always-on — injected into every chat | On-demand — loaded only when relevant |
| **Purpose** | Standing rules and coding standards | Step-by-step workflows for specific tasks |
| **Trigger** | Automatic | Natural language request |

Skills are not slash commands. You invoke them by describing the job in plain language in Chat.

> [!NOTE]
> These skills work across multiple AI coding assistants. VS Code Copilot, Kilo Code, and Google Antigravity all support the same `.github/skills/` path. For other tools, create a symlink:
> ```bash
> ln -s /path/to/copilot-instructions/.github/skills ~/.gemini/antigravity/skills
> ```

## Safety Setup (Recommended)

The Copilot instructions tell the AI "never push to main", "never merge PRs", and "never run git config." This installer enforces those rules with git hooks and shell wrappers:

### Option 1: Quick Install (curl)
```bash
curl -sSL https://raw.githubusercontent.com/bcgov/copilot-instructions/main/scripts/install-hooks.sh | bash
```

### Option 2: Clone and Run
```bash
git clone https://github.com/bcgov/copilot-instructions.git
cd copilot-instructions
./scripts/install-hooks.sh
```

**What it installs:**
1. **Global Git Hooks** (all repos on your machine)
2. **GitHub CLI Safety** (blocks `gh pr merge`, etc.)
3. **Git Config Protection** (blocks AI from running `git config`)

## Optional Enhancements

### Git Configuration Setup

Configure Git with recommended settings from core Git developers:

```bash
curl -sSL https://raw.githubusercontent.com/bcgov/copilot-instructions/main/scripts/git-setup.sh | bash
```

## Attribution

The Behavioral Guidelines section in our copilot instructions is adapted from [CLAUDE.md](https://github.com/forrestchang/andrej-karpathy-skills/blob/main/CLAUDE.md) by Forrest Chang.
The recommended Git configuration settings in `git-setup.sh` are based on [How Git core developers configure Git](https://blog.gitbutler.com/how-git-core-devs-configure-git) by GitButler.

## Contributing

We welcome contributions! Submit issues or pull requests to improve these shared guidelines.
