sudo echo "192.168.1.1 lab1" | sudo tee -a /etc/hosts
sudo echo "192.168.1.2 lab2" | sudo tee -a /etc/hosts
sudo apt -y install net-tools
sudo apt-get -y install traceroute nmap mlocate
sudo apt upgrade -y
sudo apt update

#sudo passwd testuser1 passwd 123456
sudo useradd  testuser1
sudo useradd testuser2

### 2.1
sudo apt install nfs-common -y
sudo mkdir testuser1
sudo mount lab1:/home /mnt #sudo -u testuser1 ls /mnt/testuser1
# sudo -u testuser1 tee /home/testuser1/test.txt <<< "Hello world"
# df -h
# du -sh /mnt

# # Port mapping

### 3.1

sudo umount -dflnrv /mnt
sudo apt install -y cifs-utils
sudo mount -t cifs -o user=testuser1 //192.168.1.1/Testuser1 /mnt #2021

### 4.1
sudo umount -dflnrv //192.168.1.1/Testuser1
sudo apt install sshfs
sudo mkdir -p /home/testuser1/mnt
sudo chmod 777 /home/testuser1/mnt
sudo ufw allow ssh && ufw allow 22
echo '123456' | sshfs testuser1@lab1:/home/testuser1 /home/testuser1/mnt -o password_stdin

### 5.1
sudo umount  /home/testuser1/mnt
sudo apt install cadaver
touch test3.txt
vim test3.txt

cadaver http://lab1/webdav
# Username: sammy
# Password:123456
dav:/webdav/> put /home/vagrant/test3.txt

### 5.2
sudo apt-get install davfs2
sudo vim /etc/davfs2/davfs2.conf
## added: use_locks 0
## This will disable file locking, which is not supported by some WebDAV servers.

# Add WebDAV resource credentials
sudo vim /etc/davfs2/secrets
# http://lab1/webdav /mnt sammy 123456
sudo chmod 600 /etc/davfs2/secrets

sudo mount -t davfs http://lab1/webdav /mnt -o username=sammy
#  Password:  123456

sudo umount /mnt

### 6.3
sudo apt install nfs-common -y
sudo mount lab1:/mnt/raid5 /mnt

