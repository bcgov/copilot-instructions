## Behavioral Guidelines

### Think & Plan
- ALWAYS state assumptions; list interpretations if multiple exist.
- ALWAYS propose simpler approaches; default to simplicity.
- ALWAYS use EXPLICIT INNOVATION MODE: fix FIRST; ask before proposing broader refactors or enhancements.

### Implementation Discipline
- NEVER implement unrequested features; limit changes to the active prompt.
- ALWAYS use direct code (refactor only on duplication); touch only files in the logical path of the change.
- ALWAYS match project style (naming, patterns) by inspecting adjacent files; remove unused variables/imports.
- ALWAYS default environments/toggles to PROD when variables are missing.
- NEVER report "Done" without terminal verification (e.g., `ls`, `git status`).
- DIFF-AS-RECEIPT: Every turn with an edit MUST end with a git diff in a collapsible HTML details block (using raw HTML <details> and <summary> tags).

### Verification
- ALWAYS define success criteria and verify against them before marking work done.
- ALWAYS state a brief plan with verification checks for multi-step tasks.

### Dependencies
- ALWAYS avoid dependencies for low-volume (< 20 lines) logic.
- ALWAYS use libraries ONLY when bespoke alternatives are complex or high-risk.
- ALWAYS verify new dependencies are maintained and lightweight.
- ZERO SPECULATION: Verify APIs/triggers via available tools (e.g. search, run command). NEVER guess.
- NEVER use "clever" or abstract solutions unless established.

## Standards

### Hard Stops (Never)
- NEVER branch from a feature branch; ALWAYS initialize from a fresh checkout of main.
- NEVER push to main or merge PRs; leave merging to humans.
- NEVER rewrite history with interactive rebase or squashing (e.g. `git rebase -i`, `--autosquash`, `git merge --squash`).
- NEVER use triple-backticks; ALWAYS wrap code, manifests, and copy-paste blocks in 4-backtick blocks.
- NEVER commit or include credentials, secrets, or PII in code or PRs.
- NEVER silence diagnostics (`eslint-disable`, `@ts-ignore`); fix the root cause.
- NEVER delete failing tests; ALWAYS fix the code to make the test suite pass.
- NEVER run `oc` commands. Access to OpenShift is restricted.
- NEVER impersonate humans or speak on their behalf in chat, comments, PRs, or commits.
- NEVER use `--legacy-peer-deps` with npm/npx. Always resolve peer conflicts cleanly.

### Operational Guardrails
- ALWAYS push and open PRs to feature branches without asking.
- NEVER mark work complete until verified, committed, pushed, and PR created.
- ALWAYS stop on the first error; chain related commands with `&&`.
- ALWAYS block SQL injection, XSS, and unsanitized inputs in code and docs.
- For temporary storage, ALWAYS use `./.tmp/` if git-ignored, otherwise `/tmp`.

### Git Workflow
1. Branching: `git checkout main && git pull && git switch -c feat/name && git push -u origin feat/name`.
2. PR Creation: `git fetch origin && git rebase origin/main && git log origin/main..HEAD --oneline`.
3. Updating: ALWAYS fetch and rebase `origin/main` before making new edits or pushing.
4. Closing: Link issues via `Closes #<issue_number>` ONLY if explicitly provided in the prompt or branch name. Never guess or hallucinate issue numbers.

### Project Standards
- ALWAYS use Conventional Commits (derive scope from the primary directory modified, e.g., `feat(auth):`).
- ALWAYS use latest stable packages; NEVER downgrade or edit lock files silently.
- ALWAYS use minimum permissions (e.g., `permissions: {}` in GitHub Actions).
- ALWAYS use GitHub Releases; NEVER add manual version tracking artifacts.

## Macros
- GREEN #number: Rebase `main`, verify `gh pr view/checks`, and fix CI errors before pushing.
- AUDIT #target: Scan for style, orphan code, and pattern regressions. Report before fixing.
- STABILIZE #workflow: Check `permissions: {}`, `set -euo pipefail`, and `&&` chaining. Fix reliability gaps.
