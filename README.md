# Agent Instructions

Guidelines for AI-assisted development, written with the intent of becoming a practical standard for teams across the Government of British Columbia.

> **Not an official BC Government publication.** Content here reflects community work in progress. It does not speak for, bind, or represent the Province of British Columbia. We welcome contributors so this can grow into something genuinely useful for public-sector developers in BC.

The canonical text lives in **[instructions.md](instructions.md)** at the repo root — visible, reviewable, and copy-ready.

> [!IMPORTANT]
> GitHub enforces a **4,000 character limit** for organizational Custom Instructions. Keep [instructions.md](instructions.md) under that limit (CI validates on every PR).

## Use this file

**Global-level (VS Code - Linux/macOS):** Copy the root file into your global prompts directory:

````bash
# For Linux
mkdir -p ~/.config/Code/User/prompts
curl -fsSL https://raw.githubusercontent.com/bcgov/agent-instructions/main/instructions.md \
  -o ~/.config/Code/User/prompts/global.instructions.md

# For macOS
mkdir -p ~/Library/Application\ Support/Code/User/prompts
curl -fsSL https://raw.githubusercontent.com/bcgov/agent-instructions/main/instructions.md \
  -o ~/Library/Application\ Support/Code/User/prompts/global.instructions.md
````

**Global-level (VS Code - Windows):** Copy the root file using PowerShell:

````powershell
New-Item -ItemType Directory -Force -Path "$env:APPDATA\Code\User\prompts"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/bcgov/agent-instructions/main/instructions.md" `
  -OutFile "$env:APPDATA\Code\User\prompts\global.instructions.md"
````

*(Note: You can also copy these instructions to individual repositories at `.github/copilot-instructions.md` for project-level customization).*

**Org-level:** Configure custom agent instructions from the [raw file](https://raw.githubusercontent.com/bcgov/agent-instructions/main/instructions.md) or paste its contents into org settings.

## Agent guardrails (enforcement)

These have moved to [their own repository](https://github.com/bcgov/agent-guardrails).

````bash
curl -fsSL https://raw.githubusercontent.com/bcgov/agent-guardrails/main/setup.sh | bash
````

## Contributing

We want this to become something teams across BC can actually adopt. Open a PR to improve [instructions.md](instructions.md) — keep it under 4,000 characters, stay concrete, and explain the *why* in the PR description when a rule is non-obvious.

## Attribution

Behavioral guidelines adapted from [CLAUDE.md](https://github.com/forrestchang/andrej-karpathy-skills/blob/main/CLAUDE.md) by Forrest Chang. Guardrails and git setup moved to [bcgov/agent-guardrails](https://github.com/bcgov/agent-guardrails).
