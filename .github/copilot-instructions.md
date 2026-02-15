## Behavioral Guidelines

### Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

### Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

### Goal-Driven Execution

**Define success criteria. Loop until verified.**

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
```

### Communication Preferences

- Keep code, comments, and commit messages professional and clean
- When presenting multiple options, use **comparison tables** for clarity
- Provide responses in code blocks for easy copy/paste

## Standards

### Hard Stops (Never)

- NEVER push to main or merge PRs; ALWAYS leave merging to humans
- NEVER skip `git status` checks
- NEVER generate credentials or secrets
- NEVER create duplicate files or use local .env files
- NEVER bypass security standards or grant broad permissions "just in case"

### Operational Guardrails

- ALWAYS push and open PRs to feature branches without asking permission
- NEVER mark work complete until code is committed, pushed, and PR created. Workflow: `git add`, `git commit`, `git push`, verify `git status` clean
- ALWAYS stop on first error; chain related commands with &&, separate unrelated ones

### Git Workflow (Ordered Checklist)

1. **Create Feature Branch:** MUST be on `main` with clean tree, then `git pull && git switch -c feat/description`.
2. **Create PR:** `git fetch origin && git rebase main`, then `git push -u origin $(git branch --show-current)`. MUST use `gh pr create --title "feat: title" --body $'## Summary\n\nDescription'`.
3. **Before PR Ready:** Review `git log --oneline main..HEAD`, fix problems, verify clean tree.

### Project Standards

- **Conventional Commits:** Required for all commits and PR titles.
- **Package Management (npm):** Use latest stable versions. NEVER use `--legacy-peer-deps`, edit lock files, or downgrade silently. Resolve via compatible versions or ask.
- **Least Privilege:** ALWAYS use minimum permissions. GitHub Actions: `permissions: {}` at workflow, explicit at job/step. Containers: non-root, drop capabilities. Cloud/DB/APIs: minimal scopes.
- **Documentation:** Use GitHub Releases for version history. NEVER add manual tracking artifacts when GitHub features suffice.

### Solution Design

- **ALWAYS check existing solutions** (GitHub Marketplace, npmjs.com) before building custom
- **NEVER propose repo-specific** when shared approach exists
- **NEVER suggest solutions requiring manual maintenance** across repos
