sudo echo "192.168.0.2 lab2" | sudo tee -a /etc/hosts

sudo echo "192.168.0.1 lab1" | sudo tee -a /etc/hosts

sudo echo "192.168.2.2 lab3" | sudo tee -a /etc/hosts

sudo apt -y install net-tools mlocate

sudo apt-get -y install traceroute

sudo apt upgrade -y

sudo apt update
