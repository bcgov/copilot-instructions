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
    ./scripts/bundle.sh <destination_file> [GitHubID]
    ```
    *If you omit `GitHubID`, the script automatically detects it, verifies that your profile exists, warns if the bundled output exceeds GitHub's 4,000 character limit, and bundles everything into your destination file.*

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

For example:
> **You:** "Can you run a security review on the auth module?"
> **Copilot:** *loads security-review skill* "I'll scan the auth module for vulnerabilities..."

> [!NOTE]
> Global agent skills are physically installed to the standard user-level agent skills directory: `~/.agents/skills/`.
> This directory is automatically searched by VS Code Copilot to load skills globally across all workspaces.

## Safety Setup (Recommended)

The Copilot instructions tell the AI "never push to main", "never merge PRs", and "never run git config." This installer enforces those rules with git hooks and shell wrappers:

### Option 1: Quick Install (curl)
```bash
curl -sSL https://raw.githubusercontent.com/bcgov/copilot-instructions/main/scripts/setup.sh | bash
```

### Option 2: Clone and Run
```bash
git clone https://github.com/bcgov/copilot-instructions.git
cd copilot-instructions
./scripts/setup.sh
```

### What it installs:

1. **Global Git Hooks**: Pre-commit and pre-push hooks that scan for secrets and prevent direct pushes to protected branches (e.g., `main`).
2. **Shell Safety Functions**: Clean, non-exported shell-level safety functions (`git`, `gh`, `npm`, `npx`) injected into `~/.bashrc` to prevent AI agent mistakes while remaining transparent and instantly bypassable for human developers.

#### Blocked Operations & Rationale

| Tool | Blocked Command | Rationale |
| :--- | :--- | :--- |
| **Git** | `tag` | Prevents AI from autonomously cutting releases or spawning version tags. |
| **Git** | `config` | Prevents AI from tampering with your identity (name/email) or security settings. |
| **Git** | `push --tags` | Prevents exfiltration of local tags that might trigger automated CI/CD deployments. |
| **Git** | `rebase --squash` | Prevents history destruction. Squashing makes review and forensic auditing difficult. |
| **GitHub CLI** | `release` | Complete block on creating or managing GitHub Releases via the CLI. |
| **GitHub CLI** | `pr merge` | Prevents AI from bypassing human review to merge its own code. |
| **GitHub CLI** | `repo delete` | Catastrophic failure prevention. AI should never have the power to delete repositories. |
| **GitHub CLI** | `secret` | Prevents AI from viewing or modifying organizational/repository secrets. |
| **npm / npx** | `--legacy-peer-deps` | Prevents bypassing peer dependency resolution, ensuring clean package management. |

> [!NOTE]
> **Kubernetes / OpenShift:** To ensure maximum developer convenience and standard workflows, `kubectl` and `oc` operate fully natively without any safety intercepts or blocks.

## Optional Enhancements

### Git Configuration Setup

Configure Git with recommended settings from core Git developers:

```bash
curl -sSL https://raw.githubusercontent.com/bcgov/copilot-instructions/main/scripts/git-setup.sh | bash
```

### Other AI Agents

These instructions and skills are built using open standards, making them compatible with other AI coding assistants. You can configure other tools (like Google Antigravity, Cursor, or Kilo Code) to reuse the global Copilot instructions and skills:

#### Google Antigravity

Antigravity loads global instructions from `~/.gemini/GEMINI.md` and global skills from `~/.gemini/config/skills`. You can symlink them to your global Copilot folders:

```bash
# Link global instructions
ln -sf ~/.config/Code/User/prompts/global.instructions.md ~/.gemini/GEMINI.md

# Link global skills
ln -sf ~/.agents/skills ~/.gemini/config/skills
```

#### Cursor & Kilo Code

For other agents, configure them to reference the global instructions file at `~/.config/Code/User/prompts/global.instructions.md` or symlink their respective instructions configurations.

## Attribution

The Behavioral Guidelines section in our copilot instructions is adapted from [CLAUDE.md](https://github.com/forrestchang/andrej-karpathy-skills/blob/main/CLAUDE.md) by Forrest Chang.
The recommended Git configuration settings in `git-setup.sh` are based on [How Git core developers configure Git](https://blog.gitbutler.com/how-git-core-devs-configure-git) by GitButler.
Skills documentation and patterns are adapted from [awesome-copilot](https://github.com/github/awesome-copilot).

## Contributing

We welcome contributions! Submit issues or pull requests to improve these shared guidelines.
