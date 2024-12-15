# Fundamentals

This lab focuses on understanding networking fundamentals and practicing tools for exploring and troubleshooting networks.

1. Virtual Machines Setup
Set up and access virtual machines (VMs) using SSH.
(Optional) Configure routing for communication between VMs.
2. Networking Basics
Identified key network details like active interfaces, router MAC addresses, name servers, and domain configurations.
Used tools like dig to investigate domain name system (DNS) records and email routing.
Measured latency and routing paths to different hosts using ping and traceroute.
3. Network Scanning
Used nmap to discover devices and open ports on the local network.
4. Request and Response
Explored communication protocols with netcat (nc):
Captured server responses to SSH and HTTP requests.
Simulated a basic web and SSH server to analyze client behavior.

## 1. VirtualBox virtual machines

### 1.1 Create yourself a key-pair to be used with the virtual machines

Operations for manual virtual machines

    ssh-keygen -t rsa
    ssh-copy-id username@hostname

<!-- Operations for vagrant virtual machines
//change lab1 to router
sysctl.conf ip_forward=1
//change the gateway lab2, lab3


    sudo ip route add 192.168.2.2/24 dev enp0s8(for lab2) # add to route table
    sudo ip route add 192.168.1.2/24 dev enp0s8(for lab3) # add to route table
    ssh-keygen -t rsa
    ssh-copy-id username@192.168.2.2
    ssh-copy-id username@192.168.1.2 -->

## 2. Networking basics

### 2.1 Using ip find all the active interfaces on your machine

    ip a
    ip -br a

### 2.2 Using netstat and arp, find the MAC address of the default router of your machine

    netstat -r
    arp -n

The mac address is

    08:00:27:ea:a6:93

### 2.3 From resolv.conf, find the default name servers and the internet domain of your machine

    cat /etc/resolv.conf

That is the resolv.conf document

    nameserver 127.0.0.53 (Name server IP address)

    options edns0 trust-ad

    search kyla.fi (local domain name)

- How is this file generated?

    This is a dynamic resolv.conf file for connecting local clients to the internal DNS stub resolver of systemd-resolved. This file lists all configured search domains

### 2.4 Using dig(1), find the responsible name servers for the cs.hut.fi domain

    dig NS cs.hut.fi +short

The result is

    sauna.cs.hut.fi.

    ns.niksula.hut.fi.

### 2.5 Using dig find the responsible mail exchange servers for cs.hut.fi domain

    dig MX cs.hut.fi +short

The result is

    1 mail.cs.hut.fi.

### 2.6 Using ping send 5 packets to aalto.fi and find out the average latency. Try then pinging Auckland University of Technology, aut.ac.nz, and see if the latency is different

    ping -c 5 aalto.fi
    ping -c 5 aut.ac.nz

The result is

    64 bytes from 104.17.221.22 (104.17.221.22): icmp_seq=1 ttl=56 time=15.1 ms

    64 bytes from 104.17.221.22 (104.17.221.22): icmp_seq=2 ttl=56 time=13.1 ms

    64 bytes from 104.17.221.22 (104.17.221.22): icmp_seq=3 ttl=56 time=11.8 ms

    64 bytes from 104.17.221.22 (104.17.221.22): icmp_seq=4 ttl=56 time=9.16 ms

    64 bytes from 104.17.221.22 (104.17.221.22): icmp_seq=5 ttl=56 time=10.9 ms

    --- aalto.fi ping statistics ---

    5 packets transmitted, 5 received, 0% packet loss, time 4017ms

    rtt min/avg/max/mdev = 9.164/12.012/15.120/2.011 ms

    PING aut.ac.nz (156.62.238.90) 56(84) bytes of data.

    64 bytes from bax.aut.ac.nz (156.62.238.90): icmp_seq=1 ttl=39 time=407 ms

    64 bytes from bax.aut.ac.nz (156.62.238.90): icmp_seq=2 ttl=39 time=328 ms

    64 bytes from bax.aut.ac.nz (156.62.238.90): icmp_seq=3 ttl=39 time=351 ms

    64 bytes from bax.aut.ac.nz (156.62.238.90): icmp_seq=4 ttl=39 time=312 ms

    64 bytes from bax.aut.ac.nz (156.62.238.90): icmp_seq=5 ttl=39 time=313 ms

    --- aut.ac.nz ping statistics ---

    5 packets transmitted, 5 received, 0% packet loss, time 4002ms

    rtt min/avg/max/mdev = 311.904/342.429/407.088/35.287 ms

### 2.7 Using traceroute find out how many hops away is amazon.com

    traceroute -I -m 50 amazon.com

There are 13 hops to amazon.com

    traceroute to amazon.com (54.239.28.85), 50 hops max, 60 byte packets
    1  _gateway (10.0.2.1)  0.106 ms  0.088 ms  0.082 ms
    2  gw-1-v391.kyla.fi (82.130.49.124)  2.460 ms  2.552 ms  2.517 ms
    3  funet-espoo1-100g-r1.ayy.fi (82.130.63.245)  2.547 ms  2.588 ms  2.640 ms
    4  fi-csc.nordu.net (109.105.102.168)  2.169 ms  2.376 ms  2.462 ms
    5  de-hmb.nordu.net (109.105.97.77)  18.410 ms  18.355 ms  19.271 ms
    6  nl-ams.nordu.net (109.105.97.80)  24.902 ms  24.397 ms  24.383 ms
    7  us-man.nordu.net (109.105.97.64)  111.933 ms  111.565 ms  111.547 ms
    8  nyiix-peering.amazon.com (198.32.160.64)  112.170 ms  112.258 ms  112.255 ms
    9  150.222.68.88 (150.222.68.88)  112.219 ms  112.283 ms  112.572 ms
    10  150.222.68.91 (150.222.68.91)  124.193 ms  121.707 ms  121.972 ms
    11  * * *
    12  150.222.68.66 (150.222.68.66)  112.864 ms  112.564 ms  112.443 ms
    13  * * *
    14  * * *
    15  * * *
    16  * * *
    17  * * *
    18  * * *
    19  52.93.28.84 (52.93.28.84)  122.346 ms  122.340 ms  122.582 ms
    20  * * *
    21  * * *
    22  * * *
    23  * * *
    24  * * *
    25  * * *
    26  * * *
    27  * * *
    28  * * *
    29  * * *
    30  * * *
    31  * * *
    32  * * *
    33  54.239.28.85 (54.239.28.85)  117.490 ms  118.031 ms  118.101 ms

- Why does this address sometimes produce different results on different traceroute runs?

Because amazon.com can have different ip addresses, which can cause the different roads to amazon.com or maybe there is another way to go to the same ip address or I begin from different gateway can cause different results

### 2.8 Using mtr find out the minimum, maximum and average network latency between your machine and google.com

    mtr -c 10 --report www.google.com

Result:

    # Loss% what percentage of packets will not return
    # Snt count of sent packets
    # Last latency of the last sent packet
    # Avg, Best, Wrst average, best and worst latencies of all packets
    # StDev the standard deviation of latencies to each hop. A high StDev means there are network inconsistencies

    Start: 2023-01-16T21:33:29+0000
    HOST: vm1                         Loss%   Snt   Last   Avg  Best  Wrst StDev
    1.|-- _gateway                   0.0%    10    0.1   0.1   0.1   0.2   0.0
    2.|-- gw-1-v391.kyla.fi         10.0%    10    2.1 209.8   1.9 1430. 478.7
    3.|-- funet-espoo1-100g-r1.ayy. 10.0%    10    2.0 192.8   1.8 1359. 452.7
    4.|-- fi-csc.nordu.net          10.0%    10    3.4 178.7   1.9 1287. 425.9
    5.|-- 109.105.101.10            10.0%    10   14.7 172.2  12.9 1220. 398.5
    6.|-- 109.105.101.23            10.0%    10   13.3 154.0  13.1 1147. 375.1
    7.|-- as15169-10g-sk1.sthix.net  0.0%    10   13.9 335.1  13.5 2079. 696.9
    8.|-- 108.170.253.181            0.0%    10   20.8 313.4  13.5 2008. 672.0
    9.|-- 108.170.227.249            0.0%    10   15.9 300.4  14.0 1937. 643.6
    10.|-- 216.239.49.53              0.0%    10   32.2 303.5  32.2 1884. 616.0
    11.|-- 108.170.226.48             0.0%    10   32.1 469.2  32.1 1825. 751.2
    12.|-- 108.170.253.33             0.0%    10   31.8 446.8  31.7 1753. 719.6
    13.|-- 209.85.244.219            10.0%    10   32.8 288.8  32.5 1669. 557.9
    14.|-- mil02s05-in-f68.1e100.net 10.0%    10   37.2 273.9  31.7 1596. 528.9

- Can the packet loss %age > 0 even if there is no loss in transport layer traffic? Why? Yes, it can larger than 0. A packet loss at one hop on the path doesn’t mean there is something wrong with routing, neither does it mean that the path is congested. When you see an output showing a loss, it’s usually due to ICMP limits set on the router, eg. ICMP rate limiting, which is a common practice used not to overload router CPU by ICMP requests.

## 3. Using nmap to scan networks

### 3.1 Using nmap to scan your  local network, and show  the list of all live and up hosts and open ports on VMs

    nmap -A 10.0.2.4 127.0.0.1

Check the port of the 10.0.2.4 and 127.0.0.1

    Starting Nmap 7.80 ( https://nmap.org ) at 2023-01-16 21:36 UTC
    Nmap scan report for vm1 (10.0.2.4)
    Host is up (0.000055s latency).
    Not shown: 999 closed ports
    PORT   STATE SERVICE VERSION
    22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.5 (Ubuntu Linux; protocol 2.0)
    Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

    Nmap scan report for localhost (127.0.0.1)
    Host is up (0.000050s latency).
    Not shown: 999 closed ports
    PORT   STATE SERVICE VERSION
    22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.5 (Ubuntu Linux; protocol 2.0)
    Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

    Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
    Nmap done: 2 IP addresses (2 hosts up) scanned in 0.81 seconds

## 4. Examining the request and response messages of clients and servers using netcat

### 4.1 Using netcat capture the version number of the ssh daemon running on your machine

    nc 10.0.2.4 22

The result is

    SSH-2.0-OpenSSH_8.2p1 Ubuntu-4ubuntu0.5

### 4.2 Using netcat craft a valid HTTP/1.1 request for getting HTTP headers (not the html file itself) from the front page of www.aalto.fi

    printf 'GET /get HTTP/1.1\r\nHost:www.aalto.fi\r\n\r\n' | nc -v www.aalto.fi 80 

The result is

    Connection to www.aalto.fi 80 port [tcp/http] succeeded!
    HTTP/1.1 301 Moved Permanently
    Date: Mon, 16 Jan 2023 22:42:13 GMT
    Transfer-Encoding: chunked
    Connection: keep-alive
    Cache-Control: max-age=3600
    Expires: Mon, 16 Jan 2023 23:42:13 GMT
    Location: https://www.aalto.fi/get
    Server: cloudflare
    CF-RAY: 78aa5cf37a33d937-HEL

- What request method did you use? HTTP GET
- Which headers did you need to send to the server?  Host:www.aalto.fi (A basic request with one header)
- What was the status code for the request? 301 Moved Permanently
- Which headers did the server return? Date Transfer-Encoding Connection Cache-Control Expires Location Server CF-RAY
- Explain the purpose of each header.
  - Date: Contains the date and time at which the message was originated.
  - Transfer-Encoding: Specifies the form of encoding used to safely transfer the resource to the user. (Here: Data is sent in a series of chunks. The Content-Length header is omitted in this case)
  - Connection: Controls whether the network connection stays open after the current transaction finishes. (Here: keep-alive Indicates that the client would like to keep the connection open )
  - Cache-Control: Directives for caching mechanisms in both requests and responses.
  - Expires: The date/time after which the response is considered stale. (Here: The max-age=N response directive indicates that the response remains fresh until N seconds after the response is generated.)
  - Location: The Location response header indicates the URL to redirect a page to. It only provides a meaning when served with a 3xx (redirection) or 201 (created) status response.
  - Server: Contains information about the software used by the origin server to handle the request.
  - CF-RAY: The CF-RAY response header is a unique ID from CloudFlare and indicates that the resource was served through CloudFlare.

### 4.3 Using netcat start a bogus web server listening on the loopback interface port 8080. Verify with netstat that the server really is listening where it should be. Direct your browser lynx to the bogus server and capture the User-Agent: header

netcat start a bogus web server listening on the loopback interface port 8080

    nc -l -s 127.0.0.1 -p 8080

Verify with netstat that the server really is listening where it should be.

    netstat -an | grep 8080

The result is

    tcp        0      0 127.0.0.1:8080          0.0.0.0:*               LISTEN

Direct your browser lynx to the bogus server and capture the User-Agent: header

    lynx -dump 127.0.0.1:8080

The result in nc

    GET / HTTP/1.0
    Host: 127.0.0.1:8080
    Accept: text/html, text/plain, text/sgml, text/css, */*;q=0.01
    Accept-Language: en
    User-Agent: Lynx/2.9.0dev.5 libwww-FM/2.14 SSL-MM/1.4.1 GNUTLS/3.6.13

### 4.4 With similar setup to 4.3, start up a bogus ssh server with nc and try to connect to it with ssh. Copy-paste the server version string you captured in 4.1 and see if you get a response from the client. What is the client trying to negotiate?

start up a bogus ssh server with nc, listen on port 2022

    nc -l -s 127.0.0.1 -p 2022

try to connect to it with ssh

    ssh -p 2022 127.0.0.1

Receive from ssh server

    SSH-2.0-OpenSSH_8.2p1 Ubuntu-4ubuntu0.5
    #Copy-paste the server version
    SSH-2.0-OpenSSH_8.2p1 Ubuntu-4ubuntu0.5
    #then
    �
    �D��b����)�curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group14-sha256,ext-info-c�ecdsa-sha2-nistp256-cert-v01@openssh.com,ecdsa-sha2-nistp384-cert-v01@openssh.com,ecdsa-sha2-nistp521-cert-v01@openssh.com,sk-ecdsa-sha2-nistp256-cert-v01@openssh.com,ssh-ed25519-cert-v01@openssh.com,sk-ssh-ed25519-cert-v01@openssh.com,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-256-cert-v01@openssh.com,ssh-rsa-cert-v01@openssh.com,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,sk-ecdsa-sha2-nistp256@openssh.com,ssh-ed25519,sk-ssh-ed25519@openssh.com,rsa-sha2-512,rsa-sha2-256,ssh-rsalchacha20-poly1305@openssh.com,aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.comlchacha20-poly1305@openssh.com,aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com�umac-64-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha1-etm@openssh.com,umac-64@openssh.com,umac-128@openssh.com,hmac-sha2-256,hmac-sha2-512,hmac-sha1�umac-64-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,hmac-sha1-etm@openssh.com,umac-64@openssh.com,umac-128@openssh.com,hmac-sha2-256,hmac-sha2-512,hmac-sha1none,zlib@openssh.com,zlibnone,zlib@openssh.com,zlib

From what I did below, the client trying to negotiate the ssh version and the ssh key exchange algorithms

## 5 Vagrant

### 5.1

- Which providers does vagrant support?
  Vagrant supports three providers by default: VirtualBox, Hyper-V, and Docker

- What does command: vagrant init do?
  This initializes the current directory to be a Vagrant environment by creating an initial Vagrantfile if one does not already exist.

### 5.2

- What is box in Vagrant?
  Boxes are the package format for Vagrant environments. You specify a box environment and operating configurations in your Vagrantfile.
  
- How to add a box to the vagrant environment?
  - To get started, use the init command to initialize your environment.

        vagrant init hashicorp/bionic64

  - If you have an existing Vagrantfile, add hashicorp/bionic64.

        Vagrant.configure("2") do |config|
          config.vm.box = "hashicorp/bionic64"
        end

  - If you ran the commands in the last tutorial you do not need to add a box; Vagrant installed one when you initialized your project. Sometimes you may want to install a box without creating a new Vagrantfile. For this you would use the box add subcommand.

        vagrant box add hashicorp/bionic64

### 5.3

- Show the provisioning part of your sample code and explain it?

        vagrant plugin install vagrant-disksize

        Vagrant.configure("2") do |config|

          config.vm.define "lab1" do |lab1|
            
            # set the package for environment
            lab1.vm.box = "ubuntu/focal64"
            
            # set the hostname
            lab1.vm.hostname="lab1"
            
            # set the disk size as 2GB
            lab1.disksize.size = '2GB'

              # Create a forwarded port mapping which allows access to a specific port
              # within the machine from a port on the host machine and only allow access
              # via 127.0.0.1 to disable public access
              lab1.vm.network "forwarded_port", guest: 22, host: 10004, host_ip: "127.0.0.1"
              
              # Create a private network, which allows host-only access to the machine
              # using a specific IP.
              lab1.vm.network "private_network", ip: "192.168.1.1",virtualbox__intnet: true,virtualbox__intnet:"intnet1"

              lab1.vm.network "private_network",ip: "192.168.2.1",virtualbox__intnet: true,virtualbox__intnet:"intnet2"

              lab1.vm.provider :virtualbox do |vb|

                # Custom CPU & Memory

                 vb.customize ["modifyvm", :id, "--memory", "2048"]

                 vb.customize ["modifyvm", :id, "--cpus", "1"]

              end
          
          end

          config.vm.define "lab2" do |lab2|

            lab2.vm.box = "ubuntu/focal64"

            lab2.vm.hostname="lab2"

            lab2.disksize.size = '2GB'

              lab2.vm.network "forwarded_port", guest: 22, host: 10005, host_ip: "127.0.0.1"

              lab2.vm.network "private_network", ip: "192.168.1.2",virtualbox__intnet: true,virtualbox__intnet:"intnet1"

              lab2.vm.provider :virtualbox do |vb|

                # Custom CPU & Memory

                 vb.customize ["modifyvm", :id, "--memory", "2048"]

                 vb.customize ["modifyvm", :id, "--cpus", "1"]

              end
          
          end

          config.vm.define "lab3" do |lab3|

            lab3.vm.box = "ubuntu/focal64"

            lab3.vm.hostname="lab3"

            lab3.disksize.size = '2GB'

              lab3.vm.network "forwarded_port", guest: 22, host: 10006, host_ip: "127.0.0.1"

              lab3.vm.network "private_network",ip: "192.168.2.2",virtualbox__intnet: true,virtualbox__intnet:"intnet2"

              lab3.vm.provider :virtualbox do |vb|

                # Custom CPU & Memory

                 vb.customize ["modifyvm", :id, "--memory", "2048"]

                 vb.customize ["modifyvm", :id, "--cpus", "1"]

              end
          
          end

            #add provisioning scripts to Vagrantfile

            config.vm.provision "shell", inline: <<-SHELL

            sudo echo "192.168.1.1 lab2" | sudo tee -a /etc/hosts

            sudo echo "192.168.2.1 lab3" | sudo tee -a /etc/hosts

            sudo apt install net-tools

        SHELL
        end

### 5.4

- Upload a file from your host to a vm? Share a folder on your host to a vm.

Vagrant automatically syncs files to and from the guest machine. This way you can edit files locally and run them in the virtual development environment.

By default, Vagrant shares the project directory (the one containing the Vagrantfile) to the /vagrant directory in the guest machine.

    vagrant up

To upload the file to vm, what I need to do is to create or move the file to the project directory, which will be uploaded to vm automatically.

    touch <the project directory>/<exampleFile>

To see the files sync between the guest machine and host

    # vagrant ssh into the vm, you're in /home/vagrant, which is a different directory from the synced project directory.
    vagrant ssh
    # show the the synce file
    ls

Share an additional folder to the guest VM in a Vagrantfile. The first argument is the path on the host to the actual folder. The second argument is the path on the guest to mount the folder. And the optional third argument is a set of non-required options.

    config.vm.synced_folder "../data", "/vagrant_data"

### 5.5

- Show the running boxes in your provider via ssh ?

        vagrant status

The result is

    Current machine states:

    lab1                      running (virtualbox)
    lab2                      running (virtualbox)
    lab3                      running (virtualbox)

Use ssh to connect to each vm

    vagrant ssh lab1
    vagrant ssh lab2
    vagrant ssh lab3
