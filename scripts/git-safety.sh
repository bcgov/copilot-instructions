#!/bin/bash

# GitHub CLI Safety - Prevents dangerous operations by AI and all users
# This file is automatically sourced by all bash sessions on the system
# Git operations are enforced via global hooks (see scripts/install-hooks.sh)

# GitHub CLI Safety Function - Prevents dangerous operations by AI and all users
# Uses blocklist approach: only truly dangerous commands are blocked
gh() {
    local blocked_commands=("pr merge" "repo delete" "secret")

    # Skip safety checks during tab completion only
    if [[ -n "${COMP_LINE:-}" || -n "${COMP_POINT:-}" ]]; then
        $(command which gh) "$@"
        return
    fi

    # Block only truly dangerous commands
    for cmd in "${blocked_commands[@]}"; do
        if [[ "$*" == *"$cmd"* ]]; then
            echo "🚨 BLOCKED: 'gh $cmd' not allowed. Use GitHub UI instead." >&2
            return 1
        fi
    done

    $(command which gh) "$@"
}

export -f gh
