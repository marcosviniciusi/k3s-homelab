# Homelab K3s GitOps Repository

Repositório GitOps para gerenciamento de aplicações do homelab utilizando **ArgoCD** e **Kustomize** em um cluster **K3s** bare-metal com 4 nós.

## 📋 Visão Geral

Este repositório contém todos os manifestos Kubernetes para deploy e gerenciamento das aplicações do homelab através de práticas GitOps. A estrutura utiliza ArgoCD como ferramenta de Continuous Delivery, permitindo sincronização automática entre o estado desejado (Git) e o estado real do cluster.

## 🗂️ Estrutura do Repositório

```
.
├── argocd-projects/                 # Definições de Projects do ArgoCD
│   └──                              # Manifestos do Project
├── argocd-applications/             # Applications do ArgoCD (App of Apps pattern)
│   └── Apps-applications            # manifestos ArgoCD Applications
│
└── kustomize/                       # Manifestos Kubernetes organizados por aplicação
    └── NAMESPACE                    # namespaces
        └── <app-name>/              # Pasta da App e seus manifestos
            ├── kustomization.yaml
            ├── deployment.yaml
            ├── service.yaml
            ├── configmap.yaml
            └── sealed-secret.yaml
```

## 🚀 Como Funciona

### ArgoCD Projects

Os **Projects** do ArgoCD fornecem isolamento lógico e controle de acesso para grupos de aplicações. Cada project define:

- Repositórios Git permitidos
- Clusters e namespaces de destino
- Recursos Kubernetes permitidos
- Políticas de sincronização

### ArgoCD Applications

As **Applications** seguem o padrão **App of Apps**, onde uma aplicação raiz gerencia múltiplas aplicações filhas. Isso permite:

- Deploy declarativo de múltiplas aplicações
- Sincronização hierárquica
- Gestão centralizada do ciclo de vida

### Kustomize

O **Kustomize** é utilizado para gerenciar configurações sem templates, permitindo:

- Reutilização de manifests base
- Customizações por namespace
- Patches estratégicos e merge de configurações
- Gestão de ConfigMaps e Secrets

## 📦 Aplicações Deployadas

### 🎯 ArgoCD (Namespace: `argocd`)
GitOps Continuous Delivery tool para Kubernetes
- **argocd**: Argo Cd

### 📺 Media Automation Stack (Namespace: `arr`)
Suite completa de aplicações *arr para automação de mídia
- **Sonarr** / **Sonarr Animes**: Gerenciamento automático de séries e animes
- **Radarr** / **Radarr Animes**: Gerenciamento automático de filmes e animes
- **Lidarr**: Gerenciamento automático de música
- **Readarr**: Gerenciamento automático de livros e audiobooks
- **Whisparr**: Gerenciamento automático de conteúdo adulto
- **Prowlarr**: Gerenciador de indexers para todas as *arr apps
- **Bazarr** / **Bazarr Animes**: Download automático de legendas
- **Lingarr** / **Lingarr Animes**: Tradução de legendas
- **LibreTranslate**: Serviço de tradução open-source
- **Huntarr**: Gerenciamento de solicitações e busca
- **Suggestarr**: Sugestões personalizadas de conteúdo
- **Unpackerr-TRT**: Extração automática de arquivos torrent
- **Configarr-Sync**: Sincronização de configurações entre instâncias

### 🎬 Media Server Stack (Namespace: `jelly`)
Servidores de mídia e gestão de solicitações
- **Jellyfin**: Media server open-source
- **Emby**: Media server alternativo
- **Jellystat**: Estatísticas e analytics do Jellyfin
- **Overseerr**: Sistema de solicitações de filmes/séries

### 🎨 Media Processing (Namespace: `igpu`)
Aplicações que utilizam aceleração de GPU Intel
- **Photosync**: Processamento de fotos
- **Unmanic-Movies**: Transcodificação de filmes
- **Unmanic-Series**: Transcodificação de séries

### 🔐 Security & Secrets (Namespace: `cert-manager`, `kube-system`)
Gerenciamento de certificados e secrets
- **cert-manager**: Gerenciamento automático de certificados TLS
- **cert-manager-cainjector**: Injeção de CA em recursos
- **cert-manager-webhook**: Webhooks para validação
- **Reflector**: Replicação de secrets e configmaps entre namespaces
- **sealed-secrets-controller**: Criptografia de secrets no Git

### 🔑 Secrets Management
- **Infisical Operator** (Namespace: `infisical-operator`): Operador para gerenciamento de secrets
- **Vault** (Namespace: `vault`): HashiCorp Vault para secrets management
- **Linkwarden** (Namespace: `vault`): Gerenciador de bookmarks e links

### 🌐 Networking & Ingress
- **Ingress Nginx Controller** (Namespace: `ingress-nginx`): Controlador de ingress com 4 réplicas
- **MetalLB** (Namespace: `metallb-system`): Load balancer para bare-metal
- **Calico CNI** (Namespaces: `calico-system`, `calico-apiserver`): Network plugin

### 💾 Storage
- **Longhorn** (Namespace: `longhorn-system`): Sistema de storage distribuído

### 🖥️ GPU & Hardware
- **Intel Device Plugins GPU** (Namespace: `intel-device-plugins-gpu`): Plugin para GPUs Intel
  - **intel-gpu-plugin**: DaemonSet em 3 nós com GPU
  - **inteldeviceplugins-controller-manager**: Gerenciador de dispositivos
- **Node Feature Discovery** (Namespace: `node-feature-discovery`): Detecção de features de hardware

### 📊 Monitoring & Observability (Namespace: `tools`)
Exporters Prometheus para monitoramento das aplicações
- **Prowlarr Exporter**: Métricas do Prowlarr
- **Radarr Exporter**: Métricas do Radarr principal
- **Radarr Anime Exporter**: Métricas do Radarr Animes
- **Sonarr Exporter**: Métricas do Sonarr principal
- **Sonarr Anime Exporter**: Métricas do Sonarr Animes
- **Uptime Kuma**: Monitoramento de uptime e alertas
- **QRCode**: Gerador de QR codes

### ⚙️ Core System (Namespace: `kube-system`)
Componentes essenciais do Kubernetes
- **CoreDNS**: DNS cluster com 3 réplicas
- **Metrics Server**: Métricas de recursos do cluster
- **Local Path Provisioner**: Provisionador de storage local
- **Kube-VIP**: Virtual IP para alta disponibilidade
- **Keel**: Automação de atualizações de containers

### 🔧 Operators
- **Tigera Operator** (Namespace: `tigera-operator`): Operador para Calico
- **Infisical Secrets Operator**: Operador de secrets com 3 réplicas

## 🏗️ Infraestrutura do Cluster

### Especificações
- **Distribuição**: K3s
- **Nós**: 4 nodes bare-metal
- **CNI**: Calico
- **Storage**: Longhorn (distribuído)
- **Load Balancer**: MetalLB
- **Ingress**: Nginx Ingress Controller
- **GPU**: Intel GPU device plugin (3 nós)

### High Availability
- **ArgoCD**: Controllers redundantes
- **Ingress**: 4 réplicas do nginx controller
- **CoreDNS**: 3 réplicas para DNS redundante
- **Calico**: HA com Typha e múltiplos controladores
- **Longhorn**: Storage replicado entre nós
- **Infisical Operator**: 3 réplicas

## 🔄 Workflow GitOps

1. **Desenvolvimento**: Modificar manifestos localmente
2. **Commit**: Fazer commit das alterações no Git
3. **Push**: Enviar para o repositório remoto
4. **Sync**: ArgoCD detecta mudanças e sincroniza automaticamente
5. **Deploy**: Aplicações são atualizadas no cluster K3s

## 🛠️ Pré-requisitos

- Cluster K3s configurado e operacional (4 nós)
- ArgoCD instalado no cluster
- kubectl configurado para acesso ao cluster
- Sealed Secrets Controller instalado
- Calico CNI configurado
- Longhorn storage instalado
- MetalLB configurado
- Intel GPU device plugin (para nós com GPU)

## 📝 Como Usar

### Adicionar Nova Aplicação

1. Criar manifests em `kustomize/<namespace>/<app-name>/`
   ```bash
   mkdir -p kustomize/<namespace>/<app-name>
   cd kustomize/<namespace>/<app-name>
   ```

2. Criar arquivos necessários:
   - `kustomization.yaml`
   - `deployment.yaml`
   - `service.yaml`
   - `configmap.yaml` (opcional)
   - `sealed-secret.yaml` (se necessário)

3. Criar Application do ArgoCD em `argocd-applications/`

4. Commit e push das alterações
   ```bash
   git add .
   git commit -m "Add: nova aplicação <app-name>"
   git push origin main
   ```

### Sincronizar Aplicações

```bash
# Sincronizar todas as aplicações
argocd app sync -l argocd.argoproj.io/instance=<app-name>

# Sincronizar aplicação específica
argocd app sync <app-name>

# Forçar sincronização (prune + replace)
argocd app sync <app-name> --prune --force
```

### Verificar Status

```bash
# Listar todas as aplicações
argocd app list

# Ver detalhes de uma aplicação
argocd app get <app-name>

# Ver diferenças (drift detection)
argocd app diff <app-name>

# Ver histórico de sincronizações
argocd app history <app-name>
```

### Gerenciar Namespaces

```bash
# Listar pods por namespace
kubectl get pods -n <namespace>

# Ver todos os recursos em um namespace
kubectl get all -n <namespace>

# Descrever um pod específico
kubectl describe pod <pod-name> -n <namespace>
```

## 🔐 Gestão de Secrets

Secrets sensíveis são criptografados usando **Sealed Secrets** antes de serem commitados no Git:

```bash
# Criar sealed secret
kubectl create secret generic <secret-name> \
  --from-literal=key=value \
  --namespace=<namespace> \
  --dry-run=client -o yaml | \
  kubeseal -o yaml > kustomize/<namespace>/<app>/sealed-secret.yaml
```

Para secrets mais complexos, considere usar o **Infisical Operator** ou **Vault**.

## 📊 Observabilidade

### Prometheus Exporters
Todos os exporters estão disponíveis no namespace `tools`:
- Prowlarr: Métricas de indexers
- Radarr/Radarr-Animes: Métricas de filmes
- Sonarr/Sonarr-Animes: Métricas de séries

### Uptime Monitoring
- **Uptime Kuma**: Dashboard de status e alertas

### Logs e Métricas
- Integração com stack de observabilidade (Prometheus, Grafana, Loki)
- Logs centralizados de todas as aplicações
- Métricas de recursos via Metrics Server

## 🎯 Funcionalidades Especiais

### Automação de Mídia
- **Configurações Sincronizadas**: Configarr-Sync mantém consistência entre instâncias
- **Legendas Multilíngues**: Lingarr traduz legendas automaticamente via LibreTranslate
- **Priorização PT-BR**: Custom formats para priorizar conteúdo em português brasileiro
- **Transcodificação GPU**: Unmanic utiliza GPUs Intel para conversão eficiente

### Separação de Conteúdo
- Instâncias dedicadas para animes (Sonarr, Radarr, Bazarr, Lingarr)
- Processamento de fotos separado por usuário
- Unmanic separado para filmes e séries

### Alta Disponibilidade
- Storage replicado via Longhorn
- Múltiplas réplicas de componentes críticos
- Load balancing via MetalLB
- Backup automatizado de volumes

## 🔧 Troubleshooting

### Verificar Health do Cluster
```bash
# Status dos nós
kubectl get nodes

# Status de todos os pods
kubectl get pods --all-namespaces

# Eventos recentes
kubectl get events --all-namespaces --sort-by='.lastTimestamp'
```

### Verificar ArgoCD
```bash
# Status das aplicações
argocd app list

# Ver logs de sincronização
argocd app logs <app-name>

# Forçar refresh
argocd app get <app-name> --refresh
```

### Verificar Storage Longhorn
```bash
# Status dos volumes
kubectl get pv
kubectl get pvc --all-namespaces

# Acessar UI do Longhorn
kubectl port-forward -n longhorn-system svc/longhorn-frontend 8080:80
```

## 📚 Referências

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Kustomize Documentation](https://kustomize.io/)
- [K3s Documentation](https://docs.k3s.io/)
- [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)
- [Longhorn Documentation](https://longhorn.io/docs/)
- [Calico Documentation](https://docs.tigera.io/calico/latest/about/)
- [MetalLB Documentation](https://metallb.universe.tf/)

## 🤝 Contribuindo

1. Fork o repositório
2. Crie uma branch para sua feature (`git checkout -b feature/nova-app`)
3. Commit suas alterações (`git commit -m 'Add: nova aplicação'`)
4. Push para a branch (`git push origin feature/nova-app`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.

## 🎖️ Badges

![K3s](https://img.shields.io/badge/K3s-FFC61C?style=flat-square&logo=k3s&logoColor=black)
![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?style=flat-square&logo=argo&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat-square&logo=kubernetes&logoColor=white)
![Longhorn](https://img.shields.io/badge/Longhorn-5E1F3F?style=flat-square)
![Calico](https://img.shields.io/badge/Calico-003366?style=flat-square)

---

**Nota**: Este é um repositório para uso pessoal em ambiente homelab. Adapte as configurações de acordo com suas necessidades.

**Cluster Status**: 🟢 Operacional | **Uptime**: 205+ dias | **Apps**: 100+ pods | **Nós**: 4