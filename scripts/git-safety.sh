#!/bin/bash

# GitHub CLI Safety - Prevents dangerous operations by AI and all users
# This file is automatically sourced by all bash sessions on the system
# Git operations are enforced via global hooks (see scripts/install-hooks.sh)

# GitHub CLI Safety Function - Prevents dangerous operations by AI and all users
# Uses blocklist approach: only truly dangerous commands are blocked
gh() {
    local args="$*"

    # Skip safety checks during tab completion only
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
