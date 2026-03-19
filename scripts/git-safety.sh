#!/bin/bash

# GitHub CLI Safety - Prevents dangerous operations
# Sourced by all bash sessions

git() {
    # Skip during tab completion
    if [[ -z "${COMP_LINE:-}" && -z "${COMP_POINT:-}" ]]; then
        if [[ "$*" =~ ^config ]]; then
            echo "BLOCKED: git config is not allowed. Talk to the user." >&2
            return 1
        fi
        # Block destructive squashing operations
        if [[ "$*" =~ (rebase.*squash|merge.*squash|rebase.*fixup|rebase.*-i) ]]; then
            echo "BLOCKED: Squashing commits destroys history and makes change review difficult. Never squash commits in PR branches." >&2
            return 1
        fi
    fi

    command git "$@"
}

export -f git

gh() {
    # Skip during tab completion
    if [[ -z "${COMP_LINE:-}" && -z "${COMP_POINT:-}" ]]; then
        if [[ "$*" =~ ^(pr merge|repo delete|secret) ]]; then
            echo "BLOCKED: Command not allowed. Talk to the user." >&2
            return 1
        fi
        # Block squash merge variants
        if [[ "$*" =~ squash ]]; then
            echo "BLOCKED: Squashing commits destroys history and makes review difficult. Use regular merge or rebase instead." >&2
            return 1
        fi
    fi

    command gh "$@"
}

export -f gh
