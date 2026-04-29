---
name: ocp-migration-analyst
description: Orchestrates a full OpenShift platform migration analysis — namespace discovery, repo inspection, gap analysis against target platform requirements, network flow mapping, migration task planning, and PDF report generation. Input: OCP namespace prefix + source cluster + GitHub repo + target platform. Output: a JUSTINRCC-style migration analysis report (markdown + PDF). Invoke when asked to analyse any OCP project for platform migration readiness, or to generate a migration report.
tools: Bash, Read, Write, Grep, Glob
user-invocable: true
metadata:
  author: Ryan Loiselle
  version: "1.0"
compatibility: >
  Source platforms: OCP Silver, Gold, or any OCP 4.x cluster.
  Target platforms: OCP Emerald, AWS ECS/EKS, or comparable.
  Requires: oc CLI (logged in to source cluster), gh CLI (authenticated), pandoc, Chrome headless.
  See ocp-migration-toolkit repo for automated collection scripts and GitHub Action.
---

# OCP Migration Analyst

Produces a structured migration analysis report for any OpenShift project being moved to a
new platform. The analysis matches the depth and structure of the JUSTINRCC Migration Analysis
(April 2026) which is the reference implementation for this workflow.

**Reference output:** `justinrcc-analysis/report/JUSTINRCC-Migration-Analysis.md` and PDF.

---

## Analysis Phases

```
Phase 1  DISCOVERY        — collect namespace facts + repo structure
Phase 2  GAP ANALYSIS     — compare current state against target platform requirements
Phase 3  NETWORK MAPPING  — enumerate all inbound/outbound flows with protocols/ports/CIDRs
Phase 4  REPORT DRAFT     — generate all sections from collected data
Phase 5  PDF RENDER       — pandoc + Chrome → final PDF artefact
```

---

## Phase 1 — Discovery

### 1.1 OCP Namespace Collection

Run these commands for each environment (dev, test, prod, tools) in the namespace prefix.
Substitute `<NS>` with the environment namespace (e.g. `f1b263-prod`).

```bash
# Create working directory first (avoids redirect failures on fresh workstations)
mkdir -p working/<NS>

# Workload inventory (dc covers DeploymentConfig still used on Silver/Gold)
oc get dc,deployment,statefulset,daemonset -n <NS> -o yaml > working/<NS>/workloads.yaml

# Services and Routes
oc get svc,route -n <NS> -o yaml > working/<NS>/network-svc-routes.yaml

# Persistent storage (storageclass is cluster-scoped — split from namespace-scoped pvc)
oc get pvc -n <NS> -o yaml > working/<NS>/pvcs.yaml
oc get storageclass -o yaml > working/<NS>/storageclasses.yaml  # requires cluster read; omit if RBAC restricts

# Secret names (no values — security boundary)
oc get secret -n <NS> --no-headers | awk '{print $1, $2}' > working/<NS>/secret-names.txt

# ConfigMap names and sizes
oc get configmap -n <NS> --no-headers > working/<NS>/configmap-names.txt

# NetworkPolicies
oc get networkpolicy -n <NS> -o yaml > working/<NS>/networkpolicies.yaml

# Build objects (indicates old OCP S2I patterns)
oc get bc,is -n <NS> -o yaml > working/<NS>/build-objects.yaml

# Resource quotas and limits
oc get resourcequota,limitrange -n <NS> -o yaml > working/<NS>/resource-quotas.yaml

# Events (recent errors or warnings)
oc get events -n <NS> --sort-by='.lastTimestamp' | tail -30 > working/<NS>/events.txt

# Image digests for running pods
oc get pods -n <NS> -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{range .spec.containers[*]}{.image}{"\n"}{end}{end}' > working/<NS>/image-refs.txt
```

### 1.2 Repository Collection

```bash
# Clone for local inspection (or use gh api for targeted reads)
gh repo clone <OWNER/REPO> working/repo -- --depth=1

# CI/CD workflows
find working/repo/.github/workflows -name '*.yml' -o -name '*.yaml' | sort

# Container definitions
find working/repo -name 'Containerfile' -o -name 'Dockerfile' | sort

# Build manifests (Java, Node, .NET)
find working/repo -maxdepth 4 \( -name 'pom.xml' -o -name 'build.gradle' \
  -o -name 'package.json' -o -name '*.csproj' -o -name '*.sln' \) | sort

# Helm charts or raw k8s YAML
find working/repo -name 'Chart.yaml' -o -name 'values.yaml' | sort
find working/repo -name '*.yaml' -print0 | xargs -0 grep -l 'kind: Deployment\|kind: DeploymentConfig' 2>/dev/null | head -20

# Existing health probe definitions
grep -r 'livenessProbe\|readinessProbe\|startupProbe' working/repo --include='*.yaml' -l

# NetworkPolicy files
find working/repo -name '*.yaml' -print0 | xargs -0 grep -l 'kind: NetworkPolicy' 2>/dev/null
```

### 1.3 Use `ocp-migration-toolkit` for Automated Collection

If the [ocp-migration-toolkit](https://github.com/rloisell/ocp-migration-toolkit) repo is available,
run the collection script instead of the manual commands above:

```bash
cd ocp-migration-toolkit
./collect/collect.sh \
  --namespace f1b263 \
  --cluster silver \
  --repo bcgov-c/justinrcc \
  --target emerald \
  --output working/
```

This produces `working/<namespace>/manifest-summary.md` — a structured summary ready for AI analysis.

---

## Phase 2 — Gap Analysis

Apply the following skill knowledge bases when interpreting collected data:

| Area | Skill | Key checks |
|------|-------|------------|
| Platform requirements | `bc-gov-emerald` | AVI InfraSettings, DataClass/owner/environment labels, StorageClass, PriorityClass, edge Route |
| NetworkPolicy | `bc-gov-networkpolicy` | Default-deny egress, DNS policy, CIDR-based external flows, ag-template intent API |
| CI/CD and Helm | `bc-gov-devops` | Policy-as-code gate, ag-helm-templates, Artifactory, ArgoCD, deployment checklist |
| Secrets | `vault-secrets` | Vault + ESO ExternalSecret, no plain Secrets for sensitive values |
| Observability | `observability` | Structured logging, health probes, Prometheus annotations, OpenTelemetry |
| Security | `security-architect` | Pod security contexts, OWASP, image CVE scanning, action SHA pinning |
| SDN / Zone flows | `bc-gov-sdn-zones` | Zone A/B/C egress constraints, CSBC FWCR requirements, MCCS |

### Critical gap categories (always evaluate)

Each gap maps to one or more standards in the [Sources and References](#sources-and-references) section below.

| # | Category | Source indicator | Gap test | Standard / Source |
|---|----------|-----------------|----------|-------------------|
| G1 | No egress NetworkPolicies | `networkpolicies.yaml` has no egress rules | Emerald default-denies all egress | PS-01 |
| G2 | DeploymentConfig used | `workloads.yaml` has `kind: DeploymentConfig` | DC deprecated in OCP 4.14+; must convert | OCP-01 |
| G3 | No Helm charts | No `Chart.yaml` in repo | ag-helm-templates required on Emerald | AD-01 |
| G4 | Internal image registry | `image-refs.txt` shows `image-registry.openshift-image-registry.svc` | Must migrate to Artifactory | ISB-03 |
| G5 | No health probes | No `livenessProbe/readinessProbe` in workload YAML | Required on Emerald for proper rollout | K8S-01; PS-04 |
| G6 | Plain Secrets | `secret-names.txt` shows non-system secrets | Must migrate to Vault + ESO | ISB-01 |
| G7 | Missing pod labels | No `DataClass/owner/environment` in pod templates | Datree/Conftest enforced on Emerald | AD-02 |
| G8 | Wrong StorageClass | `storage.yaml` shows `netapp-file-standard` for database PVCs | Should be `netapp-block-standard` | PS-02 |
| G9 | No PriorityClass | No `kind: PriorityClass` in repo | Polaris `priorityClassNotSet` check | AD-04 |
| G10 | CI uses SierraSystems workflows | Workflow imports `SierraSystems/reusable-workflows` | Replace with first-party GitOps | ISB-02 |
| G11 | No policy-as-code gate | No Datree/Polaris/kube-linter/Conftest in CI | Required by ag-devops standard | AD-03 |
| G12 | Image tag not pinned | `latest` or mutable tag in image refs | Use digest pinning in prod | SEC-01; SEC-02 |

---

## Phase 3 — Network Flow Mapping

Build a flow table from the workload and service data. For each flow, determine:

| Column | How to find it |
|--------|---------------|
| Source | Pod name from workloads.yaml |
| Destination | Service name, Route host, or external CIDR |
| Protocol | Port from service spec |
| External | Whether destination is outside the cluster |
| FWCR required | Whether destination is Zone B / behind a CSBC firewall |
| Status | Does a NetworkPolicy exist for this flow? |

For Zone B services (SFTP, ORDS, MQ, etc.) — see `bc-gov-sdn-zones` for FWCR process.

---

## Phase 4 — Report Generation

### 4.0 Document Header (REQUIRED)

Every migration report must open with this header block. **Each metadata line must end with two trailing spaces** (`  `) to force a Markdown line break — omit them and all fields collapse onto one line in the rendered PDF.

```markdown
# <APP_NAME> — Migration Analysis Report
## OpenShift <SOURCE_PLATFORM> (<NAMESPACE>) → <TARGET_PLATFORM> Platform Migration

**Classification:** Protected B — Internal Use  
**Prepared by:** Ryan Loisell, Developer / Solution Architect Consultant (BC Gov AG/PSSG) — Migration analysis, architecture review, and implementation planning  
**Prepared for:** <PRODUCT_OWNER_NAME>, Product Owner — for review and handoff to the implementation team  
**AI Analysis by:** GitHub Copilot (Claude Sonnet 4.6) — Technical analysis, gap identification, and documentation  
**Date:** <DATE> (v<N> — <brief description>)  
**Previous version:** v<N-1> (<DATE> — <what changed>) ← omit on v1  
**Namespace:** <NAMESPACE> (<envs>) — <SOURCE_PLATFORM>, Kamloops DC  
**Repository:** <REPO_URL>  
**Analysis scope:** Read-only — no changes made to repo, deployments, or environments.

<div style="page-break-after: always"></div>
```

Use the templates in `ocp-migration-toolkit/templates/report-sections.md` to generate each section.
The reference JUSTINRCC report has 12 sections:

| Section | Key content |
|---------|-------------|
| 1. Executive Summary | App purpose, pipeline description, current platform, migration rationale |
| 2. Current State — Technical | Services, versions, deployment model, volumes, CI/CD, image info |
| 3. Security and Programmatic Concerns | Secrets exposure, image CVEs, OWASP concerns, action pinning |
| 4. Distributed Tracing and Observability | Logging framework, tracing SDK, health probes, Prometheus |
| 5. Gap Analysis | Platform differences table + detailed gaps by category (G1–G12 above) |
| 6. Network Flow Analysis | Flow table with protocols, CIDRs, FWCR status |
| 7. Resilience and Availability | Replica counts, PDB, StatefulSet quorum, failover paths |
| 8. Resource and Capacity Planning | Current resource requests/limits, quota analysis, Emerald equivalents |
| 9. Migration Plan — Task List | HELM-XX, NP-XX, CI-XX, APP-XX, VAULT-XX, DATA-XX tasks |
| 10. Effort Estimation | Table: task × AI-assist level × estimated hours |
| 11. Diagrams | PlantUML architecture diagram (source state + target state) |
| 12. Appendices | Namespace inventory, raw manifests, FWCR templates, Vault paths |

### Task numbering convention

| Prefix | Category |
|--------|----------|
| `HELM-XX` | Helm chart authoring and configuration |
| `NP-XX` | NetworkPolicy suite |
| `CI-XX` | CI/CD pipeline updates |
| `APP-XX` | Application code changes |
| `VAULT-XX` | Secrets migration to Vault |
| `DATA-XX` | PVC / data migration |
| `ARCH-XX` | Architecture decisions (FWCRs, external connectivity) |

### AI assist level indicators

| Icon | Meaning |
|------|---------|
| 🤖 | Fully Copilot-generated (boilerplate, no project context required) |
| 🤝 | Copilot drafts, developer verifies (project-specific details needed) |
| 💼 | Admin action (GitHub Secrets, Vault namespace, CSBC FWCR) |
| 🔎 | Investigation required before task can begin |

### 4.1 Copilot Setup Guidance for Migration Projects

Include a dedicated **Section 9.6 GitHub Copilot Utilization** in every migration report, and an **Appendix F / 12.G rl-agents-n-skills Integration Guide**. These sections tell the implementation team:

1. What Copilot will and will not do for each task category (table with icons + effort reduction estimates)
2. How to set up Copilot with the `rl-agents-n-skills` submodule before starting the work
3. Which specific agents to invoke for each phase

**Standard Section 9.6 content (adapt task IDs to match the project):**

```markdown
### 9.6 GitHub Copilot Utilization — Setup and Usage Guide

#### 9.6.1 What Copilot Will Do For You

| Category | Tasks | Copilot Coverage | Est. Effort Reduction |
|---|---|---|---|
| Helm chart authoring | HELM-01 to HELM-XX | 🤖 High — fully generatable from existing specs | 60–70% reduction |
| NetworkPolicy suite | NP-XX (via HELM-11) | 🤝 Medium — external CIDRs depend on FWCR results | 50% reduction |
| ExternalSecret CRDs | VAULT-02 | 🤖 High — fully templated | 80% reduction |
| CI/CD workflow updates | CI-XX | 🤖/🤝 depends on complexity | 40–60% reduction |
| Application code changes | APP-XX | 🤝 Medium | 30–40% reduction |
| Administrative / stakeholder | PRE tasks, admin tasks | 💼 None | Not applicable |
| End-to-end validation | ENV/VAL tasks | 👤 Low | 10–15% (test scaffolding only) |

**Estimated overall effort reduction with Copilot:** approximately **35–45%** of total developer-hours.

#### 9.6.2 Prerequisites — How to Set Up Copilot for This Migration

**Option A — VS Code + GitHub Copilot (recommended)**
```bash
git submodule add https://github.com/rloisell/rl-agents-n-skills.git .github/agents
git submodule update --init --recursive
```

**Option B — npx skills add (quickstart)**
```bash
npx skills add rloisell/rl-agents-n-skills
```

**Option C — Claude Code CLI:** Configure `.claude/settings.json` to point at the `agents/` folder.

#### 9.6.3 How to Use the AI Assist Indicators

| Icon | Meaning | What you should do |
|---|---|---|
| 🤖 | Copilot can generate this fully | Load the relevant agent (Appendix F), paste the Example Invocation |
| 🤝 | Copilot drafts, you review | Validate against the live system before applying |
| 👤 | Requires developer hands-on | Live access or security-sensitive; Copilot cannot help |
| 💼 | Administrative / stakeholder | Human process only; engage the Product Owner |
```

**Standard Appendix F / 12.G content:** A table mapping each agent to its domain coverage, the migration task IDs it assists with, and a project-specific example invocation. Use the table from the reference JUSTINRCC-Migration-Analysis-v6.md Appendix F as the template, adapting task IDs for the project under analysis.

---

## Phase 5 — PDF Rendering

```bash
# Render HTML intermediate (run from the report directory so image paths resolve)
cd <report-dir>
/opt/homebrew/bin/pandoc <APP>-Migration-Analysis.md \
  --from=markdown --to=html5 --standalone \
  --css=/tmp/report-style-v2.css --embed-resources \
  --output=/tmp/report.html \
  --metadata title="<APP> — Migration Analysis"

# Render PDF via Chrome headless
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --disable-gpu \
  --print-to-pdf=<APP>-Migration-Analysis.pdf \
  --print-to-pdf-no-header --no-pdf-header-footer \
  file:///tmp/report.html 2>/dev/null

echo "PDF: $(ls -lh <APP>-Migration-Analysis.pdf)"
```

On Linux (GitHub Actions / container):
```bash
google-chrome-stable --headless --disable-gpu \
  --print-to-pdf=report.pdf \
  --print-to-pdf-no-header --no-pdf-header-footer \
  file:///tmp/report.html
```

CSS template: `ocp-migration-toolkit/templates/style/report-style.css`

---

## Invocation Patterns

### Via VS Code / GitHub Copilot

```
Use the ocp-migration-analyst skill to generate a full migration analysis for
namespace f1b263, repo bcgov-c/justinrcc, source platform Silver, target Emerald.
```

### Via ocp-migration-toolkit (automated)

```bash
# Step 1: collect data
./collect/collect.sh --namespace f1b263 --cluster silver \
  --repo bcgov-c/justinrcc --target emerald --output working/

# Step 2: open VS Code, invoke AI analysis
# Copilot reads working/f1b263/manifest-summary.md + runs gap analysis + generates report

# Step 3: render PDF
./render/render.sh --input report/<APP>-Migration-Analysis.md --output report/
```

### Via GitHub Action (any BC Gov project)

```yaml
- uses: rloisell/ocp-migration-toolkit@main
  with:
    namespace: f1b263
    cluster: silver
    repo: bcgov-c/justinrcc
    target: emerald
    oc-token: ${{ secrets.OC_SA_TOKEN }}
    gh-token: ${{ secrets.GITHUB_TOKEN }}
```

---

## Report Naming Convention

```
<APP-NAME>-Migration-Analysis.md     # Master analysis report
<APP-NAME>-Migration-Analysis.pdf    # Rendered PDF
<APP-NAME>-AWS-Cloud-Options.md      # Optional: cloud alternatives analysis
diagrams/
  plantuml/
    <app>-current-state.puml         # Source platform architecture
    <app>-target-state.puml          # Target platform architecture
    png/                             # Rendered PNGs
```

---

## PLATFORM_KNOWLEDGE

- 2026-04-16: [JUSTINRCC] Reference analysis took ~4 sessions across 3 topics (platform, networking, CI/CD). Structured collect-then-analyze approach would reduce this to ~1 session.
- 2026-04-16: [JUSTINRCC] The two most time-consuming gap areas were NetworkPolicy (external CIDR discovery requires CSBC input) and Helm authoring (no existing charts). Flag these as `ARCH-XX` pre-tasks in every report.
- 2026-04-16: [JUSTINRCC] DeploymentConfig → Deployment conversion is always task HELM-01. It is prerequisite for all other Helm tasks.
- 2026-04-16: [JUSTINRCC] Zone B external services (SFTP, ORDS) always require CSBC FWCRs — create `ARCH-01 CSBC FWCR request` as the first blocking task whenever these flows are present.
- 2026-04-16: Report PDF rendering must run from the report directory (not workspace root) so relative image paths in markdown resolve correctly.

---

## Sources and References

Every gap finding (G1–G12) and recommendation must cite the applicable standard ID so
readers can trace guidance back to its authoritative source. This is what distinguishes
an evidence-based analysis from a generic checklist.

### BC Gov Platform Services

| ID | Standard | Reference |
|----|----------|-----------|
| PS-01 | Emerald Landing Zone — default-deny egress NetworkPolicy requirement | [docs.developer.gov.bc.ca](https://docs.developer.gov.bc.ca/) |
| PS-02 | Platform Services — Storage Guide (`netapp-block-standard` for block storage workloads) | [docs.developer.gov.bc.ca](https://docs.developer.gov.bc.ca/) |
| PS-03 | Platform Services — Artifactory as mandatory image registry on Emerald | [docs.developer.gov.bc.ca](https://docs.developer.gov.bc.ca/) |
| PS-04 | Platform Services — Health Probes and Deployment Readiness requirements | [docs.developer.gov.bc.ca](https://docs.developer.gov.bc.ca/) |

### ag-devops Policy Standards

| ID | Standard | Enforcement |
|----|----------|-------------|
| AD-01 | ag-helm-templates — mandatory Helm scaffolding for all Emerald workloads | Datree policy rule |
| AD-02 | Pod labels: `DataClass`, `owner`, `environment` — all three required on every pod template | Datree + Conftest hard-deny |
| AD-03 | Policy-as-code gate: Datree + Polaris + kube-linter + Conftest must run in every CI pipeline | CI workflow requirement |
| AD-04 | PriorityClass required on all workloads | Polaris `priorityClassNotSet` check |

### BC Gov Information Security and ISB EA

| ID | Standard | Reference |
|----|----------|-----------|
| ISB-01 | BC Gov Information Security Policy — plain Kubernetes Secrets prohibited for sensitive values; Vault + ESO mandatory | [BC Gov IS Policy](https://www2.gov.bc.ca/gov/content/governments/services-for-government/information-management-technology/information-security/information-security-policy-and-guidelines/core-policy) |
| ISB-02 | ISB Enterprise Architecture — Option 2 CI/CD standard (first-party GitOps pipelines; no third-party reusable workflow vendors) | Internal ISB EA documentation |
| ISB-03 | ISB Enterprise Architecture — Artifact Management (Artifactory as single source of truth for images) | Internal ISB EA documentation |

### OpenShift Platform

| ID | Standard | Reference |
|----|----------|-----------|
| OCP-01 | OpenShift 4.14 — DeploymentConfig deprecation | [OCP 4.14 Docs](https://docs.openshift.com/container-platform/4.14/applications/deployments/what-deployments-are.html) |
| OCP-02 | OpenShift — Node Drain and Machine Config Operator (rolling upgrade behaviour) | [OCP Node Docs](https://docs.openshift.com/container-platform/4.14/nodes/) |

### Kubernetes Documentation

| ID | Standard | Reference |
|----|----------|-----------|
| K8S-01 | Configure Liveness, Readiness, and Startup Probes | [kubernetes.io](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) |
| K8S-02 | Persistent Volumes — Access Modes (RWO vs RWX) | [kubernetes.io](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) |
| K8S-03 | Network Policies | [kubernetes.io](https://kubernetes.io/docs/concepts/services-networking/network-policies/) |

### Security

| ID | Standard | Reference |
|----|----------|-----------|
| SEC-01 | OWASP A06:2021 — Vulnerable and Outdated Components (mutable image tags allow silent dependency drift) | [owasp.org](https://owasp.org/Top10/A06_2021-Vulnerable_and_Outdated_Components/) |
| SEC-02 | GitHub Actions — SHA pinning for third-party actions | [GitHub Security Hardening](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions) |
