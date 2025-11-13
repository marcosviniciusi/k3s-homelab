curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.34.1+k3s1 sh -s - server \
  --node-ip=192.168.253.5 \
  --flannel-backend=none \
  --disable-network-policy \
  --cluster-cidr=10.52.0.0/16 \
  --tls-san 192.168.253.254 \
  --disable servicelb \
  --disable traefik