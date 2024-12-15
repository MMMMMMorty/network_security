sudo echo "192.168.0.2 lab2" | sudo tee -a /etc/hosts

sudo echo "192.168.2.1 lab1" | sudo tee -a /etc/hosts

sudo echo "192.168.2.2 lab3" | sudo tee -a /etc/hosts

sudo apt -y install net-tools mlocate nmap

sudo apt-get -y install traceroute

sudo apt upgrade -y

sudo apt update

# 2.1
sudo ip route add 192.168.0.0/24 via 192.168.2.1 dev enp0s8 

# # 3
# nmap lab2


# install web server
sudo apt install -y apache2
# sudo ufw enable
# sudo ufw allow 'Apache'

# install ftp server
sudo apt install proftpd -y
sudo systemctl start proftpd
sudo systemctl enable proftpd
sudo systemctl status proftpd

sudo vim /etc/proftpd/proftpd.conf
# ServerName "lab3 FTPD server"
# PassivePorts 49152 65534
# User                            vagrant
# Group                           nogroup
sudo apt-get install openssl -y
sudo openssl req -x509 -newkey rsa:1024 -keyout /etc/ssl/private/proftpd.key -out /etc/ssl/certs/proftpd.crt -nodes -days 365
sudo chmod 600 /etc/ssl/private/proftpd.key
sudo chmod 600 /etc/ssl/certs/proftpd.crt


sudo echo "Include /etc/proftpd/tls.conf" | sudo tee -a /etc/proftpd/proftpd.conf
sudo vim /etc/proftpd/tls.conf
# <IfModule mod_tls.c>
# TLSEngine on
# TLSLog /var/log/proftpd/tls.log
# TLSProtocol SSLv23
# TLSRSACertificateFile /etc/ssl/certs/proftpd.crt
# TLSRSACertificateKeyFile /etc/ssl/private/proftpd.key
# TLSOptions AllowClientRenegotiations
# TLSRequired off
sudo systemctl restart proftpd
 