## Behavioral Guidelines

### Think Before Coding
- State assumptions; ask when uncertain.
- If multiple interpretations exist, list them instead of picking silently.
- If unclear, stop and ask.
- If a simpler approach exists, say so. Use it unless the user asks otherwise.

### Simplicity First
- No features beyond what was asked.
- Prefer simple, direct code for single-use logic; refactor and reuse when duplication appears.
- No "flexibility" or "configurability" that wasn't requested.

### Surgical Changes
- Touch only what you must; match existing style.
- Don't refactor what isn't broken; mention unrelated dead code instead.
- Remove orphans caused by your changes.

### Goal-Driven Execution
- Define success criteria and verify.
- For multi-step tasks, state a brief plan with checks.
- If you can't verify, say what remains unverified.

### Code Suggestion Expectations
- MUST analyze the project’s existing imports, utilities, and patterns before suggesting new code.  
- MUST avoid introducing new libraries unless absolutely necessary and approved.  
- MUST explain trade-offs when offering multiple implementation options.  
- MUST default to the simplest, most maintainable solution that fits the project’s current architecture.  
- MUST avoid “clever” or overly abstract solutions unless the project already uses them.

## Standards

### Hard Stops (Never)

- NEVER push to main or merge PRs; ALWAYS leave merging to humans
- NEVER use destructive commands (gh pr merge, override git hooks, etc.); talk to the user
- NEVER use triple-backticks inside another code block; ALWAYS use 4-backtick fenced code blocks with a language tag
- NEVER commit credentials or secrets in any form (.env, application.properties, application.yml, etc.)
- NEVER bypass security standards or grant broad permissions "just in case"

### Operational Guardrails

- ALWAYS push and open PRs to feature branches without asking permission
- NEVER mark work complete until code is committed, pushed, and PR created. Workflow: `git add`, `git commit`, `git push`, verify `git status` clean
- ALWAYS stop on first error; chain related commands with &&, separate unrelated ones

### Git Workflow (Ordered Checklist)

1. **Create Feature Branch:** MUST be on `main` with clean tree, then `git pull && git switch -c feat/description`.
2. **Create PR:** `git fetch origin && git rebase main`, then `git push -u origin $(git branch --show-current)`. MUST use `gh pr create --title "feat: title" --body $'## Summary\n\nDescription'`.

### Project Standards

- **Conventional Commits:** Required for all commits and PR titles.
- **Package Management (npm):** Use latest stable versions. NEVER use `--legacy-peer-deps`, edit lock files, or downgrade silently. Resolve via compatible versions or ask.
- **Least Privilege:** ALWAYS use minimum permissions. GitHub Actions: `permissions: {}` at workflow, explicit at job/step. Containers: non-root, drop capabilities. Cloud/DB/APIs: minimal scopes.
- **Documentation:** Use GitHub Releases for version history. NEVER add manual tracking artifacts when GitHub features suffice.
- **Solution Design:** Prefer existing shared solutions before building custom ones; avoid repo-specific or maintenance-heavy approaches.

### Commit Message Requirements
- MUST follow **Conventional Commits** for all commits and PR titles.  
- MUST include the **GitHub or Jira issue number** in the commit subject, formatted as:  
  - `feat(#123): description`  
  - `fix(WP-510): correct lower-case search behavior`  
- MUST keep commit messages scoped and descriptive; avoid vague messages like “fix stuff” or “update code.”  
- MUST reference only issues that actually relate to the change.  
- MUST avoid bundling unrelated changes into a single commit.

### Commit Message Examples
- `fix(#510): allow lowercase letters in Block ID search`  
- `refactor(WP-342): extract shared validation logic`  
- `feat(#128): add CSV export for admin reports`

### Dependency Discipline
- MUST prefer **existing project libraries** before introducing new ones.  
- MUST justify any new dependency with clear, project‑level value — not convenience.  
- MUST verify that the proposed library is:
  - actively maintained  
  - compatible with the project’s stack  
  - not duplicating functionality already available  
  - lightweight and low‑risk  
- MUST avoid adding libraries that:
  - solve trivial problems  
  - introduce unnecessary abstraction  
  - increase bundle size or operational complexity  
- MUST ask the user before adding any new dependency, explaining:
  - why it’s needed  
  - what alternatives were considered  
  - why existing libraries are insufficient

### When Suggesting Code
- MUST use the **existing libraries and patterns** already present in the repo.  
- MUST match the project’s coding style, architecture, and conventions.  
- MUST avoid suggesting rewrites or large refactors unless explicitly requested.  
- MUST highlight when a simpler solution exists using built‑ins or existing utilities.

