---
name: bc-gov-networkpolicy
description: Kubernetes / OpenShift NetworkPolicy authoring for BC Gov Private Cloud (Silver, Gold, Emerald). Use when writing, reviewing, or debugging NetworkPolicy YAML — two-policy rule, ag-helm intent API, DNS egress, CIDR-based egress to external systems, inter-namespace flows, and common port patterns. Applies across all BC Gov OCP clusters; Emerald-specific enforcement is in bc-gov-emerald.
tools: Read, Grep, Glob
metadata:
  author: Ryan Loiselle
  version: "1.1"
compatibility: All BC Gov Private Cloud clusters (Silver, Gold, Emerald). Emerald is the strictest — default-deny both ingress AND egress.
---

# BC Gov NetworkPolicy Patterns

Practical NetworkPolicy authoring knowledge for BC Government OpenShift workloads.

For the SDN zone model and what traffic is architecturally permitted, see `bc-gov-sdn-zones`.
For Emerald-specific mechanics (AVI annotation, DataClass label), see `bc-gov-emerald`.

---

## The Two-Policy Rule

**Every traffic flow requires exactly two NetworkPolicy objects**, one on each end:

| Role | Policy type | Applied to | Namespace |
|---|---|---|---|
| Sender | **Egress** | Sender pod | Sender's namespace |
| Receiver | **Ingress** | Receiver pod | Receiver's namespace |

Defining only one of the two is the most common NetworkPolicy mistake. The result is a
TCP timeout that looks identical to "no policy at all."

```
Frontend pod ──── Egress NP (frontend ns) ────▶ API pod
                ◀──── Ingress NP (api ns)   ────
```

---

## DNS Egress — Required on Every Pod

Emerald default-denies egress. Every pod needs DNS egress or it cannot resolve service names.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-egress-dns
  namespace: <license-plate>-dev
spec:
  podSelector: {}          # applies to all pods in namespace
  policyTypes: [Egress]
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: openshift-dns
      ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53
```

> The `to: namespaceSelector` targeting `openshift-dns` is required — Conftest hard-denies
> egress rules without a `to:` peer selector. This also keeps DNS egress least-privilege
> (only the DNS service pods, not all pods on port 53).

> Add this first. Without it, nothing will work regardless of other policies.

---

## Common Flow Patterns

### Frontend → API (same namespace)

```yaml
# Egress from frontend (in same namespace)
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-egress-frontend-to-api
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes: [Egress]
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: api
      ports:
        - protocol: TCP
          port: 8080
---
# Ingress into API from frontend (in same namespace)
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-api-from-frontend
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes: [Ingress]
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: frontend
      ports:
        - protocol: TCP
          port: 8080
```

### API → Database (same namespace)

```yaml
# Egress from API
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-egress-api-to-db
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes: [Egress]
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: mariadb
      ports:
        - protocol: TCP
          port: 3306
---
# Ingress into DB from API
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-db-from-api
spec:
  podSelector:
    matchLabels:
      app: mariadb
  policyTypes: [Ingress]
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: api
      ports:
        - protocol: TCP
          port: 3306
```

### Router → Pod (inbound from OpenShift router)

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-from-router
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes: [Ingress]
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              network.openshift.io/policy-group: ingress
```

### Egress to External IP / CIDR

Use for on-prem databases, external APIs, or 3PG endpoints.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-egress-api-to-oracle
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes: [Egress]
  egress:
    - to:
        - ipBlock:
            cidr: 142.34.0.0/16    # target CIDR — use actual destination
      ports:
        - protocol: TCP
          port: 1521               # Oracle; see port reference below
```

> ⚠️ For **Medium/High workloads** on Emerald, direct internet egress is silently dropped at 
> the SDN guardrail even if the NetworkPolicy object is applied.
> Internet = use Forward Proxy. External partner = use 3PG CIDR.
> See `bc-gov-sdn-zones` for zone egress constraints.

---

## Least-Privilege Rules

- Only open the specific **port and protocol** needed — never wildcard `{}` ports
- Use `podSelector` when the destination is within the same namespace
- Use `ipBlock` only for traffic leaving the cluster
- Never create a wildcard egress policy unless explicitly required (e.g., monitoring agents)
- Prefer named ports listed explicitly over port ranges

> ⚠️ **ag-devops Conftest hard-denies** NetworkPolicy manifests that have: `ingress/egress: - {}` (allow-all rule), rules missing `from`/`to`, rules missing `ports`, or empty `podSelector: {}` peers. These shapes pass `kubectl apply` but will be rejected by the policy gate.

---

## Preferred Authoring: ag-helm Intent API

When using the `ag-helm-templates` library chart, use `ag-template.networkpolicy` with the intent inputs `AllowIngressFrom` and `AllowEgressTo` rather than writing raw YAML. The intent API produces correctly-shaped rules that pass all ag-devops Conftest checks.

```yaml
# In your Helm template (e.g. templates/networkpolicy.yaml)
{{- $np := dict "Values" .Values -}}
{{- $_ := set $np "ApplicationGroup" .Values.project -}}
{{- $_ := set $np "Name" "jrcc-loader" -}}
{{- $_ := set $np "Namespace" $.Release.Namespace -}}
{{- $_ := set $np "PolicyTypes" (list "Ingress" "Egress") -}}

{{/* Allow ingress from RabbitMQ (same namespace) */}}
{{- $_ := set $np "AllowIngressFrom" (dict
  "ports" (list 8080)
  "apps" (list (dict "name" "rabbitmq"))
) -}}

{{/* Allow egress to ORDS API (specific CIDR) */}}
{{- $_ := set $np "AllowEgressTo" (dict
  "ipBlocks" (list (dict
    "cidr" "142.34.X.X/24"
    "ports" (list 443)
  ))
) -}}

{{ include "ag-template.networkpolicy" $np }}
```

### Internet-wide egress (requires approval annotations)

If egress to `0.0.0.0/0` is unavoidable, Conftest requires both annotations or it hard-denies:

```yaml
{{- $_ := set $np "Annotations" (dict
  "justification" "Reason this service needs internet-wide egress"
  "approvedBy"    "Ticket reference or approver name"
) -}}
{{- $_ := set $np "AllowEgressTo" (dict
  "internet" (dict "enabled" true "cidrs" (list "0.0.0.0/0") "ports" (list 443))
) -}}
```

Prefer a specific CIDR (`ipBlock`) over `0.0.0.0/0` — specific CIDRs do not require the approval annotations.

### AllowIngressFrom / AllowEgressTo intent schema summary

| Key | Type | Description |
|-----|------|-------------|
| `apps` | list of `{name, ports?}` | Same-namespace pods by `app` label |
| `namespaces` | list of `{name, podSelector?}` | Cross-namespace (e.g. openshift-ingress router) |
| `ipBlocks` | list of `{cidr, ports}` | CIDR-based (on-prem systems, external APIs) |
| `internet` | `{enabled, cidrs, ports}` | Internet-wide egress — requires approval annotations |

For full schema and examples: [bcgov/ag-devops cd/shared-lib/ag-helm/docs/SIMPLE-API.md](https://github.com/bcgov/ag-devops/blob/main/cd/shared-lib/ag-helm/docs/SIMPLE-API.md)

---

## Common Port Reference

| Service | Protocol | Port |
|---|---|---|
| Oracle Database | TCP | 1521 |
| SQL Server (MSSQL) | TCP | 1433 |
| PostgreSQL | TCP | 5432 |
| MySQL / MariaDB | TCP | 3306 |
| LDAP | TCP | 389 |
| LDAPS | TCP | 636 |
| SMTP | TCP | 25 / 587 |
| NTP | UDP | 123 |
| DNS | UDP + TCP | 53 |
| HTTP | TCP | 80 |
| HTTPS | TCP | 443 |
| Kubernetes API server | TCP | 6443 |
| OpenShift internal app port | TCP | 8080 |

---

## Debugging Checklist

When a flow is not working:

1. **Two-policy rule** — does the sender have Egress AND the receiver have Ingress?
2. **DNS egress** — is there an `allow-egress-dns` policy on the sender pod?
3. **Label match** — do `podSelector.matchLabels` values in the NP match the actual pod labels?
4. **Namespace scope** — are both pods in the same namespace, or does a `namespaceSelector` need to be added?
5. **Port match** — does the port in the NP match the actual listening port?
6. **SDN guardrail** — is the destination on the internet and the workload Medium/High? NetworkPolicy cannot override the guardrail.

### Useful commands

```bash
# View NetworkPolicies in namespace
oc get networkpolicy -n be808f-dev

# Describe a specific policy
oc describe networkpolicy <name> -n be808f-dev

# Test egress from a running pod
oc exec <pod> -n be808f-dev -- curl -v <destination>:<port>

# Launch a debug pod (if pod has no shell)
oc debug -n be808f-dev deployment/<name> -- curl -v <destination>:<port>

# Check pod labels (to validate selector match)
oc get pod <pod> -n be808f-dev --show-labels
```
