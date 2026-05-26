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
        local is_destructive=false
        if [[ "$sub" == "rebase" ]]; then
            for arg in "$@"; do
                if [[ "$arg" == "-i" || "$arg" == "--interactive" || "$arg" == "squash" || "$arg" == "fixup" || "$arg" == "--autosquash" || "$arg" =~ autosquash ]]; then
                    is_destructive=true
                    break
                fi
            done
        elif [[ "$sub" == "merge" ]]; then
            for arg in "$@"; do
                if [[ "$arg" == "--squash" || "$arg" == "squash" ]]; then
                    is_destructive=true
                    break
                fi
            done
        fi

        if [[ "$is_destructive" == "true" ]]; then
            echo "BLOCKED: Squashing or interactive rebasing destroys history and makes change review difficult. Never squash commits in PR branches." >&2
            return 1
        fi

        # Block tag pushes in all forms
        if [[ "$sub" == "push" ]]; then
            for arg in "$@"; do
                if echo "$arg" | grep -qE "^(--tags|--follow-tags|refs/tags/|.*:refs/tags/)"; then
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

    fi

    command gh "$@"
}

export -f gh

oc() {
    # Treat as completion ONLY if both variables are non-empty and it is a completion call
    local is_completion=false
    if [[ -n "${COMP_LINE:-}" && -n "${COMP_POINT:-}" && "$1" == "__complete" ]]; then
        is_completion=true
    fi

    if [[ "$is_completion" != "true" ]]; then
        echo "BLOCKED: Running oc directly is restricted." >&2
        return 1
    fi

    command oc "$@"
}

export -f oc

kubectl() {
    # Treat as completion ONLY if both variables are non-empty and it is a completion call
    local is_completion=false
    if [[ -n "${COMP_LINE:-}" && -n "${COMP_POINT:-}" && "$1" == "__complete" ]]; then
        is_completion=true
    fi

    if [[ "$is_completion" != "true" ]]; then
        echo "BLOCKED: Running kubectl directly is restricted." >&2
        return 1
    fi

    command kubectl "$@"
}

export -f kubectl

npm() {
    # Skip during tab completion
    if [[ -z "${COMP_LINE:-}" && -z "${COMP_POINT:-}" ]]; then
        # Check environment bypass vector
        if [[ -n "${NPM_CONFIG_LEGACY_PEER_DEPS:-}" ]]; then
            echo "BLOCKED: NPM_CONFIG_LEGACY_PEER_DEPS is set. Bypassing peer deps is forbidden." >&2
            return 1
        fi

        # Check arguments for exact flags
        for arg in "$@"; do
            if [[ "$arg" == "--legacy-peer-deps" || "$arg" =~ ^--legacy-peer-deps= ]]; then
                echo "BLOCKED: npm with --legacy-peer-deps is strictly forbidden. Resolve your peer dependency conflicts cleanly instead of bypassing them." >&2
                return 1
            fi
        done
    fi

    command npm "$@"
}

export -f npm

npx() {
    # Skip during tab completion
    if [[ -z "${COMP_LINE:-}" && -z "${COMP_POINT:-}" ]]; then
        # Check environment bypass vector
        if [[ -n "${NPM_CONFIG_LEGACY_PEER_DEPS:-}" ]]; then
            echo "BLOCKED: NPM_CONFIG_LEGACY_PEER_DEPS is set. Bypassing peer deps is forbidden." >&2
            return 1
        fi

        # Check arguments for exact flags
        for arg in "$@"; do
            if [[ "$arg" == "--legacy-peer-deps" || "$arg" =~ ^--legacy-peer-deps= ]]; then
                echo "BLOCKED: npx with --legacy-peer-deps is strictly forbidden. Resolve your peer dependency conflicts cleanly instead of bypassing them." >&2
                return 1
            fi
        done
    fi

    command npx "$@"
}

export -f npx

