curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.34.2+k3s1 sh -s - server --cluster-init \
  --node-ip=192.168.253.6 \
  --flannel-backend=none \
  --disable-network-policy \
  --cluster-cidr=10.52.0.0/16 \
  --tls-san 192.168.253.254 \
  --disable servicelb \
  --disable traefik


curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.35.0+k3s1 sh -s - server \
  --server https://192.168.253.254:6443 \
  --token  \
  --node-ip=192.168.253.6 \
  --flannel-backend=none \
  --disable-network-policy \
  --cluster-cidr=10.52.0.0/16 \
  --tls-san 192.168.253.254 \
  --disable servicelb \
  --disable traefik

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.35.0+k3s1 sh -s - server \
  --server https://192.168.253.254:6443 \
  --token  \
  --node-ip=192.168.253.7 \
  --flannel-backend=none \
  --disable-network-policy \
  --cluster-cidr=10.52.0.0/16 \
  --tls-san 192.168.253.254 \
  --disable servicelb \
  --disable traefik

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.35.0+k3s1 sh -s - server \
  --server https://192.168.253.254:6443 \
  --token  \
  --node-ip=192.168.253.8 \
  --flannel-backend=none \
  --disable-network-policy \
  --cluster-cidr=10.52.0.0/16 \
  --tls-san 192.168.253.254 \
  --disable servicelb \
  --disable traefik


curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.34.2+k3s1 sh -s - server \
  --server https://192.168.253.5:6443 \
  --token  \
  --node-ip=192.168.253.8 \
  --flannel-backend=none \
  --disable-network-policy \
  --cluster-cidr=10.52.0.0/16 \
  --tls-san 192.168.253.254 \
  --disable servicelb \
  --disable traefik

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.34.2+k3s1 sh -s - server \
  --server https://192.168.253.254:6443 \
  --token  \
  --node-ip=192.168.253.7 \
  --flannel-backend=none \
  --disable-network-policy \
  --cluster-cidr=10.52.0.0/16 \
  --tls-san 192.168.253.254 \
  --disable servicelb \
  --disable traefik