sudo echo "192.168.1.2 ns2" | sudo tee -a /etc/hosts

sudo echo "192.168.1.1 ns1" | sudo tee -a /etc/hosts

sudo echo "192.168.1.3 ns3" | sudo tee -a /etc/hosts

sudo echo "192.168.1.4 client" | sudo tee -a /etc/hosts

sudo apt -y install net-tools

sudo apt-get -y install traceroute

sudo apt upgrade -y

sudo apt update

#2.1

# sudo ./data/resolv >  /etc/resolv.conf

sudo apt install resolvconf

sudo service resolvconf restart

dig linuxfoundation.org

nslookup linuxfoundation.org