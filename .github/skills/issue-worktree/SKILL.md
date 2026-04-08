# Issue Worktree Skill

Use this skill when asked to work on a GitHub issue in an isolated worktree. It uses `git worktree` to keep issue work separate from your main checkout and supports a clean issue-to-PR workflow.

## Objective
Automatically set up a dedicated `git worktree`, implement the requested fix, submit a PR with correct closure language, and keep the worktree available until the user confirms cleanup.

## The Standard Protocol

### 1. Verification & Selection
- Identify the Issue ID (e.g., #123).
- Verify the base branch exists (usually `main`).

### 2. Workspace Setup
- Verify which base branch exists (usually `main`) and use that verified branch in the setup commands below.
- Create a dedicated worktree:
  ```bash
  export ISSUE_ID="<id>"
  export BASE_BRANCH="<verified-base-branch>"
  git worktree add .workspaces/$ISSUE_ID -b fix/$ISSUE_ID "$BASE_BRANCH"
  ```
- Add `.workspaces/` to your local exclude list to prevent accidental commits:
  ```bash
  echo ".workspaces" >> .git/info/exclude
  ```
- All subsequent operations MUST be performed inside `.workspaces/$ISSUE_ID`.

### 3. Implementation Ritual
- **Step 1: Test Baseline.** Run existing tests if they exist to confirm the current state.
- **Step 2: Surgical Edit.** Apply changes following the "Surgical Changes" rule in the Copilot instructions.
- **Step 3: Verification.** Run tests to confirm the fix works and no regressions were introduced.

### 4. The Pull Request
- Stage and commit following **Conventional Commits** (e.g., `fix: resolve issue #123`).
- Push the branch: `git push -u origin fix/$ISSUE_ID`.
- Create the PR:
  ```bash
  gh pr create --title "fix: resolution for #$ISSUE_ID" --body $'## Summary\n\n[Description of changes]\n\nCloses #$ISSUE_ID'
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
