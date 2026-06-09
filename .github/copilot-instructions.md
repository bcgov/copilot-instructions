## Behavioral Guidelines

### Think & Plan
- **ALWAYS** state assumptions; list interpretations if multiple exist.
- **ALWAYS** propose simpler approaches; default to simplicity.
- **ALWAYS** use **Explicit Innovation Mode**: fix FIRST, then ask before proposing "better" versions.

### Implementation Discipline
- **NEVER** implement unrequested features; limit changes strictly to the active prompt requirements.
- **ALWAYS** use direct code (refactor only on duplication) and touch only files in the logical path of the change.
- **ALWAYS** match project style (naming, patterns) by inspecting adjacent files, and remove unused variables/imports.
- **NEVER** report "Done" without terminal verification (e.g., `ls`, `git status`).
- **DIFF-AS-RECEIPT**: Every turn with an edit MUST end with a collapsed `git diff`.

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
- **NEVER** run `kubectl` or `oc` (access is restricted).
- **NEVER** impersonate, simulate, or speak on behalf of any human actor in chat, comments, PRs, or commits.
- **NEVER** use `--legacy-peer-deps` with npm/npx. Always resolve peer conflicts cleanly.

### Operational Guardrails
- **ALWAYS** push and open PRs to feature branches without asking.
- **NEVER** mark work complete until verified, committed, pushed, and PR created.
- **ALWAYS** stop on the first error; chain related commands with `&&`.
- **ALWAYS** block SQL injection, XSS, and unsanitized inputs in code and docs.
- For temporary storage, **ALWAYS** use `./.tmp/` if git-ignored, otherwise `/tmp`.

### Git Workflow
1. **Branching:** `git checkout main && git pull && git switch -c feat/name && git push -u origin feat/name`.
2. **PR Creation:** `git fetch origin && git rebase origin/main && git log origin/main..HEAD --oneline`.
3. **Closing:** Link issues via `Closes #<issue_number>` ONLY if explicitly provided in the prompt or branch name. Never guess or hallucinate issue numbers.

### Project Standards
- **ALWAYS** use Conventional Commits (derive the scope from the primary directory modified, e.g., `feat(auth):`).
- **ALWAYS** use latest stable packages; **NEVER** downgrade or edit lock files silently.
- **ALWAYS** use minimum permissions (e.g., `permissions: {}` in GitHub Actions).
- **ALWAYS** use GitHub Releases; **NEVER** add manual version tracking artifacts.

