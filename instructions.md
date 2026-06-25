## Behavioral Guidelines

### Think & Plan
- **ALWAYS** state assumptions; list interpretations if ambiguous.
- **ALWAYS** propose simpler approaches; default to simplicity.
- **ALWAYS** fix FIRST; ask before proposing broader refactors/enhancements.

### Implementation Discipline
- **NEVER** implement unrequested features.
- **ALWAYS** use direct code (refactor only on duplication); touch only files in the logical path of the change.
- **ALWAYS** match project style by inspecting adjacent files; remove unused imports.
- **NEVER** report "Done" without terminal verification (e.g., ls, git status).
- **ALWAYS** default environments/toggles to PROD if variables are missing.
- **DIFF-AS-RECEIPT**: Every turn with an edit MUST end with a git diff in a collapsible HTML <details> block.

### Verification
- **ALWAYS** define and verify success criteria before finishing.
- **ALWAYS** state a brief plan with checks for multi-step tasks.

### Dependencies
- **ALWAYS** avoid dependencies for < 20 lines of logic.
- **ALWAYS** use libraries ONLY if bespoke alternatives are complex/high-risk.
- **ALWAYS** verify new dependencies are maintained/lightweight.
- **ZERO SPECULATION**: Verify APIs via tools. NEVER guess.
- **NEVER** use "clever"/abstract solutions unless established.

## Standards

### Hard Stops (Never)
- **NEVER** branch from a feature branch; **ALWAYS** initialize from main.
- **NEVER** push to main or merge PRs; humans merge.
- **NEVER** rewrite history (e.g. rebase -i, squash).
- **NEVER** use triple-backticks; ALWAYS use 4-backtick blocks.
- **NEVER** commit credentials, secrets, or PII.
- **NEVER** silence diagnostics; fix root causes.
- **NEVER** delete failing tests; fix the code.
- **NEVER** run `oc` commands.
- **NEVER** impersonate humans in chat, PRs, or commits.
- **NEVER** use `--legacy-peer-deps`; resolve conflicts cleanly.

### Operational Guardrails
- **ALWAYS** push and open PRs without asking.
- **NEVER** mark work complete until verified, pushed, and PR'd.
- **ALWAYS** stop on first error; chain related commands with `&&`.
- **ALWAYS** block SQLi, XSS, and unsanitized inputs.
- **ALWAYS** use `./.tmp/` if git-ignored, otherwise `/tmp` for temp storage.

### Git Workflow
1. **Branching:** `git checkout main && git pull && git switch -c feat/name && git push -u origin feat/name`
2. **PR:** `git fetch origin && git rebase origin/main && git log origin/main..HEAD --oneline`
3. **Updating:** **ALWAYS** fetch and merge/rebase `origin/main` to keep the active feature branch up to date before making new edits or pushing.
4. **Closing:** Link issues via `Closes #<num>` ONLY if explicitly provided. Never guess.

### Project Standards
- **ALWAYS** use Conventional Commits (derive scope from primary directory, e.g., `feat(auth):`).
- **ALWAYS** use latest stable packages; NEVER edit lock files silently.
- **ALWAYS** use minimum permissions (e.g., `permissions: {}` in Actions).
- **ALWAYS** use GitHub Releases; NEVER add manual tracking artifacts.

## Macros
- **Green #number**: Rebase `main`, verify `gh pr view/checks`, fix CI errors before pushing.
- **Audit #target**: Scan for style, orphan code, pattern regressions. Report before fixing.
- **Stabilize #workflow**: Check `permissions: {}`, `set -euo pipefail`, and `&&` chaining. Fix gaps.
