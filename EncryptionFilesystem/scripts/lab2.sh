sudo echo "192.168.1.1 lab1" | sudo tee -a /etc/hosts
sudo echo "192.168.1.2 lab2" | sudo tee -a /etc/hosts
sudo apt -y install net-tools
sudo apt-get -y install traceroute nmap mlocate cryptsetup gnupg haveged gocryptfs
sudo apt upgrade -y
sudo apt update

modprobe dm_crypt 
modprobe aes 
#  cat /proc/crypto | grep aes
# lsmod | grep cryptoloop 
# -> nothing

### 2.2
gpg --full-generate-key
# gpg --list-keys

cd /vagrant/
gpg --output lab2PublicKey.gpg --export lab2-key
mv lab1PublicKey.gpg ~/

cd ~
gpg --import lab1PublicKey.gpg

cd /vargrant/
# decrypt
gpg --decrypt --output result test.gpg
cat result

#sign in ASCII
gpg --encrypt --sign --armor --recipient lab1@example.com test.txt

