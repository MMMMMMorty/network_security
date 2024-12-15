# Network filesystems

The lab aims to provide practical experience with different file sharing protocols and storage solutions, emphasizing security, redundancy, and performance. Participants will gain hands-on experience in configuring, managing, and troubleshooting network file systems, ensuring they can select the most appropriate solution for different network environments and security requirements.

## 1. Preparation

## 2. Configuring and testing NFS

### 2.1 Demonstrate a working configuration.

check files lab1.sh and lab2.sh

### 2.2 Is it possible to encrypt all NFS traffic? How?

Yes, it possible.

One way to achieve this is by using the NFS over TLS (Transport Layer Security) protocol.
Generate a TLS certificate and key pair for the NFS server.
Configure the NFS server to use the TLS certificate and key pair.
Generate a TLS certificate and key pair for each NFS client.
Configure each NFS client to use its TLS certificate and key pair.
Configure the NFS server to only allow connections from authorized clients using valid certificates.
Configure the NFS client to connect to the NFS server using the TLS protocol.

One method of encrypting NFS traffic over a network is to use the port-forwarding capabilities of ssh. However, as we shall see, doing so has a serious drawback if you do not utterly and completely trust the local users on your server.

It may also be possible to use IPSec to encrypt network traffic between your client and your server, without compromising any local security on the server; this will not be taken up here. See the FreeS/WAN home page for details on using IPSec under Linux.

## 3 Configuring and testing samba

### 3.1 Demonstrate a working configuration.

check files lab1.sh and lab2.sh

### 3.2 Only root can use mount. What problem does this pose for users trying to access their remote home directories? Is there a workaround for the problem?

The problem with only allowing root to use the mount command is that regular users cannot mount Samba shares on their own. This can be an issue for users who need to access their remote home directories through Samba, as they would need to rely on the root user or an administrator to mount the share for them.

Just add users in /etc/fstab like that:

    //192.168.1.1/Testuser1 /mnt cifs credentials=/root/.smbcredentials,users,uid=<user>,gid=<group> 0 0

This line specifies the Samba share path, mount point, and mount options. The credentials option specifies the path to a file containing the username and password for the Samba share. The users option allows any user to mount the share, and the uid and gid options specify the user and group ownership for the mounted file

After adding the line to /etc/fstab, you can run the mount -a command as root to mount all file systems listed in /etc/fstab.

Normally, only the superuser can mount filesystems. However, when fstab contains the user option on a line, anybody can mount the corresponding system.

Or if you want any user to mount/unmount the drives users (with suid bit set) instead.

Or uses -o specify the user and group that can use to mount the filsyetem.

## 4 Configuring and testing sshfs

### 4.1 Provide the commands that you used.

check files lab1.sh and lab2.sh

### 4.2 When is sshfs a good solution?

SSHFS can be very handy when working with remote filesystems, especially if you only have SSH access to the remote system. Moreover, you don't need to add or run a special client tool on the client nodes or a special server tool on the storage node. You just need SSH active on your system. As a user, you can access the user space filesystem.

### 4.3 What are the advantages of FUSE?

Developing in user space has several advantages. The APIs are saner, crashes are less frequent, debuggers and profilers work better. Many more libraries are available, providing functionality ranging from very generic things like advanced data structures to very specific things like encryption or erasure coding. It's easier to test user-space code, or clean up and start over when a test fails. The pool of potential collaborators is much larger. Except for the very specific case of developing a high-performance local filesystem.

It can be used to create application specific virtual filesystems for configuration data (gvfs does this).
It can be used to develop new filesystems.
It can provide access to a database using ordinary shell commands.
It can be used to provide access to encrypted files (gets tricky though as that usually requires any password to the file be given to the FUSE application so it can decrypt the data).
It has been used to provide a directory level view of archive tar files (tarfs).
I used it to prototype a hierarchical storage file system (mostly just to see if it could be done).
I believe it has been used to form a union file system (aufs) that combines storage from two different file systems.

### 4.4 Why doesn't everyone use encrypted channels for all network filesystems?

Performance: Encryption and decryption of data can add overhead to the network traffic, which can result in slower transfer speeds and increased latency. This can be especially noticeable when transferring large files or using high-bandwidth applications.

Complexity: Setting up and maintaining encrypted channels can be complex, and may require specialized knowledge and skills. This can be challenging for smaller organizations or individuals who may not have dedicated IT resources or expertise.

Compatibility: Encrypted channels may not be supported by all network filesystems or devices. This can limit the ability to share files and collaborate with others who may not be using the same encryption protocols.

Cost: Some encryption protocols may require additional software or hardware components, which can add to the cost of implementing and maintaining encrypted channels.

User convenience: Using encrypted channels can require additional steps or authentication measures for users to access shared files and resources. This can be inconvenient for users who may prioritize ease of use and accessibility over security.

## 5 Configuring and testing WebDAV

### 5.1 Demonstrate a working setup. (View for example a web page on one machine and edit it from another using cadaver).

check files lab1.sh and lab2.sh

### 5.2 Demonstrate mounting a WebDAV resource into the local filesystem.

check files lab1.sh and lab2.sh

Result:

    vagrant@lab2:~$ df -h
    Filesystem                      Size  Used Avail Use% Mounted on
    udev                            975M     0  975M   0% /dev
    tmpfs                           199M 1008K  198M   1% /run
    /dev/sda1                        39G  2.2G   37G   6% /
    tmpfs                           992M     0  992M   0% /dev/shm
    tmpfs                           5.0M     0  5.0M   0% /run/lock
    tmpfs                           992M     0  992M   0% /sys/fs/cgroup
    /dev/loop0                       64M   64M     0 100% /snap/core20/1778
    /dev/loop1                       50M   50M     0 100% /snap/snapd/17950
    /dev/loop2                       92M   92M     0 100% /snap/lxd/24061
    vagrant                          76G  7.3G   69G  10% /vagrant
    tmpfs                           199M     0  199M   0% /run/user/1000
    testuser1@lab1:/home/testuser1   39G  2.3G   37G   6% /home/testuser1/mnt
    http://lab1/webdav              1.3T  763G  509G  61% /mnt

### 5.3 Does your implementation support versioning? If not, what should be added

My ansewr doesn't support versioning

WebDAV supports versioning of files through the use of the DeltaV (Versioning Extensions to WebDAV) protocol. With DeltaV, you can keep multiple versions of a file and manage changes to files in a more efficient and structured manner.

[avatar!][http://www.webdav.org/specs/rfc3253.html]

To add versioning to a WebDAV server, you need to enable the DeltaV protocol on the server.

1. Verify that your WebDAV server supports DeltaV: Not all WebDAV servers support the DeltaV protocol, so check with your server documentation to see if this is supported.

2. Enable DeltaV on your WebDAV server: Once you have verified that your server supports DeltaV, you need to enable it. The specific steps to do this depend on the server you are using. Consult your server documentation for instructions on how to enable DeltaV.

3. Create a version-controlled resource: To add versioning to a file or folder, you need to create a version-controlled resource. This is a resource that the server knows should be versioned. You can create a version-controlled resource by using the MKVERSION-CONTROL method in your WebDAV client.

4. Check out a version-controlled resource: Once you have created a version-controlled resource, you can check it out by using the CHECKOUT method in your WebDAV client. This allows you to make changes to the resource without affecting the previous version.

5. Check in a version-controlled resource: When you are done making changes to the resource, you can check it back in using the CHECKIN method in your WebDAV client. This creates a new version of the resource with your changes.

6. View version history: You can view the version history of a resource by using the VERSION-CONTROL method in your WebDAV client. This shows you all of the previous versions of the resource and allows you to compare different versions.

## 6 Raid 5

### 6.1 What is raid?  What is parity? Explain raid5?

1. RAID is an acronym meaning “Redundant Array of Independent Disks”. As the name implies, RAID creates an array of multiple hard disks in order to provide redundancy. An array simply means a collection of drives that are presented to the operating system as a single logical device. The “redundancy” in RAID is a key feature of most RAID types, used to provide additional reliability for storing data on less-than-perfect hard drives. As a side benefit, by combining many drives into one array, RAID also improves disk access speed and increases available disk space.

2. Parity is a type of extra data that is calculated and stored alongside the data the user wants to write to the hard drive. 

3. RAID 5 is a type of RAID that offers redundancy using a technique known as “parity”. This extra data can be used to verify the integrity of stored data, and also to calculate any “missing” data if some of your data cannot be read (such as when a drive fails). To explain how it does this, think back to high school algebra class, with equations like “9 = X + 4. Solve for X”. In this case, “X” is unknown data that was previously stored on a drive that has failed. “4” meanwhile, is data that is stored on a drive you can read, and “9” is parity data stored on a third drive, that was previously calculated for redundancy purposes. By solving for X, we can re-construct that the missing data should have been “5”. This allows you to have redundancy without storing a full extra copy of your data, saving disk space compared to RAID 1 or RAID 10.

### 6.2 Show that your raid5 solution is working.

see lab1 and lab2

### 6.3 Access the NAS device from lab2 over NFS

see lab2.sh

## 7 Final question

Samba:
Samba is commonly used to share files and printers between Windows and Linux/Unix machines. It is useful in environments where there are both Windows and Linux/Unix machines that need to share resources. One of its strengths is that it supports a wide range of Windows file sharing protocols, making it easy to integrate with Windows networks. However, its weakness is that it can be challenging to configure properly, and it may not perform as well as some other file sharing protocols in certain situations.

NFS:
NFS is a protocol for sharing files between Unix/Linux machines. It is commonly used in environments where there are multiple Linux/Unix machines that need to share resources. One of its strengths is that it is very efficient and performs well in high-bandwidth environments. However, its weakness is that it can be difficult to configure properly, and it may not be as secure as some other file sharing protocols.

SSHFS:
SSHFS is a file system client based on the SSH File Transfer Protocol (SFTP). It allows you to mount a remote file system using SSH as the secure transport. This is useful for securely accessing remote files and folders over the internet or across networks. One of its strengths is that it is easy to set up and use, and it provides strong security for file transfers. However, its weakness is that it may not perform as well as some other file sharing protocols in certain situations.

WebDAV:
WebDAV (Web Distributed Authoring and Versioning) is a protocol for sharing files over the web. It is commonly used in environments where users need to share and collaborate on files remotely. One of its strengths is that it is easy to access and use through a web browser, and it supports versioning, which allows users to track changes to files over time. However, its weakness is that it can be less efficient than other file sharing protocols, especially for large files, and it may not be as secure as some other protocols.