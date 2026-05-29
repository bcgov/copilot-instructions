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
            echo "BLOCKED: AI Agents are STRICTLY FORBIDDEN from modifying Git configuration." >&2
            echo "         Changes to Git configuration could alter repository behavior and bypass safety rules." >&2
            echo "         HALT immediately and request manual action from the USER." >&2
            return 1
        fi

        # Block tagging
        if [[ "$sub" == "tag" ]]; then
            echo "BLOCKED: AI Agents are STRICTLY FORBIDDEN from tagging commits." >&2
            echo "         AI is not allowed to manage git tags or cut releases." >&2
            echo "         HALT immediately and request manual action from the USER." >&2
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
            echo "BLOCKED: AI Agents are STRICTLY FORBIDDEN from squashing commits or interactive rebasing." >&2
            echo "         Squashing destroys git history and makes change review difficult." >&2
            echo "         HALT immediately and request manual action from the USER." >&2
            return 1
        fi

        # Block tag pushes in all forms
        if [[ "$sub" == "push" ]]; then
            for arg in "$@"; do
                if echo "$arg" | grep -qE "^(--tags|--follow-tags|refs/tags/|.*:refs/tags/)"; then
                    echo "BLOCKED: AI Agents are STRICTLY FORBIDDEN from pushing tags." >&2
                    echo "         AI is not allowed to manage git tags or cut releases." >&2
                    echo "         HALT immediately and request manual action from the USER." >&2
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
        # Identify command and subcommand (skip global options like -R, --repo, etc.)
        local cmd=""
        local sub=""
        local args=("$@")
        local i=0
        while [[ $i -lt ${#args[@]} ]]; do
            case "${args[$i]}" in
                -R|--repo|--app|--host)
                    ((i+=2))
                    ;;
                -*)
                    ((i+=1))
                    ;;
                *)
                    if [[ -z "$cmd" ]]; then
                        cmd="${args[$i]}"
                    elif [[ -z "$sub" ]]; then
                        sub="${args[$i]}"
                        break
                    fi
                    ((i+=1))
                    ;;
            esac
        done

        if [[ "$cmd" == "release" ]]; then
            echo "BLOCKED: AI Agents are STRICTLY FORBIDDEN from managing GitHub Releases." >&2
            echo "         AI is not allowed to cut releases or manage git tags." >&2
            echo "         HALT immediately and request manual action from the USER." >&2
            return 1
        elif [[ "$cmd" == "repo" && "$sub" == "delete" ]]; then
            echo "BLOCKED: AI Agents are STRICTLY FORBIDDEN from deleting repositories." >&2
            echo "         Repository deletion is highly destructive and irreversible." >&2
            echo "         HALT immediately and request manual action from the USER." >&2
            return 1
        elif [[ "$cmd" == "secret" ]]; then
            echo "BLOCKED: AI Agents are STRICTLY FORBIDDEN from managing repository secrets." >&2
            echo "         Secret management must be handled directly by the USER." >&2
            echo "         HALT immediately." >&2
            return 1
        elif [[ "$cmd" == "pr" ]]; then
            if [[ "$sub" == "merge" ]]; then
                echo "BLOCKED: AI Agents are STRICTLY FORBIDDEN from merging Pull Requests." >&2
                echo "         Under bcgov/copilot-instructions policy, all merges must be reviewed and executed manually by the USER." >&2
                echo "         Do NOT attempt to bypass this block using absolute paths, alternate flags, or command overrides." >&2
                echo "         HALT immediately and report to the user." >&2
                return 1
            elif [[ "$sub" == "review" ]]; then
                local has_approve=false
                for arg in "$@"; do
                    if [[ "$arg" == "--approve" || "$arg" == "-a" ]]; then
                        has_approve=true
                        break
                    fi
                done
                if [[ "$has_approve" == "true" ]]; then
                    echo "BLOCKED: AI Agents are STRICTLY FORBIDDEN from approving Pull Requests." >&2
                    echo "         Self-approving or bypass-approving is a direct violation of repository security guardrails." >&2
                    echo "         HALT immediately and request manual approval from the USER." >&2
                    return 1
                fi
            fi
        fi
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
        echo "BLOCKED: AI Agents are STRICTLY FORBIDDEN from running OpenShift (oc) commands directly." >&2
        echo "         Direct cluster interaction is restricted to ensure system stability." >&2
        echo "         HALT immediately and request manual action from the USER." >&2
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
        echo "BLOCKED: AI Agents are STRICTLY FORBIDDEN from running Kubernetes (kubectl) commands directly." >&2
        echo "         Direct cluster interaction is restricted to ensure system stability." >&2
        echo "         HALT immediately and request manual action from the USER." >&2
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
            echo "BLOCKED: AI Agents are STRICTLY FORBIDDEN from bypassing peer dependencies." >&2
            echo "         NPM_CONFIG_LEGACY_PEER_DEPS environment variable must not be set." >&2
            echo "         HALT immediately and resolve peer dependency conflicts cleanly." >&2
            return 1
        fi

        # Check arguments for exact flags
        for arg in "$@"; do
            if [[ "$arg" == "--legacy-peer-deps" || "$arg" =~ ^--legacy-peer-deps= ]]; then
                echo "BLOCKED: AI Agents are STRICTLY FORBIDDEN from bypassing peer dependencies." >&2
                echo "         npm with --legacy-peer-deps is strictly forbidden." >&2
                echo "         HALT immediately and resolve peer dependency conflicts cleanly." >&2
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
            echo "BLOCKED: AI Agents are STRICTLY FORBIDDEN from bypassing peer dependencies." >&2
            echo "         NPM_CONFIG_LEGACY_PEER_DEPS environment variable must not be set." >&2
            echo "         HALT immediately and resolve peer dependency conflicts cleanly." >&2
            return 1
        fi

        # Check arguments for exact flags
        for arg in "$@"; do
            if [[ "$arg" == "--legacy-peer-deps" || "$arg" =~ ^--legacy-peer-deps= ]]; then
                echo "BLOCKED: AI Agents are STRICTLY FORBIDDEN from bypassing peer dependencies." >&2
                echo "         npx with --legacy-peer-deps is strictly forbidden." >&2
                echo "         HALT immediately and resolve peer dependency conflicts cleanly." >&2
                return 1
            fi
        done
    fi

    command npx "$@"
}

export -f npx
