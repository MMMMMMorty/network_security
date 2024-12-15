sudo echo "192.168.0.2 lab2" | sudo tee -a /etc/hosts

sudo echo "192.168.0.1 lab1" | sudo tee -a /etc/hosts

sudo echo "192.168.2.2 lab3" | sudo tee -a /etc/hosts

sudo apt -y install net-tools mlocate nmap lynx

sudo apt-get -y install traceroute

sudo apt upgrade -y

sudo apt update

# # 2.1
sudo ip route add 192.168.2.0/24 via 192.168.0.1 dev enp0s8 

traceroute lab3

# 3
nmap lab3

# test web
sudo apt install -y lynx

lynx lab3:80


# ftp
ftp lab3
# vagrant
# vagrant

# 4

curl -I lab3

# #test proxy

# curl -x http://lab1:3128  -L http://google.com



# 5


sudo apt install -y apache2
