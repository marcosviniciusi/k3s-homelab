# K3s Homelab - GitOps Infrastructure

Production-grade Kubernetes homelab running on bare-metal K3s with full GitOps automation via ArgoCD.

![K3s](https://img.shields.io/badge/K3s_v1.35-FFC61C?style=flat-square&logo=k3s&logoColor=black)
![ArgoCD](https://img.shields.io/badge/ArgoCD_v3.3.6-EF7B4D?style=flat-square&logo=argo&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat-square&logo=kubernetes&logoColor=white)
![Traefik](https://img.shields.io/badge/Traefik_v3.6.0-24A1C1?style=flat-square&logo=traefikproxy&logoColor=white)
![Cilium](https://img.shields.io/badge/Cilium_v1.19.2-F8C517?style=flat-square&logo=cilium&logoColor=black)
![Longhorn](https://img.shields.io/badge/Longhorn_v1.10.1-5E1F3F?style=flat-square)

## Cluster Overview

| | |
|---|---|
| **Nodes** | 7 (4 workers + 3 control-plane) |
| **Running Pods** | 175+ |
| **Deployments** | 102 |
| **ArgoCD Applications** | 58 |
| **Namespaces** | 23 |
| **OS** | Debian 12 (Bookworm) |

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        GitHub (Git)                             │
│                   k3s-homelab repository                        │
└──────────────────────────┬──────────────────────────────────────┘
                           │ auto-sync
┌──────────────────────────▼──────────────────────────────────────┐
│  ArgoCD v3.3.6                                                  │
│  ├── App of Apps pattern (58 applications)                      │
│  ├── Image Updater v0.18.0 (digest/semver strategies)           │
│  └── Notifications → Pushover (sync, health events)             │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│  K3s v1.35.0 Cluster                                            │
│                                                                  │
│  Networking        Storage          Security                     │
│  ├── Cilium 1.19   ├── Longhorn     ├── Sealed Secrets          │
│  │   eBPF + BGP    │   Replicated   ├── Infisical Operator      │
│  ├── Traefik 3.6   │   Backups      └── Cert-Manager            │
│  │   DaemonSet     │   Trim/GC                                  │
│  └── MetalLB       └── NFS                                      │
│                                                                  │
│  Observability     Registry         Hardware                     │
│  ├── SigNoz        └── Zot v2.1.15  ├── Intel GPU (4 nodes)     │
│  ├── OpenTelemetry     OCI + Trivy   └── Node Feature Discovery  │
│  └── Prometheus                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Infrastructure Stack

| Component | Version | Role |
|-----------|---------|------|
| **Cilium** | v1.19.2 | CNI with eBPF dataplane, kube-proxy replacement, BGP control plane for route advertisement |
| **Traefik** | v3.6.0 | Ingress controller as DaemonSet, IngressRoute CRDs, TLS termination, middlewares |
| **Longhorn** | v1.10.1 | Distributed block storage with automated backups (weekly), snapshot cleanup, and filesystem trim |
| **MetalLB** | - | Bare-metal LoadBalancer IP allocation |
| **Cert-Manager** | - | Automatic TLS certificate provisioning |
| **Sealed Secrets** | - | Encrypts Kubernetes Secrets for safe Git storage (kubeseal) |
| **Infisical** | v0.9.3 | External secrets management with Kubernetes operator (4 replicas) |
| **Zot Registry** | v2.1.15 | Private OCI container registry with web UI and Trivy CVE scanning |

## GitOps Pipeline

```
Developer push ──→ GitHub ──→ ArgoCD auto-sync ──→ K3s cluster
                                    ↑
Image Updater ──→ detects rebuild ──→ git commit ──→ ArgoCD
                                    ↓
                            Pushover notification
```

**ArgoCD Image Updater** monitors container registries and automatically commits image updates:
- **digest** strategy for `latest` tags (28 apps) — detects rebuilds via SHA256 without changing the tag
- **semver** strategy for versioned tags (3 apps) — upgrades to newer semantic versions
- Write-back via Git commits directly to this repository

**Notifications** are delivered via Pushover webhooks for sync succeeded, sync failed, and health degraded events. Credentials are managed through Infisical (SealedSecret for the service token, InfisicalSecret CR for Pushover keys).

## Workloads

### Media Automation (Namespace: `arr`)

Full *arr stack for automated media management: Sonarr, Radarr, Lidarr, Readarr, Whisparr (each with dedicated anime instances where applicable), Prowlarr for indexer management, Bazarr + Lingarr for subtitle download and translation via LibreTranslate, Autobrr for release automation, Suggestarr for content recommendations, Blockbusterr, Unpackerr, Configarr for cross-instance config sync, and Ryot for media tracking.

### Media Servers (Namespace: `jelly`)

Jellyfin and Emby as media servers, Jellystat for analytics, Overseerr for user requests. Transcoding offloaded to Intel iGPU via Unmanic workers (separate instances for series and anime in the `igpu` namespace, alongside 3 PhotoPrism instances for photo management per user).

### MCP Servers (Namespaces: `mcp-arr`, `mcp-k8s`, `mcp-proxmox`)

19 Model Context Protocol servers exposing ~290 tools for AI-powered infrastructure and media management (Claude Desktop, OpenWebUI). Each server has RBAC with per-user token authentication, health checks, and OpenTelemetry audit logging to SigNoz. Covers Sonarr, Radarr, TMDB, OMDB, Prowlarr, Bazarr, Emby, Jellyfin, MAL, Ryot, Lidarr, Whisparr, TVDB, Jellyseerr, qBittorrent, NZBGet, Kubernetes cluster operations, and Proxmox hypervisor management.

### Observability

SigNoz platform (ClickHouse + Zookeeper) for distributed tracing, logs, and metrics. OpenTelemetry Operator for automatic instrumentation. Prometheus exporters for *arr application metrics. Uptime Kuma for endpoint monitoring.

### Tools & Productivity

Homepage (dashboard), SearXNG (meta search), LibreChat with RAG (AI chat), FreshRSS (RSS reader), Uptime Kuma, QR Code Generator (custom image on private registry), The Lounge (IRC), Vaultwarden (password manager), Linkwarden (bookmark manager).

### Databases

MongoDB, Meilisearch (search engine), PGVector (PostgreSQL with vector support) — all in a dedicated `databases` namespace.

## Security Model

All secrets follow a zero-plaintext-in-Git policy:

1. **Sealed Secrets**: Kubernetes Secrets encrypted with kubeseal before committing. The cluster's sealed-secrets-controller decrypts them at runtime.
2. **Infisical Operator**: Syncs secrets from an external Infisical vault (`cofre.vinicima.com`) into Kubernetes Secrets via `InfisicalSecret` CRDs. Service tokens are stored as SealedSecrets.
3. **`.gitignore`**: Blocks `service-token.yaml` and `secrets.yaml` patterns to prevent accidental commits.
4. **RBAC**: ArgoCD project `vinicima-prod` with scoped cluster resource access. Image Updater uses a dedicated `apiKey` account with minimal permissions.

## Storage Architecture

**Longhorn** provides replicated block storage with automated maintenance:

| RecurringJob | Schedule | Purpose |
|---|---|---|
| `full-backup` | Saturday 8am | Full volume backup, retain 1 |
| `delete-snapshot` | Thursday 8am | Purge marked snapshots |
| `trim-filesystem` | Monday 8am | fstrim to reclaim unused blocks |

**NFS** is used for large media libraries (videos, photos metadata, transcode cache). **hostPath** volumes for apps requiring node-local storage (e.g., Unmanic GPU workers).

## Repository Structure

```
├── arcocd-projects/          # ArgoCD Project definitions (RBAC, allowed resources)
├── argocd-applications/      # 58 Application manifests (App of Apps pattern)
├── k3s-install/
│   ├── ansible/              # Node provisioning playbooks
│   ├── install-cmd/          # K3s bootstrap scripts
│   └── manifests/            # Core infrastructure (ArgoCD, Cilium values, Longhorn, etc)
├── kustomize/
│   ├── argocd-stack/         # ArgoCD + Image Updater + Notifications + SealedSecrets
│   ├── arr-stack/            # 20+ media automation apps
│   ├── cert-manager-stack/   # Cert-Manager + Reflector + Reloader
│   ├── databases-stack/      # MongoDB, Meilisearch, PGVector
│   ├── igpu-stack/           # GPU-accelerated workloads (Unmanic, PhotoPrism)
│   ├── infisical-stack/      # Infisical operator + server
│   ├── jelly-stack/          # Media servers (Jellyfin, Emby, Jellystat, Overseerr)
│   ├── longhorn-stack/       # Longhorn + RecurringJobs
│   ├── mcp-arr/              # 17 MCP servers for media management
│   ├── mcp-k8s/              # MCP server for Kubernetes operations
│   ├── mcp-proxmox/          # MCP server for Proxmox management
│   ├── signoz-observability/ # SigNoz platform (Helm chart + values)
│   ├── tools-stack/          # Productivity tools + Prometheus exporters
│   ├── traefik-stack/        # Traefik ingress controller
│   └── vault-stack/          # Vaultwarden + Linkwarden
└── vinicima-apps-argo-iac.yaml  # Root App of Apps
```

Each application directory follows a consistent pattern:

```
kustomize/<stack>/<app>/
├── kustomization.yaml       # Resource list and namespace
├── deploy.yaml              # Deployment with resource limits, probes, affinity
├── svc.yaml                 # Service
├── sealed-secret.yaml       # Encrypted secrets (kubeseal)
├── infisical-sync.yaml      # InfisicalSecret CR for external secret sync
├── ingressroute.yaml        # Traefik IngressRoute for HTTPS exposure
└── configmap.yaml           # Application configuration
```

## Key Design Decisions

- **Kustomize over Helm** for application deployments — simpler diffs, explicit manifests, no template rendering ambiguity
- **DaemonSet Traefik** instead of Deployment — every node handles ingress, no single point of failure
- **Cilium with kube-proxy replacement** — eBPF-based networking eliminates iptables overhead, BGP for direct route advertisement to upstream routers
- **Digest strategy for image updates** — prevents tag mutation issues (e.g., `latest` pointing to incompatible versions); only rebuilds of the same tag trigger updates
- **Infisical + SealedSecrets dual approach** — Infisical for dynamic secrets with automatic rotation, SealedSecrets for static credentials that rarely change
- **Separate anime instances** — dedicated Sonarr/Radarr/Bazarr/Lingarr instances for anime content with different quality profiles and indexers

## References

- [ArgoCD](https://argo-cd.readthedocs.io/) | [Image Updater](https://argocd-image-updater.readthedocs.io/)
- [K3s](https://docs.k3s.io/) | [Kustomize](https://kustomize.io/)
- [Cilium](https://docs.cilium.io/) | [Traefik](https://doc.traefik.io/traefik/)
- [Longhorn](https://longhorn.io/docs/) | [MetalLB](https://metallb.universe.tf/)
- [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets) | [Infisical](https://infisical.com/docs)
- [Zot Registry](https://zotregistry.dev/) | [SigNoz](https://signoz.io/docs/)
