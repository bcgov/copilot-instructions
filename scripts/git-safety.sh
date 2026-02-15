#!/bin/bash

# GitHub CLI Safety - Prevents dangerous operations
# This file is automatically sourced by all bash sessions on the system
# Git operations are enforced via global hooks (see scripts/install-hooks.sh)

# GitHub CLI Safety Function - Blocklist approach: only truly dangerous commands
gh() {
gh() {
    # Check blocklist (skip during tab completion)
    if [[ -z "${COMP_LINE:-}" && -z "${COMP_POINT:-}" ]]; then
        if [[ "$*" =~ ^(pr merge|repo delete|secret) ]]; then
            echo "BLOCKED: Command not allowed. Talk to the user." >&2
            return 1
        fi
    fi

    command gh "$@"
}

export -f gh
