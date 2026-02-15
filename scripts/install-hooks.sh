#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
HOOKS_DIR="$HOME/.githooks"
BIN_DIR="$HOME/.local/bin"

install_gitleaks() {
  mkdir -p "$BIN_DIR"

  local os
  local arch
  os=$(uname -s | tr '[:upper:]' '[:lower:]')
  arch=$(uname -m)

  case "$arch" in
    x86_64|amd64)
      arch="x64"
      ;;
    arm64|aarch64)
      arch="arm64"
      ;;
    *)
      echo "ERROR: Unsupported architecture: $arch" >&2
      exit 1
      ;;
  esac

  case "$os" in
    linux|darwin)
      ;;
    *)
      echo "ERROR: Unsupported OS: $os" >&2
      exit 1
      ;;
  esac

  local latest_url
  latest_url=$(curl -fsSL "https://api.github.com/repos/gitleaks/gitleaks/releases/latest" \
    | grep -Eo '"browser_download_url"\s*:\s*"[^"]+"' \
    | cut -d '"' -f 4 \
    | grep "gitleaks_.*_${os}_${arch}\.tar\.gz" \
    | head -n 1)

  if [[ -z "${latest_url:-}" ]]; then
    echo "ERROR: Could not find latest gitleaks tarball for ${os}_${arch}." >&2
    exit 1
  fi

  curl -fsSL "$latest_url" | tar -xz -C "$BIN_DIR" gitleaks

  if ! command -v gitleaks >/dev/null 2>&1; then
    echo "NOTE: Ensure $BIN_DIR is on your PATH to use gitleaks." >&2
  fi
}

install_hooks() {
  mkdir -p "$HOOKS_DIR"

  if [[ ! -f "$SCRIPT_DIR/hooks/pre-commit" ]]; then
    echo "ERROR: Hook file not found: $SCRIPT_DIR/hooks/pre-commit" >&2
    exit 1
  fi

  if [[ ! -f "$SCRIPT_DIR/hooks/pre-push" ]]; then
    echo "ERROR: Hook file not found: $SCRIPT_DIR/hooks/pre-push" >&2
    exit 1
  fi

  # Backup existing hooks if they exist
  local timestamp
  timestamp=$(date +%s)
  
  if [[ -f "$HOOKS_DIR/pre-commit" ]]; then
    mv "$HOOKS_DIR/pre-commit" "$HOOKS_DIR/pre-commit.bak.$timestamp"
    echo "NOTE: Existing pre-commit hook backed up to $HOOKS_DIR/pre-commit.bak.$timestamp" >&2
  fi
  
  if [[ -f "$HOOKS_DIR/pre-push" ]]; then
    mv "$HOOKS_DIR/pre-push" "$HOOKS_DIR/pre-push.bak.$timestamp"
    echo "NOTE: Existing pre-push hook backed up to $HOOKS_DIR/pre-push.bak.$timestamp" >&2
  fi

  cp "$SCRIPT_DIR/hooks/pre-commit" "$HOOKS_DIR/pre-commit"
  cp "$SCRIPT_DIR/hooks/pre-push" "$HOOKS_DIR/pre-push"

  chmod +x "$HOOKS_DIR/pre-commit" "$HOOKS_DIR/pre-push"

  # Check and warn about existing git config
  local current_hooks_path
  current_hooks_path=$(git config --global --get core.hooksPath 2>/dev/null || true)
  
  if [[ -n "${current_hooks_path:-}" ]] && [[ "$current_hooks_path" != "$HOOKS_DIR" ]]; then
    echo "WARNING: Your global git core.hooksPath is currently set to: $current_hooks_path" >&2
    echo "This script will change it to: $HOOKS_DIR" >&2
    read -r -p "Do you want to proceed? [y/N]: " answer
    if [[ "${answer:-n}" != "y" ]] && [[ "${answer:-n}" != "Y" ]]; then
      echo "Skipped updating global core.hooksPath. Hooks were copied to $HOOKS_DIR." >&2
      return 0
    fi
  fi

  git config --global core.hooksPath "$HOOKS_DIR"
}

install_gh_safety() {
  local bashrc="$HOME/.bashrc"
  local git_safety="$SCRIPT_DIR/git-safety.sh"
  
  if grep -q "AI POLICY (bcgov/copilot-instructions)" "$bashrc" 2>/dev/null; then
    echo "NOTE: Remove the existing gh() function in ~/.bashrc to re-install it." >&2
    return 0
  fi

  if [[ ! -f "$git_safety" ]]; then
    echo "ERROR: Could not find $git_safety" >&2
    return 1
  fi

  cat >> "$bashrc" << 'EOF'

# ============================================
# AI POLICY (bcgov/copilot-instructions)
# - NEVER push to main or merge PRs
# - NEVER run destructive GitHub CLI commands; talk to the user
# - Use feature branches + PRs only
# ============================================

EOF

  # Append the gh safety function from git-safety.sh (skip shebang)
  tail -n +2 "$git_safety" >> "$bashrc"
  
  echo "Added GitHub CLI safety to ~/.bashrc"
}

install_gitleaks
install_hooks
if ! install_gh_safety; then
  echo "ERROR: Failed to install GitHub CLI safety." >&2
  exit 1
fi

echo ""
echo "✅ Setup complete!"
echo "Git hooks: Secrets blocked (Gitleaks) + main/master push blocked"
echo "GitHub CLI: Blocklist enforced (gh pr merge, repo delete, secret blocked)"
echo ""
echo "Restart your terminal or run: source ~/.bashrc"
