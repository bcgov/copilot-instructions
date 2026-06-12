#!/bin/bash
# git-safety — bcgov/copilot-instructions
# Clean, non-exported shell safety functions that protect against AI mistakes
# while remaining completely transparent and bypassable for human developers.

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

        # Block hook circumvention (--no-verify and -n bypass)
        local is_commit=false
        if [[ "$sub" == "commit" ]]; then
            is_commit=true
        fi

        for arg in "$@"; do
            if [[ "$arg" == "--" ]]; then
                break
            fi

            if [[ "$arg" =~ ^- ]]; then
                if [[ "$arg" == "--no-verify" ]]; then
                    echo "BLOCKED: AI Agents are STRICTLY FORBIDDEN from bypassing Git hooks." >&2
                    echo "         Using --no-verify violates repository security policy." >&2
                    echo "         HALT immediately and request manual action from the USER." >&2
                    return 1
                fi

                # Check for commit short options containing 'n' (e.g. -n, -nam, -an)
                if [[ "$is_commit" == "true" && "$arg" =~ ^-[^-] ]]; then
                    local opts="${arg#\-}"
                    local idx=0
                    while [[ $idx -lt ${#opts} ]]; do
                        local opt="${opts:$idx:1}"
                        if [[ "$opt" == "n" ]]; then
                            echo "BLOCKED: AI Agents are STRICTLY FORBIDDEN from bypassing Git hooks." >&2
                            echo "         Using -n/--no-verify violates repository security policy." >&2
                            echo "         HALT immediately." >&2
                            return 1
                        fi
                        # Stop scanning option characters if this option consumes the rest as an argument
                        if [[ "$opt" =~ [mFccCt] ]]; then
                            break
                        fi
                        ((idx++))
                    done
                fi
            fi
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

        # Block destructive squashing / interactive rebase
        local is_destructive=false
        if [[ "$sub" == "rebase" ]]; then
            for arg in "$@"; do
                if [[ "$arg" == "-i" || "$arg" == "--interactive" || "$arg" == "squash" || "$arg" == "fixup" || "$arg" == "--autosquash" ]]; then
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
        elif [[ "$cmd" == "issue" ]]; then
            if [[ "$sub" == "create" || "$sub" == "comment" || "$sub" == "edit" || "$sub" == "close" || "$sub" == "reopen" || "$sub" == "delete" ]]; then
                echo "BLOCKED: AI Agents are STRICTLY FORBIDDEN from creating, editing, commenting on, or closing issues." >&2
                echo "         Running write commands via 'gh issue' posts content using the USER's identity, which violates impersonation policies." >&2
                echo "         HALT immediately. Output the issue/comment content to the chat for the USER to post manually." >&2
                return 1
            fi
        elif [[ "$cmd" == "pr" ]]; then
            if [[ "$sub" == "create" || "$sub" == "comment" || "$sub" == "close" || "$sub" == "reopen" || "$sub" == "review" ]]; then
                echo "BLOCKED: AI Agents are STRICTLY FORBIDDEN from creating, commenting on, reviewing, or closing Pull Requests." >&2
                echo "         Running write commands via 'gh pr' posts content using the USER's identity, which violates impersonation policies." >&2
                echo "         HALT immediately. Output the details/commands to the chat for the USER to execute manually." >&2
                return 1
            elif [[ "$sub" == "merge" ]]; then
                echo "BLOCKED: AI Agents are STRICTLY FORBIDDEN from merging Pull Requests." >&2
                echo "         Under bcgov/copilot-instructions policy, all merges must be reviewed and executed manually by the USER." >&2
                echo "         Do NOT attempt to bypass this block using absolute paths, alternate flags, or command overrides." >&2
                echo "         HALT immediately and report to the user." >&2
                return 1
            fi
        fi
    fi

    command gh "$@"
}

npm() {
    # Skip during tab completion
    if [[ -z "${COMP_LINE:-}" && -z "${COMP_POINT:-}" ]]; then
        # Block environment-based bypass vector
        if [[ -n "${NPM_CONFIG_LEGACY_PEER_DEPS:-}" ]]; then
            echo "BLOCKED: AI Agents are STRICTLY FORBIDDEN from bypassing peer dependencies." >&2
            echo "         NPM_CONFIG_LEGACY_PEER_DEPS environment variable must not be set." >&2
            echo "         HALT immediately and resolve peer dependency conflicts cleanly." >&2
            return 1
        fi

        # Block flag-based bypass
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

npx() {
    # Skip during tab completion
    if [[ -z "${COMP_LINE:-}" && -z "${COMP_POINT:-}" ]]; then
        # Block environment-based bypass vector
        if [[ -n "${NPM_CONFIG_LEGACY_PEER_DEPS:-}" ]]; then
            echo "BLOCKED: AI Agents are STRICTLY FORBIDDEN from bypassing peer dependencies." >&2
            echo "         NPM_CONFIG_LEGACY_PEER_DEPS environment variable must not be set." >&2
            echo "         HALT immediately and resolve peer dependency conflicts cleanly." >&2
            return 1
        fi

        # Block flag-based bypass
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
