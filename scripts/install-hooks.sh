#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
HOOKS_DIR="$HOME/.githooks"
BIN_DIR="$HOME/.local/bin"

GITLEAKS_VERSION="8.18.2"

install_gitleaks() {
  if command -v gitleaks >/dev/null 2>&1; then
    return 0
  fi

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

  local tarball
  tarball="gitleaks_${GITLEAKS_VERSION}_${os}_${arch}.tar.gz"

  curl -fsSL "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/${tarball}" \
    | tar -xz -C "$BIN_DIR" gitleaks

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

  cp "$SCRIPT_DIR/hooks/pre-commit" "$HOOKS_DIR/pre-commit"
  cp "$SCRIPT_DIR/hooks/pre-push" "$HOOKS_DIR/pre-push"

  chmod +x "$HOOKS_DIR/pre-commit" "$HOOKS_DIR/pre-push"

  git config --global core.hooksPath "$HOOKS_DIR"
}

install_gh_safety() {
  local bashrc="$HOME/.bashrc"
  
  if grep -q "GitHub CLI Safety (copilot-instructions)" "$bashrc" 2>/dev/null; then
    echo "GitHub CLI safety already in ~/.bashrc"
    return 0
  fi

  cat >> "$bashrc" << 'EOF'

# ============================================
# AI POLICY (bcgov/copilot-instructions)
# - NEVER push to main or merge PRs
# - NEVER use gh pr merge (use GitHub UI)
# - Use feature branches + PRs only
# ============================================

# GitHub CLI Safety (copilot-instructions)
gh() {
    local args="$*"

    if [[ -n "${COMP_LINE:-}" || -n "${COMP_POINT:-}" ]]; then
        $(command which gh) "$@"
        return
    fi

    # Block only truly dangerous commands
    if [[ "$args" == *"pr merge"* ]]; then
        echo "🚨 BLOCKED: 'gh pr merge' not allowed. Use GitHub UI for merging." >&2
        return 1
    fi

    if [[ "$args" == *"repo delete"* ]]; then
        echo "🚨 BLOCKED: 'gh repo delete' not allowed. Use GitHub UI for deletion." >&2
        return 1
    fi

    if [[ "$args" == *" secret "* ]]; then
        echo "🚨 BLOCKED: 'gh secret' commands not allowed. Use GitHub UI for secrets." >&2
        return 1
    fi

    $(command which gh) "$@"
}
export -f gh
EOF

  echo "Added GitHub CLI safety to ~/.bashrc"
}

install_gitleaks
install_hooks
install_gh_safety

echo ""
echo "✅ Setup complete!"
echo "Git hooks: Secrets blocked (Gitleaks) + main/master push blocked"
echo "GitHub CLI: Allowlist enforced (gh pr merge blocked)"
echo ""
echo "Restart your terminal or run: source ~/.bashrc"
