sudo echo "192.168.0.2 lab2" | sudo tee -a /etc/hosts

sudo echo "192.168.0.1 lab1" | sudo tee -a /etc/hosts

sudo echo "192.168.2.2 lab3" | sudo tee -a /etc/hosts

sudo apt -y install net-tools mlocate openvpn bridge-utils

sudo apt-get -y install traceroute

sudo apt upgrade -y

sudo apt update

# Step 1 — Installing OpenVPN and EasyRSA
wget -P /home/vagrant/ https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.8/EasyRSA-3.0.8.tgz

cd /home/vagrant/

tar xvf EasyRSA-3.0.8.tgz

cd /home/vagrant//EasyRSA-3.0.8/

cp vars.example vars

# sudo vim vars

cat << EOF >> vars
set_var EASYRSA_REQ_COUNTRY     "US"
set_var EASYRSA_REQ_PROVINCE    "California"
set_var EASYRSA_REQ_CITY        "San Francisco"
set_var EASYRSA_REQ_ORG "DigitalOcean"
set_var EASYRSA_REQ_EMAIL       "lab1@example.com"
set_var EASYRSA_REQ_OU          "Community"
EOF

# Within the EasyRSA directory is a script called easyrsa which is called to perform a variety of tasks involved with building and managing the CA. Run this script with the init-pki option to initiate the public key infrastructure on the CA server
sudo ./easyrsa init-pki

# Step 2 — Configuring the EasyRSA Variables and Building the CA
# no password
./easyrsa build-ca nopass

ca.crt and ca.key — which make up the public and private sides of an SSL certificate.
Your new CA certificate file for publishing is at: EasyRSA-3.0.8/pki/ca.crt

# Enter PEM pass phrase? because openssl doesn't want to output private key in clear text. The password is used to output encrypted private key (2021)

# Step 3 — Creating the Server Certificate, Key, and Encryption Files

# It’s necessary to run it here because your server and CA will have separate PKI directories
# ./easyrsa init-pki (I dont have to set it again)

# generate request for server
./easyrsa gen-req server nopass

# use it
sudo cp ~/EasyRSA-3.0.8/pki/private/server.key /etc/openvpn/

# scp ~/EasyRSA-3.0.8/pki/reqs/server.req sammy@your_CA_ip:/tmp (dont have to do it, same machine)

# import request as a ca
sudo ./easyrsa import-req /home/vagrant/EasyRSA-3.0.8/pki/reqs/server.req lab1
# Using the easyrsa script again, import the server.req file, following the file path with its common name lab1(lab1 will be the common name in CA and for server)

# ca sign the request from server
./easyrsa sign-req server lab1 # yes 2021
# Then sign the request by running the easyrsa script with the sign-req option, followed by the request type(server or client) and the common name.
# The Subject's Distinguished Name is as follows
# commonName            :ASN.1 12:'lab1'
# Certificate is to be certified until Jun 18 21:01:34 2025 GMT (825 days)
# Certificate created at: /home/vagrant/EasyRSA-3.0.8/pki/issued/lab1.crt

# scp pki/issued/server.crt sammy@your_server_ip:/tmp
# scp pki/ca.crt sammy@your_server_ip:/tmp

# In Server, copy the server.crt and ca.crt files into your /etc/openvpn/ directory
sudo cp ./pki/ca.crt  /etc/openvpn/
sudo cp ./pki/issued/lab1.crt  /etc/openvpn/

# create a strong Diffie-Hellman key to use during key exchange
sudo ./easyrsa gen-dh
sudo cp ~/EasyRSA-3.0.8/pki/dh.pem /etc/openvpn/

# generate an HMAC signature to strengthen the server’s TLS integrity verification capabilities
sudo openvpn --genkey secret ta.key
sudo cp ~/EasyRSA-3.0.8/ta.key /etc/openvpn/

# Step 4 — Generating a Client Certificate and Key Pair in server
mkdir -p ~/client-configs/keys
# store clients’ certificate/key pairs and configuration files in this directory, lock down its permissions now as a security measure
chmod -R 700 ~/client-configs

# in server
cd ~/EasyRSA-3.0.8/
sudo ./easyrsa gen-req lab3 nopass

sudo cp pki/private/lab3.key ~/client-configs/keys/

# # scp pki/reqs/lab3.req vagrant@ca:/tmp (same)

# in CA
cd ~/EasyRSA-3.0.8/
# lab3 known as client1 in CA
sudo ./easyrsa import-req pki/reqs/lab3.req client1
# CA sign on it
sudo ./easyrsa sign-req client client1

# in server 
# copy the client certificate to the /client-configs/keys/
sudo cp pki/issued/client1.crt ~/client-configs/keys/
# copy the ca.crt and ta.key files to the /client-configs/keys/
sudo cp ~/EasyRSA-3.0.8/ta.key ~/client-configs/keys/    
sudo cp /etc/openvpn/ca.crt ~/client-configs/keys/

# Step 5 — Configuring the OpenVPN Service
# configuring the OpenVPN service to use these credentials
# in server
sudo cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf /etc/openvpn/
sudo groupadd openvpn
sudo vim /etc/openvpn/server.conf
# Find the HMAC section by looking for the tls-auth directive.
# find the section on cryptographic ciphers by looking for the commented out cipher lines
#  add an auth directive to select the HMAC message digest algorithm
# add auth SHA256
# dh dh.pem
# It's a good idea to reduce the OpenVPN
# daemon's privileges after initialization.
# user nobody
# group opemvpn
# cert lab1.crt
# key server.key

# Step 6 — Adjusting the Server Networking Configuration
# sudo vim /etc/sysctl.conf

echo "net.ipv4.ip_forward=1" | tee -a /etc/sysctl.conf
sudo sysctl -p
sudo vim /etc/ufw/before.rules
# # START OPENVPN RULES
# # NAT table rules
# *nat
# :POSTROUTING ACCEPT [0:0]
# # Allow traffic from OpenVPN client to enp0s8 (change to the interface you discovered!)
# -A POSTROUTING -s 10.8.0.0/8 -o enp0s8 -j MASQUERADE
# COMMIT
# # END OPENVPN RULES

# MASQUERADE will automatically read the current ip address of enp0s8 and then do SNAT out, so that a good dynamic SNAT address translation is achieved

sudo vim /etc/default/ufw
# DEFAULT_FORWARD_POLICY="ACCEPT"

sudo ufw allow 1194/udp
sudo ufw allow OpenSSH
sudo ufw enable

# Step 7 — Starting and Enabling the OpenVPN Service
sudo systemctl start openvpn@server
sudo systemctl status openvpn@server

ip addr show tun0
sudo systemctl enable openvpn@server

# Step 8 — Creating the Client Configuration Infrastructures
mkdir -p ~/client-configs/files
cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf ~/client-configs/base.conf
sudo vim ~/client-configs/base.conf
# remote lab1 1194
# proto udp
# user nobody
# group nogroup
# # ca ca.crt (comment out)
# # cert client1.crt
# # key lab3.key
# # tls-auth ta.key 1
# cipher AES-256-CBC
# auth SHA256
# key-direction 1

# # These clients rely on the resolvconf utility to update DNS information for Linux clients
# ; script-security 2
# ; up /etc/openvpn/update-resolv-conf
# ; down /etc/openvpn/update-resolv-conf

# # set of lines for clients that use systemd-resolved for DNS resolution
# ; script-security 2
# ; up /etc/openvpn/update-systemd-resolved
# ; down /etc/openvpn/update-systemd-resolved
# ; down-pre
# ; dhcp-option DOMAIN-ROUTE .

# sudo vim ~/client-configs/make_config.sh
cat << EOF >>~/client-configs/make_config.sh
#!/bin/bash

# First argument: Client identifier and certificate name
# Second argumebt: key name

KEY_DIR=~/client-configs/keys
OUTPUT_DIR=~/client-configs/files
BASE_CONFIG=~/client-configs/base.conf

cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    ${KEY_DIR}/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    ${KEY_DIR}/${1}.crt \
    <(echo -e '</cert>\n<key>') \
    ${KEY_DIR}/${2}.key \
    <(echo -e '</key>\n<tls-auth>') \
    ${KEY_DIR}/ta.key \
    <(echo -e '</tls-auth>') \
    > ${OUTPUT_DIR}/${1}.ovpn
EOF

sudo chmod 700 ~/client-configs/make_config.sh

# Step 9 — Generating Client Configurations

cd ~/client-configs
sudo ./make_config.sh client1 lab3
ls ~/client-configs/files



# Step 10 — Installing the Client Configuration



### 6.1
sudo systemctl stop openvpn@server
sudo cp /vagrant/server_bridge.conf  /etc/openvpn/server.conf

sudo cp /usr/share/doc/openvpn/examples/sample-scripts/bridge-start /etc/openvpn/
    # #!/bin/bash

    # #################################
    # # Set up Ethernet bridge on Linux
    # # Requires: bridge-utils
    # #################################

    # # Define Bridge Interface
    # br="br0"

    # # Define list of TAP interfaces to be bridged,
    # # for example tap="tap0 tap1 tap2".
    # tap="tap0"

    # # Define physical ethernet interface to be bridged
    # # with TAP interface(s) above.
    # eth="enp0s8"
    # eth_ip="192.168.0.1"
    # eth_netmask="255.255.255.0"
    # eth_broadcast="192.168.0.255"

    # for t in $tap; do
    #     openvpn --mktun --dev $t
    # done

    # brctl addbr $br
    # brctl addif $br $eth

    # for t in $tap; do
    #     brctl addif $br $t
    # done

    # for t in $tap; do
    #     ifconfig $t 0.0.0.0 promisc up
    # done

    # ifconfig $eth 0.0.0.0 promisc up

    # ifconfig $br $eth_ip netmask $eth_netmask broadcast $eth_broadcast
sudo cp /usr/share/doc/openvpn/examples/sample-scripts/bridge-stop /etc/openvpn/

sudo iptables -A INPUT -i tap0 -j ACCEPT
sudo iptables -A INPUT -i br0 -j ACCEPT
sudo iptables -A FORWARD -i br0 -j ACCEPT

sudo vim /etc/ufw/before.rules
# # START OPENVPN RULES
# # NAT table rules
# *nat
# :POSTROUTING ACCEPT [0:0]
# # Allow traffic from OpenVPN client to enp0s3 (change to the interface you discovered!)
# -A POSTROUTING -o enp0s8 -j MASQUERADE
# COMMIT
# # END OPENVPN RULES


# allow promiscuous mode
sudo /etc/openvpn/bridge-start
sudo service openvpn start

sudo service openvpn stop
sudo /etc/openvpn/bridge-stop
