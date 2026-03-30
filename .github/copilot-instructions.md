## Behavioral Guidelines

### Think Before Coding
- State assumptions; ask when uncertain.
- If multiple interpretations exist, list them instead of picking silently.
- If unclear, stop and ask.
- If a simpler approach exists, say so. Use it unless requested otherwise.

### Simplicity First
- No features beyond what was asked.
- Prefer simple, direct code for single-use logic; refactor when duplication appears.
- No "flexibility" or "configurability" that wasn't requested.

### Surgical Changes
- Touch only what you must; match existing style.
- Don't refactor what isn't broken; mention unrelated dead code instead.
- Remove orphans caused by your changes.

### Goal-Driven Execution
- Define success criteria and verify.
- For multi-step tasks, state a brief plan with checks.
- Always verify before marking work done; if verification is impossible, say so explicitly.

### Code Quality & Dependencies
- MUST analyze existing patterns before suggesting new code.
- MUST avoid new libraries unless absolutely necessary. If adding one, verify it is maintained, compatible, non-duplicative, and lightweight. Avoid libraries that solve trivial problems or increase complexity.
- MUST explain trade-offs when offering multiple options.
- MUST avoid "clever" or overly abstract solutions unless already used.
- MUST match the project's style, architecture, and conventions.

## Standards

### Hard Stops (Never)
- NEVER push to main or merge PRs; leave merging to humans
- NEVER use destructive commands (gh pr merge, override git hooks, etc.)
- NEVER squash, rebase -i, or otherwise destroy commit history in PR branches
- NEVER use triple-backticks inside code blocks; use 4-backtick fenced blocks
- NEVER commit credentials/secrets (.env files, API keys, tokens) OR include them in PR bodies/issues/markdown.
- NEVER bypass security standards or grant broad permissions
- NEVER silently delete, skip, or comment out failing tests, and NEVER advise ignoring or bypassing them. ALWAYS ensure all tests pass — fix the underlying code, not the test. If a test is genuinely outdated, flag it for human review before removing.

### Operational Guardrails
- ALWAYS push and open PRs to feature branches without asking
- NEVER mark work complete until verified, committed, pushed, and PR created
- ALWAYS stop on first error; chain related commands with &&
- Block SQL injection, XSS, and unsanitized inputs (e.g., eval, innerHTML, string-concatenated queries) in code/docs.
- When a scratchpad or temporary storage is needed, use `./.tmp/` if `git check-ignore .tmp/` confirms it is git-ignored, otherwise `/tmp`.

### Git Workflow
1. **Create Branch:** On `main` with clean tree: `git pull && git switch -c feat/description`
2. **Create PR:** `git fetch origin && git rebase main`, then `git push -u origin $(git branch --show-current)`. Use `gh pr create --title "feat: title" --body $'## Summary\n\nDescription'`

### Project Standards
- **Conventional Commits:** Required for all commits and PR titles. Keep messages scoped and descriptive.
- **Package Management:** Use latest stable versions. NEVER use `--legacy-peer-deps`, edit lock files, or downgrade silently.
- **Least Privilege:** Use minimum permissions. GitHub Actions: `permissions: {}` at workflow, explicit at job/step. Containers: non-root, drop capabilities.
- **Documentation:** Use GitHub Releases for version history. NEVER add manual tracking artifacts.
