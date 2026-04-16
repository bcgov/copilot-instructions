---
name: repo-maturity
description: Assess GitHub repository and application maturity. Provides scorecard, maturity level (1-5), and prioritized improvement checklist based on CI/CD, security, code quality, and operational criteria.
---

# Repository Maturity Model

Assess GitHub repositories against a weighted maturity model to identify gaps and prioritize improvements.

## Overview

This skill evaluates a repository across 7 dimensions with weighted criteria. It produces:
- **Scorecard** - Pass/fail breakdown per criterion
- **Maturity Level** - 1 (Initial) to 5 (Optimizing)
- **Improvement Checklist** - Prioritized items to reach next level

The model is influenced by CMM (Capability Maturity Model) and SLSA (Supply-chain Levels for Software Artifacts) concepts.

## Dimensions & Criteria

| Dimension | Weight | Criteria |
|-----------|--------|----------|
| CI/CD & Automation | 25% | PR workflows, linting, testing, auto-dependency updates, deployment |
| Code Quality | 20% | ESLint flat config, Prettier, TypeScript strict, test coverage |
| Security | 20% | Trivy scanning, secret scanning, supply chain verification, OWASP alignment |
| GitHub Hygiene | 15% | Branch protection, issue/PR templates, CODEOWNERS |
| Dependency Management | 10% | Renovate/Dependabot, pinned versions, lockfile hygiene |
| Documentation | 5% | README, SECURITY.md, CONTRIBUTING.md, LICENSE |
| Deployment | 5% | Rolling deployments, environment separation |

### CI/CD & Automation (25%)

| Criterion | Level 2 | Level 3 | Level 4 | Level 5 |
|-----------|---------|---------|---------|---------|
| Lint check | Basic ESLint | Flat config | + Prettier + rules | All rules pass |
| Tests | Some tests | >50% coverage | >80% coverage | >90% coverage + e2e |
| PR workflow | Manual trigger | On PR open | On push + checks | Auto-merge safe |
| Dependency updates | Manual | Dependabot PRs | Renovate auto-merge | Auto-merge all |
| Deployment | Manual | On merge to main | Env promotion | Rolling + canary |

### Code Quality (20%)

| Criterion | Level 2 | Level 3 | Level 4 | Level 5 |
|-----------|---------|---------|---------|---------|
| ESLint config | .eslintrc | Flat config (.mjs) | + Prettier | All rules pass |
| Formatting | Prettier present | CI integration | On save + CI | Enforced |
| TypeScript | loose | strict | Strict + coverage | Strict 100% |
| Test coverage | Any | >50% | >80% | >90% + badges |

### Security (20%)

| Criterion | Level 2 | Level 3 | Level 4 | Level 5 |
|-----------|---------|---------|---------|---------|
| Secret scanning | GitHub enabled | + pre-commit | + CI scan | All pass |
| Vulnerability scan | None | Trivy on schedule | Trivy on PR | No High/CRITICAL |
| Supply chain | Dependabot | + lockfile | + audit | All verified |
| OWASP | None | Awareness | Basic checks | Full compliance |

### GitHub Hygiene (15%)

| Criterion | Level 2 | Level 3 | Level 4 | Level 5 |
|-----------|---------|---------|---------|---------|
| Branch protection | None | Require reviews | + status checks | All protected |
| PR templates | None | Basic template | Multiple templates | Auto-labeling |
| Issue templates | None | Bug/Feature | Full suite | Full suite + task template |
| CODEOWNERS | None | Present | Review required | All paths |
| Issue workflow | None | Labels | Projects | Automation |

### Dependency Management (10%)

| Criterion | Level 2 | Level 3 | Level 4 | Level 5 |
|-----------|---------|---------|---------|---------|
| Auto-deps | None | Dependabot | Renovate | All auto |
| Pinning | Exact in dev | Lockfile | Pin all | All pinned |
| Updates | Manual | Weekly | Daily | Auto-merge |
| Lockfile | Present | Updated | Verified | Audited |

### Documentation (5%)

| Criterion | Level 2 | Level 3 | Level 4 | Level 5 |
|-----------|---------|---------|---------|---------|
| README | Basic | Full usage | API + deploy | All scenarios |
| SECURITY | None | Present | Contact info | CVE process |
| CONTRIBUTING | None | Basic | Full guide | Templates |
| LICENSE | Missing | Present | Correct | Current year |

### Deployment (5%)

| Criterion | Level 2 | Level 3 | Level 4 | Level 5 |
|-----------|---------|---------|---------|---------|
| CI deployment | Manual | On main | Env promotion | Automated |
| Rolling updates | None | Basic | + health checks | + canary |
| Env separation | Same | dev/staging/prod | + secrets | + RBAC |

## Maturity Levels

| Level | Name | Description | Min Score |
|-------|------|-------------|-----------|
| 1 | **Initial** | Repo created, basic structure | 0% |
| 2 | **Developing** | Key workflows present, partial checks | 25% |
| 3 | **Defined** | Most checks implemented, some automation | 50% |
| 4 | **Managed** | Full CI/CD, auto-deps, security scanning | 75% |
| 5 | **Optimizing** | Auto-merge, advanced scanning, SLSA-like | 90% |

## Assessment Steps

### 1. Gather Repository Information

```bash
# Check for key files and directories
ls -la .github/workflows/
ls -la .github/ISSUE_TEMPLATE/
ls -la CODEOWNERS
ls -la eslint.config.mjs  # or .eslintrc*
ls -la package.json
ls -la renovate.json     # or .github/dependabot.yml   # either is fine
ls -la .gitignore

# Check branch protection (via GitHub CLI or web)
gh repo view --json branchProtectionRules
```

### 2. Scan for Security Tools

```bash
# Check for security scanning configs
ls -la .github/trivy.yaml
ls -la .trivyignore
grep -r "secret scanning" .github/ 2>/dev/null
grep -r "dependabot" .github/ 2>/dev/null
```

### 3. Analyze Package.json

```bash
# Check scripts and devDependencies
cat package.json | jq '.scripts'
cat package.json | jq '.devDependencies | keys'
```

### 4. Evaluate Each Criterion

For each dimension, tally points based on criterion completion:
- Level 2 criterion met = 1 point
- Level 3 criterion met = 2 points
- Level 4 criterion met = 3 points
- Level 5 criterion met = 4 points

### 5. Calculate Weighted Score

Each dimension is scored as a percentage (earned_points / max_points), then weighted:

```
Total Score = Σ(dimension_percent × dimension_weight)
```

> **Note:** Scores can exceed 100% when repos implement bonus features beyond the base checklist. However, **missing items are more important than bonuses** — focus on the improvement checklist to close gaps before adding extra features.

### 6. Determine Maturity Level

| Score Range | Level |
|-------------|-------|
| 0-24% | 1 |
| 25-49% | 2 |
| 50-74% | 3 |
| 75-89% | 4 |
| 90-100% | 5 |

## Output Format

### Scorecard

```
## Repository Maturity Scorecard

### CI/CD & Automation (25%)
- [x] Lint check (Level 4) - 3 pts
- [x] Tests (Level 3) - 2 pts
- [x] PR workflow (Level 3) - 2 pts
- [ ] Dependency updates (Level 2) - 1 pt
- [x] Deployment (Level 3) - 2 pts
**Subtotal: 10/20 pts (50%)**

### Code Quality (20%)
- [x] ESLint config (Level 4) - 3 pts
- [ ] Formatting (Level 2) - 1 pt
- [x] TypeScript (Level 3) - 2 pts
- [ ] Test coverage (Level 2) - 1 pt
**Subtotal: 6/16 pts (38%)**

... (continue for all dimensions)

### Overall Score: 65/100 (65%) -> Level 3 (Defined)
```

### Improvement Checklist

```
## Priority Improvements

### High Impact (Tier 1)
- [ ] Add test coverage (>80%) - +12 pts, moves to Level 4
- [ ] Enable Dependabot/Renovate auto-deps - +8 pts
- [ ] Configure branch protection rules - +6 pts

### Medium Impact (Tier 2)
- [ ] Add Prettier integration - +4 pts
- [ ] Create issue templates - +3 pts
- [ ] Add Trivy security scan - +5 pts

### Low Impact (Tier 3)
- [ ] Update LICENSE year
- [ ] Add CONTRIBUTING.md
- [ ] Add SECURITY.md contact info
```

## Reference Patterns

See the [quickstart-openshift](https://github.com/bcgov/quickstart-openshift) repository for reference implementations:

- [.github/workflows/analysis.yml](https://github.com/bcgov/quickstart-openshift/blob/main/.github/workflows/analysis.yml) - CI with lint, test, security scans
- [.github/workflows/merge.yml](https://github.com/bcgov/quickstart-openshift/blob/main/.github/workflows/merge.yml) - Deployment promotion
- [.github/trivy.yaml](https://github.com/bcgov/quickstart-openshift/blob/main/.github/trivy.yaml) - Trivy configuration
- [renovate.json](https://github.com/bcgov/quickstart-openshift/blob/main/renovate.json) - Renovate configuration
- [eslint.config.mjs](https://github.com/bcgov/quickstart-openshift/blob/main/eslint.config.mjs) - ESLint flat config
- [.github/ISSUE_TEMPLATE/](https://github.com/bcgov/quickstart-openshift/tree/main/.github/ISSUE_TEMPLATE) - Issue templates
- [.github/pull_request_template.md](https://github.com/bcgov/quickstart-openshift/blob/main/.github/pull_request_template.md) - PR template

## Related Standards

- **SLSA** (Supply-chain Levels for Software Artifacts) - Supply chain security
- **OWASP ASVS** - Application security verification
- **OWASP Agentic Security (ASI)** - AI agent security
- **CMM** - Capability Maturity Model

## Automated Assessment (Tier 2)

Run the maturity check script to automatically assess a repository:

```bash
./resources/maturity-check.sh /path/to/repo
```

### Output

```
================================================================================
                    REPOSITORY MATURITY ASSESSMENT
================================================================================
Repo: owner/repo-name
Date: 2025-04-15

--------------------------------------------------------------------------------
                            DIMENSION SCORES
--------------------------------------------------------------------------------
CI/CD & Automation      [################    ] 15/25 (60%) - Level 3
Code Quality           [##########        ] 12/20 (60%) - Level 3
Security               [############     ] 14/20 (70%) - Level 4
GitHub Hygiene         [#############   ] 11/15 (73%) - Level 4
Dependency Management  [#######          ] 7/10 (70%) - Level 3
Documentation          [####              ] 2/5 (40%) - Level 2
Deployment             [#####             ] 3/5 (60%) - Level 3

--------------------------------------------------------------------------------
                            OVERALL SCORE
--------------------------------------------------------------------------------
Total: 64/100 (64%) - Level 3 (Defined)

--------------------------------------------------------------------------------
                         CRITERION DETAILS
--------------------------------------------------------------------------------
[✓] PR workflow with test + lint
[✓] ESLint flat config
[✓] Test coverage >50%
[✓] Renovate configured
[✓] Branch protection (require reviews)
[ ] Test coverage >80%
[ ] Trivy in CI workflow
[ ] CODEOWNERS file
[ ] SECURITY.md

--------------------------------------------------------------------------------
                         IMPROVEMENT CHECKLIST
--------------------------------------------------------------------------------
> **Priority:** Address missing items (unchecked) before adding bonus features. High impact items offer the biggest score improvements.

High Impact:
  [ ] Add test coverage >80% (+12 pts) - Target: Level 4
  [ ] Add Trivy security scan to CI (+5 pts)
  [ ] Add CODEOWNERS file (+3 pts)

Medium Impact:
  [ ] Add SECURITY.md contact info (+2 pts)
  [ ] Update to ESLint flat config (+3 pts)

Low Impact:
  [ ] Add CONTRIBUTING.md (+1 pt)

================================================================================
```

### CI Integration

Add to your workflow to enforce minimum maturity:

```yaml
name: Maturity Check

on: [pull_request]

jobs:
  maturity:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run maturity check
        run: |
          wget -q -O maturity-check.sh \
            https://raw.githubusercontent.com/bcgov/copilot-instructions/main/.github/skills/repo-maturity/resources/maturity-check.sh
          chmod +x maturity-check.sh
          ./resources/maturity-check.sh . --min-level 3

      - name: Check results
        run: |
          if [ -f .tmp/maturity/score.txt ]; then
            SCORE=$(cat .tmp/maturity/score.txt)
            LEVEL=$(cat .tmp/maturity/level.txt)
            echo "Maturity Level: $LEVEL (Score: $SCORE)"
          fi
```

### Standardized Summary

When presenting results, always use this format:

```
## Final Report

| Repo | Score | Level | Status |
|------|-------|-------|--------|
| **owner/repo** | score/max (percent%) | Level N | Status |

### owner/repo (score/max - percent%)
| Category | Score | Max | % | Level |
|----------|-------|-----|---|-------|
| CI/CD | X | N | N% | N |
| Code Quality | X | N | N% | N |
| Security | X | N | N% | N |
| GitHub Hygiene | X | N | N% | N |
| Dependencies | X | N | N% | N |
| Documentation | X | N | N% | N |
| Deployment | X | N | N% | N |

**Missing from owner/repo**: item1, item2, item3 (or: None - fully compliant)

### Notes
- Scores can exceed 100% for bonus features (e.g., 121/124 = 97% because max includes bonuses)
- "Missing: None" means fully compliant with all required checks
- Missing items are more important than bonuses
```

### Minimum Thresholds

| Level | Use Case |
|-------|---------|
| 2 | Minimum for any new repo |
| 3 | Production-ready |
| 4 | Full compliance |

## Usage

Use this skill when:
- Onboarding a new repository
- Performing security audits
- Creating improvement roadmaps
- Comparing repositories for consistency
- Identifying technical debt
- Enforcing CI quality gates

### Quick Assessment

For a rapid assessment, check these key files in order:

1. `.github/workflows/` - At least one workflow with test + lint
2. `package.json` - Has lint + test scripts
3. `renovate.json` or `.github/dependabot.yml` - Auto-deps
4. `eslint.config.mjs` - Flat config present
5. `.github/trivy.yaml` or workflow with Trivy - Security scan
6. `CODEOWNERS` - Review assignment
7. Branch protection in repo settings