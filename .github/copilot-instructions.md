## Behavioral Guidelines

### Think & Plan
- **ALWAYS** state assumptions and ask when uncertain; list interpretations if multiple exist.
- **ALWAYS** propose simpler approaches and default to simplicity unless requested otherwise.

### Implementation Discipline
- **NEVER** implement unrequested features or configurability.
- **ALWAYS** use direct, single-use code; refactor only when duplication appears.
- **ALWAYS** touch only what is required; **NEVER** refactor unrelated code.
- **ALWAYS** match existing style, architecture, and conventions exactly.
- **ALWAYS** remove orphans created by your changes.

### Verification
- **ALWAYS** define success criteria and verify against them before marking work done.
- **ALWAYS** state a brief plan with verification checks for multi-step tasks.

### Dependencies
- **ALWAYS** avoid dependencies for low-volume (< 20 lines) or low-risk logic.
- **ALWAYS** use battle-tested libraries only when bespoke alternatives are complex, security-sensitive, or high-risk.
- **ALWAYS** verify new dependencies are maintained, compatible, non-duplicative, and lightweight.
- **ALWAYS** explain trade-offs for proposed architectural choices.
- **NEVER** use "clever" or overly abstract solutions unless already established in the codebase.

## Standards

### Hard Stops (Never)
- **NEVER** branch from an existing feature branch; **ALWAYS** initialize new work from a fresh checkout of main.
- **NEVER** push to main or merge PRs; leave merging to humans.
- **NEVER** use destructive git commands on shared history (e.g., `gh pr merge`, `git push --force`, `git rebase -i`).
- **NEVER** use triple-backticks inside code blocks; **ALWAYS** use 4-backtick fenced blocks.
- **NEVER** commit or include credentials, secrets, or PII in code or PR descriptions.
- **NEVER** bypass security standards or grant broad permissions.
- **NEVER** silence tooling diagnostics (`eslint-disable`, `@ts-ignore`); fix the root cause.
- **NEVER** delete or skip failing tests; **ALWAYS** fix the code to ensure the full test suite passes.

### Operational Guardrails
- **ALWAYS** push and open PRs to feature branches without asking.
- **NEVER** mark work complete until verified, committed, pushed, and PR created.
- **ALWAYS** stop on the first error; chain related commands with `&&`.
- **ALWAYS** block SQL injection, XSS, and unsanitized inputs in both code and docs.
- For temporary storage, **ALWAYS** use `./.tmp/` if git-ignored, otherwise `/tmp`.

### Git Workflow
1. **Branching:** **ALWAYS** run `git checkout main && git pull && git switch -c feat/description` before making any changes.
2. **PR Creation:** **ALWAYS** run `git fetch origin && git rebase origin/main && git log origin/main..HEAD --oneline` before pushing; **STOP** if unintended commits appear.
3. **Closing:** **ALWAYS** end PR bodies with `Closes #<number>` if a task references a GitHub issue.

### Project Standards
- **ALWAYS** use Conventional Commits with scoped, descriptive messages.
- **ALWAYS** use latest stable package versions; **NEVER** downgrade or edit lock files silently.
- **ALWAYS** use minimum permissions (e.g., `permissions: {}` in GitHub Actions).
- **ALWAYS** use GitHub Releases; **NEVER** add manual version tracking artifacts.
