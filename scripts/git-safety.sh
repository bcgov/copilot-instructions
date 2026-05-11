#!/bin/bash

# GitHub CLI Safety - Prevents dangerous operations
# Sourced by all bash sessions

git() {
    # Skip during tab completion
    if [[ -z "${COMP_LINE:-}" && -z "${COMP_POINT:-}" ]]; then
        # Identify the subcommand (skip global options like -C, -c, etc.)
        local sub=""
        local args=("$@")
        local i=0
        while [[ $i -lt ${#args[@]} ]]; do
            case "${args[$i]}" in
                -c|-C|--git-dir|--work-tree|--namespace|--super-prefix)
                    ((i+=2))
                    ;;
                -*)
                    ((i+=1))
                    ;;
                *)
                    sub="${args[$i]}"
                    break
                    ;;
            esac
        done

        # Block config
        if [[ "$sub" == "config" ]]; then
            echo "BLOCKED: git config is not allowed. Talk to the user." >&2
            return 1
        fi

        # Block tagging
        if [[ "$sub" == "tag" ]]; then
            echo "BLOCKED: Tagging is restricted. AI is not allowed to cut releases. Talk to the user." >&2
            return 1
        fi

        # Block destructive squashing operations
        if [[ "$*" =~ (rebase.*squash|merge.*squash|rebase.*fixup|rebase.*-i) ]]; then
            echo "BLOCKED: Squashing commits destroys history and makes change review difficult. Never squash commits in PR branches." >&2
            return 1
        fi

        # Block tag pushes in all forms
        if [[ "$sub" == "push" ]]; then
            for arg in "$@"; do
                if [[ "$arg" =~ ^(--tags|--follow-tags|refs/tags/|.*:refs/tags/) ]]; then
                    echo "BLOCKED: Pushing tags is restricted. AI is not allowed to cut releases. Talk to the user." >&2
                    return 1
                fi
            done
        fi
    fi

    command git "$@"
}

export -f git

gh() {
    # Skip during tab completion
    if [[ -z "${COMP_LINE:-}" && -z "${COMP_POINT:-}" ]]; then
        case "$1" in
            release)
                echo "BLOCKED: Release operations are restricted. AI is not allowed to cut releases. Talk to the user." >&2
                return 1
                ;;
            pr)
                if [[ "$2" == "merge" ]]; then
                    echo "BLOCKED: PR merging is restricted. Talk to the user." >&2
                    return 1
                fi
                ;;
            repo)
                if [[ "$2" == "delete" ]]; then
                    echo "BLOCKED: Repository deletion is restricted. Talk to the user." >&2
                    return 1
                fi
                ;;
            secret)
                echo "BLOCKED: Secret management is restricted. Talk to the user." >&2
                return 1
                ;;
        esac

        # Block squash merge variants
        if [[ "$*" =~ squash ]]; then
            echo "BLOCKED: Squashing commits destroys history and makes review difficult. Use regular merge or rebase instead." >&2
            return 1
        fi
    fi

    command gh "$@"
}

export -f gh
