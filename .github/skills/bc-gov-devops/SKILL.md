---
name: bc-gov-devops
description: BC Government Emerald OpenShift deployment patterns — Artifactory image registry setup, Helm chart requirements, health check standards, Common SSO authentication integration, OpenShift oc command reference, secrets management, and ArgoCD GitOps CRDs. Use when deploying, configuring, or troubleshooting services on the Emerald OpenShift platform.
tools: Read, Grep, Glob
user-invocable: false
metadata:
  author: Ryan Loiselle
  version: "1.1"
compatibility: Emerald OpenShift 4.x. BC Gov GitHub Actions. Requires Artifactory account from BC Gov DevExchange.
---

# BC Gov DevOps Agent

Drives deployment onto the BC Government Emerald OpenShift platform.

**Shared skills referenced by this agent:**
- Container image standards → [`../containerfile-standards/SKILL.md`](../containerfile-standards/SKILL.md)
- AVI InfraSettings, DataClass labels, NetworkPolicy model, StorageClass → [`../bc-gov-emerald/SKILL.md`](../bc-gov-emerald/SKILL.md)
- Full NetworkPolicy YAML examples → [`references/networkpolicy-patterns.md`](references/networkpolicy-patterns.md)

---

## Platform Reference

| Cluster | API URL | OIDC Issuer |
|---------|---------|-------------|
| Gold | `https://api.gold.devops.gov.bc.ca:6443` | `https://loginproxy.gov.bc.ca/auth/realms/standard` |
| Gold DR | `https://api.golddr.devops.gov.bc.ca:6443` | same |
| Silver | `https://api.silver.devops.gov.bc.ca:6443` | `https://loginproxy.gov.bc.ca/auth/realms/standard` |

**Namespace pattern:** `<license-plate>-<env>` (e.g. `be808f-dev`)

---

## Artifactory Setup

1. Request Artifactory service account at <https://bcgov.github.io/platform-developer-docs/docs/build-deploy-and-maintain/push-and-pull-images/>
2. Store credentials as GitHub Actions secrets:
   - `ARTIFACTORY_URL` = `artifacts.developer.gov.bc.ca`
   - `ARTIFACTORY_SERVICE_ACCOUNT` = service account name
   - `ARTIFACTORY_SERVICE_ACCOUNT_TOKEN` = token
3. In workflow, use the Artifactory URL as the registry prefix — see
   `../ci-cd-pipeline/SKILL.md` for full build/push steps.

---

## ag-helm Helm Library Chart (BC Gov AG standard)

`ag-helm-templates` is the shared Helm library used across BC Gov AG ministry projects.
Consume it via OCI in your chart's `Chart.yaml`:

```yaml
# gitops-repo/charts/<app>/Chart.yaml
dependencies:
  - name: ag-helm-templates
    version: "<released-version>"
    repository: "oci://ghcr.io/bcgov-c/helm"
```

If the registry requires auth:
```bash
echo $GITHUB_TOKEN | helm registry login ghcr.io -u <github-user> --password-stdin
helm dependency update ./charts/<app>
```

**Templates provided by ag-helm:**

| Template | Description |
|----------|-------------|
| `ag-template.deployment` | Deployment with OpenShift SCC awareness |
| `ag-template.statefulset` | StatefulSet |
| `ag-template.job` | Job with TTL |
| `ag-template.service` | Service |
| `ag-template.serviceaccount` | ServiceAccount |
| `ag-template.route.openshift` | OpenShift Route with AVI annotation enforcement |
| `ag-template.networkpolicy` | Intent-based NetworkPolicy (recommended) |
| `ag-template.hpa` | HPA (autoscaling/v2) |
| `ag-template.pdb` | PodDisruptionBudget |
| `ag-template.pvc` | PersistentVolumeClaim |

**Required `values.yaml` root keys when using ag-helm:**
```yaml
global:
  openshift: true    # enables OpenShift SCC mode — do NOT omit on Emerald

project: <app-name>  # becomes ApplicationGroup label prefix
registry: artifacts.developer.gov.bc.ca
```

**`global.openshift: true` behaviour:**
- Default container `securityContext` does **not** pin `runAsUser`/`runAsGroup` — OpenShift SCC assigns runtime UID/GID
- Adds `checkov.io/skip999: CKV_K8S_40=OpenShift SCC assigns runtime UID/GID` annotation to suppress Checkov false-positive
- Still enforces: `runAsNonRoot: true`, `allowPrivilegeEscalation: false`, `readOnlyRootFilesystem: true`, `capabilities.drop: [ALL]`

> When NOT using the ag-helm library (raw YAML Helm charts), manually include
> `global.openshift: true` in `values.yaml` and omit `runAsUser`/`runAsGroup` from
> your pod `securityContext` — OpenShift SCC handles them.

---

## Policy-as-Code Gate (Required — bcgov/ag-devops standard)

Before deploying to **any** environment, render Helm output and pass all four tools.
Failing any tool must block the pipeline. Source configs: [bcgov/ag-devops cd/policies/](https://github.com/bcgov/ag-devops/tree/main/cd/policies).

```bash
# 1. Render Helm to a single YAML file (all resources together — cross-resource checks need them)
helm template myapp ./charts/<app> --values ./deploy/dev_values.yaml --debug > rendered.yaml

# 2. Run all four policy checks — all must pass before deploy
datree test rendered.yaml --policy-config cd/policies/datree-policies.yaml
polaris audit --config cd/policies/polaris.yaml --format pretty rendered.yaml
kube-linter lint rendered.yaml --config cd/policies/kube-linter.yaml
conftest test rendered.yaml --policy cd/policies --all-namespaces --fail-on-warn
```

### What each tool checks

| Tool | Key checks relevant to AG/Emerald workloads |
|------|--------------------------------------------|
| **Datree** | `DataClass` label present and `Low\|Medium\|High`; `owner` label required; `environment` label must be `production\|test\|development`; Route must have `aviinfrasetting.ako.vmware.com/name`; image tag required (no floating); resource requests/limits required; probes required; `imagePullPolicy: Always` |
| **Polaris** | `hostIPC/PID/Network: false`; `allowPrivilegeEscalation: false`; `runAsNonRoot: true`; `readOnlyRootFilesystem: true`; no secrets in env vars or ConfigMaps; `missingNetworkPolicy` custom check; `deploymentMissingReplicas`; `priorityClassNotSet`; `dataClassLabelRequired`; `routeAviAnnotationRequired` |
| **kube-linter** | `run-as-non-root`; `privilege-escalation-container`; `default-service-account`; `latest-tag`; `env-var-secret`; selector mismatches; PDB min/max |
| **Conftest (OPA/Rego)** | Hard-deny: Deployment without matching NetworkPolicy; Deployment without `DataClass`; NP without `policyTypes`; NP empty `podSelector: {}`; allow-all ingress/egress (`- {}`); missing `from/to`; missing `ports`; internet egress without `justification` + `approvedBy` annotations; edge-terminated Route without `app.kubernetes.io/component=frontend` label or `isb.gov.bc.ca/edge-termination-approval` annotation |

### Required pod labels (enforced by Datree + Conftest)

Every Deployment/StatefulSet pod template must include **all three**:

```yaml
podLabels:
  DataClass: "Medium"          # Low | Medium | High — must match AVI annotation suffix
  owner: "<team-or-ticket>"    # team name or Jira ticket reference
  environment: "development"   # production | test | development
```

When using `ag-template.deployment`, set these via `ModuleValues.dataClass` (renders `DataClass`) plus explicit `LabelData` fragment for `owner` and `environment`.

### PriorityClass (required — Polaris `priorityClassNotSet`)

Every Deployment and StatefulSet must reference a PriorityClass. Define one per app (or use a shared cluster class):

```yaml
# priorityclass.yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: <app>-priority
value: 1000000
globalDefault: false
description: "<app> workloads"
```

```yaml
# In pod spec
spec:
  template:
    spec:
      priorityClassName: <app>-priority
```

### Internet egress approval annotations (Conftest hard-deny)

If a NetworkPolicy has egress to `0.0.0.0/0` or `::/0`, Conftest **denies** it unless both annotations are present:

```yaml
metadata:
  annotations:
    justification: "Why this service requires internet-wide egress"
    approvedBy: "Ticket reference or approver name"
```

Prefer specific CIDRs (`ipBlock.cidr`) over internet-wide egress — specific CIDRs do not require the annotations.

### Route edge termination approval (Conftest hard-deny)

Edge-terminated Routes are denied unless the Route has either:
- Label `app.kubernetes.io/component: frontend`, **or**
- Annotation `isb.gov.bc.ca/edge-termination-approval: "<ticket>"`

Passthrough (`spec.tls.termination: passthrough`) and re-encrypt termination are not affected.

---

## Helm Chart Requirements

Every service needs a Helm chart in `charts/<service>/`.

**Required files:**
```
charts/<service>/
  Chart.yaml
  values.yaml              ← per-service defaults
  values-dev.yaml          ← dev environment overrides
  values-test.yaml
  values-prod.yaml
  templates/
    deployment.yaml
    service.yaml
    route.yaml
    networkpolicy.yaml     ← required; see references/networkpolicy-patterns.md
    _helpers.tpl
```

**Chart.yaml minimum:**
```yaml
apiVersion: v2
name: <service>
description: <description>
type: application
version: 0.1.0
appVersion: "1.0.0"
```

For AVI InfraSettings and `app.kubernetes.io/part-of` + DataClass labels,
see [`../bc-gov-emerald/SKILL.md`](../bc-gov-emerald/SKILL.md).

---

## Health Checks

Every deployment must include both probes:

```yaml
livenessProbe:
  httpGet:
    path: /health/live
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 30
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /health/ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 10
  failureThreshold: 3
```

**.NET health check setup:**
```csharp
builder.Services.AddHealthChecks()
    .AddDbContextCheck<ApplicationDbContext>("database");

app.MapHealthChecks("/health/live");
app.MapHealthChecks("/health/ready", new HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("ready") || check.Name == "database"
});
```

---

## Common SSO Authentication

BC Gov uses DIAM/Keycloak via `loginproxy.gov.bc.ca`. See `jag-diam-documentation/` in the workspace for detailed OIDC flows.

**Realms:**
| Realm | Use |
|-------|-----|
| `standard` | Production services |
| `onestopauth` | Existing IDIR / BCeID |
| `onestopauth-basic` | BCeID Basic |
| `onestopauth-business` | BCeID Business |

**React frontend — OIDC PKCE config:**
```json
{
  "authority": "https://loginproxy.gov.bc.ca/auth/realms/standard",
  "client_id": "<client-id>",
  "redirect_uri": "https://<app-route>/callback",
  "response_type": "code",
  "scope": "openid profile email"
}
```

---

## OpenShift `oc` Command Reference

```bash
# Login
oc login --token=<token> --server=https://api.gold.devops.gov.bc.ca:6443

# Switch project
oc project <license-plate>-<env>

# List running pods
oc get pods -n <namespace>

# Pod logs
oc logs <pod-name> -n <namespace> --tail=100

# Describe pod (events + probe failures)
oc describe pod <pod-name> -n <namespace>

# Exec into pod
oc exec -it <pod-name> -n <namespace> -- /bin/sh

# Force rollout
oc rollout restart deployment/<name> -n <namespace>

# Watch rollout
oc rollout status deployment/<name> -n <namespace>

# Scale down for maintenance
oc scale deployment/<name> --replicas=0 -n <namespace>
```

---

## Secrets Management

**Never commit secrets.** Store in OpenShift Secrets, reference via env vars.

```yaml
# In Helm deployment.yaml
env:
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: <service>-db-secret
        key: password
  - name: KEYCLOAK_CLIENT_SECRET
    valueFrom:
      secretKeyRef:
        name: <service>-keycloak-secret
        key: client-secret
```

```bash
# Create secret in namespace
oc create secret generic <service>-db-secret \
  --from-literal=password=<value> \
  -n <namespace>
```

---

## ArgoCD Application CRD

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: <service>-<env>
  namespace: openshift-gitops
spec:
  project: default
  source:
    repoURL: https://github.com/<org>/gitops-be<id>.git
    targetRevision: HEAD
    path: environments/<env>/<service>
    helm:
      valueFiles:
        - values.yaml
        - values-<env>.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: <license-plate>-<env>
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=false
```

---

## Deployment Checklist

- [ ] Containerfile at `src/<service>/Containerfile` — see `containerfile-standards`
- [ ] Port 8080 used throughout
- [ ] Non-root `USER 1001` in Containerfile
- [ ] Health probes configured (`/health/live`, `/health/ready`)
- [ ] AVI InfraSettings annotation on every Route (`aviinfrasetting.ako.vmware.com/name`)
- [ ] Pod labels: `DataClass`, `owner`, `environment` on every Deployment/StatefulSet
- [ ] `Internet-Ingress: DENY` label on all internal workloads
- [ ] PriorityClass defined and referenced in every Deployment/StatefulSet
- [ ] NetworkPolicy: intent-based via `ag-template.networkpolicy` — no allow-all shapes
- [ ] Policy-as-code gate passes: Datree + Polaris + kube-linter + Conftest (rendered.yaml)
- [ ] Image pinned by tag or digest (no floating `latest`)
- [ ] `imagePullPolicy: Always` set on all containers
- [ ] Artifactory secrets in namespace
- [ ] ArgoCD Application CRD syncing

---

## PLATFORM_KNOWLEDGE

> Append new Emerald / OpenShift / Helm discoveries here.
> Format: `YYYY-MM-DD: <discovery>`

- 2026-04-16: ag-devops Conftest hard-denies Deployments without a matching NetworkPolicy — render all resources into one YAML file so cross-resource checks work.
- 2026-04-16: Required pod labels are DataClass + owner + environment (all three enforced by Datree/Conftest). owner = team name or ticket; environment = production|test|development.
- 2026-04-16: Polaris priorityClassNotSet check requires every Deployment/StatefulSet to set spec.template.spec.priorityClassName.
- 2026-04-16: Edge-terminated Routes need label app.kubernetes.io/component=frontend OR annotation isb.gov.bc.ca/edge-termination-approval — else Conftest denies.
- 2026-04-16: Internet-wide egress (0.0.0.0/0) in NetworkPolicy requires justification + approvedBy annotations or Conftest denies. Prefer specific CIDRs to avoid this requirement.
