# Autonomous Worktree Skill

Use this skill when tasked with work on a GitHub Issue. It ensures a clean, isolated environment using `git worktree`, allowing you to work on multiple issues in parallel without workspace contamination.

## Objective
Automatically set up a dedicated `git worktree`, implement the requested fix, submit a PR with correct closure language, and clean up the environment.

## The Standard Protocol

### 1. Verification & Selection
- Identify the Issue ID (e.g., #123).
- Verify the base branch exists (usually `main`).

### 2. Workspace Setup
- Create a dedicated worktree:
  ```bash
  export ISSUE_ID="<id>"
  git worktree add .workspaces/$ISSUE_ID -b fix/$ISSUE_ID main
  ```
- All subsequent operations MUST be performed inside `.workspaces/$ISSUE_ID`.

### 3. Implementation Ritual
- **Step 1: Test Baseline.** Run existing tests if they exist to confirm the current state.
- **Step 2: Surgical Edit.** Apply changes following the "Surgical Changes" rule in `copilot-instructions.md`.
- **Step 3: Verification.** Run tests to confirm the fix works and no regressions were introduced.

### 4. The Pull Request
- Stage and commit following **Conventional Commits** (e.g., `fix: resolve issue #123`).
- Push the branch: `git push -u origin fix/$ISSUE_ID`.
- Create the PR:
  ```bash
  gh pr create --title "fix: resolution for #$ISSUE_ID" --body "## Summary\n\n[Description of changes]\n\nCloses #$ISSUE_ID"
  ```

### 5. Cleanup (Post-Verification)
- DO NOT automatically remove the worktree unless the user explicitly confirms the PR looks good.
- Keep the workspace available for the user to inspect or for further refinements.
- Once confirmed by the user, remove the worktree:
  ```bash
  git worktree remove .workspaces/$ISSUE_ID --force
  git worktree prune
  ```

## Instructions for the AI
When using this skill:
- **ALWAYS** check for an existing `.workspaces/` folder to avoid conflicts.
- **ALWAYS** use the correct closure keywords ("Closes", "Fixes", or "Resolves").
- **PERSISTENCE**: DO NOT execute Step 5 (Cleanup) unless the user explicitly says "Cleanup the worktree" or "Delete the workspace" after the PR is created.
- **AUTONOMY**: If `// turbo` is enabled, execute the setup and implementation steps without asking, but respect the **PERSISTENCE** rule for cleanup.
