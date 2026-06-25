# Agent Instructions

Guidelines for AI-assisted development, written with the intent of becoming a practical standard for teams across the Government of British Columbia.

> **Not an official BC Government publication.** Content here reflects community work in progress. It does not speak for, bind, or represent the Province of British Columbia. We welcome contributors so this can grow into something genuinely useful for public-sector developers in BC.

The canonical text lives in **[instructions.md](instructions.md)** at the repo root — visible, reviewable, and copy-ready.

## Use this file

You can apply these instructions at different levels depending on your setup:

### Global-level (Linux/macOS/WSL)
Copy the root file into your global Copilot instructions folder to apply these guidelines across all your local sessions:

````bash
mkdir -p ~/.copilot/instructions
curl -fsSL https://raw.githubusercontent.com/bcgov/agent-instructions/main/instructions.md \
  -o ~/.copilot/instructions/instructions.md
````

### Project-level (Repository)
Copy the root file into individual repositories as `.github/copilot-instructions.md` for project-specific customization:

````bash
curl -fsSL https://raw.githubusercontent.com/bcgov/agent-instructions/main/instructions.md \
  -o .github/copilot-instructions.md
````

### Org-level (Organization)
Configure custom agent instructions for your GitHub Organization by copying the contents of the [raw file](https://raw.githubusercontent.com/bcgov/agent-instructions/main/instructions.md) and pasting them directly into your organization's settings.

> [!IMPORTANT]
> GitHub enforces a **4,000 character limit** for organizational Custom Instructions. Keep [instructions.md](instructions.md) under that limit (CI validates on every PR).

## Agent guardrails (enforcement)

These have moved to [their own repository](https://github.com/bcgov/agent-guardrails).

````bash
curl -fsSL https://raw.githubusercontent.com/bcgov/agent-guardrails/main/setup.sh | bash
````

## Contributing

We want this to become something teams across BC can actually adopt. Open a PR to improve [instructions.md](instructions.md) — keep it under 4,000 characters, stay concrete, and explain the *why* in the PR description when a rule is non-obvious.

## Attribution

Guardrails and git setup moved to [bcgov/agent-guardrails](https://github.com/bcgov/agent-guardrails).
