#!/bin/bash

# GitHub CLI Safety - Prevents dangerous operations by AI and all users
# This file is automatically sourced by all bash sessions on the system
# Git operations are enforced via global hooks (see scripts/install-hooks.sh)

# GitHub CLI Safety Function - Prevents dangerous operations by AI and all users
# Uses blocklist approach: only truly dangerous commands are blocked
gh() {
    local blocked_commands=("pr merge" "repo delete" "secret")

    # Check blocklist (skip during tab completion)
    if [[ -z "${COMP_LINE:-}" && -z "${COMP_POINT:-}" ]]; then
        for cmd in "${blocked_commands[@]}"; do
            if [[ "$*" == *"$cmd"* ]]; then
                echo "🚨 BLOCKED: 'gh $cmd' not allowed. Use GitHub UI instead." >&2
                return 1
            fi
        done
    fi

    command gh "$@"
}

export -f gh
