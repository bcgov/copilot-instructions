# Copilot Instructions

Shared BC Government guidelines for AI-assisted development.

This repository is **work standards only** — the canonical `.github/copilot-instructions.md` file teams copy into projects or receive via org-level GitHub Copilot settings.

> [!IMPORTANT]
> GitHub enforces a **4,000 character limit** for organizational Copilot Instructions. Keep `.github/copilot-instructions.md` under that limit (CI validates on every PR).

## Use this file

**Project-level:** copy [copilot-instructions.md](.github/copilot-instructions.md) into your repo as `.github/copilot-instructions.md`.

**Org-level:** configure GitHub Copilot custom instructions to point at the shared content in this repository.

## Agent guardrails (enforcement)

Shell safety wrappers, global git hooks, and optional human git configuration live in [bcgov/agent-guardrails](https://github.com/bcgov/agent-guardrails):

````bash
curl -fsSL https://raw.githubusercontent.com/bcgov/agent-guardrails/main/setup.sh | bash
````

## What is not in this repo

- **Personal instructions** — maintain outside this repo (e.g. your own dotfiles).
- **Instruction bundling** — consumers merge work + personal locally if needed.
- **AI guardrails** (shell wrappers, gitleaks hooks, git-setup) — [bcgov/agent-guardrails](https://github.com/bcgov/agent-guardrails).

## Contributing

Submit PRs to improve shared standards. Keep the main instructions file under 4,000 characters.

## Attribution

Behavioral guidelines adapted from [CLAUDE.md](https://github.com/forrestchang/andrej-karpathy-skills/blob/main/CLAUDE.md) by Forrest Chang. Guardrails and git setup moved to [bcgov/agent-guardrails](https://github.com/bcgov/agent-guardrails).
