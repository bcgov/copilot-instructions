## Behavioral Guidelines

### Think & Plan
- **ALWAYS** state assumptions; list interpretations if multiple exist.
- **ALWAYS** propose simpler approaches; default to simplicity.
- **ALWAYS** use **Explicit Innovation Mode**: fix FIRST, then ask before proposing "better" versions. (Simpler/safer alternatives can be raised before starting).

### Implementation Discipline
- **NEVER** implement unrequested features.
- **ALWAYS** use direct code; refactor only on duplication. Touch ONLY required files.
- **ALWAYS** match project style exactly and remove orphans.
- **NEVER** report "Done" without terminal verification (e.g., `ls`, `git status`).
- **DIFF-AS-RECEIPT**: Every turn with an edit MUST end with a sanitized `git diff` (redact all secrets/PII).

### Verification
- **ALWAYS** define success criteria and verify against them before marking work done.
- **ALWAYS** state a brief plan with verification checks for multi-step tasks.

### Dependencies
- **ALWAYS** avoid dependencies for low-volume (< 20 lines) logic.
- **ALWAYS** use libraries ONLY when bespoke alternatives are complex or high-risk.
- **ALWAYS** verify new dependencies are maintained and lightweight.
- **ZERO SPECULATION**: Verify APIs/triggers via available tools (e.g. search, run command). NEVER guess.
- **NEVER** use "clever" or abstract solutions unless established.

## Standards

### Hard Stops (Never)
- **NEVER** branch from a feature branch; **ALWAYS** use a fresh `main`.
- **NEVER** push to main, merge PRs, or use destructive git commands on shared history.
- **NEVER** use triple-backticks; **ALWAYS** wrap code, manifests, and copy-paste blocks in 4-backtick blocks.
- **NEVER** commit secrets, PII, or grant broad permissions.
- **NEVER** silence diagnostics (`eslint-disable`); fix the root cause.
- **NEVER** delete failing tests; **ALWAYS** fix the code.
- **NEVER** run `kubectl` or `oc` commands. Access to Kubernetes and OpenShift is restricted.

### Operational Guardrails
- **ALWAYS** push and open PRs to feature branches without asking.
- **NEVER** mark work complete until verified, committed, pushed, and PR created.
- **ALWAYS** stop on the first error; chain related commands with `&&`.
- **ALWAYS** block SQL injection, XSS, and unsanitized inputs in code and docs.
- For temporary storage, **ALWAYS** use `./.tmp/` if git-ignored, otherwise `/tmp`.

### Git Workflow
1. **Branching:** `git checkout main && git pull && git switch -c feat/name && git push -u origin feat/name`.
2. **PR Creation:** `git fetch origin && git rebase origin/main && git log origin/main..HEAD --oneline`.
3. **Closing:** **ALWAYS** end PR bodies with `Closes #<number>`.

### Project Standards
- **ALWAYS** use Conventional Commits with scoped, descriptive messages.
- **ALWAYS** use latest stable packages; **NEVER** downgrade or edit lock files silently.
- **ALWAYS** use minimum permissions (e.g., `permissions: {}` in GitHub Actions).
- **ALWAYS** use GitHub Releases; **NEVER** add manual version tracking artifacts.

## Macros
- **Green #number**: Rebase on `main`, review `gh pr view/checks`. Fix CI errors before pushing.
- **Audit #target**: Scan for regressions, orphans, and style issues. Report before fixing.
- **Stabilize #workflow**: Check permissions, `set -euo pipefail`, and `&&` chaining.
