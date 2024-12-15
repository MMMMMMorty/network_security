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
gpg --output lab1PublicKey.gpg --export lab1-key
mv lab2PublicKey.gpg ~/

cd ~
gpg --import lab2PublicKey.gpg
touch test.txt
echo "hello world" >> test.txt
mv test.txt /vagrant/
cd /vargrant/
# encrypt
gpg --encrypt --output test.gpg --recipient lab2@example.com test.txt

# decrypt
gpg --encrypt --sign --armor --recipient lab1@example.com test.txt

### 3.1

dd if=/dev/urandom of=loop.img bs=1k count=32k
# Create a loopback device for the file 
sudo losetup loop11 loop.img
# format the loopback device
sudo cryptsetup luksFormat /dev/loop11 #YES 2021
# map it to a pseudo-device
sudo cryptsetup luksOpen /dev/loop11 secrets # 2021  wrong passed: No key available with this passphrase.
# Create an ext2 filesystem on the pseudo-device
sudo mkfs.ext2 /dev/mapper/secrets
# lsblk
# mount
sudo mount /dev/mapper/secrets /mnt


# remove the device mapping and detach the file mapped with the loop device
sudo umount /mnt
cryptsetup luksClose secrets
losetup -d /dev/loop10

### 4.1
df -h
cd ~
mkdir cipher plain
gocryptfs -init cipher
gocryptfs cipher plain

touch plain/test.txt
ls cipher
# fuse userfs
fusermount -u plain

### 5.1
# add the PPA repository named unit193 which contains the VeraCrypt
sudo add-apt-repository ppa:unit193/encryption
#  Update the packages repository
sudo apt update
sudo apt install veracrypt
veracrypt --version

# sudo veracrypt -t -c --volume-type=hidden /dev/sdb2 --size=500M --encryption=aes --hash=sha-512 --filesystem=ext4 -p STRONGP@33WORDHID --pim=0 -k "" --random-source=/dev/urandom
sudo veracrypt -t -c
# 2, /dev/sda1, 1, 1, 2, 2021, y, 2021, 0, , random_characters
veracrypt -m=nokernelcrypto /dev/sda1 /mnt
veracrypt -l
