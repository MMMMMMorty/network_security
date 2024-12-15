sudo apt -y install net-tools

sudo apt-get -y install traceroute

sudo apt upgrade -y

sudo apt update

sudo sysctl -w net.ipv6.conf.enp0s3.accept_ra=0

sudo sysctl -w net.ipv6.conf.default.forwarding=1
sudo sysctl -w net.ipv6.conf.all.forwarding=1
sudo sysctl -w net.ipv4.ip_forward=1
