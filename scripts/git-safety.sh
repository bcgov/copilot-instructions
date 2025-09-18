#!/bin/bash

# Git Safety Function - Prevents dangerous operations by AI and all users
# This file is automatically sourced by all bash sessions on the system

git() {
    local args="$*"

    # Skip safety checks during tab completion only
    if [[ -n "$COMP_LINE" || -n "$COMP_POINT" ]]; then
        $(command which git) "$@"
        return
    fi

    local current_branch=$(command git branch --show-current 2>/dev/null)
    local default_branch=$(command git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' 2>/dev/null || echo main)

    if [[ "$current_branch" = "$default_branch" ]]; then
        local first_cmd=$(echo "$args" | awk '{print $1}')
        local allowed_commands="branch checkout config diff fetch help log pull restore show status switch version"

        if [[ " $allowed_commands " != *" $first_cmd "* ]]; then
            echo "🚨 BLOCKED: '$first_cmd' not allowed on default branch ($default_branch)! Use feature branches."
            return 1
        fi
    fi

    $(command which git) "$@"
}

# GitHub CLI Safety Function - Prevents dangerous operations by AI and all users
# Uses allowlist approach: only explicitly allowed commands are permitted
gh() {
    local args="$*"

    # Skip safety checks during tab completion only
    if [[ -n "$COMP_LINE" || -n "$COMP_POINT" ]]; then
        $(command which gh) "$@"
        return
    fi

    # Parse command more robustly - handle both single and two-word commands
    local first_cmd=$(echo "$args" | awk '{print $1}')
    local second_cmd=$(echo "$args" | awk '{print $2}')
    local full_command="$first_cmd $second_cmd"

    # Handle common safe flags
    if [[ "$first_cmd" == "--version" ]]; then
        full_command="version"
    elif [[ "$first_cmd" == "--help" ]]; then
        full_command="help"
    elif [[ "$second_cmd" == "--version" ]]; then
        full_command="$first_cmd version"
    elif [[ "$second_cmd" == "--help" ]]; then
        full_command="$first_cmd help"
    elif [[ "$second_cmd" =~ ^--(json|jq|template)$ ]]; then
        # Allow output formatting flags for any command
        full_command="$first_cmd $second_cmd"
    fi

    # Define allowlist of safe commands
    local allowed_commands=(
        # Safe standalone commands
        "auth"
        "config"
        "version"
        "help"
        "browse"
        "search"
        "status"
        "completion"
        "extension"
        # Safe PR operations (close/reopen are easily reversible)
        "pr create"
        "pr list"
        "pr view"
        "pr status"
        "pr checkout"
        "pr diff"
        "pr close"
        "pr reopen"
        # Safe issue operations (close/reopen are easily reversible)
        "issue create"
        "issue list"
        "issue view"
        "issue status"
        "issue close"
        "issue reopen"
    )

    # Check if command is in allowlist
    local is_allowed=false
    for allowed in "${allowed_commands[@]}"; do
        if [[ "$full_command" == "$allowed" ]]; then
            is_allowed=true
            break
        fi
    done

    # Execute if allowed, block if not
    if [[ "$is_allowed" == true ]]; then
        $(command which gh) "$@"
    else
        echo "🚨 BLOCKED: 'gh $full_command' not in allowlist! Use GitHub UI for management."
        return 1
    fi
}

export -f git gh
