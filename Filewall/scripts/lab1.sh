sudo echo "192.168.0.2 lab2" | sudo tee -a /etc/hosts

sudo echo "192.168.0.1 lab1" | sudo tee -a /etc/hosts

sudo echo "192.168.2.2 lab3" | sudo tee -a /etc/hosts

sudo apt -y install net-tools mlocate nmap

sudo apt-get -y install traceroute

sudo apt upgrade -y

sudo apt update

# 2.1

## 如果突然不通，可能是因为这个！！，每次开机必备
sudo sysctl -w net.ipv4.ip_forward=1

sudo sysctl -w net.ipv4.conf.enp0s8.forwarding=1 
sudo sysctl -w net.ipv4.conf.enp0s9.forwarding=1
sudo sysctl -w net.ipv4.conf.enp0s8.proxy_arp=1
sudo sysctl -w net.ipv4.conf.enp0s9.proxy_arp=1

# sudo iptables -L

# Set up an nftables(8) FORWARD policy to disallow traffic through the router by default
sudo vim /etc/nftables.conf
#    chain forward {
#                 type filter hook forward priority 0;
#                 policy drop;
#         }
sudo nft -f /etc/nftables.conf
sudo nft list ruleset

# Add rules to allow ping(8) from lab2 on the enp0s8 interface and replies to lab2.
# define NET=enp0s8

#  chain forward {
#                 type filter hook forward priority filter; policy drop;
#                 iifname $NET ip protocol icmp icmp type echo-request accept
#                 oifname $NET ip protocol icmp icmp type echo-reply accept
#                 tcp dport 22 accept
#                 tcp sport 22 accept
#                 iifname $NET tcp dport 49152-65534 accept
#                 oifname $NET tcp sport 49152-65534 accept
#                 iifname $NET tcp dport { 20, 21 } accept
#                 oifname $NET tcp sport { 20, 21 } accept
#                 iifname $NET tcp dport { 80, 443 } accept
#                 oifname $NET tcp sport { 80, 443 } accept
#         }

# You will probably need the "ip_conntrack_ftp" kernel module for FTP filtering. Load it with modprobe(8)?
#  tell iptables that he has to first track the FTP command channel 
iptables -A INPUT  -p tcp -m tcp --sport 21 -m conntrack --ctstate ESTABLISHED -j ACCEPT 
iptables -A OUTPUT -p tcp -m tcp --dport 21 -m conntrack --ctstate ESTABLISHED,NEW -j ACCEPT
#  allow passive outbound connections 
iptables -A INPUT  -p tcp -m tcp --sport 1024: --dport 1024: -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 
iptables -A OUTPUT -p tcp -m tcp --sport 1024: --dport 1024: -m conntrack --ctstate ESTABLISHED -j ACCEPT

## 4
sudo apt -y install squid
sudo systemctl start squid
sudo systemctl enable squid
sudo systemctl status squid

# sudo sed -i 's/acl lan src lab2/acl lan src 192.168.0.0/24/g'   /etc/squid/squid.conf
# sudo sed -i '/http_access deny all/'   /etc/squid/squid.conf

sudo echo "http_port 8000 transparent" | sudo tee -a /etc/squid/squid.conf
sudo echo "acl lan src lab2" | sudo tee -a /etc/squid/squid.conf
sudo echo "http_access allow localhost" | sudo tee -a /etc/squid/squid.conf
sudo echo "http_access allow lan" | sudo tee -a /etc/squid/squid.conf
# sudo echo "acl destination dst 192.168.2.0/24" | sudo tee -a /etc/squid/squid.conf
# sudo echo "http_access deny destination" | sudo tee -a /etc/squid/squid.conf
# sudo echo "http_access deny all" | sudo tee -a /etc/squid/squid.conf
sudo echo "http_reply_access allow all" | sudo tee -a /etc/squid/squid.conf
sudo echo "acl lab3 dstdomain lab3" | sudo tee -a /etc/squid/squid.conf
sudo echo "never_direct allow lab3" | sudo tee -a /etc/squid/squid.conf


sudo sed -i 's/http_access deny all/http_access allow all/g' /etc/squid/squid.conf

sudo sed -i 's/http_port 8080 transparent/http_port 8000 transparent/g' /etc/squid/squid.conf
# sudo sed -i 's/http_port 8080 intercept/http_port 8080 transparent/g' /etc/squid/squid.conf
# sudo sed -i 's/# acl destination dst 192.168.2.0/24/ acl destination dst 192.168.2.0/24/g' /etc/squid/squid.conf
# sudo sed -i 's/http_access allow destination/# http_access allow destination/g' /etc/squid/squid.conf
# sudo sed -i 's/http_access allow all/http_access deny all/g' /etc/squid/squid.conf
# http_access allow all

# # check the file
sudo grep -v "^#" /etc/squid/squid.conf | sed -e '/^$/d'    

sudo systemctl restart squid
# sudo nft add table ip filter
# sudo nft add chain ip filter prerouting { type nat hook prerouting priority 0 \; policy accept\;}
# sudo nft add rule ip filter prerouting iifname enp0s8 ip saddr 192.168.0.2 tcp dport 80 redirect to :8000
sudo vim /etc/nftables.conf
# table ip filter{
#         chain prerouting{
#                 type nat hook prerouting priority 0;
#                 policy accept;
#                 iifname $NET ip saddr 192.168.0.2 tcp dport 80 redirect to :8000
#         }
# }
sudo nft -f /etc/nftables.conf
sudo nft list ruleset


# delete 
sudo nft -a list table ip filter
# sudo nft delete rule ip filter prerouting handle 4

## 5
sudo vim /etc/nftables.conf
#   Add a rule to the prerouting chain that redirects incoming packets on port 8080 to the port 80 on lab2. It means the traffic coming from eth0 will be redirected to eth1. 
#  chain prerouting {
#                 type nat hook prerouting priority filter; policy accept;
#                 iifname "enp0s8" ip saddr 192.168.0.2 tcp dport 80 redirect to :8000
#                 iifname "enp0s3" tcp dport 8080 dnat to 192.168.0.2:80
#         }

# or
# sudo nft add rule ip filter prerouting iifname enp0s3 tcp dport 8080 dnat 192.168.0.2:80

# Add a rule to the postrouting chain to masquerade outgoing traffic.
#   chain postrouting {
#     type nat hook postrouting priority srcnat; policy accept;

#     # SNAT for IPv4 traffic to Internet
#     oifname $INT_DEV masquerade
#   }



# 4. The traffic coming from eth2 to eth 1 would be passed without any problem.
# 5. eth1 just allows to pass traffic in response to requests that have been made to lab2 in DMZ.
# chain forward {
#                 type filter hook forward priority 0;
#                 policy drop;
#                 # question 3 needs it
#                 # iifname $NET ip protocol icmp icmp type echo-request accept
#                 # oifname $NET ip protocol icmp icmp type echo-reply accept
#                 tcp dport 22 accept
#                 tcp sport 22 accept
#                 iifname $NET tcp dport 49152-65534 accept
#                 oifname $NET tcp sport 49152-65534 accept
#                 iifname $NET tcp dport { 20, 21 } accept
#                 oifname $NET tcp sport { 20, 21 } accept
#                 iifname $NET tcp dport { 80, 443 } accept
#                 oifname $NET tcp sport { 80, 443 } accept
#                 iifname $LAN_DEV oifname $NET accept
#                 iifname $NET oifname $LAN_DEV ct state established accept
# }
# new added
# iifname $LAN_DEV oifname $NET accept
# iifname $NET oifname $LAN_DEV ct state established accept

nc -l 8080

# Windows
tnc 127.0.0.1 -p 8080
# ComputerName     : 127.0.0.1
# RemoteAddress    : 127.0.0.1
# RemotePort       : 8080
# InterfaceAlias   : Loopback Pseudo-Interface 1
# SourceAddress    : 127.0.0.1
# TcpTestSucceeded : True