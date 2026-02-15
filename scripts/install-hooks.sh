#!/usr/bin/env bash
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

install_gitleaks
install_hooks

echo "Global git hooks installed. Secrets are blocked at commit time; pushes to main are blocked."
