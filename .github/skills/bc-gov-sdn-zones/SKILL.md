---
name: bc-gov-sdn-zones
description: BC Government network security classification and zone model. Use when determining what security zone a workload belongs to, mapping ISCF data classification to DataClass labels, designing connectivity between zones, evaluating internet egress constraints, or planning Third Party Gateway (3PG) connections to external partners.
tools: Read, Grep, Glob
metadata:
  author: Ryan Loiselle
  version: "1.0"
  sources:
    - "OCIO SDN Security Classification Model v1.0 (2022)"
    - "IMIT Standard 6.13 — Network Security Zones Standard (2012)"
    - "OCIO ISCF — Information Security Classification Framework"
    - "ASRB SEP Network Zones submission v4.1"
compatibility: All BC Government workloads. SDN model applies to OpenShift Private Cloud (Silver, Gold, Emerald) and legacy gov.bc.ca network.
---

# BC Gov Network Security Classification & Zone Model

Core BC Government network architecture knowledge. Platform-independent — applies before
you write a single line of NetworkPolicy or Helm chart.

For Emerald-specific enforcement mechanics (AVI, pod labels), see `bc-gov-emerald`.
For NetworkPolicy YAML patterns, see `bc-gov-networkpolicy`.

---

## Information Security Classification Framework (ISCF)

The ISCF is the **root policy** that defines how sensitive government information is classified.
Every workload's `DataClass` label and network zone placement must be derived from ISCF.

| ISCF Class | Examples | OpenShift `DataClass` | SDN zone | Historic zone |
|---|---|---|---|---|
| Public / Unclassified | Public websites, open data | `Low` | Low | DMZ |
| Protected A | Low-sensitivity personal info, internal business | `Medium` | Medium | Zone B |
| Protected B (lower) | Medical records, financial data | `Medium` | Medium | Zone B |
| Protected B (higher) / Protected C | Cabinet records, law enforcement data | `High` | High | Zone A |
| Classified (federal co-owned) | — | `High` | High | Zone A |

> Rule: **classify the data, then assign the zone.** Never infer classification from where a
> workload currently lives — legacy zone placement is not a reliable indicator of data class.

---

## 2022 SDN Security Classification Model (Low / Medium / High)

The 2022 SDN model replaces the historic A/B/C/DMZ zone names with three workload tags.
All BC Gov Private Cloud namespaces operate under this model.

### Low

- Equivalent: DMZ / Zone C (internet-facing)
- Internet ingress: permitted
- Internet egress: **direct** (no proxy required)
- Typical workloads: public-facing websites, open-data APIs

### Medium

- Equivalent: Zone B
- Internet ingress: **blocked** — ingress only via reverse proxy in a Low zone
- Internet egress: **only via SSBC SDN Forward Proxy** (HTTP 80 / HTTPS 443 only)
  Direct internet egress is **silently dropped at the guardrail** even if a NetworkPolicy
  object allows it.
- Typical workloads: internal APIs, back-office services, Protected-A data stores

### High

- Equivalent: Zone A (Restricted High Security)
- Internet ingress: **blocked** — no path from internet
- Internet egress: **blocked** — requires Ministry ISO (MISO) exemption
- Typical workloads: law enforcement, Protected B-C data processing, classified workloads

---

## Historic Zone Model — IMIT Standard 6.13

The historic zone model is still referenced in OCIO documents and by network/security teams
who pre-date the SDN migration. Know both so you can communicate across generations.

| Zone | Name | Trust | ISCF data | Key constraint |
|---|---|---|---|---|
| DMZ | Internet-facing | Lowest | Public | Reverse proxies only; no direct app hosting |
| Zone C | Trusted Client | Low–Medium | Protected A | IDIR-managed workstations; not server workloads |
| Zone B | High Security | Medium | Protected A / lower Prot. B | Internal app tier; no direct internet |
| Zone A | Restricted High Security | Highest | Protected B-C / Classified | Server-to-server only; no user devices |
| ExtraNet / 3PG | External Partner | External | Varies | Traverse via Third Party Gateway |
| SPAN / BC | Shared Services | Internal | Varies | BC Government shared network segment |

---

## Zone Adjacency Rule — No Zone Hopping

**Traffic may only flow between adjacent zones.** The permitted path is:

```
Internet  →  DMZ / Low  →  Medium  →  High
```

- The internet **cannot** initiate a session directly into Medium or High.
- A High workload **cannot** be reached in a single hop from the internet.
- A Medium workload **cannot** directly reach a High workload without traversing
  the appropriate intermediate policy boundary.
- **NetworkPolicy cannot override this.** Adjacency is enforced at the SDN guardrail,
  not at the pod level. A NetworkPolicy allow rule from internet to Medium will be
  silently dropped by the guardrail.

---

## Internet Egress Constraints by SDN Classification

| Classification | Internet egress path | Notes |
|---|---|---|
| Low | Direct | No proxy required |
| Medium | SSBC SDN Forward Proxy only | HTTP/HTTPS only; other protocols not supported via proxy |
| High | Blocked | MISO exemption required; direct internet egress denied at guardrail |

### Forward Proxy (Medium workloads)

To reach the internet from a Medium workload:
1. Configure your application to use the SSBC Forward Proxy endpoint
2. Write a NetworkPolicy Egress rule allowing traffic to the proxy host (not the final destination)
3. Do **not** write a CIDR NetworkPolicy pointing at the public internet — it will be silently dropped

---

## External Partner Connectivity — Third Party Gateway (3PG) / ExtraNet

Any connection to an **external government partner** (other ministries, Crown corporations,
health authorities, municipalities, federal partners) must traverse the **ExtraNet zone** via a
**Third Party Gateway (3PG)**.

### Process

1. Submit a formal SSBC connection request referencing the target organisation and IP range
2. Await 3PG CIDR allocation from SSBC (the actual destination CIDRs are not directly routable)
3. Write an Egress NetworkPolicy targeting the **3PG CIDR** (not the partner's final destination IP)
4. The 3PG performs NAT/routing to the partner's network

> Do **not** attempt to route external-partner traffic through the SSBC Forward Proxy or
> the regular internet egress path — neither path reaches the ExtraNet segment.

### SPAN / BC Gov Network

Connections within the BC Gov SPAN network (e.g., to on-premises data centres, shared
services, or other ministries on the corporate LAN) are also subject to zone-to-zone
adjacency rules. Confirm the target system's zone before designing your NetworkPolicy.

---

## Worked Example — Classifying a New Workload

> **Q**: My API stores Protected-B criminal justice data. What zone, what `DataClass` label,
> can I call a public REST API for address validation?

1. Data class = Protected B → **SDN High** → `DataClass: High`
2. Internet egress → **blocked at guardrail** — address validation API is on the internet
3. Options:
   - Move address validation to a Medium proxy service that calls the API on behalf of High
   - Reclassify if the API response does not contain High-class data and isolation is possible
   - Apply for MISO exemption (lengthy process; avoid if possible)

---

## Quick Reference — Which Standard Governs?

| Question | Standard | Document |
|---|---|---|
| What class is this data? | ISCF | `information-security-classification` on gov.bc.ca |
| What zone? | IMIT 6.13 (historic) / SDN Model (current) | `SDN Security Classification Model v1.0 (2022)` |
| Can I reach the internet? | SDN guardrail rules | `SDN Security Classification Model v1.0 (2022)` |
| Can I connect to another ministry? | 3PG / ExtraNet rules | `N2N Connectivity Standard (2008)` |
| What pod label? | Emerald DataClass enforcement | `bc-gov-emerald` skill |
| How to write the NetworkPolicy? | NetworkPolicy patterns | `bc-gov-networkpolicy` skill |
