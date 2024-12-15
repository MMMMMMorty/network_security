sudo echo "192.168.1.1 lab1" | sudo tee -a /etc/hosts
sudo echo "192.168.1.2 lab2" | sudo tee -a /etc/hosts
sudo apt -y install net-tools
sudo apt-get -y install traceroute nmap mlocate
sudo apt upgrade -y
sudo apt update

# with home directory
#sudo passwd testuser1 passwd 123456
sudo useradd -m testuser1
sudo useradd testuser2

# ### 2.1
# sudo apt install nfs-kernel-server
# sudo systemctl start nfs-kernel-server.service
# sudo systemctl enable --now nfs-server
# # # Port mapping
# sudo systemctl enable --now rpcbind
# sudo vim /etc/exports
# # File added: /home/testuser1 lab2(rw,async,no_subtree_check,no_root_squash)
# sudo exportfs -a
# sudo systemctl restart nfs-kernel-server

# sudo ufw enable
# sudo ufw allow from 192.168.1.2 to any port nfs
# sudo ufw allow OpenSSH

# ### 3.1
# sudo apt install samba -y
# # sudo systemctl status smbd
# sudo smbpasswd -a testuser1 # passwd: 2021
# sudo apt-get install acl
# sudo setfacl -R -m "u:testuser1:rwx" /home/testuser1

# sudo vim /etc/samba/smb.conf
# # [Testuser1]
# # comment = Home Directory Share
# # path = /home
# # browsable = yes
# # read only = no
# # create mask = 0755
# # directory mask = 0755
# # valid users = testuser1

# sudo systemctl restart smbd

# sudo ufw allow samba

# ### 4.1
# # AllowPassword yes
# sudo vim /etc/ssh/sshd_config
# df -h

# ### 5.1
# sudo apt -y install apache2
# sudo a2enmod dav
# sudo a2enmod dav_fs
# sudo systemctl restart apache2.service

# sudo mkdir -p /var/www/WebDAV/files
# sudo chown -R www-data:www-data /var/www/WebDAV/files
# sudo chmod -R 750 /var/www/WebDAV/files
# sudo touch /var/DavLock
# sudo chown www-data:www-data /var/DavLock
# sudo chmod 664 /var/DavLock
# sudo vim /etc/apache2/sites-available/000-default.conf
#         # DavLockDB /var/DavLock
#         # Alias /webdav /var/www/WebDAV
#         <Directory /var/www/WebDAV/files>
#                 DAV On
#                 Options Indexes FollowSymLinks
#                 AllowOverride None
#                 Require all granted
#         </Directory>
# sudo ln -s /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-enabled/
# sudo systemctl restart apache2.service
# sudo ufw allow 80/tcp

# elinks http://localhost/webdav

# sudo a2enmod auth_digest
# sudo touch /var/local/users.password
# sudo chown www-data:www-data /var/local/users.password
# sudo htdigest /var/local/users.password webdav sammy
# sudo vim /etc/apache2/sites-available/000-default.conf

# <Location /webdav>
#         DAV On
#         AuthType Digest
#         AuthName "sammy"
#         AuthUserFile /var/local/users.password
#         Require valid-user
# </Location>

# sudo systemctl restart apache2.service

# sudo vim /var/www//var/www/WebDAV/files/test3.txt

# ### 6.2

# sudo fdisk -l









