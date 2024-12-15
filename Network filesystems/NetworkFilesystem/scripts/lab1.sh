sudo echo "192.168.1.1 lab1" | sudo tee -a /etc/hosts
sudo echo "192.168.1.2 lab2" | sudo tee -a /etc/hosts
sudo apt -y install net-tools
sudo apt-get -y install traceroute nmap mlocate
sudo apt upgrade -y
sudo apt update

# with home directory
#sudo passwd testuser1 passwd 123456
sudo useradd -m testuser1 --uid 1002 # adduser useradd
sudo useradd testuser2 --uid 1003

### 2.1
sudo apt install nfs-kernel-server
sudo systemctl start nfs-kernel-server.service
sudo systemctl enable --now nfs-server
# # Port mapping
sudo systemctl enable --now rpcbind
sudo vim /etc/exports
# File added: /home/testuser1 lab2(rw,async,no_subtree_check,no_root_squash)
sudo exportfs -a
sudo systemctl restart nfs-kernel-server

sudo ufw enable
sudo ufw allow from 192.168.1.2 to any port nfs
sudo ufw allow OpenSSH

### 3.1
sudo apt install samba -y
# sudo systemctl status smbd
sudo smbpasswd -a testuser1 # passwd: 2021
sudo apt-get install acl
sudo setfacl -R -m "u:testuser1:rwx" /home/testuser1

sudo vim /etc/samba/smb.conf
# [Testuser1]
# comment = Home Directory Share
# path = /home/testuser1
# browsable = yes
# read only = no
# create mask = 0775
# directory mask = 0775
# valid users = testuser1

sudo systemctl restart smbd

sudo ufw allow samba

### 4.1
# AllowPassword yes
sudo vim /etc/ssh/sshd_config # set the passwd before
df -h

### 5.1
sudo apt -y install apache2
sudo a2enmod dav
sudo a2enmod dav_fs
sudo systemctl restart apache2.service

sudo mkdir -p /var/www/WebDAV/files
sudo chown -R www-data:www-data /var/www/WebDAV/files
sudo chmod -R 750 /var/www/WebDAV/files
sudo touch /var/DavLock
sudo chown www-data:www-data /var/DavLock
sudo chmod 664 /var/DavLock
sudo vim /etc/apache2/sites-available/000-default.conf
        DavLockDB /var/DavLock
        Alias /webdav /var/www/WebDAV
        <Directory /var/www/WebDAV/files>
                DAV On
                Options Indexes FollowSymLinks
                AllowOverride None
                Require all granted
        </Directory>
sudo ln -s /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-enabled/
sudo systemctl restart apache2.service
sudo ufw allow 80/tcp

elinks http://localhost/webdav

sudo a2enmod auth_digest
sudo touch /var/local/users.password
sudo chown www-data:www-data /var/local/users.password
sudo htdigest /var/local/users.password webdav sammy
sudo vim /etc/apache2/sites-available/000-default.conf

<Location /webdav>
        DAV On
        AuthType Digest
        AuthName "sammy"
        AuthUserFile /var/local/users.password
        Require valid-user
</Location>

sudo systemctl restart apache2.service

sudo vim /var/www//var/www/WebDAV/files/test3.txt

### 6.2

sudo fdisk -l
lsblk

# $env:VAGRANT_EXPERIMENTAL="disks"
# vagrant up
# (0..3).each do |i|
# lab1.vm.disk :disk, size: "5GB", name: "disk-#{i}"
# end
sudo mdadm --create --verbose /dev/md0 --level=5 --raid-device=3 /dev/sdc /dev/sdd /dev/sde
sudo mkfs.ext4 /dev/md0
mkdir /mnt/raid5
sudo mount /dev/md0 /mnt/raid5
sudo chmod 777 /mnt/raid5

sudo apt install nfs-kernel-server
sudo systemctl start nfs-kernel-server.service
sudo systemctl enable --now nfs-server
# # Port mapping
sudo systemctl enable --now rpcbind
sudo vim /etc/exports
# /mnt lab2(rw,async,no_subtree_check,no_root_squash)
sudo apt install nfs-kernel-server
sudo exportfs -a
sudo systemctl restart nfs-kernel-server

sudo ufw enable 
sudo ufw allow from 192.168.1.2 to any port nfs
sudo ufw allow OpenSSH

sudo mdadm --fail /dev/md0 /dev/sdd
# check the status
cat /proc/mdstat
sudo mdadm --remove /dev/md0 /dev/sdd
sudo mdadm --add /dev/md0 /dev/sdf




