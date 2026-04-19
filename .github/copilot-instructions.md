## Behavioral Guidelines

### Think & Plan
- **ALWAYS** state assumptions and ask when uncertain; list interpretations if multiple exist.
- **ALWAYS** propose simpler approaches and default to simplicity unless requested otherwise.
- **ALWAYS** suggest improvements proactively—even if not requested, framing as "I'd suggest X, want me to do that?" gives you choice.
- **ALWAYS** use **Explicit Innovation Mode**: complete and verify the requested fix FIRST, then ask for permission before proposing or implementing a "better" version.

### Implementation Discipline
- **NEVER** implement unrequested features or configurability.
- **ALWAYS** use direct, single-use code; refactor only when duplication appears.
- **ALWAYS** touch only what is required; **NEVER** refactor unrelated code.
- **ALWAYS** match project style and conventions exactly.
- **ALWAYS** remove orphans created by your changes.
- **NEVER** report "Done" without verifying state via terminal (e.g., `ls`, `git status`); **ALWAYS** prioritize uncomfortable truth over convenient fiction.
- **NEVER** combine bug fixes with "polished" or "creative" improvements. Use **Strict Isolation**: modify ONLY the requested element.

### Verification
- **ALWAYS** define success criteria and verify against them before marking work done.
- **ALWAYS** state a brief plan with verification checks for multi-step tasks.
- **ALWAYS** perform a **Regression Heartbeat**: verify that core components (like the Resources accordion) remain functional before reporting completion.

### Dependencies
- **ALWAYS** avoid dependencies for low-volume (< 20 lines) or low-risk logic.
- **ALWAYS** use battle-tested libraries only when bespoke alternatives are complex, security-sensitive, or high-risk.
- **ALWAYS** verify new dependencies are maintained, compatible, non-duplicative, and lightweight.
- **ALWAYS** explain trade-offs for proposed architectural choices.
- **NEVER** use "clever" or overly abstract solutions unless already established.

## Standards

### Hard Stops (Never)
- **NEVER** branch from a feature branch; **ALWAYS** initialize from a fresh checkout of main.
- **NEVER** push to main or merge PRs; leave merging to humans.
- **NEVER** use destructive git commands (gh pr merge, squash, rebase -i) on shared history.
- **NEVER** use triple-backticks in code blocks; **ALWAYS** use 4-backtick fenced blocks.
- **NEVER** commit or include credentials, secrets, or PII in code or PRs.
- **NEVER** bypass security standards or grant broad permissions.
- **NEVER** silence diagnostics (`eslint-disable`, `@ts-ignore`); fix the root cause.
- **NEVER** delete failing tests; **ALWAYS** fix the code to ensure the test suite passes.

### Operational Guardrails
- **ALWAYS** push and open PRs to feature branches without asking.
- **NEVER** mark work complete until verified, committed, pushed, and PR created.
- **ALWAYS** stop on the first error; chain related commands with `&&`.
- **ALWAYS** block SQL injection, XSS, and unsanitized inputs in code and docs.
- For temporary storage, **ALWAYS** use `./.tmp/` if git-ignored, otherwise `/tmp`.

### Git Workflow
1. **Branching:** **ALWAYS** run `git checkout main && git pull && git switch -c feat/description && git push -u origin feat/description`. Verify with `git branch -vv`.
2. **PR Creation:** **ALWAYS** run `git fetch origin && git rebase origin/main && git log origin/main..HEAD --oneline` before pushing; **STOP** if unintended commits appear.
3. **Closing:** **ALWAYS** end PR bodies with `Closes #<number>` if a task references an issue.

### Project Standards
- **ALWAYS** use Conventional Commits with scoped, descriptive messages.
- **ALWAYS** use latest stable packages; **NEVER** downgrade or edit lock files silently.
- **ALWAYS** use minimum permissions (e.g., `permissions: {}` in GitHub Actions).
- **ALWAYS** use GitHub Releases; **NEVER** add manual version tracking artifacts.

## Macros
- **Green #number**: **ALWAYS** rebase onto `main`, review `gh pr view --comments` and `gh pr checks`. Address feedback and CI errors before pushing.
- **Audit #target**: **ALWAYS** scan for pattern regressions, orphan code, and style inconsistencies relative to project standards. Report findings before fixing.
- **Stabilize #workflow**: **ALWAYS** review for minimum permissions (`permissions: {}`), `set -euo pipefail` settings, and `&&` chaining. Fix reliability gaps.
