---
name: ocp-resilience-analyst
description: Produces a full resilience posture report for any OpenShift namespace, grading workloads against 15 resilience categories (R01–R15) and generating prioritised remediation tasks. Use when assessing OpenShift namespace resilience, PDB coverage, HPA configuration, or replica availability.
tools: Bash, Read, Write, Grep, Glob
user-invocable: true
compatibility: OpenShift 4.x clusters (Silver, Gold, Emerald). Platform-agnostic resilience checks apply to any Kubernetes cluster.
---

# SKILL: ocp-resilience-analyst

## Purpose

Grade an OpenShift namespace against 15 resilience categories (R01–R15) and generate a
prioritised remediation task list.

Invocation tiers:

| Tier | Invocation | Depth |
|------|-----------|-------|
| 1 | Direct AI invocation in VS Code | Full data collection → gap analysis → report → optional PDF |
| 2 | Toolkit CLI | Automated OC commands + AI analysis |
| 3 | GitHub Action (`rloisell/ocp-resilience-toolkit@main`) | Automated collection + AI analysis in CI |

---

## Invocation

```
Use the ocp-resilience-analyst skill to produce a resilience posture report for
namespace <license-plate>-prod. Log in to the Silver cluster before running.
```

---

## Phase 1 — Collect Namespace Data

### 1.1 Workload and Replica State

```bash
NS=<license-plate>-prod

# Deployments with replica counts
oc get deployment,statefulset,daemonset -n $NS -o yaml > working/$NS/workloads.yaml

# Current pod status
oc get pods -n $NS -o wide > working/$NS/pods.txt

# HPA
oc get hpa -n $NS -o yaml > working/$NS/hpa.yaml

# PDB
oc get pdb -n $NS -o yaml > working/$NS/pdb.yaml

# Replication summary
oc get deployment -n $NS -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.replicas}{"\n"}{end}' > working/$NS/replica-counts.txt
```

### 1.2 Networking and Routing

```bash
# Services
oc get svc -n $NS -o yaml > working/$NS/services.yaml

# Routes
oc get route -n $NS -o yaml > working/$NS/routes.yaml

# NetworkPolicies
oc get networkpolicy -n $NS -o yaml > working/$NS/networkpolicies.yaml
```

### 1.3 Storage and Quotas

```bash
# Persistent Volume Claims
oc get pvc -n $NS -o yaml > working/$NS/pvc.yaml

# Resource quotas and limit ranges
oc get resourcequota,limitrange -n $NS -o yaml > working/$NS/resource-quotas.yaml

# Node labels (for topology spread key discovery)
oc get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels.topology\.kubernetes\.io/zone}{"\n"}{end}'
```

---

## Phase 2 — Gap Analysis (R01–R15)

Grade each check: **Pass** / **Warn** / **Fail**

| # | Category | Severity | Standard | What to check |
|---|----------|----------|----------|---------------|
| R01 | Replica count ≥ 2 for all Deployments | High | K8S-01 | `spec.replicas` on every non-job Deployment |
| R02 | Pod Disruption Budget (PDB) present and meaningful | High | K8S-02 | PDB exists; `minAvailable ≥ 1` or `maxUnavailable < 100%` |
| R03 | Anti-affinity rules (pod spread across nodes) | High | K8S-03 | `podAntiAffinity` on all multi-replica Deployments |
| R04 | TopologySpreadConstraints configured | Medium | K8S-04 | `topologySpreadConstraints` present with `maxSkew: 1` |
| R05 | HPA configured for stateless services | Medium | K8S-05 | HPA with `minReplicas ≥ 2` exists for all non-StatefulSet workloads |
| R06 | Resource requests and limits set | High | K8S-06 | All containers have `resources.requests` and `resources.limits` defined |
| R07 | Liveness and Readiness probes configured | High | K8S-07 | Both probes present on every container |
| R08 | Graceful termination / preStop hook | Medium | K8S-08 | `terminationGracePeriodSeconds` set; `preStop` sleep on HTTP servers |
| R09 | Rolling update strategy — not Recreate | High | K8S-09 | `strategy.type: RollingUpdate` on all Deployments |
| R10 | No single-point-of-failure StatefulSets | High | K8S-01 | StatefulSet replicas ≥ 3 for quorum services (Kafka, Zookeeper, etcd) |
| R11 | QoS class is Guaranteed or Burstable | Medium | K8S-06 | Avoid QoS class `BestEffort` (no requests set) |
| R12 | PVC uses appropriate StorageClass | Medium | PS-01 | Block PVCs on `netapp-block-standard`; avoid RWX for stateful |
| R13 | NetworkPolicy default-deny egress present | High | PS-02 | At minimum one default-deny egress NetworkPolicy per namespace |
| R14 | Startup probe for slow-starting containers | Low | K8S-07 | `startupProbe` present for Java / .NET apps with long initialisation |
| R15 | Image pull policy is `IfNotPresent` or pinned digest | Medium | SEC-01 | `imagePullPolicy: Always` combined with mutable tags is a restart risk |

### Grade Scoring

| Grade | Meaning |
|-------|---------|
| A | 0 High failures; ≤ 2 Medium warnings |
| B | ≤ 1 High failure; ≤ 4 Medium warnings |
| C | 2–3 High failures or ≥ 5 Medium warnings |
| D | 4+ High failures |
| F | Critical availability risk; immediate remediation required |

---

## Phase 3 — Report Structure

Generate the following sections from the collected data.

| # | Section |
|---|---------|
| 1 | Executive Summary — grade, workload count, top 3 risks |
| 2 | Namespace Inventory — Deployment, StatefulSet, DaemonSet list with replica counts |
| 3 | R01–R15 Gap Matrix — pass/warn/fail with evidence from YAML |
| 4 | HPA Coverage Map — which services have HPA; min/max replicas |
| 5 | PDB Coverage Map — which services have PDB; min available |
| 6 | Network Resilience — NetworkPolicy coverage; default-deny present? |
| 7 | Storage Resilience — StorageClass choices; RWO vs RWX vs block |
| 8 | Remediation Task List — prioritised tasks with prefix `RES-XX` |
| 9 | Effort Estimation — task × complexity × AI-assist level |
| 10 | Diagrams — PlantUML component diagram with replica counts |
| A1 | Appendix — Raw replica counts and PDB dump |
| A2 | Appendix — Full R01–R15 evidence YAML snippets |

### Task prefix convention

| Prefix | Category |
|--------|----------|
| `RES-XX` | Resilience fix (replica count, PDB, anti-affinity) |
| `OBS-XX` | Observability fix (probes, logging, Prometheus) |
| `NP-XX` | NetworkPolicy remediation |
| `STG-XX` | Storage class migration |
| `HPA-XX` | Autoscaling configuration |

---

## Phase 4 — PDF Render

```bash
pandoc <APP>-Resilience-Report.md \
  --from=markdown --to=html5 --standalone \
  --css=report-style.css --embed-resources \
  --output=/tmp/resilience-report.html \
  --metadata title="<APP> — Resilience Posture Report"

"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --disable-gpu \
  --print-to-pdf=<APP>-Resilience-Report.pdf \
  --print-to-pdf-no-header --no-pdf-header-footer \
  file:///tmp/resilience-report.html 2>/dev/null
```

---

## Reference Patterns

### PDB — Recommended Patterns

```yaml
# At least one pod must always be available
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: my-service-pdb
  namespace: <license-plate>-prod
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: my-service
```

```yaml
# At most one pod may be unavailable at a time (preferred for N≥3)
spec:
  maxUnavailable: 1
```

### Pod Anti-Affinity

```yaml
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          topologyKey: kubernetes.io/hostname
          labelSelector:
            matchLabels:
              app: my-service
```

### TopologySpreadConstraints

```yaml
topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: topology.kubernetes.io/zone
    whenUnsatisfiable: DoNotSchedule
    labelSelector:
      matchLabels:
        app: my-service
```

### Graceful Termination with preStop Hook

For HTTP servers that receive in-flight requests during a rolling update:

```yaml
lifecycle:
  preStop:
    exec:
      command: ["/bin/sh", "-c", "sleep 5"]
terminationGracePeriodSeconds: 30
```

The `sleep 5` allows the load balancer to drain connections before the pod begins shutting down.

### QoS Class Reference

| QoS Class | When assigned | Risk |
|-----------|--------------|------|
| `Guaranteed` | All containers have `requests == limits` | Lowest — never OOM-evicted first |
| `Burstable` | At least one container has `requests < limits` | Medium — evicted before Guaranteed |
| `BestEffort` | No requests or limits set | Highest — evicted first under pressure |

Always set `requests` at minimum. Set `limits` for CPU (avoid CPU throttling) and memory (required for Guaranteed QoS).

### RollingUpdate Strategy

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1        # Extra pods allowed above replicas during rollout
    maxUnavailable: 0  # Zero-downtime: never reduce below desired replicas
```

### Disruption Simulation Rules

Before load testing or deliberately draining nodes:
1. Confirm a PDB exists that prevents dropping below `minAvailable`
2. Verify HPA can scale up new pods before old pods terminate
3. Confirm StatefulSet quorum is maintained (for Kafka/Zookeeper: N/2+1 pods must stay up)
4. Run `oc adm drain <node> --ignore-daemonsets --dry-run` first to preview evictions

---

## Sources and References

### Kubernetes Documentation

| ID | Standard | Reference |
|----|----------|-----------|
| K8S-01 | ReplicaSet and Deployment replica specification | [kubernetes.io](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/) |
| K8S-02 | Pod Disruption Budgets | [kubernetes.io](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/) |
| K8S-03 | Pod affinity and anti-affinity | [kubernetes.io](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity) |
| K8S-04 | TopologySpreadConstraints | [kubernetes.io](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/) |
| K8S-05 | HorizontalPodAutoscaler | [kubernetes.io](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) |
| K8S-06 | Resource requests and limits | [kubernetes.io](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) |
| K8S-07 | Configure liveness, readiness, and startup probes | [kubernetes.io](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) |
| K8S-08 | Pod lifecycle — termination and preStop hooks | [kubernetes.io](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/) |
| K8S-09 | Deployment update strategy | [kubernetes.io](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#rolling-update-deployment) |
| K8S-10 | Quality of Service classes | [kubernetes.io](https://kubernetes.io/docs/concepts/workloads/pods/pod-qos/) |

### OpenShift Platform

| ID | Standard | Reference |
|----|----------|-----------|
| OCP-01 | OpenShift — StatefulSet rolling updates and quorum | [docs.openshift.com](https://docs.openshift.com/container-platform/4.14/applications/working_with_replication_controllers.html) |
| OCP-02 | OpenShift — Machine Config and node drain behaviour | [docs.openshift.com](https://docs.openshift.com/container-platform/4.14/nodes/nodes/nodes-nodes-working.html) |
| OCP-03 | OpenShift — Resource quotas and LimitRange | [docs.openshift.com](https://docs.openshift.com/container-platform/4.14/applications/quotas/quotas-setting-per-project.html) |

### BC Gov Platform Services

| ID | Standard | Reference |
|----|----------|-----------|
| PS-01 | Platform Services — Storage Guide (StorageClass selection) | [docs.developer.gov.bc.ca](https://docs.developer.gov.bc.ca/) |
| PS-02 | Emerald Landing Zone — default-deny NetworkPolicy requirement | [docs.developer.gov.bc.ca](https://docs.developer.gov.bc.ca/) |
| PS-03 | Platform Services — Resource requests required for scheduling | [docs.developer.gov.bc.ca](https://docs.developer.gov.bc.ca/) |

### ag-devops Policy Standards

| ID | Standard | Enforcement |
|----|----------|-------------|
| AD-01 | Pod label requirements: `DataClass`, `owner`, `environment` | Datree + Conftest hard-deny |
| AD-02 | PriorityClass required on all workloads | Polaris `priorityClassNotSet` check |

### Security

| ID | Standard | Reference |
|----|----------|-----------|
| SEC-01 | OWASP A06:2021 — Vulnerable and Outdated Components (mutable image tags) | [owasp.org](https://owasp.org/Top10/A06_2021-Vulnerable_and_Outdated_Components/) |
