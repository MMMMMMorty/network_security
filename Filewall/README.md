# Firewall

The aim of this lab is to configure and understand various aspects of network security and routing using Linux-based networking tools. It involves setting up a router with multiple interfaces, configuring IP forwarding, implementing firewall rules using nftables, and managing network traffic through packet filtering. Additionally, the lab demonstrates the use of transparent web proxy servers and examines their impact on HTTP traffic.

## 2. Set up the network

### 2.1 List all commands you used to create the router setup, and briefly explain what they do. Show the results of the traceroute as well.

        sudo ip route add 192.168.0.0/24 via 192.168.2.1 dev enp0s8 
        sudo ip route add 192.168.2.0/24 via 192.168.0.1 dev enp0s8 

        sudo sysctl -w net.ipv4.ip_forward=1   # This command enables IP forwarding on the system. When IP forwarding is enabled, the Linux kernel will forward packets from one network interface to another if the destination IP address is not on the same subnet as the source IP address.

        sudo sysctl -w net.ipv4.conf.enp0s8.forwarding=1  # This command enables IP forwarding on the “enp0s8” network interface. When IP forwarding is enabled, the Linux kernel will forward packets from one network interface to another if the destination IP address is not on the same subnet as the source IP address.

        sudo sysctl -w net.ipv4.conf.enp0s9.forwarding=1 # This command enables IP forwarding on the “enp0s9” network interface.
        sudo sysctl -w net.ipv4.conf.enp0s8.proxy_arp=1 # This command enables proxy ARP on the “enp0s8” network interface. Proxy ARP allows a system to respond to ARP requests on behalf of another system. This is useful when a network device needs to communicate with a remote device that is not on the same subnet.
        sudo sysctl -w net.ipv4.conf.enp0s9.proxy_arp=1 This command enables proxy ARP on the “enp0s9” network interface.

what is arp?

        In computer networking, proxy ARP (Address Resolution Protocol) is a technique by which a device on a given network answers the ARP queries for an IP address that is not on that network. The ARP request is received by the proxy ARP device, which then responds with its own MAC address. The requesting device then sends packets to the proxy ARP device, which forwards them to the actual destination

See scripts

    traceroute lab3
    traceroute to lab3 (192.168.2.2), 30 hops max, 60 byte packets
    1  lab1 (192.168.0.1)  0.496 ms  0.940 ms  0.520 ms
    2  lab3 (192.168.2.2)  1.719 ms  1.381 ms  1.374 ms

### 2.2 Explain Tables ,chains, hooks and rules in nftables?

nftables replaces the popular {ip,ip6,arp,eb}tables. This software provides a new in-kernel packet classification framework that is based on a network-specific Virtual Machine (VM) and a new nft userspace command line tool. nftables reuses the existing Netfilter subsystems such as the existing hook infrastructure, the connection tracking system, NAT, userspace queueing and logging subsystem

1. Tables: Tables are containers for chains, sets and stateful objects. They are identified by their address family and their name. The address family must be one of ip, ip6, inet, arp, bridge, netdev.Tables are the top-level structure in nftables that contain chains of rules. There are five different types of tables in nftables:

        ip: Matches only IPv4 packets. This is the default if you do not specify an address family.
         ip6: Matches only IPv6 packets.
         inet: Matches both IPv4 and IPv6 packets.
         arp: Matches IPv4 address resolution protocol (ARP) packets.
         bridge: Matches packets that traverse a bridge device.
         netdev: Matches packets from ingress.

2. Chains: Chains are sets of rules that are executed in a specific order. Chains are containers for rules. They exist in two kinds, base chains and regular chains. A base chain is an entry point for packets from the networking stack, a regular chain may be used as jump target and is used for better rule organization. Each chain is associated with a specific table and a specific hook, which determines when the chain is executed. There are three types of chains in nftables:


      filter, which is used to filter packets. This is supported by the arp, bridge, ip, ip6 and inet table families.
      route, which is used to reroute packets if any relevant IP header field or the packet mark is modified. If you are familiar with iptables, this chain type provides equivalent semantics to the mangle table but only for the output hook (for other hooks use type filter instead). This is supported by the ip, ip6 and inet table families.
      nat, which is used to perform Networking Address Translation (NAT). Only the first packet of a given flow hits this chain; subsequent packets bypass it. Therefore, never use this chain for filtering. The nat chain type is supported by the ip, ip6 and inet table families.

3. Hooks: Hooks determine when chains are executed. There are five types of hooks in nftables:

        prerouting: This hook is executed when traffic enters the network interface and is destined for the local system.
        input: This hook is executed when traffic enters the network interface and is destined for the local system.
        forward: This hook is executed when traffic passes through the firewall and is neither input nor output traffic.
        output: This hook is executed when traffic is sent out by the network interface.
        postrouting: This hook is executed when traffic leaves the network interface and is destined for another system.

4. Rules: Rules are the individual firewall rules that are applied to the traffic. Each rule is associated with a specific chain and is executed when the conditions of the rule are met. Rules can filter traffic based on a variety of factors, including IP address, port number, and protocol type.

## 3. Implement packet filtering on the router


### 3.1 List the services that were found scanning the machines with and without the firewall active. Explain the differences in how the details of the system were detected

      # without firewall lab2
      nmap lab3
      Starting Nmap 7.80 ( https://nmap.org ) at 2023-03-21 19:14 UTC
      Nmap scan report for lab3 (192.168.2.2)
      Host is up (0.0056s latency).
      Other addresses for lab3 (not scanned): 192.168.2.2
      Not shown: 999 closed ports
      PORT   STATE SERVICE
      22/tcp open  ssh

      Nmap done: 1 IP address (1 host up) scanned in 0.20 seconds

      # without firewall lab2
      nmap lab2
      Starting Nmap 7.80 ( https://nmap.org ) at 2023-03-23 14:33 UTC
      Nmap scan report for lab2 (192.168.0.2)
      Host is up (0.0019s latency).
      Not shown: 999 closed ports
      PORT   STATE SERVICE
      22/tcp open  ssh

      Nmap done: 1 IP address (1 host up) scanned in 0.22 seconds

      # with firewall lab3
      nmap lab2
      Starting Nmap 7.80 ( https://nmap.org ) at 2023-03-23 14:34 UTC
      Nmap scan report for lab2 (192.168.0.2)
      Host is up (0.0011s latency).
      Not shown: 594 filtered ports, 405 closed ports
      PORT   STATE SERVICE
      22/tcp open  ssh

      Nmap done: 1 IP address (1 host up) scanned in 2.71 seconds

      # with firewall lab2
      nmap lab3
      Starting Nmap 7.80 ( https://nmap.org ) at 2023-03-23 14:37 UTC
      Nmap scan report for lab3 (192.168.2.2)
      Host is up (0.0015s latency).
      Other addresses for lab3 (not scanned): 192.168.2.2
      Not shown: 940 filtered ports, 57 closed ports
      PORT   STATE SERVICE
      21/tcp open  ftp
      22/tcp open  ssh
      80/tcp open  http

      Nmap done: 1 IP address (1 host up) scanned in 3.75 seconds

1. namp lab3

      In the first scenario, where the firewall is not enabled on lab3, Nmap was able to detect that port 22 (SSH) was open on lab3, and the scan report showed that the host is up with low latency. This is because without the firewall, all incoming traffic to port 22 is allowed by default, and therefore Nmap was able to establish a connection to the SSH service on lab3 and determine that the port was open.

      In the second scenario, where the firewall is enabled on lab2, Nmap was only able to detect that port 22 was open on lab2, and the scan report showed that many ports were filtered or closed. This is because the firewall on lab2 was blocking incoming traffic to many ports, including the ones that Nmap was attempting to scan. As a result, Nmap was unable to establish a connection to most of the ports on lab2 and could not determine whether they were open or closed. Only the port that was explicitly allowed by the firewall rules (port 22 for SSH) was detected as open.

2. nmap lab2

      In the first scenario, where the firewall is not enabled on lab3, Nmap was able to detect that port 22 is open and running the SSH service on lab3.

      In the second scenario, where the firewall is enabled on lab3, Nmap is reporting that it found 3 open ports: 21 (FTP), 22 (SSH), and 80 (HTTP). However, it also shows that 940 ports are being filtered and 57 are closed.

      This indicates that the firewall is blocking Nmap from detecting many ports on lab3. When a port is filtered, it means that the firewall is actively blocking access to that port, while a closed port means that there is no active service listening on that port.

### 3.2 List the commands used to implement the ruleset with explanations.

               chain forward{
                        type filter hook forward priority 0;
                        policy drop;
                        iffname enp0s8 ip saddr 192.168.0.2 icmp type echo-request counter accept
                        offname enp0s8 ip daddr 192.168.0.2 icmp type echo-reply counter accept
                        ip saddr $lab2 tcp dport 22 accept
                        ip daddr $lab2 tcp sport 22 accept
                        ip saddr $lab2 tcp dport 49152-65534 accept
                        ip daddr $lab2 tcp sport 49152-65534 accept
                        ip saddr $lab2 tcp dport { 20, 21 } accept
                        ip daddr $lab2 tcp sport { 20, 21 } accept
                        ip saddr $lab2 tcp dport { 80, 443 } accept
                        ip daddr $lab2 tcp sport { 80, 443 } accept
              }

### 3.3 Create a few test cases to verify your ruleset. Run the tests and provide minimal, but sufficient snippets of iptables' or tcpdump's logs to support your test results.

        #lab3
        sudo tcpdump host lab2 -i enp0s8
        #lab2
        lynx lab3:80
        ftp lab3
        #ls
        #put test.txt test.txt
        #ls
        #passive 
        #put test2.txt test2.txt
        #ls

### 3.4 Explain the difference between netfilter DROP and REJECT targets. Test both of them, and explain your findings.

In nftables, DROP and REJECT are two actions that can be used to block traffic. The main difference between these two targets is in the response that the sender receives when its traffic is blocked.

When a packet is matched by a DROP rule, the packet is silently discarded by the firewall, and the sender doesn't receive any response. It's as if the packet was never sent in the first place. From the sender's perspective, it appears as if the packet was lost somewhere on the network.

On the other hand, when a packet is matched by a REJECT rule, the firewall sends a response to the sender indicating that its traffic was blocked. This response can take different forms, depending on the protocol being used. For example, for TCP traffic, the firewall sends a TCP RST (reset) packet to indicate that the connection was refused. For UDP traffic, the firewall sends an ICMP Port Unreachable message.

In other words, DROP silently discards the traffic, while REJECT sends a response to the sender indicating that its traffic was blocked.

In terms of security, DROP is generally considered more secure because it doesn't reveal any information to the sender. On the other hand, REJECT can be useful for troubleshooting, because it provides feedback to the sender that its traffic was blocked and can help identify the source of the problem. However, this can also be used by attackers to gather information about the network and its security measures.

Reject ssh:
        tcp dport 22 reject
        tcp sport 22 reject

Result:
        ssh vagrant@lab3
        ssh: connect to host lab3 port 22: Connection refused

Drop ssh:
        tcp dport 22 drop
        tcp sport 22 drop

No result

## 4. Implement a web proxy

### 4.1 List the commands you used to send the traffic to the proxy with explanations.

        sudo vim /etc/nftables.conf
         # table ip filter{
         #         chain prerouting{
         #                 type nat hook prerouting priority 0;
         #                 policy accept;
         #                 iifname $NET ip saddr 192.168.0.2 tcp dport 80 redirect to :8000
         #         }
         # }

         # sudo nft add table ip filter
         # sudo nft add chain ip filter prerouting { type nat hook prerouting priority 0 \; policy accept\;}
         # sudo nft add rule ip filter prerouting iifname enp0s8 ip saddr 192.168.0.2 tcp dport 80 redirect to :8000

        curl -I http://lab3

        -I, --head
              (HTTP FTP FILE) Fetch the headers only! HTTP-servers feature the
              command HEAD which this uses to get nothing but the header of  a
              document.  When  used  on an FTP or FILE file, curl displays the
              file size and last modification time only.

              Example:
               curl -I https://example.com

        http://
              Makes it use it as an HTTP proxy. The default if no scheme  pre-
              fix is used.

### 4.2 Show and explain the changes you made to the squid.conf.

        http_port 8080 transparent
        http_port 3128
        acl lan src lab2
        http_access allow lan
        <!-- http_access allow all -->
        http_reply_access allow all

        # deny destination lab3
        # acl lab3 dstdomain lab3
        # never_direct allow lab3

### 4.3 What is a transparent proxy?

A transparent proxy is a type of proxy server that intercepts and redirects all or some of the communication between a client and a server without requiring any configuration on the client side. It works by intercepting network traffic and forwarding it to the proxy server, which can then modify or filter the requests and responses as needed before forwarding them to their destination.

Transparent proxies are often used in corporate networks to enforce security policies, such as blocking certain websites or filtering out malicious content. They can also be used to optimize network performance by caching frequently accessed content, reducing bandwidth usage, and improving response times for clients.

From the client's perspective, a transparent proxy is invisible, meaning that the user is not aware that their network traffic is being intercepted and filtered. The client's requests are simply forwarded to the proxy server, which acts as an intermediary between the client and the destination server.

### 4.4 List the differences in HTTP headers after setting up the proxy. What has changed?

        curl -I lab3
        HTTP/1.1 200 OK
        Date: Thu, 23 Mar 2023 15:12:39 GMT
        Server: Apache/2.4.52 (Ubuntu)
        Last-Modified: Thu, 23 Mar 2023 12:18:06 GMT
        ETag: "29af-5f79044e69d36"
        Accept-Ranges: bytes
        Content-Length: 10671
        Vary: Accept-Encoding
        Content-Type: text/html

        curl -I http://lab3
        HTTP/1.1 200 OK
        Date: Thu, 23 Mar 2023 18:30:02 GMT
        Server: Apache/2.4.52 (Ubuntu)
        Last-Modified: Thu, 23 Mar 2023 12:18:06 GMT
        ETag: "29af-5f79044e69d36"
        Accept-Ranges: bytes
        Content-Length: 10671
        Vary: Accept-Encoding
        Content-Type: text/html
        X-Cache: MISS from lab1
        X-Cache-Lookup: MISS from lab1:8080
        Via: 1.1 lab1 (squid/5.2)
        Connection: keep-alive

        HTTP/1.1 200 OK
        Date: Sun, 26 Mar 2023 07:14:34 GMT
        Server: Apache/2.4.41 (Ubuntu)
        Last-Modified: Sun, 26 Mar 2023 06:12:49 GMT
        ETag: "2aa6-5f7c78412f89f"
        Accept-Ranges: bytes
        Content-Length: 10918
        Vary: Accept-Encoding
        Content-Type: text/html
        Age: 188
        X-Cache: HIT from lab1
        X-Cache-Lookup: HIT from lab1:3128
        Via: 1.1 lab1 (squid/5.2)
        Connection: keep-alive

        X-Cache: MISS from lab1: This header indicates that the requested URL was not found in the proxy cache on the server at lab1. The value MISS means that the cache lookup failed to find a matching response.

        X-Cache-Lookup: MISS from lab1:8080: This header provides more information about the cache lookup process. The value MISS again means that the cache lookup failed, while lab1:8080 refers to the hostname and port number of the proxy server that performed the lookup.

        Via: 1.1 lab1 (squid/5.2): This header identifies the proxy server that processed the request and indicates that the HTTP version used was 1.1. lab1 is the hostname of the proxy server, while squid/5.2 is the name and version number of the proxy software that was used. Via header may be added by the proxy to indicate that the request has been forwarded through it

        Connection: keep-alive: This header indicates that the connection between the client and the server will remain open after the response is sent, allowing for additional requests to be sent over the same connection in the future.

        The response header has an additional line: Age: 188, which indicates that the response was cached by squid on lab1 for 188 seconds.

## 5. Implement a DMZ

### 5.1 Demonstrate you can browse the Apache webserver from your host and lab3. Demonstrate you cannot ping from lab2 to lab3

Demonstrate you can browse the Apache webserver from your host and lab3

        # host 
        vagrant ssh lab1 -- -L  8080:localhost:8080
        localhost:8080

        browse the Apache webserver from your host
        # host
        127.0.0.1:8080
        #lab3
        lynx lab2:80

Demonstrate you cannot ping from lab2 to lab3

        # lab2
        ping lab3

### 5.2 List the commands you used to set up the DMZ in nftables. You must show the prerouting, postrouting , forward, input and output chains.

setting in nftables

        #!/usr/sbin/nft -f

        flush ruleset
        define INT_DEV=enp0s3
        define NET=enp0s8
        define LAN_DEV=enp0s9
        table inet filter {
                chain input {
                        type filter hook input priority 0;
                }
                chain forward {
                        type filter hook forward priority 0;
                }
                chain output {
                        type filter hook output priority 0;
                }
        }

        table ip filter{
               chain forward{
                        type filter hook forward priority 0;
                        policy drop;
                        # question 3 needs it
                        #ip saddr 192.168.0.2 icmp type echo-request counter accept
                        #ip daddr 192.168.0.2 icmp type echo-reply counter accept
                        ip saddr $lab2 tcp dport 22 accept
                        ip daddr $lab2 tcp sport 22 accept
                        ip saddr $lab2 tcp dport 49152-65534 accept
                        ip daddr $lab2 tcp sport 49152-65534 accept
                        ip saddr $lab2 tcp dport { 20, 21 } accept
                        ip daddr $lab2 tcp sport { 20, 21 } accept
                        ip saddr $lab2 tcp dport { 80, 443 } accept
                        ip daddr $lab2 tcp sport { 80, 443 } accept
                        ip saddr $lab3 ip daddr $lab2 accept
                        ip saddr $lab2 ip daddr $lab3 ct state established accept
              }
                chain prerouting{
                        type nat hook prerouting priority 0;
                        policy accept;
                        iifname $NET ip saddr 192.168.0.2 tcp dport 80 redirect to :8000
                        dport 8080 dnat 192.168.0.2:80
                }
                chain postrouting {
                        type nat hook postrouting priority srcnat;
                        policy accept;
                        # SNAT for IPv4 traffic to Internet
                        oifname $INT_DEV masquerade
                }
        }

        # add virtual box forwarding port
        sudo nft -f /etc/nftables.conf
