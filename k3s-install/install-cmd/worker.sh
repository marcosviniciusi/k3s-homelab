systemctl stop k3s-agent; \
curl -sfL https://get.k3s.io | \
  INSTALL_K3S_VERSION=v1.34.1+k3s1 \
  K3S_URL=https://192.168.253.254:6443 \
  K3S_TOKEN='' \
  sh -