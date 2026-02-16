#!/bin/bash
set -euo pipefail

GITIGNORE_URL="https://raw.githubusercontent.com/bcgov/quickstart-openshift/main/.gitignore"
GLOBAL_GITIGNORE="$HOME/.gitignore_global"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
  echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

print_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
  echo -e "${YELLOW}ℹ $1${NC}"
}

print_skip() {
  echo -e "${YELLOW}→ $1${NC}"
}

# Function to set git config only if not already set
set_git_config() {
  local key="$1"
  local value="$2"
  local scope="${3:-global}"
  
  local current_value
  current_value=$(git config --"$scope" --get "$key" 2>/dev/null || true)
  
  if [[ -z "$current_value" ]]; then
    git config --"$scope" "$key" "$value"
    print_success "Set $key = $value"
  else
    print_skip "Skipping $key (already set to: $current_value)"
  fi
}

# Configure user name and email
configure_user() {
  print_header "Git User Configuration"
  
  local current_name
  local current_email
  current_name=$(git config --global --get user.name 2>/dev/null || true)
  current_email=$(git config --global --get user.email 2>/dev/null || true)
  
  if [[ -z "$current_name" ]]; then
    read -r -p "What is your name? " name
    if [[ -n "$name" ]]; then
      git config --global user.name "$name"
      print_success "Set user.name = $name"
    fi
  else
    print_skip "user.name already set to: $current_name"
  fi
  
  if [[ -z "$current_email" ]]; then
    read -r -p "What is your email address? " email
    if [[ -n "$email" ]]; then
      git config --global user.email "$email"
      print_success "Set user.email = $email"
    fi
  else
    print_skip "user.email already set to: $current_email"
  fi
}

# Set up global gitignore
configure_gitignore() {
  print_header "Global .gitignore Configuration"
  
  local current_gitignore
  current_gitignore=$(git config --global --get core.excludesfile 2>/dev/null || true)
  
  if [[ -n "$current_gitignore" ]] && [[ -f "$current_gitignore" ]]; then
    print_skip "core.excludesfile already set to: $current_gitignore"
    echo "File exists. How would you like to proceed?"
    echo "  1) Replace - overwrite with recommended patterns"
    echo "  2) Append - add recommended patterns to existing file"
    echo "  3) Skip - keep current file unchanged"
    read -r -p "Choose [1/2/3] (default: 3): " choice
    
    case "${choice}" in
      1)
        print_info "Downloading gitignore patterns from bcgov/quickstart-openshift..."
        if curl -fsSL "$GITIGNORE_URL" -o "$current_gitignore"; then
          print_success "Replaced $current_gitignore with recommended patterns"
        else
          print_info "Failed to download gitignore patterns"
        fi
        ;;
      2)
        print_info "Downloading gitignore patterns from bcgov/quickstart-openshift..."
        local temp_file
        temp_file=$(mktemp)
        if curl -fsSL "$GITIGNORE_URL" -o "$temp_file"; then
          {
            echo ""
            echo "# Patterns from bcgov/quickstart-openshift"
            cat "$temp_file"
          } >> "$current_gitignore"
          rm "$temp_file"
          print_success "Appended recommended patterns to $current_gitignore"
        else
          print_info "Failed to download gitignore patterns"
          rm "$temp_file"
        fi
        ;;
      *)
        print_skip "Keeping existing gitignore unchanged"
        ;;
    esac
  else
    print_info "Downloading global gitignore from bcgov/quickstart-openshift..."
    if curl -fsSL "$GITIGNORE_URL" -o "$GLOBAL_GITIGNORE"; then
      git config --global core.excludesfile "$GLOBAL_GITIGNORE"
      print_success "Set core.excludesfile = $GLOBAL_GITIGNORE"
    else
      print_info "Failed to download gitignore, skipping"
    fi
  fi
}

# Apply recommended git configurations
configure_git_settings() {
  print_header "Recommended Git Configuration"
  print_info "Applying settings from Git core developers' recommendations"
  
  # Basic branch settings
  set_git_config "init.defaultBranch" "main"
  set_git_config "branch.sort" "-committerdate"
  set_git_config "tag.sort" "version:refname"
  
  # Diff settings
  set_git_config "diff.algorithm" "histogram"
  set_git_config "diff.colorMoved" "plain"
  set_git_config "diff.mnemonicPrefix" "true"
  set_git_config "diff.renames" "true"
  
  # Push settings
  set_git_config "push.default" "simple"
  set_git_config "push.autoSetupRemote" "true"
  set_git_config "push.followTags" "true"
  
  # Fetch settings
  set_git_config "fetch.prune" "true"
  set_git_config "fetch.pruneTags" "true"
  
  # Rebase settings
  set_git_config "rebase.autoSquash" "true"
  set_git_config "rebase.autoStash" "true"
  set_git_config "rebase.updateRefs" "true"
  
  # Commit settings
  set_git_config "commit.verbose" "true"
  
  # Rerere (reuse recorded resolution)
  set_git_config "rerere.enabled" "true"
  set_git_config "rerere.autoupdate" "true"
  
  # Help settings
  set_git_config "help.autocorrect" "prompt"
  
  # Column display
  set_git_config "column.ui" "auto"
  
  # Grep settings
  set_git_config "grep.patternType" "perl"
}

# Main execution
main() {
  echo -e "${BLUE}=== Git Configuration Setup ===${NC}"
  echo -e "${BLUE}bcgov/copilot-instructions${NC}"
  
  configure_user
  configure_gitignore
  configure_git_settings
  
  print_header "Setup Complete!"
  echo -e "${GREEN}Your Git configuration has been updated with recommended settings.${NC}"
  echo -e "${YELLOW}Run 'git config --global --list' to see all your global settings.${NC}"
  echo ""
}

main
