#!/bin/bash

# GitHub CLI Safety - Prevents dangerous operations by AI and all users
# This file is automatically sourced by all bash sessions on the system
# Git operations are enforced via global hooks (see scripts/install-hooks.sh)

# GitHub CLI Safety Function - Prevents dangerous operations by AI and all users
# Uses blocklist approach: only truly dangerous commands are blocked
gh() {
    # Check blocklist (skip during tab completion)
    if [[ -z "${COMP_LINE:-}" && -z "${COMP_POINT:-}" ]]; then
        # Check actual gh subcommands, not just any string in arguments
        if [[ "$1 $2" == "pr merge" ]] || [[ "$1 $2" == "repo delete" ]] || [[ "$1" == "secret" ]]; then
            echo "🚨 BLOCKED: Command not allowed. Use GitHub UI instead." >&2
            return 1
        fi
    fi

    command gh "$@"
}

export -f gh
