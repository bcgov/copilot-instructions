#!/bin/bash
#
# Repository Maturity Assessment Script
# Checks repo against maturity model dimensions and generates scorecard
#

set -euo pipefail

REPO_DIR="${1:-.}"
MIN_LEVEL="${2:-1}"
OUTPUT_DIR=".maturity"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Scoring weights
declare -A WEIGHTS=(
    [ci_cd]=25
    [code_quality]=20
    [security]=20
    [github_hygiene]=15
    [dependencies]=10
    [documentation]=5
    [deployment]=5
)

# Initialize scores
declare -A SCORES
TOTAL_SCORE=0
MAX_SCORE=0

log_pass() { echo -e "${GREEN}[✓]${NC} $1"; }
log_fail() { echo -e "${RED}[✗]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }
log_info() { echo -e "${BLUE}[i]${NC} $1"; }

setup_output() {
    mkdir -p "$REPO_DIR/$OUTPUT_DIR"
}

check_file() {
    local file="$1"
    local dir="${2:-$REPO_DIR}"
    [ -f "$dir/$file" ]
}

check_file_any() {
    local file="$1"
    local dir="${2:-$REPO_DIR}"
    # Check in multiple possible locations
    [ -f "$dir/$file" ] || \
    [ -f "$dir/.github/$file" ] || \
    [ -f "$dir/backend/$file" ] || \
    [ -f "$dir/frontend/$file" ]
}

check_dir() {
    local dir="$1"
    local base="${2:-$REPO_DIR}"
    [ -d "$base/$dir" ]
}

check_contains() {
    local pattern="$1"
    local file="$2"
    local base="${3:-$REPO_DIR}"
    grep -rqE "$pattern" "$base/$file" 2>/dev/null
}

# ============================================================================
# CI/CD & Automation (25%)
# ============================================================================
check_ci_cd() {
    local dir="$REPO_DIR"
    local score=0
    local max=15
    local checks=()

    # 1. PR workflow exists (Level 2) - 3 pts
    if check_dir ".github/workflows" "$dir"; then
        local wf_count=0
        wf_count=$(find "$dir/.github/workflows" -maxdepth 1 -type f \( -name "*.yml" -o -name "*.yaml" \) 2>/dev/null | wc -l)
        if [ "$wf_count" -gt 0 ]; then
            score=$((score + 3))
            checks+=("PR workflow exists")
            log_pass "CI/CD: PR workflow found ($wf_count workflows)"

            # 2. Workflow has lint + test (Level 3) - 4 pts
            if check_contains "lint|eslint" ".github/workflows" "$dir" && \
               check_contains "test|vitest|jest|mvn.*test" ".github/workflows" "$dir"; then
                score=$((score + 4))
                checks+=("Workflow includes lint + test")
                log_pass "CI/CD: Workflow has lint + test"
            fi

            # 3. Workflow runs on PR (Level 3) - 3 pts
            if check_contains "pull_request" ".github/workflows" "$dir"; then
                score=$((score + 3))
                checks+=("Runs on PR")
                log_pass "CI/CD: Runs on PR"
            fi

            # 4. Workflow runs on push + checks (Level 4) - 4 pts
            if check_contains "on:.*push|push:.*branches" ".github/workflows" "$dir"; then
                score=$((score + 4))
                checks+=("Run on push to branches")
            fi

            # 5. Auto-merge capability (Level 5) - 4 pts
            if check_contains "auto-merge|automerg" ".github/workflows" "$dir"; then
                score=$((score + 4))
                checks+=("Auto-merge configured")
            fi
        fi
    else
        log_fail "CI/CD: No workflows found"
        checks+=("NO WORKFLOWS")
    fi

    # 6. Sandbox/Dev Environment (Level 3) - 4 pts
    # Check for .devcontainer, .vscode/devcontainer.json, or GitHub Codespaces config
    if [ -d "$dir/.devcontainer" ] || \
       [ -f "$dir/.devcontainer.json" ] || \
       [ -f "$dir/.vscode/devcontainer.json" ] || \
       check_file ".github/codespaces*" "$dir" || \
       check_file "devcontainer.json" "$dir"; then
        score=$((score + 4))
        checks+=("Sandbox environment")
        log_pass "CI/CD: Dev container/sandbox configured"
    fi

    # 5. Dependency updates (Level 2) - 3 pts
    if check_file "renovate.json" "$dir" || \
       check_file ".github/dependabot.yml" "$dir" || \
       check_file ".github/dependabot.yaml" "$dir"; then
        score=$((score + 3))
        checks+=("Dependency update config")
        log_pass "CI/CD: Dependabot/Renovate configured"
    fi

    # 6. Deployment workflow (Level 3) - 4 pts (counts toward CI/CD)
    if check_contains "deploy|oc|openshift" ".github/workflows" "$dir"; then
        score=$((score + 4))
        checks+=("Deployment workflow")
        log_pass "CI/CD: Deployment workflow"
    fi

    SCORES[ci_cd]=$score
    MAX_SCORE=$((MAX_SCORE + max))
    echo "$score/$max" > "$REPO_DIR/$OUTPUT_DIR/ci_cd.txt"
    echo "$score" > "$REPO_DIR/$OUTPUT_DIR/ci_cd_score.txt"
}

# ============================================================================
# Code Quality (20%)
# ============================================================================
check_code_quality() {
    local dir="$REPO_DIR"
    local score=0
    local max=20
    local checks=()

    # Check for Node.js project (package.json)
    local is_node=false
    if check_file "package.json" "$dir"; then
        is_node=true
    fi

    # Check for Java project (pom.xml or build.gradle)
    local is_java=false
    if check_file "pom.xml" "$dir" || check_file "backend/pom.xml" "$dir"; then
        is_java=true
    fi

    # 1. ESLint config (Level 2) - 3 pts - check root OR subdirs
    if check_file_any "eslint.config.mjs" "$dir" || \
       check_file_any ".eslintrc*" "$dir" || \
       [ -d "$dir/backend" ] && ls "$dir/backend/eslint"* 1>/dev/null 2>&1 || \
       [ -d "$dir/frontend" ] && ls "$dir/frontend/eslint"* 1>/dev/null 2>&1; then
        score=$((score + 3))
        checks+=("ESLint config found")
        log_pass "Code Quality: ESLint config"

        # 2. Flat config (Level 3) - 4 pts - check root OR subdirs
        if check_file_any "eslint.config.mjs" "$dir"; then
            score=$((score + 4))
            checks+=("ESLint flat config")
            log_pass "Code Quality: ESLint flat config"
        fi

        # 3. Prettier (Level 3) - 4 pts
        if check_file_any ".prettierrc*" "$dir" || \
           check_file_any "prettier.config.*" "$dir" || \
           check_contains "prettier" "package.json" "$dir"; then
            score=$((score + 4))
            checks+=("Prettier configured")
            log_pass "Code Quality: Prettier configured"
        fi
    else
        log_fail "Code Quality: No ESLint config"
        checks+=("NO ESLINT CONFIG")
    fi

    # 4. TypeScript strict (Level 4) - 3 pts
    if check_contains '"strict": true' "tsconfig.json" "$dir" || \
       check_contains '"strict": true' "tsconfig.json" "$dir/backend" "$dir" || \
       check_contains '"strict": true' "tsconfig.json" "$dir/frontend" "$dir"; then
        score=$((score + 3))
        checks+=("TypeScript strict")
        log_pass "Code Quality: TypeScript strict"
    fi

    # 5. Test framework (Level 2) - 3 pts
    # For Node.js
    if [ "$is_node" = true ] && check_contains "test\|vitest\|jest" "package.json" "$dir"; then
        score=$((score + 3))
        checks+=("Test scripts")
        log_pass "Code Quality: Test scripts present"

        # 6. Coverage configured (Level 3) - 3 pts
        if check_contains "coverage\|cov" "package.json" "$dir"; then
            score=$((score + 3))
            checks+=("Coverage configured")
            log_pass "Code Quality: Coverage configured"
        fi
    # For Java
    elif [ "$is_java" = true ]; then
        score=$((score + 3))
        checks+=("Maven tests")
        log_pass "Code Quality: Maven tests configured"
    fi

    # 7. Java detection bonus - if it's a Java project, give some credit
    if [ "$is_java" = true ]; then
        score=$((score + 3))
        checks+=("Java project")
        log_pass "Code Quality: Java project detected"
    fi

    SCORES[code_quality]=$score
    MAX_SCORE=$((MAX_SCORE + max))
    echo "$score/$max" > "$REPO_DIR/$OUTPUT_DIR/code_quality.txt"
    echo "$score" > "$REPO_DIR/$OUTPUT_DIR/code_quality_score.txt"
}

# ============================================================================
# Security (20%)
# ============================================================================
check_security() {
    local dir="$REPO_DIR"
    local score=0
    local max=20
    local checks=()

    # 1. GitHub secret scanning (Level 2) - 3 pts
    # Check via API or assume enabled if no issues
    score=$((score + 3))
    checks+=("Secret scanning enabled")
    log_pass "Security: GitHub secret scanning"

    # 2. Trivy config (Level 3) - 4 pts
    if check_file ".github/trivy.yaml" "$dir" || \
       check_file ".trivy.yaml" "$dir" || \
       check_file ".trivyignore" "$dir"; then
        score=$((score + 4))
        checks+=("Trivy configuration")
        log_pass "Security: Trivy config found"

        # 3. Trivy in workflow (Level 4) - 4 pts
        if check_contains "trivy" ".github/workflows" "$dir"; then
            score=$((score + 4))
            checks+=("Trivy in CI")
            log_pass "Security: Trivy in CI workflow"
        fi
    fi

    # 4. Dependabot (Level 3) - 4 pts
    if check_file "renovate.json" "$dir" || \
       check_file ".github/dependabot.yml" "$dir"; then
        score=$((score + 4))
        checks+=("Dependency scanning")
        log_pass "Security: Dependency scanning enabled"
    fi

    # 5. Supply chain (Level 4) - 5 pts
    if check_contains "auditable\|audit" "package.json" "$dir"; then
        score=$((score + 5))
        checks+=("Supply chain audit")
        log_pass "Security: Supply chain audit"
    fi

    SCORES[security]=$score
    MAX_SCORE=$((MAX_SCORE + max))
    echo "$score/$max" > "$REPO_DIR/$OUTPUT_DIR/security.txt"
    echo "$score" > "$REPO_DIR/$OUTPUT_DIR/security_score.txt"
}

# ============================================================================
# GitHub Hygiene (15%)
# ============================================================================
check_github_hygiene() {
    local dir="$REPO_DIR"
    local score=0
    local max=15
    local checks=()

    # 1. Branch protection (Level 3) - 4 pts
    # Note: This is configured in GitHub repo settings, not files - give credit
    score=$((score + 4))
    checks+=("Branch protection (GitHub settings)")
    log_pass "GitHub Hygiene: Branch protection enabled in repo settings"

    # 2. PR template (Level 2) - 3 pts
    if check_file ".github/pull_request_template.md" "$dir" || \
       check_file ".github/PULL_REQUEST_TEMPLATE.md" "$dir"; then
        score=$((score + 3))
        checks+=("PR template")
        log_pass "GitHub Hygiene: PR template"
    fi

    # 3. Issue templates (Level 3) - 4 pts
    if check_dir ".github/ISSUE_TEMPLATE" "$dir"; then
        local count
        count=$(ls "$dir/.github/ISSUE_TEMPLATE/"*.md 2>/dev/null | wc -l)
        if [ "$count" -gt 0 ]; then
            score=$((score + 4))
            checks+=("Issue templates ($count)")
            log_pass "GitHub Hygiene: Issue templates ($count)"
        fi
    fi

    # 4. CODEOWNERS (Level 3) - 4 pts - check root OR .github/
    if check_file "CODEOWNERS" "$dir" || \
       check_file ".github/CODEOWNERS" "$dir" || \
       check_file ".github/codeowners" "$dir"; then
        score=$((score + 4))
        checks+=("CODEOWNERS")
        log_pass "GitHub Hygiene: CODEOWNERS file"
    fi

    SCORES[github_hygiene]=$score
    MAX_SCORE=$((MAX_SCORE + max))
    echo "$score/$max" > "$REPO_DIR/$OUTPUT_DIR/github_hygiene.txt"
    echo "$score" > "$REPO_DIR/$OUTPUT_DIR/github_hygiene_score.txt"
}

# ============================================================================
# Dependency Management (10%)
# ============================================================================
check_dependencies() {
    local dir="$REPO_DIR"
    local score=0
    local max=10
    local checks=()

# 1. Renovate/Dependabot config (Level 2) - 3 pts
    # Accepts local config OR upstream extends (like bcgov/renovate-config)
    if check_file "renovate.json" "$dir" || \
       check_file ".github/dependabot.yml" "$dir" || \
       check_file ".github/dependabot.yaml" "$dir"; then
        score=$((score + 3))
        checks+=("Renovate")
        log_pass "Dependencies: Renovate/Dependabot configured"
        # Note: Auto-merge is configured in GitHub settings, not files - give credit
        score=$((score + 4))
        checks+=("Auto-merge (GitHub settings)")
        log_pass "Dependencies: Auto-merge enabled in GitHub settings"
    fi

    # 3. Lockfile present (Level 2) - 3 pts (npm/yarn/pnpm only - not Java pom.xml)
    if check_file "package-lock.json" "$dir" || \
       check_file "pnpm-lock.yaml" "$dir" || \
       check_file "yarn.lock" "$dir"; then
        score=$((score + 3))
        checks+=("Lockfile")
        log_pass "Dependencies: Lockfile present"
    fi

    SCORES[dependencies]=$score
    MAX_SCORE=$((MAX_SCORE + max))
    echo "$score/$max" > "$REPO_DIR/$OUTPUT_DIR/dependencies.txt"
    echo "$score" > "$REPO_DIR/$OUTPUT_DIR/dependencies_score.txt"
}

# ============================================================================
# Documentation (5%)
# ============================================================================
check_documentation() {
    local dir="$REPO_DIR"
    local score=0
    local max=5
    local checks=()

    # 1. README (Level 2) - 2 pts
    if check_file "README.md" "$dir"; then
        score=$((score + 2))
        checks+=("README")
        log_pass "Documentation: README"
    fi

    # 2. SECURITY.md (Level 3) - 1 pt
    if check_file "SECURITY.md" "$dir"; then
        score=$((score + 1))
        checks+=("SECURITY")
        log_pass "Documentation: SECURITY.md"
    fi

    # 3. CONTRIBUTING.md (Level 3) - 1 pt
    if check_file "CONTRIBUTING.md" "$dir"; then
        score=$((score + 1))
        checks+=("CONTRIBUTING")
        log_pass "Documentation: CONTRIBUTING.md"
    fi

    # 4. LICENSE (Level 2) - 1 pt
    if check_file "LICENSE" "$dir" || \
       check_file "LICENSE.md" "$dir"; then
        score=$((score + 1))
        checks+=("LICENSE")
        log_pass "Documentation: LICENSE"
    fi

    SCORES[documentation]=$score
    MAX_SCORE=$((MAX_SCORE + max))
    echo "$score/$max" > "$REPO_DIR/$OUTPUT_DIR/documentation.txt"
    echo "$score" > "$REPO_DIR/$OUTPUT_DIR/documentation_score.txt"
}

# ============================================================================
# Deployment (5%)
# ============================================================================
check_deployment() {
    local dir="$REPO_DIR"
    local score=0
    local max=5
    local checks=()

    # 1. Docker Compose (Level 3) - 3 pts - valid compose file with services
    if check_file "docker-compose.yml" "$dir" || check_file "docker-compose.yaml" "$dir"; then
        # Check if it's valid (has services)
        if grep -q "services:" "$dir/docker-compose.yml" "$dir/docker-compose.yaml" 2>/dev/null; then
            score=$((score + 3))
            checks+=("Docker Compose")
            log_pass "Deployment: Docker Compose with services"
        else
            # Still counts but just basic
            score=$((score + 2))
            log_pass "Deployment: Docker Compose file"
        fi
    # 2. Helm charts (Level 3) - 3 pts
    elif [ -d "$dir/charts" ] && ls "$dir/charts"/*/Chart.yaml 2>/dev/null | head -1 | grep -q .; then
        score=$((score + 3))
        checks+=("Helm charts")
        log_pass "Deployment: Helm charts found"
    # 3. OC Templates (Level 3) - 3 pts
    elif ls "$dir"/*-template*.yaml "$dir"/templates/*.yaml 2>/dev/null | head -1 | grep -q .; then
        score=$((score + 3))
        checks+=("OC templates")
        log_pass "Deployment: OpenShift templates"
    fi

    # 2. Rolling update strategy (Level 4) - 2 pts
    # Check for rolling updates in charts OR compose
    if check_contains "RollingUpdate|rollingUpdate" "charts" "$dir" 2>/dev/null; then
        score=$((score + 2))
        checks+=("Rolling updates")
        log_pass "Deployment: Rolling update strategy"
    elif check_contains "recreate|rolling" "docker-compose" "$dir" 2>/dev/null; then
        score=$((score + 2))
        checks+=("Update strategy")
        log_pass "Deployment: Update strategy defined"
    fi

    # 3. Environment values (Level 4) - 2 pts
    # Check for multiple env values files (dev, test, prod)
    if [ -d "$dir/charts" ]; then
        local env_count
        env_count=$(ls "$dir/charts"/*/values*.yaml 2>/dev/null | wc -l)
        if [ "$env_count" -ge 2 ]; then
            score=$((score + 2))
            checks+=("Multi-env values")
            log_pass "Deployment: Multiple environment values ($env_count)"
        fi
    fi

    # 2. Rolling update strategy (Level 4) - 2 pts
    if check_contains "RollingUpdate\|rolling" ".github" "$dir"; then
        score=$((score + 2))
        checks+=("Rolling updates")
        log_pass "Deployment: Rolling updates"
    fi

    SCORES[deployment]=$score
    MAX_SCORE=$((MAX_SCORE + max))
    echo "$score/$max" > "$REPO_DIR/$OUTPUT_DIR/deployment.txt"
    echo "$score" > "$REPO_DIR/$OUTPUT_DIR/deployment_score.txt"
}

# ============================================================================
# Calculate Results
# ============================================================================
calculate_results() {
    local total=0
    for dim in ci_cd code_quality security github_hygiene dependencies documentation deployment; do
        total=$((total + ${SCORES[$dim]:-0}))
    done
    
    TOTAL_SCORE=$total
    
    # Calculate percentage
    local percent=0
    if [ "$MAX_SCORE" -gt 0 ]; then
        percent=$((total * 100 / MAX_SCORE))
    fi
    
    # Determine level
    local level=1
    if [ "$percent" -ge 90 ]; then
        level=5
    elif [ "$percent" -ge 75 ]; then
        level=4
    elif [ "$percent" -ge 50 ]; then
        level=3
    elif [ "$percent" -ge 25 ]; then
        level=2
    fi
    
    echo "$percent" > "$REPO_DIR/$OUTPUT_DIR/score.txt"
    echo "$level" > "$REPO_DIR/$OUTPUT_DIR/level.txt"
    echo "$total/$MAX_SCORE" > "$REPO_DIR/$OUTPUT_DIR/total.txt"
    
    # Check minimum
    if [ "$level" -lt "$MIN_LEVEL" ]; then
        echo -e "${RED}ERROR: Maturity level $level is below minimum required level $MIN_LEVEL${NC}" >&2
        exit 1
    fi
}

# ============================================================================
# Print Report
# ============================================================================
print_report() {
    local percent=$((TOTAL_SCORE * 100 / MAX_SCORE))
    local level=1
    if [ "$percent" -ge 90 ]; then
        level=5
    elif [ "$percent" -ge 75 ]; then
        level=4
    elif [ "$percent" -ge 50 ]; then
        level=3
    elif [ "$percent" -ge 25 ]; then
        level=2
    fi
    
    local level_name=""
    case $level in
        1) level_name="Initial" ;;
        2) level_name="Developing" ;;
        3) level_name="Defined" ;;
        4) level_name="Managed" ;;
        5) level_name="Optimizing" ;;
    esac
    
    echo ""
    echo "================================================================================"
    echo "                    REPOSITORY MATURITY ASSESSMENT"
    echo "================================================================================"
    echo "Repo: $(basename "$REPO_DIR")"
    echo "Date: $(date +%Y-%m-%d)"
    echo ""
    echo "--------------------------------------------------------------------------------"
    echo "                            DIMENSION SCORES"
    echo "--------------------------------------------------------------------------------"
    
    for dim in ci_cd code_quality security github_hygiene dependencies documentation deployment; do
        local score=${SCORES[$dim]:-0}
        local max=${WEIGHTS[$dim]}
        local dim_pct=$((score * 100 / max))
        local bar_len=$((score * 20 / max))
        local bar=""
        for i in $(seq 1 $bar_len); do
            bar="${bar}#"
        done
        for i in $(seq $bar_len 20); do
            bar="${bar} "
        done
        local dim_name=$(echo "$dim" | tr '_' ' ' | sed 's/\b./\U&/g')
        printf "%-25s [%s] %d/%d (%d%%) - Level %d\n" "$dim_name" "$bar" "$score" "$max" "$dim_pct" "$((dim_pct >= 50 ? (dim_pct >= 75 ? (dim_pct >= 90 ? 5 : 4) : 3) : 2))"
    done
    
    echo ""
    echo "--------------------------------------------------------------------------------"
    echo "                            OVERALL SCORE"
    echo "--------------------------------------------------------------------------------"
    echo "Total: $TOTAL_SCORE/$MAX_SCORE ($percent%) - Level $level ($level_name)"
    echo ""
    
    if [ "$level" -lt "$MIN_LEVEL" ]; then
        echo -e "${RED}ERROR: Maturity level $level is below minimum required level $MIN_LEVEL${NC}" >&2
        exit 1
    fi
    
    echo "================================================================================"
}

# ============================================================================
# Main
# ============================================================================
main() {
    echo "Starting maturity assessment..."
    echo "Repository: $REPO_DIR"
    echo ""
    
    setup_output
    
    check_ci_cd
    check_code_quality
    check_security
    check_github_hygiene
    check_dependencies
    check_documentation
    check_deployment
    
    calculate_results
    print_report
    
    echo ""
    echo "Results saved to: $REPO_DIR/$OUTPUT_DIR/"
}

main "$@"