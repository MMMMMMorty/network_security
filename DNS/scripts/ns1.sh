sudo echo "192.168.1.2 ns2" | sudo tee -a /etc/hosts

sudo echo "192.168.1.1 ns1" | sudo tee -a /etc/hosts

sudo echo "192.168.1.3 ns3" | sudo tee -a /etc/hosts

sudo echo "192.168.1.4 client" | sudo tee -a /etc/hosts

sudo apt -y install net-tools

sudo apt-get -y install traceroute

sudo apt upgrade -y

sudo apt update

sudo apt install bind9 bind9-utils bind9-dnsutils -y

sudo ufw enable

sudo ufw allow Bind9

# 2.1

# sudo ./data/options >  /etc/bind/named.conf.options

sudo named-checkconf

sudo service bind9 restart

sudo ufw enable

sudo ufw allow from 192.168.1.0/24 to 192.168.1.2 port 53 proto udp

# 3.1

sudo mkdir -p /etc/bind/zones/


