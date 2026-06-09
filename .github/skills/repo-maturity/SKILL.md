---
name: repo-maturity
description: Assess GitHub repository and application maturity against BC Gov DevOps & Dependency Security Standards, including mandatory branch protection, TypeScript settings, dependency age, vulnerability SLAs, and container security.
owner: bcgov
tags: [repo-maturity, devops, security, bcgov]
---

# Repository Maturity Model

Evaluate repository compliance against contractually mandated BC Gov DevOps and security standards.

## Use When
- Onboarding a new repository to a BC Gov GitHub organization.
- Preparing for a security audit, compliance review, or sprint planning.
- Evaluating a repository before transitioning it to maintenance mode.
- Validating vendor compliance with BC Gov digital standards.

## Don't Use When
- Auditing personal, experimental, or toy repositories not bound for a BC Gov environment.
- Reviewing documentation-only or basic scripting repositories that do not deploy software.

## Workflow
1. **Analyze Project Structure**: Inspect root configuration files (`package.json`, `tsconfig.json`, `renovate.json`, `.github/workflows/`, and deployment templates).
2. **Run Automated Script**: Execute the maturity tool to obtain a scorecard and check for strict settings:
   ```bash
   ./resources/maturity-check.sh /path/to/repo
   ```
3. **Audit Repository Configurations**: Manually verify GitHub repository and branch protection settings.
4. **Scan for Credentials & Secrets**: Audit source code and configuration files for exposed secrets (API keys, committed `.env` files, connection strings).
5. **Trace Data Flow & Sinks**: Perform a data flow check on user inputs (e.g. API parameters, headers, file uploads) tracing them to critical sinks (e.g. database queries, command execution).
6. **Apply Exploitation Triage**: Query the CISA KEV catalog and EPSS (score >= 0.1) for flagged CVEs to prioritize remediation.
7. **Report Findings**: Output the scorecard and generate a prioritized checklist of findings. Highlight any contract violations immediately.

## Rules
- **No-Exemption Policy**: All security vulnerabilities must be remediated regardless of justifications like "trusted environments," "internal access," or "unreachable paths."
- **GitHub Repository Settings**: Enforce Squash Merging Only (uncheck merge/rebase commits). Enable Branch Auto-Cleanup and Always Suggest Updating PR branches.
- **Branch Protection Ruleset**: The `main` branch ruleset must require a PR, at least 1 approval, conversation resolution, linear history, and strict status checks (`Analysis Results`, `PR Results`, `Validate Results`). Block force pushes.
- **TypeScript Hygiene**: For TypeScript projects, compiler options must enforce strictness:
   ```json
   {
     "compilerOptions": {
       "strict": true,
       "noImplicitAny": true,
       "strictNullChecks": true
     }
   }
   ```
- **Linter & Diagnostic Escapes**: Use of `@ts-ignore`, `@ts-nocheck`, `any` type escapes, or `eslint-disable` is strictly prohibited. Linter warnings or TS compiler diagnostics must fail build pipelines.
- **Test Coverage Baseline**: Maintain a minimum of 80% statement and branch test coverage. PRs that lower coverage below this threshold must be rejected.
- **Dependency Management**:
  - Pinned Renovate configurations extending stable config (e.g. `github>bcgov/renovate-config#2026.4.0` CalVer style).
  - Minimum release age of 7 days before adopting dependency updates.
  - Zero-dependency policy for low-volume (< 20 lines) custom logic.
- **OpenShift Security Context**: Default security contexts (`readOnlyRootFilesystem: true`, `runAsNonRoot: true`, `allowPrivilegeEscalation: false`) must not be bypassed or removed. Write operations must use memory-backed `emptyDir` volumes.
- **Vulnerability SLAs**: Critical findings (24 hours), High (1 week), Medium (2 weeks), Low (next sprint).

## Examples
- **Audit Request**: `"Is my repo ready for BC Gov production?"` -> Assess using `maturity-check.sh` and flag any missing branch protections or TypeScript strict flags.
- **Maintenance Readiness**: `"Can we move this app into maintenance mode?"` -> Verify 80% test coverage, sandbox preview environments, and deep health check endpoints (Terminus/Caddy) are implemented.

## Edge Cases
- **Non-TypeScript Projects**: Do not dock points or flag failures for TypeScript compiler settings if the codebase is written in Java, Python, or Go.
- **Monorepos**: Run the maturity checker on individual subdirectories (e.g. `frontend/` and `backend/`) to avoid overlooking configuration flags.
- **Offline / No API Access**: When GitHub API access is unavailable, manually audit repo branch rulesets and settings.

## References
- **Target Skill Catalog**: [bcgov/agent-skills](https://github.com/bcgov/agent-skills)
- **Local Assessment Tool**: [maturity-check.sh](resources/maturity-check.sh)
- **Vulnerability Databases**: CISA KEV Catalog, Exploit Prediction Scoring System (EPSS)
- **BC Gov Platform Docs**: OpenShift and Azure Landing Zone Design Specifications