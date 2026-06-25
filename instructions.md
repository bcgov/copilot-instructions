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
1. Branching: `git checkout main && git pull && git switch -c feat/name && git push -u origin feat/name`.
2. PR Creation: `gh pr create --fill`.
3. Updating: ALWAYS fetch and merge `origin/main` before making new edits or pushing.
4. Closing: ALWAYS link issues via `Closes #<num>` ONLY if explicitly provided. NEVER guess.

### Project Standards
- ALWAYS use Conventional Commits.
- ALWAYS use latest stable packages; NEVER downgrade or edit lock files silently.
- ALWAYS use minimum permissions (e.g., `permissions: {}` in GitHub Actions).
- NEVER add manual version tracking artifacts.

### Model Cost & Complexity

CRITICAL: Match model to task complexity (if active class is unknown, ask; do not guess). If mismatched, ALWAYS warn and recommend the correct tier at response start and end.

- TIER 1 (Trivial): Typos, formatting, single-file scripts, basic explanations.
  - Action: DOWNSCALE WARNING if Tier 2/3 model is active.
- TIER 2 (Standard): Features, refactors, tests. UPSCALE if Tier 1; DOWNSCALE if Tier 3.
- TIER 3 (Architecture): Distributed systems, concurrency, major migrations, multi-repo.
  - Action: UPSCALE WARNING if Tier 1/2 active.

