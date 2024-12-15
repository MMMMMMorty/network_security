sudo echo "192.168.0.2 lab2" | sudo tee -a /etc/hosts

sudo echo "192.168.0.1 lab1" | sudo tee -a /etc/hosts

sudo echo "192.168.2.2 lab3" | sudo tee -a /etc/hosts

sudo apt -y install net-tools mlocate openvpn bridge-utils

sudo apt-get -y install traceroute

sudo apt upgrade -y

sudo apt update

# # Step 1 — Installing OpenVPN and EasyRSA
# wget -P ~/ https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.8/EasyRSA-3.0.8.tgz

# cd ~

# tar xvf EasyRSA-3.0.8.tgz

# cd ~/EasyRSA-3.0.8/

# cp vars.example vars

# # sudo vim vars

# cat << EOF >> vars
# set_var EASYRSA_REQ_COUNTRY     "US"
# set_var EASYRSA_REQ_PROVINCE    "California"
# set_var EASYRSA_REQ_CITY        "San Francisco"
# set_var EASYRSA_REQ_ORG "DigitalOcean"
# set_var EASYRSA_REQ_EMAIL       "lab1@example.com"
# set_var EASYRSA_REQ_OU          "Community"
# EOF

# # Within the EasyRSA directory is a script called easyrsa which is called to perform a variety of tasks involved with building and managing the CA. Run this script with the init-pki option to initiate the public key infrastructure on the CA server
# ./easyrsa init-pki

# # Step 2 — Configuring the EasyRSA Variables and Building the CA
# # no password
# ./easyrsa build-ca nopass

# # ca.crt and ca.key — which make up the public and private sides of an SSL certificate.
# # Your new CA certificate file for publishing is at: EasyRSA-3.0.8/pki/ca.crt

# ./easyrsa build-ca nopass
# # Enter PEM pass phrase? because openssl doesn't want to output private key in clear text. The password is used to output encrypted private key
# # Common name: lab1

# # Step 3 — Creating the Server Certificate, Key, and Encryption Files

# # It’s necessary to run it here because your server and CA will have separate PKI directories
# # ./easyrsa init-pki (I dont have to set it again)

# ./easyrsa gen-req server nopass
# # Common name: lab1

# sudo cp ~/EasyRSA-3.0.8/pki/private/server.key /etc/openvpn/

# # scp ~/EasyRSA-3.0.8/pki/reqs/server.req sammy@your_CA_ip:/tmp (dont have to do it, same machine)

# ./easyrsa import-req /home/vagrant/EasyRSA-3.0.8/pki/reqs/server.req lab1
# # Using the easyrsa script again, import the server.req file, following the file path with its common name lab1(lab1 will be the common name in CA)

# ./easyrsa sign-req server lab1 # yes 2021
# # Then sign the request by running the easyrsa script with the sign-req option, followed by the request type(server or client) and the common name.
# # The Subject's Distinguished Name is as follows
# # commonName            :ASN.1 12:'lab1'
# # Certificate is to be certified until Jun 18 21:01:34 2025 GMT (825 days)
# # Certificate created at: /home/vagrant/EasyRSA-3.0.8/pki/issued/lab1.crt

# # scp pki/issued/server.crt sammy@your_server_ip:/tmp
# # scp pki/ca.crt sammy@your_server_ip:/tmp

# # copy the server.crt and ca.crt files into your /etc/openvpn/ directory
# sudo cp ./pki/ca.crt  /etc/openvpn/
# sudo cp ./pki/issued/lab1.crt  /etc/openvpn/

# # create a strong Diffie-Hellman key to use during key exchange
# ./easyrsa gen-dh
# sudo cp ~/EasyRSA-3.0.8/pki/dh.pem /etc/openvpn/

# # generate an HMAC signature to strengthen the server’s TLS integrity verification capabilities
# openvpn --genkey secret ta.key
# sudo cp ~/EasyRSA-3.0.8/ta.key /etc/openvpn/

# # Step 4 — Generating a Client Certificate and Key Pair in server
# mkdir -p ~/client-configs/keys
# # store clients’ certificate/key pairs and configuration files in this directory, lock down its permissions now as a security measure
# chmod -R 700 ~/client-configs

# cd ~/EasyRSA-3.0.8/
# ./easyrsa gen-req lab3 nopass

# cp pki/private/lab3.key ~/client-configs/keys/

# # scp pki/reqs/lab3.req vagrant@lab1:/tmp (same)

# # ssh-keygen -t ed25519

# ./easyrsa sign-req client lab3
