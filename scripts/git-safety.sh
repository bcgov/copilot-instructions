#!/bin/bash

# GitHub CLI Safety - Prevents dangerous operations
# Sourced by all bash sessions

gh() {
    # Skip during tab completion
    if [[ -z "${COMP_LINE:-}" && -z "${COMP_POINT:-}" ]]; then
        if [[ "$*" =~ ^(pr merge|repo delete|secret) ]]; then
            echo "BLOCKED: Command not allowed. Talk to the user." >&2
            return 1
        fi
    fi

    command gh "$@"
}

export -f gh
