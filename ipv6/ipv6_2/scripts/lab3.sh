sudo apt -y install net-tools

sudo apt-get -y install traceroute

sudo apt upgrade -y

sudo apt update

sudo sysctl -w net.ipv6.conf.enp0s3.accept_ra=0

sudo sysctl -w net.ipv6.conf.default.forwarding=1
sudo sysctl -w net.ipv6.conf.all.forwarding=1
sudo sysctl -w net.ipv4.ip_forward=1

sudo ip6tables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

sudo ip -6 route del default via fe80::1 dev enp0s8
sudo ip -6 route add default via 2001:708:30:1190::e dev enp0s8

