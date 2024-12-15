sudo echo "192.168.0.2 lab2" | sudo tee -a /etc/hosts

sudo echo "192.168.2.1 lab1" | sudo tee -a /etc/hosts

sudo echo "192.168.2.2 lab3" | sudo tee -a /etc/hosts

sudo apt -y install net-tools mlocate openvpn 

sudo apt-get -y install traceroute

sudo apt upgrade -y

sudo apt update

# echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIvtuEiEqN5RT8jNk58Nww9zz2SP+lFl/gw6YwHi0nsY vagrant@lab1" | tee -a ~/.ssh/authorized_keys

# Step 9 — Generating Client Configurations

 # in client(lab3) config the ssh properly
sftp vagrant@lab1:client-configs/files/client1.ovpn ~/


# Step 10 — Installing the Client Configuration
# It provides scripts that will force systemd-resolved to use the VPN server for DNS resolution
sudo apt install openvpn-systemd-resolved

sudo vim client1.ovpn
sudo openvpn --config client1.ovpn

sudo cp /vagrant/client1.ovpn /etc/openvpn/client1.ovpn

#  connect to the VPN by just pointing the openvpn command to the client configuration file
sudo tee /etc/systemd/system/client.service <<EOL
[Unit]
Description=Client service
[Service]
ExecStart=/bin/bash -c "openvpn /etc/openvpn/client1.ovpn"
[Install]
WantedBy=multi-user.target
EOL
sudo ip route add 192.168.2.0/24 via 192.168.2.2 dev enp0s8
sudo systemctl enable client --now

# script-security 2
# up /etc/openvpn/update-systemd-resolved
# down /etc/openvpn/update-systemd-resolved
# down-pre
# dhcp-option DOMAIN-ROUTE .