## Behavioral Guidelines

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 3. Surgical Changes

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

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## Standards

### Hard Stops (Never)

- NEVER push directly to main or merge PRs; ALWAYS leave merging to humans
- NEVER skip `git status` checks
- NEVER generate credentials or secrets
- NEVER create duplicate files or use local .env files for configuration
- NEVER bypass security standards or grant broad permissions "just in case"

### Operational Guardrails

- ALWAYS push and open PRs to feature branches without asking permission
- NEVER mark work complete until all code is committed, pushed to remote, and PR is created. Workflow: `git add`, `git commit` (conventional format), `git push`, then verify `git status` is clean
- ALWAYS stop on first error; chain related commands with &&, separate unrelated ones

### Git Workflow (Ordered Checklist)

1. **Create Feature Branch (CRITICAL):** MUST be on `main` with clean tree, then `git pull && git switch -c feat/description`.
2. **Create PR:** `git fetch origin && git rebase main`, then `git push --set-upstream origin $(git branch --show-current)`. MUST use `gh pr create --title "feat: title" --body $'## Summary\n\nDescription'`.
3. **Before Declaring PR Ready:** Review `git log --oneline main..HEAD`, fix problems, verify clean tree before pushing.

### Project Standards

- **Conventional Commits:** Required for all commits and PR titles.
- **Formatting:** Use 4-space indent, no trailing whitespace, LF line endings.
- **Package Management (npm):** Use latest stable versions when possible. NEVER use `--legacy-peer-deps`, edit lock files, or downgrade silently. Resolve conflicts via compatible versions or ask.
- **Least Privilege (CRITICAL):** ALWAYS use minimum permissions. GitHub Actions: `permissions: {}` at workflow, explicit at job/step. Containers: non-root, drop capabilities. Cloud/DB/APIs: minimal scopes.
- **Documentation:** Use GitHub Releases for version history. NEVER add manual tracking artifacts when GitHub features suffice.
