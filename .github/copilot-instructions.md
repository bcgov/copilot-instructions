## Behavioral Guidelines

### Think & Plan
- **ALWAYS** state assumptions and list multiple interpretations.
- **ALWAYS** propose simpler approaches; default to simplicity.
- **ALWAYS** use **Explicit Innovation Mode**: fix FIRST; ask before proposing broader refactors or enhancements.

### Implementation Discipline
- **NEVER** implement unrequested features; limit changes strictly to the active prompt requirements.
- **ALWAYS** use direct code (refactor only on duplication) and touch only files in the logical path of the change.
- **ALWAYS** match project style (naming, patterns) by inspecting adjacent files, and remove unused variables/imports.
- **NEVER** report "Done" without terminal verification (e.g., `ls`, `git status`).
- **DIFF-AS-RECEIPT**: Every turn with an edit MUST end with a git diff in a collapsible HTML details block (using raw HTML <details> and <summary> tags).

### Verification
- **ALWAYS** define success criteria and verify against them before marking work done.
- **ALWAYS** state a brief plan with verification checks for multi-step tasks.

### Dependencies
- **ALWAYS** avoid dependencies for low-volume (<20 lines) logic.
- **ALWAYS** use libraries only if bespoke solutions are high-risk.
- **ALWAYS** verify new dependencies are maintained and lightweight.
- **ZERO SPECULATION**: Verify APIs/triggers via available tools (e.g. search, run command). NEVER guess.
- **NEVER** use "clever" or abstract solutions unless established.

## Standards

### Hard Stops (Never)
- **NEVER** branch from a feature branch; **ALWAYS** use a fresh main checkout.
- **NEVER** push to main or merge PRs; leave merging to humans.
- **NEVER** use destructive git commands (squash, rebase -i) on shared history.
- **NEVER** use triple-backticks; **ALWAYS** wrap code, manifests, and copy-paste blocks in 4-backtick blocks.
- **NEVER** commit or include credentials, secrets, or PII in code or PRs.
- **NEVER** silence diagnostics (eslint-disable, @ts-ignore); fix the root cause.
- **NEVER** delete failing tests; **ALWAYS** fix the code to ensure the test suite passes.
- **NEVER** run `kubectl` or `oc` commands. Access to Kubernetes and OpenShift is restricted.
- **NEVER** impersonate, simulate, or speak on behalf of any human in chat, comments, PRs, or commits.
- **NEVER** use `--legacy-peer-deps` with npm/npx under any circumstances. Always resolve peer dependency conflicts cleanly.

### Operational Guardrails
- **ALWAYS** push and open PRs to feature branches without asking.
- **NEVER** mark work complete until verified, committed, pushed, and PR created.
- **ALWAYS** stop on the first error; chain related commands with `&&`.
- **ALWAYS** block SQL injection, XSS, and unsanitized inputs in code and docs.
- For temporary storage, **ALWAYS** use `./.tmp/` (if git-ignored) or `/tmp`.

### Git Workflow
1. **Branching:** `git checkout main && git pull && git switch -c feat/name && git push -u origin feat/name`.
2. **PR Creation:** `git fetch origin && git rebase origin/main && git log origin/main..HEAD --oneline`.
3. **Closing:** Link issues via `Closes #<issue_number>` ONLY if explicitly provided. Never guess issue numbers.

### Project Standards
- **ALWAYS** use Conventional Commits (e.g., `feat(auth):` scoped by directory).
- **ALWAYS** use latest stable packages; **NEVER** edit lock files silently.
- **ALWAYS** use minimum permissions (e.g., `permissions: {}` in GitHub Actions).
- **ALWAYS** use GitHub Releases; **NEVER** track versions manually.

## Macros
- **Green #number**: Rebase on `main`, review `gh pr view --comments` and `gh pr checks`. Address feedback and CI errors before pushing.
- **Audit #target**: Scan for pattern regressions, orphan code, and style inconsistencies relative to project standards. Report findings before fixing.
- **Stabilize #workflow**: Review for minimum permissions (`permissions: {}`), `set -euo pipefail` settings, and `&&` chaining. Fix reliability gaps.
