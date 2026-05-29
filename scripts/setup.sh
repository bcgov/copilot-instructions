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
  current_hooks_path=$(command git config --global --get core.hooksPath 2>/dev/null || true)
  
  if [[ -n "${current_hooks_path:-}" ]] && [[ "$current_hooks_path" != "$HOOKS_DIR" ]]; then
    echo "WARNING: Your global git core.hooksPath is currently set to: $current_hooks_path" >&2
    echo "This script will change it to: $HOOKS_DIR" >&2
    read -r -p "Do you want to proceed? [y/N]: " answer
    if [[ "${answer:-n}" != "y" ]] && [[ "${answer:-n}" != "Y" ]]; then
      echo "Skipped updating global core.hooksPath. Hooks were copied to $HOOKS_DIR." >&2
      return 0
    fi
  fi

  command git config --global core.hooksPath "$HOOKS_DIR"
}

cleanup_old_bashrc_safety() {
  local bashrc="$HOME/.bashrc"
  if [[ -f "$bashrc" ]]; then
    echo "Cleaning up old safety wrapper definitions from ~/.bashrc..."
    
    if command -v python3 >/dev/null 2>&1; then
      python3 -c '
import sys, re
path = sys.argv[1]
with open(path, "r") as f:
    content = f.read()

# 1. Clean up the new marked block first if it exists
content = re.sub(r"# >>> bcgov/copilot-instructions safety block >>>.*?# <<< bcgov/copilot-instructions safety block <<<\n*", "", content, flags=re.DOTALL)

# 2. Clean up legacy/historical unmarked blocks safely (matching up to their specific exports)
content = re.sub(r"# Git Safety.*?\nexport -f git\n*", "", content, flags=re.DOTALL)
content = re.sub(r"# GitHub CLI Safety.*?\nexport -f gh\n*", "", content, flags=re.DOTALL)
# Make sure we do not leave orphaned functions by matching through the entire old AI policy block
content = re.sub(r"# AI POLICY \(bcgov/copilot-instructions\).*?\nexport -f (gh|npx)\n*", "", content, flags=re.DOTALL)

# Remove trailing empty lines or excessive newlines
content = re.sub(r"\n{3,}", "\n\n", content)

with open(path, "w") as f:
    f.write(content)
' "$bashrc"
    else
      echo "WARNING: python3 is not available. Skipping deep regex cleanup of old safety blocks." >&2
      echo "         Any existing marked safety block will be cleaned up using basic sed." >&2
      
      # Securely strip marked block using sed fallback if present
      if grep -q "# >>> bcgov/copilot-instructions safety block >>>" "$bashrc"; then
        local temp_file
        temp_file=$(mktemp)
        sed '/# >>> bcgov/copilot-instructions safety block >>>/,/# <<< bcgov/copilot-instructions safety block <<</d' "$bashrc" > "$temp_file"
        cat "$temp_file" > "$bashrc"
        rm -f "$temp_file"
      fi
    fi
  fi
}

install_gh_safety() {
  local bashrc="$HOME/.bashrc"
  local git_safety="$SCRIPT_DIR/git-safety.sh"
  local timestamp
  timestamp=$(date +%s)
  
  # 1. Pre-flight check: Verify source file exists before modifying anything
  if [[ ! -f "$git_safety" ]]; then
    echo "ERROR: Could not find safety source script at $git_safety" >&2
    return 1
  fi

  # 2. Pre-flight check: Create a backup of ~/.bashrc first
  if [[ -f "$bashrc" ]]; then
    cp "$bashrc" "$bashrc.bak.$timestamp"
    echo "NOTE: Created backup of ~/.bashrc at $bashrc.bak.$timestamp" >&2
  fi

  # 3. Purge old blocks safely
  cleanup_old_bashrc_safety

  # 4. Append the gh safety function wrapped in explicit BEGIN/END markers (skip shebang)
  {
    echo ""
    echo "# >>> bcgov/copilot-instructions safety block >>>"
    echo "# AI POLICY (bcgov/copilot-instructions)"
    tail -n +2 "$git_safety"
    echo "# <<< bcgov/copilot-instructions safety block <<<"
  } >> "$bashrc"
  
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
echo "Git config: All git config commands blocked (use 'command git config' to bypass)"
echo "Kubernetes/OpenShift: All kubectl and oc commands blocked by default"
echo ""
echo "Restart your terminal or run: source ~/.bashrc"
