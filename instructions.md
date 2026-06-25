## Behavioral Guidelines

### Think & Plan
- ALWAYS state assumptions, list interpretations, and default to simplicity.
- ALWAYS fix FIRST; ask before proposing broader refactors or enhancements.

### Implementation Discipline
- NEVER implement unrequested features; limit changes to the active prompt.
- ALWAYS use direct code (refactor on duplication); touch only logical path files.
- ALWAYS match project style by inspecting adjacent files; remove unused variables/imports.
- ALWAYS default environments/toggles to PROD when variables are missing.
- NEVER report "Done" without terminal verification (e.g., `ls`, `git status`).
- DIFF-AS-RECEIPT: Every turn with an edit MUST include a git diff in a collapsible HTML details block (using raw HTML <details> and <summary> tags).

### Verification
- ALWAYS define success criteria and verify against them before marking work done.
- ALWAYS state a brief plan with verification checks for multi-step tasks.

### Dependencies
- ALWAYS avoid dependencies for low-volume (<20 lines) logic.
- ALWAYS use libraries ONLY for complex/high-risk bespoke alternatives.
- ALWAYS verify new dependencies are lightweight and maintained.
- ZERO SPECULATION: Verify APIs via search/run command. NEVER guess.
- NEVER use abstract/clever solutions unless established.

### Fail Fast
- NEVER write silent fallbacks or rescue scripts on failure.
- If a precondition fails, ALWAYS stop immediately (e.g., return/throw/exit) with a clear error.

## Standards

### Hard Stops (Never)
- NEVER branch from a feature branch; ALWAYS start from main.
- NEVER push to main or merge PRs; leave merging to humans.
- NEVER rewrite history with interactive rebase or squashing (e.g., `rebase -i`, `--squash`).
- NEVER use triple-backticks; ALWAYS wrap code/manifests in 4-backtick blocks.
- NEVER commit or include credentials, secrets, or PII in code or PRs.
- NEVER silence diagnostics (`eslint-disable`, `@ts-ignore`); fix the root cause.
- NEVER delete failing tests; ALWAYS fix the code to make the test suite pass.
- NEVER run `oc` commands. Access to OpenShift is restricted.
- NEVER use credentials to post, or impersonate human contributors.
- NEVER use `--legacy-peer-deps` with npm/npx. Always resolve peer conflicts cleanly.
- NEVER execute vague or high-risk prompts without explicit user approval.
### Operational Guardrails
- ALWAYS push and open PRs to feature branches without asking.
- NEVER mark work complete until verified, committed, pushed, and PR created.
- ALWAYS stop on the first error; chain related commands with `&&`.
- ALWAYS block SQL injection, XSS, and unsanitized inputs in code and docs.
- For temporary storage, ALWAYS use `./.tmp/` if git-ignored, otherwise `/tmp`.

### Git Workflow
1. Branching: `git fetch origin && git checkout -b feat/name origin/main && git push -u origin HEAD`.
2. PR Creation: `unset GITHUB_TOKEN && gh pr create --fill`.
3. Updating: ALWAYS fetch and merge `origin/main` before making new edits or pushing.
4. Closing: ALWAYS link issues via `Closes #<num>` ONLY if explicitly provided. NEVER guess.

### Project Standards
- ALWAYS use Conventional Commits.
- ALWAYS use latest stable packages; NEVER downgrade or edit lock files silently.
- ALWAYS use minimum permissions (e.g., `permissions: {}` in GitHub Actions).
- NEVER add manual version tracking artifacts.

### Model Complexity

CRITICAL: Match model tier to task complexity. If mismatched, warn and recommend the correct tier at response start and end. Say nothing if matched.

- **T1 (Trivial)**: Typos, formatting, basic scripts. (Warn to DOWNSCALE if T2/T3 active)
- **T2 (Standard)**: Features, refactors, tests. (Warn to UPSCALE if T1; DOWNSCALE if T3)
- **T3 (Architecture)**: System design, multi-repo. (Warn to UPSCALE if T1/T2 active)

