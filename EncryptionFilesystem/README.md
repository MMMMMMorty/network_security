# Encryption File System

The aim of the lab is to explore encryption techniques for securing files, filesystems, and devices. It focuses on:

- Understanding tools like GnuPG, LUKS, and gocryptfs.  
- Practicing encryption for files, devices, and filesystems.  
- Comparing the security of older and modern cryptographic methods.  
- Addressing key management, entropy, and real-world security challenges.  

## 2 Encrypting a single file using GnuPG

### 2.1 What are the differences between stacked file system encryption and Block device encryption?

1. Encryption Scope: Stacked file system encryption encrypts individual files and directories, whereas block device encryption encrypts entire storage devices or partitions.

2. Encryption Granularity: Stacked file system encryption encrypts data on a per-file basis, whereas block device encryption encrypts data in fixed-size blocks or sectors.

3. Encryption Layer: Stacked file system encryption operates at the file system layer and can be implemented on top of an existing file system, whereas block device encryption operates at the block device layer and encrypts data before it is written to the device.

4. Performance: Stacked file system encryption can have a higher overhead compared to block device encryption, as it encrypts and decrypts data on a per-file basis. Block device encryption can be more efficient as it encrypts data in larger blocks or sectors.

5. Flexibility: Stacked file system encryption can provide more flexibility in terms of managing encryption at the file system level, such as supporting multiple encryption algorithms or keys for different files. Block device encryption is typically implemented at the device level and may not provide as much flexibility.

### 2.2 Provide the commands you used for creating and verifying the keys and explain what they do.

lab1
   gpg --full-generate-key
   #gpg --list-keys
   cd /vagrant/
   gpg --output lab1PublicKey.gpg --export lab1-key
   mv lab2PublicKey.gpg ~/

   cd ~
   gpg --import lab2PublicKey.gpg
   touch test.txt
   echo "hello world" >> test.txt
   mv test.txt /vagrant/
   cd /vargrant/
   #encrypt
   gpg --encrypt --output test.gpg --recipient lab2@example.com test.txt

   #decrypt
   gpg --decrypt --output result test.gpg


lab2
   gpg --full-generate-key
   #gpg --list-keys

   cd /vagrant/
   gpg --output lab2PublicKey.gpg --export lab2-key
   mv lab1PublicKey.gpg ~/

   cd ~
   gpg --import lab1PublicKey.gpg

   cd /vargrant/
   gpg --decrypt --output result test.gpg
   <!-- #decrypt
   gpg --encrypt --sign --armor --recipient lab1@example.com test.txt -->
   cat result

   #sign in ASCII
   gpg --encrypt --sign --armor --recipient lab1@example.com test.txt

### 2.3 Are there any security problems in using GPG like this?

1. Weak Passphrases: If you use a weak passphrase to protect your GPG private key, an attacker may be able to easily crack it and gain access to your private key, which can compromise the security of all your encrypted files and messages.

2. Man in the middle attack. There is no assurance this key belongs to the named user

3. This key is not certified with a trusted signature! There is no indication that the signature belongs to the owner.

4. Key Verification: To ensure the security of encrypted communications, it is important to verify the authenticity of public keys used by other parties. If you encrypt a file or message using an unverified public key, an attacker can substitute their own public key and intercept your encrypted communication.

5. Key Management: Managing GPG keys properly is essential for maintaining security. If your private key is compromised, an attacker can use it to impersonate you and decrypt your encrypted files and messages. It is important to keep your private key secure, and to revoke and regenerate keys when necessary.

### 2.4 How does GnuPG relate to PGP?

**GnuPG (GNU Privacy Guard)** is an open-source software application that provides encryption and digital signature functionality, and it is designed to be compatible with the OpenPGP standard. **PGP (Pretty Good Privacy)** is a proprietary software application that provides similar functionality to GnuPG, but it is not open source.

GnuPG was developed as a free and open-source alternative to PGP, and it is based on the OpenPGP standard, which defines a format for encrypted and signed messages as well as key management. GnuPG uses public-key cryptography to provide encryption and digital signatures, and it uses similar algorithms and key formats as PGP.

Difference between GnuPG and PGP is their user interfaces. GnuPG is a command-line application. PGP has a graphical user interface (GUI).

### 2.5 What is haveged and why did we install it earlier? What possible problems can usage of haveged have?

The haveged project is an attempt to provide an easy-to-use, unpredictable random number generator based upon an adaptation of the HAVEGE algorithm. Haveged was created to remedy low-entropy conditions in the Linux random device that can occur under some workloads, especially on headless servers. Entropy refers to the amount of randomness or unpredictability in a system.

The haveged software provides a source of entropy by monitoring a variety of hardware events, such as hard disk activity and keyboard input, and using them to generate random numbers. This helps to ensure that the entropy pool remains sufficiently full to meet the needs of the system.

However, there are some potential problems that can arise from the usage of haveged.

It may affect the security, which causes by incorrect configuration.

One problem is that haveged can consume a significant amount of CPU resources, which can affect system performance.

Additionally, haveged is not guaranteed to provide high-quality randomness in all cases, and there have been some concerns raised about its effectiveness in certain scenarios.

## 3 Crypto filesystem with loopback and device mapper

### 3.1 Provide the commands you used

   dd if=/dev/urandom of=loop.img bs=1k count=32k
   #Create a loopback device for the file
   sudo losetup loop11 loop.img
   #format the loopback device
   sudo cryptsetup luksFormat /dev/loop11 #YES 2021
   #map it to a pseudo-device
   sudo cryptsetup luksOpen /dev/loop11 secrets # 2021  wrong passed: No key available with this passphrase.
   #Create an ext2 filesystem on the pseudo-device
   sudo mkfs.ext2 /dev/mapper/secrets
   #lsblk
   #mount
   sudo mount /dev/mapper/secrets /mnt

   #remove the device mapping and detach the file mapped with the loop device
   cryptsetup luksClose secrets
   losetup -d /dev/loop10

### 3.2 Explain the concepts of the pseudo-device and loopback device

A pseudo-device is a special type of device in a computer system that does not correspond to a physical device, but rather is a virtual device that provides a specific type of functionality. Pseudo-devices are often used to provide access to system resources or to emulate physical devices that are not present in the system. Examples of pseudo-devices include the null device, which discards all data written to it, and the random device, which generates random data.

A loopback device is a type of network interface that allows a computer to communicate with itself over a network. The loopback device is often assigned the IP address "127.0.0.1", which is known as the loopback address. When a program on the computer sends data to the loopback address, the data is routed back to the same computer, as if it had been sent over a physical network connection. This can be useful for testing network applications or for providing local services that do not need to be accessible over a network.

In some cases, the loopback device can also be used as a pseudo-device. For example, in Linux, the loopback device can be used to create virtual block devices that can be used for various purposes, such as creating disk images or testing file systems. The virtual block devices are represented as files on the file system, and the loopback device is used to mount these files as if they were physical block devices.

### 3.3 What is LUKS? (Knowing the meaning of abbreviation won't get you a point.)

LUKS (Linux Unified Key Setup) is a disk encryption specification and implementation used in Linux-based operating systems to provide full disk encryption. LUKS is designed to support multiple encryption algorithms, including AES, Twofish, and Serpent, and to provide strong security for user data.

One of the advantages of LUKS is its support for multiple key slots, which allows multiple passphrases or keys to be used to unlock the device. This can be useful in situations where multiple users or administrators need access to the same encrypted device, or when a backup key is needed in case the primary key is lost or forgotten.

### 3.4 What is this kind of encryption method (creating a filesystem into a large random file, and storing a password protected decryption key with it) good for? What strengths and weaknesses does it have?\

Encrypting filesystem files, container-based encryption, encrypted container ( a file or a block device is created as a virtual disk that is encrypted and mounted as a regular file system on the system)

This encryption method is useful for protecting sensitive data that is stored on a physical device or a network storage location, such as cloud storage. It can also be used for creating secure backups or archives that can be easily moved and copied to different locations.

Strong encryption: Container-based encryption uses advanced encryption algorithms such as AES, which is widely considered to be highly secure.

Flexibility: Container-based encryption can be used on any storage media or cloud storage and can be easily moved and copied.

Convenient: It is a convenient way of encrypting and decrypting data as the encrypted file or container is mounted like any other file system.

A Protected, Virtual Drive
How do you use these containers? A mounted container is based on virtual drive technology. While it's mounted, it appears to your software like any other drive. You can use the container to store internal data and temp files. They never show up in unencrypted form on the physical storage. When it's dismounted, the files aren't visible to anybody. No other applications can read them, even if they have hardware-level access to the drive.

Weakness

Vulnerable to brute-force attacks: If the encryption passphrase used to protect the container is weak, an attacker could use a brute-force attack to crack the encryption.

Vulnerable to insider attacks: If an attacker gains access to the passphrase or keyfile used to encrypt the container, they can easily access the data stored in the container.

Limited protection: Container-based encryption only protects the data stored within the container. Any data outside of the container is not protected.

Not recommended for long-term storage: The container file can become corrupted over time, and if the container is damaged, the encrypted data stored inside it can be lost.

When the key is compromised, attackers can access all the data.

### 3.5 Why did we remove cryptoloop from the assignment and replaced it with dm_crypt? Extending the question a bit, what realities must a sysadmin remember with any to-be-deployed and already deployed security-related software?

Cryptoloop is a Linux kernel's disk encryption module that relies on the Crypto API, it can create an encrypted file system within a partition or from within a regular file in the regular file system. Once a file is encrypted, it can be moved to another storage device. This is accomplished by making use of a loop device, a pseudo device that enables a normal file to be mounted as if it were a physical device. By encrypting I/O to the loop device, any data being accessed must first be decrypted before passing through the regular file system; conversely, any data being stored will be encrypted.

Cryptoloop is vulnerable to watermarking attacks, making it possible to determine presence of watermarked data on the encrypted filesystem:

This attack exploits weakness in IV computation and knowledge of how file systems place files on disk. This attack works with file systems that have soft block size of 1024 or greater. At least ext2, ext3, reiserfs and minix have such property. This attack makes it possible to detect presence of specially crafted watermarked files. Watermarked files contain special bit patterns that can be detected without decryption.

Newer versions of cryptoloop's successor, dm-crypt, are less vulnerable to this type of attack if used correctly.

Unlike its predecessor cryptoloop, dm-crypt was designed to support advanced modes of operation, such as XTS, LRW and ESSIV (see disk encryption theory for further information), in order to avoid watermarking attacks. In addition to that, dm-crypt addresses some reliability problems of cryptoloop.

Also, dm-crypt supports more encryption algotithm.

The reason:

Keep software up to date: Security vulnerabilities are constantly being discovered and fixed in software, so it is important to keep all security-related software up to date with the latest patches and updates.

Use reputable software: Use security software that is well-known and widely used, and has a good track record of being secure and reliable.

Follow best practices: Follow best practices for security-related software, such as using strong passwords or passphrases, protecting encryption keys carefully, and limiting access to sensitive data.

Monitor for security issues: Regularly monitor security logs and alerts for any signs of security issues or breaches, and take immediate action if any are detected.

Plan for disaster recovery: In case of a security breach or data loss, have a plan for disaster recovery in place to minimize the impact and restore operations as quickly as possible.

## 4 Gocryptfs

### 4.1 Provide the commands you used.

Create and Mount Filesystem
   $ mkdir cipher plain
   $ gocryptfs -init cipher
     [...]
   $ gocryptfs cipher plain
     [...]
You should now have a working gocryptfs that is stored in cipher and mounted to plain. You can verify it by creating a test file in the plain directory. This file will show up encrypted in the cipher directory.

   $ touch plain/test.txt
   $ ls cipher
    gocryptfs.conf  gocryptfs.diriv  ZSuIZVzYDy5-TbhWKY-ciA==

   fusermount -u plain


### 4.2 Explain how this approach differs from the loopback one. What are the main differences between gocryptfs and encFS? Is encFS secure?

1. Gocryptfs is designed to be more portable than loopback encryption. It uses a standard file format that can be mounted on any system that supports FUSE (Filesystem in Userspace), while loopback encryption is more closely tied to the Linux kernel. 
2. More than that, Gocryptfs is compatible with a wider range of file systems than loopback encryption. While loopback encryption can only be used with certain file systems like ext2, ext3, and ext4, Gocryptfs can be used with any file system that supports FUSE
3. Gocryptfs is a modern cryptographic file system that uses authenticated encryption, which is designed to prevent tampering with encrypted data. In contrast, loopback encryption typically uses older encryption algorithms like AES-256 in CBC mode, which is vulnerable to certain attacks.

Main differences:

Encryption method: Gocryptfs uses modern, authenticated encryption algorithms like AES-256-GCM and supports additional encryption features like file names encryption, while EncFS uses a simpler encryption algorithm, typically Blowfish, which is not as secure as AES.

Performance: Gocryptfs is designed to be faster than EncFS when working with large files, especially when the file is being edited. Gocryptfs achieves this by minimizing the number of disk writes and reducing overhead.

Portability: Gocryptfs is more portable than EncFS because it does not require any kernel modules, and it can be mounted on any system that supports FUSE (Filesystem in Userspace). EncFS, on the other hand, requires kernel support, and it may not work on some operating systems.

Key management: Gocryptfs offers more flexible key management options than EncFS. It allows the use of a master key and a password, or a combination of both, while EncFS only uses a passphrase for key management.

Security: Gocryptfs is designed to be more secure than EncFS. Gocryptfs uses modern encryption algorithms and has been audited by security experts, while EncFS has known security vulnerabilities and has not been updated in several years.

Overall, Gocryptfs is a newer, more secure, and more performant encryption soft

EncFs is not secure:

EncFS is discouraged because of the unresolved security issues. It is unsafe if the attacker gets access to previous versions of files (which will be the case when you store data on the Cloud.  EncFS is not secure when an attacker gets multiple versions of the same encrypted file at different times. So if you upload your files to your Dropbox and then modify them, they are not securely encrypted anymore.).

Also it leaks meta information like file sizes. The encrypted files are not stored in their own file, someone who obtains access to the system can still see the underlying directory structure, the number of files, their sizes and when they were modified. They cannot see the contents, however.

This particular method of securing data is obviously not perfect, but there are situations in which it is useful.

## 5 TrueCrypt and alternatives

### 5.1 Which encryption software did you choose and why?

TrueCrypt is a discontinued source-available freeware utility used for on-the-fly encryption (OTFE). It can create a virtual encrypted disk within a file, or encrypt a partition or the whole storage device (pre-boot authentication).

On 28 May 2014, the TrueCrypt website announced that the project was no longer maintained and recommended users find alternative solutions. Though development of TrueCrypt has ceased, an independent audit of TrueCrypt (published in March 2015) has concluded that no significant flaws are present. Two projects forked from TrueCrypt: VeraCrypt (active) and CipherShed (abandoned).

FileVault: FileVault is a disk encryption software that is built into the macOS operating system. It provides good security and is easy to use, but it is only available on Apple devices.

BitLocker: BitLocker is a disk encryption software that is built into the Windows operating system. It is easy to use and provides good security, but it is only available in certain editions of Windows.

VeraCrypt: VeraCrypt is a free and open-source disk encryption software that is based on the TrueCrypt code. It offers improved security features and is actively maintained by a community of developers.

ecryptfs-utils: ecryptfs-utils is a tool that provides encryption of home directories in Ubuntu. It uses AES encryption and is easy to use. However, it has some limitations, such as not being able to encrypt the entire system and being less flexible than some other encryption tools.

if I require advanced encryption features like hidden volumes or plausible deniability, VeraCrypt is a more powerful and flexible tool.

So I choose VeraCrypt.

### 5.2 Provide the commands that you used to create the volumes. Demonstrate that you can mount the outer and the hidden volume.

   sudo veracrypt -t -c

   The hidden VeraCrypt volume has been successfully created and is ready for use. If all the instructions have been followed and if the precautions and requirements listed in the section "Security Requirements and Precautions Pertaining to Hidden Volumes" in the VeraCrypt User's Guide are followed, it should be impossible to prove that the hidden volume exists, even when the outer volume is mounted.

   WARNING: IF YOU DO NOT PROTECT THE HIDDEN VOLUME (FOR INFORMATION ON HOW TO DO SO, REFER TO THE SECTION "PROTECTION OF HIDDEN VOLUMES AGAINST DAMAGE" IN THE VERACRYPT USER'S GUIDE), DO NOT WRITE TO THE OUTER VOLUME. OTHERWISE, YOU MAY OVERWRITE AND DAMAGE THE HIDDEN VOLUME!

    veracrypt -m=nokernelcrypto /dev/sda1 /mnt
    Instead of using kernel cryptography you can tell Veracrypt to use software based encryption. This is slower than doing it in the kernel or hardware layer but will allow you to mount the drive. Adding the -m=nokernelcrypto option will mount the drive and should fix the above issue. 

    veracrypt -l
    1: /dev/sda1 /dev/loop4 /mnt
    # umont
    sudo veracrypt -d /dev/sda1

### 5.3 What is plausible deniability?

Plausible deniability can refer to the ability to hide sensitive data, such as encrypted files or communication, in a way that makes it difficult or impossible for an attacker to prove its existence or contents.

For example, in the case of encrypted volumes with hidden volumes, the outer volume containing non-sensitive data can be used to provide plausible deniability that a hidden volume exists. The password to the hidden volume is different from the password to the outer volume, and it is impossible to prove whether a hidden volume exists or not without the knowledge of the user who created it. This can be useful in situations where an attacker or authority might coerce someone to reveal the contents of an encrypted volume. By using plausible deniability, the user can deny the existence of the hidden volume and protect sensitive information.