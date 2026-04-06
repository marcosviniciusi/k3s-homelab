# Implementar MTU 9000 (Jumbo Frames) no K3s Homelab

**Data:** 2026-03-29
**Cluster:** K3s v1.35.0+k3s1 com Cilium 1.18.4

## Estado atual

| Item | Valor |
|------|-------|
| Interface dos nodes | `enp3s0` — MTU **1500** |
| Cilium | v1.18.4, modo **VXLAN tunnel** |
| MTU Cilium | Auto-detectado: **1500** |
| Nodes ativos | tess (.6), yuna (.7), cole (.8) |
| Nodes offline | aloy (.2), ellie (.3), joel (.4), nardine (.5) |
| Pod CIDR | 10.52.0.0/16 |
| BGP | ASN 64513 → OPNsense .1 (ASN 64512) |

## Objetivo

Subir MTU para 9000 em toda a cadeia (switch → host → Cilium → pods).

Com VXLAN, o overhead é de 50 bytes, então o MTU efetivo dos pods será **8950**.

---

## Passo 1: Pré-requisitos de infraestrutura (manual)

Antes de qualquer mudança no cluster, garantir que TODA a cadeia suporta jumbo frames:

1. **Switch(es)** — habilitar jumbo frames (MTU 9000+) nas portas da VLAN 192.168.253.0/24
2. **OPNsense** — subir MTU para 9000 na interface que conecta ao cluster (tráfego BGP e gateway)
3. **Proxmox** — se os nodes são VMs, o bridge do Proxmox E a interface física precisam de MTU 9000

> **Se qualquer elo da cadeia não suportar jumbo frames, a conectividade será perdida.**

---

## Passo 2: MTU 9000 nas interfaces dos nodes

Em **cada node Debian 12** (tess, yuna, cole — e os workers quando voltarem):

### Aplicar imediatamente (temporário)

```bash
sudo ip link set enp3s0 mtu 9000
```

### Persistir (sobrevive reboot)

Editar `/etc/network/interfaces`:

```
auto enp3s0
iface enp3s0 inet static
    address 192.168.253.X/24
    gateway 192.168.253.1
    mtu 9000
```

### Verificar

```bash
ip link show enp3s0 | grep mtu
# Deve mostrar: mtu 9000

ping -M do -s 8972 192.168.253.1
# 8972 + 28 bytes header = 9000 — testa jumbo frame até o gateway
```

> **Fazer em todos os nodes ao mesmo tempo** para evitar fragmentação entre nodes com MTU diferente.

---

## Passo 3: Configurar MTU no Cilium

Editar `kustomize/network-stack/cillium/values.yaml`, adicionar:

```yaml
MTU: 9000
```

O arquivo final fica:

```yaml
bgpControlPlane:
  enabled: true
hubble:
  enabled: true
  metrics:
    enabled:
    - dns
    - drop
    - tcp
    - flow
    - icmp
    - http
  relay:
    enabled: true
k8sClientRateLimit:
  burst: 400
  qps: 200
k8sServiceHost: 192.168.253.254
k8sServicePort: 6443
kubeProxyReplacement: true
MTU: 9000
operator:
  prometheus:
    enabled: true
    port: 9963
  replicas: 1
prometheus:
  enabled: true
  port: 9962
```

---

## Passo 4: Aplicar no cluster

### Opção A — GitOps (recomendado)

```bash
git add kustomize/network-stack/cillium/values.yaml
git commit -m "feat(network): set Cilium MTU to 9000 for jumbo frame support"
git push
# ArgoCD faz o sync automaticamente
```

### Opção B — Helm direto

```bash
helm upgrade cilium cilium/cilium \
  --namespace kube-system \
  --reuse-values \
  --set MTU=9000
```

---

## Passo 5: Restart dos componentes

```bash
# Restart do Cilium
kubectl -n kube-system rollout restart daemonset/cilium
kubectl -n kube-system rollout status daemonset/cilium

# Restart dos workloads (pods precisam recriar veth para pegar novo MTU)
# Por namespace, ex:
kubectl -n arr-stack rollout restart deployment --all
kubectl -n jelly-stack rollout restart deployment --all
# ... ou todos de uma vez:
kubectl get deployments -A -o jsonpath='{range .items[*]}{.metadata.namespace}{" "}{.metadata.name}{"\n"}{end}' | \
  while read ns name; do kubectl -n "$ns" rollout restart deployment/"$name"; done
```

---

## Passo 6: Validação

```bash
# 1. MTU no host
ip link show enp3s0 | grep mtu
# Esperado: mtu 9000

# 2. MTU no Cilium
kubectl -n kube-system exec ds/cilium -- cilium-dbg status --verbose | grep -i mtu
# Esperado: MTU updated (8950)

# 3. Jumbo frame entre nodes
ping -M do -s 8972 192.168.253.7
# Esperado: sucesso (sem fragmentação)

# 4. Jumbo frame entre pods
kubectl exec -it <pod-a> -- ping -M do -s 8922 <pod-b-ip>
# 8922 + 28 = 8950 (MTU efetivo com VXLAN)
# Esperado: sucesso
```

---

## Riscos e rollback

| Risco | Impacto | Rollback |
|-------|---------|----------|
| Switch sem jumbo frames | Perda total de conectividade entre nodes | `sudo ip link set enp3s0 mtu 1500` em cada node |
| Apenas Cilium alterado (host ainda 1500) | Cilium ignora e mantém 1500 (safe) | Remover `MTU: 9000` do values.yaml |
| Pods antigos com MTU 1500 | Pacotes grandes fragmentados ou dropados | Restart dos pods |
| OPNsense sem jumbo frames | BGP funciona (pacotes pequenos) mas tráfego pesado fragmenta | Subir MTU na interface do OPNsense |

---

## Notas sobre VLANs

Se há outras VLANs com MTU 1500, não há problema. O MTU da interface pai (`enp3s0`) define o máximo — sub-interfaces VLAN podem ter MTU igual ou menor. Subir a interface base para 9000 **não quebra** VLANs que continuam com 1500.
