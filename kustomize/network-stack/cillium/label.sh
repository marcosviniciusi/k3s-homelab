for node in $(kubectl get nodes -o name); do
  kubectl patch $node --type merge --patch-file patch-nodes-bgp.yaml
done


helm upgrade cilium cilium/cilium \
  --version 1.18.4 \
  --namespace kube-system \
  --set bgpControlPlane.enabled=true \
  --set k8sClientRateLimit.qps=200 \
  --set k8sClientRateLimit.burst=400 \
  --set kubeProxyReplacement=true \
  --set k8sServiceHost=192.168.253.254 \
  --set k8sServicePort=6443 \
  --set operator.replicas=1 \
  --set prometheus.enabled=true \
  --set prometheus.port=9962 \
  --set operator.prometheus.enabled=true \
  --set operator.prometheus.port=9963 \
  --set hubble.enabled=true \
  --set hubble.metrics.enabled="{dns,drop,tcp,flow,icmp,http}" \
  --set hubble.relay.enabled=true

helm upgrade cilium cilium/cilium \
  --version 1.18.4 \
  --namespace kube-system \
  --set bgpControlPlane.enabled=true \
  --set k8sClientRateLimit.qps=200 \
  --set k8sClientRateLimit.burst=400 \
  --set kubeProxyReplacement=true \
  --set k8sServiceHost=192.168.253.254 \
  --set k8sServicePort=6443 \
  --set operator.replicas=1 \
  --set prometheus.enabled=true \
  --set prometheus.port=9962 \
  --set operator.prometheus.enabled=true \
  --set operator.prometheus.port=9963 \
  --set hubble.enabled=true \
  --set hubble.metrics.enabled="{dns,drop,tcp,flow,icmp,http}" \
  --set hubble.relay.enabled=true


helm upgrade cilium cilium/cilium \
  --version 1.18.4 \
  --namespace kube-system \
  --set bgpControlPlane.enabled=true \
  --set k8sClientRateLimit.qps=200 \
  --set k8sClientRateLimit.burst=400 \
  --set kubeProxyReplacement=true \
  --set k8sServiceHost=192.168.253.254 \
  --set k8sServicePort=6443 \
  --set operator.replicas=1 \
  --set prometheus.enabled=true \
  --set prometheus.port=9962 \
  --set operator.prometheus.enabled=true \
  --set operator.prometheus.port=9963 \
  --set hubble.enabled=true \
  --set hubble.metrics.enabled="{dns,drop,tcp,flow,icmp,http}" \
  --set hubble.relay.enabled=true \
  --set hubble.export.dynamic.enabled=true \
  --set hubble.export.dynamic.config.configMapName=hubble-export-config \
  --set hubble.export.dynamic.config.createConfigMap=false