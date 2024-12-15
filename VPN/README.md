# VPN

The lab is aimed at providing hands-on experience with setting up a VPN using OpenVPN, including the configuration of a Public Key Infrastructure (PKI) for secure authentication. Participants will learn how to generate and manage certificates and keys, configure VPN servers and clients, and address authentication methods including the use of simpler static keys versus more secure PKI-based methods. The lab also covers IP address allocation, logging configurations, and troubleshooting common issues that may arise during VPN setup.

## 1. Initial Setup

### 1.1 Present your network configuration. What IPs did you assign to the interfaces (4 interfaces in all) of each of the three hosts?

VagrantFile

## 2. Setting up a PKI (Public Key Infrastructure)

### 2.1 What is the purpose of each of the generated files? Which ones are needed by the client?

1. a separate certificate (also known as a public key) and private key for the server and each client, and a master Certificate Authority (CA) certificate and key which is used to **sign each of the server and client certificates**.

   Both server and client will authenticate the other by first verifying that the presented certificate was signed by the master certificate authority (CA). Server certificates typically are issued to hostnames, which could be a machine name (such as ‘XYZ-SERVER-01’) or domain name (such as ‘www.digicert.com’). A web browser reaching the server validates that the TLS/SSL server certificate is authentic. That tells the user that their interaction with the website has no eavesdroppers, and that the website is representing exactly who they claim they are.

   Client cetificates are digital certificates for users and individuals to prove their identity to a server. Client certificates tend to be used within private organizations to authenticate requests to remote servers

   Diffie-Hellman parameters: after authentication process is finished and was created a tunnel (VPN) for transportation data will used one symmetric key which very fast, but not very safe. Therefore it will used the unique parameters (a secret value) for every session, which generated for both point after authentication process.

2. Certificate and key of client are needed by the client.

1. ca.crt This is the public key certificate for a Certificate Authority (CA) that is used to verify the authenticity of other certificates in the SSL/TLS connection.
2. ca.key This is the private key that corresponds to the public key in the ca.crt file. This key is used to sign other certificates and is kept secure by the Certificate Authority.
3. server.key This is the private key for the server in an SSL/TLS connection. It is used to decrypt incoming data from clients and encrypt outgoing data to clients.
4. server.crt This is the public key certificate for the server in an SSL/TLS connection. It is sent to clients to verify the authenticity of the server.
5. client.key This is the private key for a client in an SSL/TLS connection. It is used to decrypt incoming data from the server and encrypt outgoing data to the server.
6. client.crt This is the public key certificate for a client in an SSL/TLS connection. It is sent to the server to verify the authenticity of the client.
7. df.key  Diffie–Hellman key   Diffie-Hellman is a key exchange algorithm that allows two parties to establish a shared secret key over an insecure channel. This shared secret key can then be used for secure communication between the two parties. In the context of SSL/TLS, a Diffie-Hellman key exchange can be used to negotiate a shared secret key between the server and client, which is used to encrypt and decrypt data transmitted between them. The "df.key" file would contain the private key for the Diffie-Hellman key exchange on the server side.
8. ta.key This file likely contains a key for a HMAC (Hashed Message Authentication Code) signature, which is used to verify the integrity and authenticity of messages exchanged between the server and clients. The "ta" refers to a "tls-auth" key used by the OpenVPN protocol to authenticate clients

ca.crt, client.key, client.crt, df.key, ta.key

### 2.2 Is there a simpler way of authentication available in OpenVPN? What are its benefits/drawbacks?

A simpler way is to securely obtain a username and password from a connecting client, and to use that information as a basis for authenticating the client. It is also possible to disable the use of client certificates, and force username/password authentication only. It uses client-cert-not-required may remove the cert and key directives from the client configuration file, but not the ca directive, because it is necessary for the client to verify the server certificate.

Benefits: it is simple, drawbacks it is dangerous.

There is a simpler way of authentication available in OpenVPN called "static key authentication". In this method, a pre-shared secret key is used instead of a PKI. The benefit of this method is that it is simple to set up and does not require the overhead of a PKI. However, the drawback is that it is less secure than using a PKI, as there is only one shared secret key for all clients and the server. This means that if the key is compromised, all clients are compromised.

Benefits:

* Simple to configure and set up
* Does not require a PKI or certificate infrastructure
* Fast and efficient because it does not need to perform complex cryptographic operations

Drawbacks:

* Less secure than certificate-based authentication methods since the same pre-shared key is used for all connections, making it easier for an attacker to intercept and potentially compromise the key.
* Difficult to revoke a key if it gets compromised, as the same key is used for all connections.
Cannot provide user-level authentication, meaning all clients with the same key have the same level of access.

## 3. Configuring the VPN server

### 3.1 List and give a short explanation of the commands you used in your server configuration.

This is server certificate and key generation.

      # It’s necessary to run it here because your server and CA will have separate PKI directories
      # ./easyrsa init-pki (I dont have to set it again)

      # generate request for server(no password)
      ./easyrsa gen-req server nopass

      # use it
      sudo cp ~/EasyRSA-3.0.8/pki/private/server.key /etc/openvpn/

      # scp ~/EasyRSA-3.0.8/pki/reqs/server.req sammy@your_CA_ip:/tmp (dont have to do it, same machine)

      # import request in a ca
      sudo ./easyrsa import-req /home/vagrant/EasyRSA-3.0.8/pki/reqs/server.req lab1
      # Using the easyrsa script again, import the server.req file, following the file path with its common name lab1(lab1 will be the common name in CA and for server)

      # ca sign the request from server
      ./easyrsa sign-req server lab1 # yes 2021
      # Then sign the request by running the easyrsa script with the sign-req option, followed by the request type(server or client) and the common name.
      # The Subject's Distinguished Name is as follows
      # commonName            :ASN.1 12:'lab1'
      # Certificate is to be certified until Jun 18 21:01:34 2025 GMT (825 days)
      # Certificate created at: /home/vagrant/EasyRSA-3.0.8/pki/issued/lab1.crt

      # scp pki/issued/server.crt sammy@your_server_ip:/tmp
      # scp pki/ca.crt sammy@your_server_ip:/tmp

      # In Server, copy the server.crt and ca.crt files into your /etc/openvpn/ directory
      sudo cp ./pki/ca.crt  /etc/openvpn/
      sudo cp ./pki/issued/lab1.crt  /etc/openvpn/

      # create a strong Diffie-Hellman key to use during key exchange
      sudo ./easyrsa gen-dh
      sudo cp ~/EasyRSA-3.0.8/pki/dh.pem /etc/openvpn/

      # generate an HMAC signature to strengthen the server’s TLS integrity verification capabilities
      sudo openvpn --genkey secret ta.key
      sudo cp ~/EasyRSA-3.0.8/ta.key /etc/openvpn/

This is the configuration for server.conf

    Please see the server_bridge.conf

### 3.2 What IP address space did you allocate to the OpenVPN clients?

Ip address space: 192.168.0.10-192.168.0.254

### 3.3 Where can you find the log messages of the server by default? How can you change this?

1. If you are using the network manager plugin (network-manager-openvpn), look into /var/log/syslog
    grep VPN /var/log/syslog

    Connection details are to be found in /etc/openvpn/

    Could also be /var/log/openvpn/openvpn-status.log

2. config files can set the logfile location explicitly, e.g.: in .conf file

   log-append /var/log/openvpn.log
   log /var/log/openvpn/openvpn.log

   This works for both OpenVPN clients and servers. OpenVPN config files are usually located in /etc/openvpn and usually named *.conf. server.conf is canonical; client config filenames are usually like <client nam>.conf.

## 4. Bridging setup

### 4.1 Show with ifconfig that you have created the new interfaces (virtual and bridge). What's the IP of the bridge interface?

    ifconfig

    115: tap0: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc fq_codel master br0 state UP group default qlen 1000
    link/ether ce:b5:49:5d:2d:24 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::ccb5:49ff:fe5d:2d24/64 scope link
       valid_lft forever preferred_lft forever

    116: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
       link/ether e6:d0:a5:50:68:9e brd ff:ff:ff:ff:ff:ff
       inet 192.168.0.1/24 brd 192.168.0.255 scope global br0
          valid_lft forever preferred_lft forever
       inet6 fe80::e4d0:a5ff:fe50:689e/64 scope link
          valid_lft forever preferred_lft forever

Ip address: 192.168.0.1 (br0, same as enp0s8)

### 4.2 What is the difference between routing and bridging in VPN? What are the benefits/disadvantages of the two? When would you use routing and when bridging?

1. When a client connects via bridging to a remote network, it is assigned an IP address that is part of the remote physical ethernet subnet and is then able to interact with other machines on the remote subnet as if it were connected locally. Bridging setups require a special OS-specific tool to bridge a physical ethernet adapter with a virtual TAP style device.

When a client connects via routing, it uses its own separate subnet, and routes are set up on both the client machine and remote gateway so that data packets will seamlessly traverse the VPN. The "client" is not necessarily a single machine. It could be a subnet of several machines. The routing acts as gateway.

Bridging and routing are functionally very similar, with the major difference being that a routed VPN will not pass IP broadcasts while a bridged VPN will.

Routing is the process of forwarding data packets from one network to another through intermediate devices such as routers. In a VPN, routing is used to connect remote networks over the internet or other public networks. When routing is used, each network is assigned a unique IP address range, and data packets are sent between the networks based on their destination IP address. Routing is more flexible than bridging, as it allows different networks to use different IP address ranges and can handle more complex network topologies.

Bridging, on the other hand, is the process of connecting two or more network segments into a single network. In a VPN, bridging is used to connect individual devices or hosts to a remote network. When bridging is used, all devices on the remote network appear to be on the same network as the local device, and they can communicate directly with each other.

2. Now lets see benefits and drawbacks of TAP(bridging) vs TUN(routing).

   TAP benefits:

   behaves like a real network adapter (except it is a virtual network adapter)
   can transport any network protocols (IPv4, IPv6, Netalk, IPX, etc, etc)
   Works in layer 2, meaning Ethernet frames are passed over the VPN tunnel
   Can be used in bridges

   TAP drawbacks:

   causes much more broadcast overhead on the VPN tunnel
   adds the overhead of Ethernet headers on all packets transported over the VPN tunnel
   scales poorly
   can not be used with Android or iOS devices
   TUN benefits:

   A lower traffic overhead, transports only traffic which is destined for the VPN client
   Transports only layer 3 IP packets

   TUN drawbacks:

   Broadcast traffic is not normally transported
   Can only transport IPv4 (OpenVPN 2.3 adds IPv6)
   Cannot be used in bridges

3. Overall, routing is probably a better choice for most people, as it is more efficient and easier to set up (as far as the OpenVPN configuration itself) than bridging. Routing also provides a greater ability to selectively control access rights on a client-specific basis.

   I would recommend using routing unless you need a specific feature which requires bridging, such as:

   the VPN needs to be able to handle non-IP protocols such as IPX,
   you are running applications over the VPN which rely on network broadcasts (such as LAN games), or
   you would like to allow browsing of Windows file shares across the VPN without setting up a Samba or WINS server.

   Routing is used when connecting to separate networks, and briding is used for connecting to existing network.

## 5. Configuring the VPN client and testing connection

### 5.1 List and give a short explanation of the commands you used in your VPN client configuration.

This is how to generate the client key and certificate

    mkdir -p ~/client-configs/keys
    # store clients’ certificate/key pairs and configuration files in this directory, lock down its permissions now as a security measure
    chmod -R 700 ~/client-configs

    # in server
    cd ~/EasyRSA-3.0.8/
    sudo ./easyrsa gen-req lab3 nopass

    sudo cp pki/private/lab3.key ~/client-configs/keys/

    # # scp pki/reqs/lab3.req vagrant@ca:/tmp (same)

    # in CA
    cd ~/EasyRSA-3.0.8/
    # lab3 known as client1 in CA
    sudo ./easyrsa import-req pki/reqs/lab3.req client1
    # CA sign on it
    sudo ./easyrsa sign-req client client1

    # in server 
    # copy the client certificate to the /client-configs/keys/
    sudo cp pki/issued/client1.crt ~/client-configs/keys/
    # copy the ca.crt and ta.key files to the /client-configs/keys/
    sudo cp ~/EasyRSA-3.0.8/ta.key ~/client-configs/keys/    
    sudo cp /etc/openvpn/ca.crt ~/client-configs/keys/

    mkdir -p ~/client-configs/files
    cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf ~/client-configs/base.conf
    sudo vim ~/client-configs/base.conf
    # remote lab1 1194
    # proto udp
    # user nobody
    # group nogroup
    # # ca ca.crt (comment out)
    # # cert client1.crt
    # # key lab3.key
    # # tls-auth ta.key 1
    # cipher AES-256-CBC
    # auth SHA256
    # key-direction 1

    # # These clients rely on the resolvconf utility to update DNS information for Linux clients
    # ; script-security 2
    # ; up /etc/openvpn/update-resolv-conf
    # ; down /etc/openvpn/update-resolv-conf

    # # set of lines for clients that use systemd-resolved for DNS resolution
    # ; script-security 2
    # ; up /etc/openvpn/update-systemd-resolved
    # ; down /etc/openvpn/update-systemd-resolved
    # ; down-pre
    # ; dhcp-option DOMAIN-ROUTE .

    # sudo vim ~/client-configs/make_config.sh
    cat << EOF >>~/client-configs/make_config.sh
    #!/bin/bash

    # First argument: Client identifier and certificate name
    # Second argumebt: key name

    KEY_DIR=~/client-configs/keys
    OUTPUT_DIR=~/client-configs/files
    BASE_CONFIG=~/client-configs/base.conf

    cat ${BASE_CONFIG} \
        <(echo -e '<ca>') \
        ${KEY_DIR}/ca.crt \
        <(echo -e '</ca>\n<cert>') \
        ${KEY_DIR}/${1}.crt \
        <(echo -e '</cert>\n<key>') \
        ${KEY_DIR}/${2}.key \
        <(echo -e '</key>\n<tls-auth>') \
        ${KEY_DIR}/ta.key \
        <(echo -e '</tls-auth>') \
        > ${OUTPUT_DIR}/${1}.ovpn
    EOF

    sudo chmod 700 ~/client-configs/make_config.sh

    # Step 9 — Generating Client Configurations

    cd ~/client-configs
    sudo ./make_config.sh client1 lab3
    ls ~/client-configs/files

Please see client_bridge.conf

### 5.2 Demonstrate that you can reach the SS from the RW. Setup a server on the client with netcat and connect to this with telnet/nc. Send messages to both directions.

lab2:
   netcat -l 1234

lab3:
   telnet lab2 1234

### 5.3 Capture incoming/outgoing traffic on GW's enp0s9 or RW's enp0s8. Why can't you read the messages sent in 5.2 (in plain text) even if you comment out the cipher command in the config-files?

lab1:
   sudo tcpdump -i enp0s9 -s 0 -w - port 1194
   tcpdump: listening on enp0s9, link-type EN10MB (Ethernet), snapshot length 262144 bytes
   �ò�

commment out cipher AES-256-CBC
   ncp-disable
   chiper none
   it can work

<!-- lab2:
   sudo tcpdump -i enp0s8 -->

Note that v2.4 client/server will automatically negotiate AES-256-GCM in TLS mode. if settingg cipher none, same. Adding ncp-disable, it can work then.

The reason for this is that encryption is not the only factor that determines whether a message is readable or not. OpenVPN also uses key exchange and authentication mechanisms to secure its connections, and without these mechanisms, the connection won't be established in the first place.

Additionally, OpenVPN may use other encryption methods besides the cipher command in the server.conf file. For example, it may use HMAC-based authentication codes (HMACs) or digital signatures to ensure message integrity and authenticity. Without these mechanisms, the message may be altered or forged during transmission.

Furthermore, even if you were able to remove all encryption and security mechanisms, some messages sent over OpenVPN may still be unreadable because they are not designed to be read in plain text. For example, some protocols, like HTTPS or SSH, may use binary encoding or other mechanisms that require additional processing or decryption to be readable.

In summary, removing the cipher command in the server.conf file may not be sufficient to read messages sent over OpenVPN in plain text. To decrypt OpenVPN traffic, you would need access to the keys and certificates used for encryption, as well as a deep understanding of the encryption and security mechanisms used by OpenVPN.

### 5.4 Enable ciphering. Is there a way to capture and read the messages sent in 5.2 on GW despite the encryption? Where is the message encrypted and where is it not?

Yes, if you capture the traffic on GW's enp0s8 or br0, I can see the message.

   sudo tcpdump -i enp0s8 -s 0 -w - port 1194
   sudo tcpdump -i br0 -s 0 -w - port 1194

The encryption process occurs before the data is sent over the VPN connection, and decryption occurs at the other end of the connection.

### 5.5 traceroute RW from SS and vice versa. Explain the result.

lab3
   traceroute lab2
   traceroute to lab2 (192.168.0.2), 30 hops max, 60 byte packets
    1  lab2 (192.168.0.2)  6.931 ms  6.977 ms  6.883 ms

In a bridged OpenVPN setup, the VPN server acts as a bridge between two or more networks, allowing all hosts to communicate as if they were on the same local network. This means that hosts on one network can communicate with hosts on another network, including hosts on the other side of the VPN connection. Here lab3 is the client, it can be seen as in the same network as enp0s8. So it can connect to lab2 directly.

In summary, in a bridged OpenVPN setup, hosts on different networks can communicate with each other as if they were on the same local network, allowing traceroute packets to successfully traverse the network and reach the destination host. The VPN server acts as a bridge, forwarding the packets to the appropriate network segment without modifying the IP addresses or routing information in the packets.

lab2
   traceroute lab3
   traceroute to lab3 (192.168.2.2), 30 hops max, 60 byte packets
    1  _gateway (10.0.2.2)  0.407 ms  0.271 ms  0.207 ms
    2  * * *
    3  * * *

Failed, it didnt go through the VPN.

   traceroute 192.168.0.10
   traceroute to 192.168.0.10 (192.168.0.10), 30 hops max, 60 byte packets
    1  192.168.0.10 (192.168.0.10)  2.862 ms  2.574 ms  2.591 ms
   
Successed, it goes through the VPN bridge.

## 6. Setting up routed VPN

In this task, you have to set up routed VPN as opposed to the bridged VPN above. Stop openvpn service on both server and client.

1. Reconfigure the server.conf and the client.conf to have routed vpn.

2. Restart openvpn service on both server and client.

3. Now you should be able to ping virtual IP address of vpn server from client.

### 6.1 List and give a short explanation of the commands you used in your server configuration

See server.conf

### 6.2 Show with ifconfig that you have created the new virtual IP interfaces . What's the IP  address?

Server:

    tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UNKNOWN group default qlen 500
       link/none
       inet 10.8.0.1 peer 10.8.0.2/32 scope global tun0
          valid_lft forever preferred_lft forever
       inet6 fe80::5991:5961:c34:e7df/64 scope link stable-privacy
          valid_lft forever preferred_lft forever

Client:

    tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UNKNOWN group default qlen 500
    link/none
    inet 10.8.0.6 peer 10.8.0.5/32 scope global tun0
       valid_lft forever preferred_lft forever
    inet6 fe80::5ada:f3ff:a068:6881/64 scope link stable-privacy
       valid_lft forever preferred_lft forever

      tun0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UNKNOWN group default qlen 500: This line provides general information about the tun0 interface, including its status (UP and LOWER_UP), its maximum transmission unit (MTU) size of 1500 bytes, the queuing discipline (fq_codel), its state (UNKNOWN), the default network group it belongs to, and the maximum length of the transmit queue.

      link/none: This line indicates that the tun0 interface does not have a physical link.

      inet 10.8.0.1 peer 10.8.0.2/32 scope global tun0: This line provides the Internet Protocol version 4 (IPv4) address for the tun0 interface, which is 10.8.0.1. It also shows the peer address for the remote end of the connection, which is 10.8.0.2. The /32 indicates that the peer address is a single IP address rather than a range. The scope global indicates that this address is reachable from anywhere on the network.

      valid_lft forever preferred_lft forever: These lines indicate that the IPv4 address for the tun0 interface has an infinite validity period and is preferred over any other address.

      inet6 fe80::5991:5961:c34:e7df/64 scope link stable-privacy: This line provides the Internet Protocol version 6 (IPv6) link-local address for the tun0 interface. The fe80:: prefix indicates that this is a link-local address that can only be used to communicate with other devices on the same network segment. The /64 indicates the subnet prefix length, which is the number of bits in the address that identify the network segment. The scope link indicates that this address is only valid for communication within the same network segment. The stable-privacy indicates that this address is automatically generated and will remain stable over time.

      Mar 21 07:29:20 lab3 bash[31764]: 2023-03-21 07:29:20 net_route_v4_add: 192.168.0.0/24 via 10.8.0.5 dev [NULL] table 0 metric -1
      Mar 21 07:29:20 lab3 bash[31764]: 2023-03-21 07:29:20 net_route_v4_add: 10.8.0.1/32 via 10.8.0.5 dev [NULL] table 0 metric -1

      net_route_v4_add: 192.168.0.0/24 via 10.8.0.5 dev [NULL] table 0 metric -1: This line indicates that a new route has been added for the network 192.168.0.0/24. The route will be accessed via the device with no name ([NULL]) and the IP address of the next hop on this route is 10.8.0.5. The route has been added to the main routing table (table 0) with a metric of -1. A metric is a value assigned to a route that is used to determine the best path for a packet to take.

      net_route_v4_add: 10.8.0.1/32 via 10.8.0.5 dev [NULL] table 0 metric -1: This line indicates that a new route has been added for the IP address 10.8.0.1. The route will be accessed via the device with no name ([NULL]) and the IP address of the next hop on this route is 10.8.0.5. The route has been added to the main routing table (table 0) with a metric of -1.