# Copilot Instructions

Guidelines and tooling to help developers effectively use GitHub Copilot while maintaining security and quality standards.

> [!IMPORTANT]
> GitHub enforces a **4,000 character limit** for global Copilot Instructions. All changes to the shared `.github/copilot-instructions.md` MUST stay within this limit to remain compatible with GitHub's organizational settings.

## Quick Start: Install Everything (Recommended)

To automatically bundle instructions, set up global git hooks (including Gitleaks for secret scanning), and configure shell safety functions, run the setup script:

````bash
curl -fsSL https://raw.githubusercontent.com/bcgov/copilot-instructions/main/setup.sh | bash
````

### Customizing with a Personalized Profile

If you want to maintain your own personality settings or technical preferences without polluting the shared standards:

1. **Clone this repo** locally.
2. **Create your profile**: Create a file in `.github/profiles/your-GITHUB-username.md` (use `DerekRoberts.md` as a template).
3. **Run the installer** with your GitHub username:
   ````bash
   ./setup.sh [GitHubID]
   ````
   *If you omit the ID, the script attempts to resolve it automatically via the GitHub CLI, and falls back to only bundling the shared standards if not found.*

---

## What Setup Automates

1. **AI Instructions Bundle**: Bundles the shared guidelines (and your personalized profile, if specified) and writes them to VS Code's global prompts directory (`~/.config/Code/User/prompts/global.instructions.md`).
2. **Global Agent Skills**: For shared developer or agent skills, check out the centralized [bcgov/agent-skills](https://github.com/bcgov/agent-skills) catalog. We highly encourage everyone to install and use it via `npx skills add bcgov/agent-skills`.
3. **Global Git Hooks**: Configures global pre-commit and pre-push hooks that scan for secrets (using Gitleaks) and prevent direct pushes to protected branches (e.g. `main`).
4. **Shell Safety Wrappers**: Injects transparent shell safety functions into `~/.bashrc` to prevent AI agents from performing destructive operations (e.g., `repo delete`, `pr merge`, etc.) while remaining fully transparent and bypassable for developers.

### Blocked Operations & Rationale

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

---

## Alternative and Per-Project Configurations

### Copying to Individual Repositories
If you prefer not to use the global installer, or want to configure project-specific instructions, you can copy these files directly into individual repositories:
- **Project Instructions**: Copy or download [copilot-instructions.md](/.github/copilot-instructions.md) into your project's `.copilot/instructions` file.
- **Project Skills**: For team and organization-wide skills, please reference the centralized [bcgov/agent-skills](https://github.com/bcgov/agent-skills) library.

---

## Optional Enhancements

### Git Configuration Setup
Configure Git with recommended settings from core Git developers (e.g., config defaults, global gitignore, and commit signing):

````bash
curl -fsSL https://raw.githubusercontent.com/bcgov/copilot-instructions/main/scripts/git-setup.sh | bash
````

### Tolerated Editors & AI Agents (Antigravity and Cursor)
While other editors and agents are not explicitly encouraged, the setup script can tolerate and link assets for them. Run the setup script with environment flags to automatically create symlinks:

````bash
ANTIGRAVITY=true CURSOR=true ./setup.sh [GitHubID]
````

This will automatically configure:
- **Google Antigravity**: Symlinks `~/.gemini/GEMINI.md` to the global Copilot paths.
- **Cursor**: Symlinks `~/.config/Cursor/User/prompts/global.instructions.md` to the global VS Code prompts directory.

Alternatively, you can configure them manually:

````bash
# Link global instructions for Cursor manually
mkdir -p ~/.config/Cursor/User/prompts
ln -sf ~/.config/Code/User/prompts/global.instructions.md ~/.config/Cursor/User/prompts/global.instructions.md

# Link global instructions for Antigravity manually
ln -sf ~/.config/Code/User/prompts/global.instructions.md ~/.gemini/GEMINI.md
````

---

## Attribution

The Behavioral Guidelines section in our copilot instructions was originally adapted from [CLAUDE.md](https://github.com/forrestchang/andrej-karpathy-skills/blob/main/CLAUDE.md) by Forrest Chang.
The recommended Git configuration settings in `git-setup.sh` are based on [How Git core developers configure Git](https://blog.gitbutler.com/how-git-core-devs-configure-git) by GitButler.
Skills documentation and patterns are adapted from [awesome-copilot](https://github.com/github/awesome-copilot).

## Contributing

We welcome contributions! Submit issues or pull requests to improve these shared guidelines.

