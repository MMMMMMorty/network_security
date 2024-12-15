# IPV6

This lab aims to provide a clear understanding of IPv6 configuration and routing, focusing on:

- **Addressing**: How to assign and manage IPv6 addresses, including unique local addresses and dynamic allocation methods like SLAAC and DHCPv6.  
- **Routing**: Enabling IPv6 forwarding, setting static routes, and configuring router advertisements for network communication.  
- **Traffic Analysis**: Tools and techniques like `tcpdump`, `ping`, and `traceroute` to troubleshoot and verify IPv6 functionality.  
- **IPv6 over IPv4**: Setting up tunneling to ensure IPv6 connectivity in an IPv4-based environment.  

## 1

### 1.1 In Unique Local IPv6 Unicast Address space. how does a device know whether the IPv6 address it just created for itself is unique?

RFC 4193 Unique Local IPv6 Unicast Address 
Locally assigned Global IDs MUST be generated with a pseudo-random
algorithm consistent with [RANDOM].  Section 3.2.2 describes a
suggested algorithm.  It is important that **all sites generating Global IDs use a functionally similar algorithm** to ensure there is a
high probability of uniqueness.

The use of a pseudo-random algorithm to generate Global IDs in the
locally assigned prefix gives an assurance that any network numbered
using such a prefix is highly unlikely to have that address space
clash with any other network that has another locally assigned prefix
allocated to it.

This algorithm will result in a Global ID that is **reasonably unique**
and can be used to create a locally assigned Local IPv6 address
prefix.

### 1.2 Explain 3 methods of dynamically allocating IPv6 global unicast addresses?

There are two methods available for the dynamic configuration of IPv6 global unicast addresses.

Manualy

Stateless Address Autoconfiguration (SLAAC)

Dynamic Host Configuration Protocol for IPv6 (Stateful DHCPv6)

Option 1 - SLAAC Only – The device should use the prefix, prefix-length, and default gateway address information contained in the RA(router advertisement) message. No other information is available from a DHCPv6 server.

Option 1 (SLAAC Only) – "I'm everything you need (Prefix, Prefix-length, Default Gateway)"

Option 2 – SLAAC and DHCPv6 – The device should use the prefix, prefix-length, and default gateway address information in the RA message. There is other information available from a DHCPv6 server such as the DNS server address. The device will, through the normal process of discovering and querying a DHCPv6 server, obtain this additional information. This is known as stateless DHCPv6 because the DHCPv6 server does not need to allocate or keep track of any IPv6 address assignments, but only provide additional information such as the DNS server address.

Option 2 (SLAAC and DHCPv6) – "Here is my information but you need to get other information such as DNS addresses from a DHCPv6 server."

Option 3 – DHCPv6 only – The device should not use the information in this RA message for its addressing information. Instead, the device will use the normal process of discovering and querying a DHCPv6 server to obtain all of its addressing information. This includes an IPv6 global unicast address, prefix length, a default gateway address, and the addresses of DNS servers. In this case, the DHCPv6 server is acting as a stateful DHCP server similar to DHCP for IPv4. The DHCPv6 server allocates and keeps track of IPv6 addresses so it does not assign the same IPv6 address to multiple devices.

Option 3 (DHCPv6 Only) – "I can’t help you. Ask a DHCPv6 server for all your information."

## 2

### 2.1 What do the above sysctl commands do?

The net.ipv6.conf.all.forwarding flags are used to tell the system whether it can forward packets or not.

Configuring Linux to forward IPv6 packets

sudo sysctl -w net.ipv6.conf.default.forwarding=1 (default)
sudo sysctl -w net.ipv6.conf.all.forwarding=1  (all interfaces)

not allow enp0s3 to receive router advertisement

sudo sysctl -w net.ipv6.conf.enp0s3.accept_ra=0


### 2.2 The subnets used belong to Unique Local IPv6 Unicast Address space. Explain what this means and what is the format of such addresses.

The unique local address (ULA), which is the counterpart of IPv4 private addresses. Unique local addresses are also known as private IPv6 addresses or local IPv6 addresses.

ULA addresses can be used similarly to global unicast addresses but are for private use and should not be routed in the global Internet. 

only to be used in a more limited area, such as within a site or routed between a limited number of administrative domains.

![avatar](https://ptgmedia.pearsoncmg.com/images/chap4_9781587144776/elementLinks/04fig09_alt.jpg)
ULA addresses have the prefix fc00::/7, or the first 7 bits as 1111 110x. As shown in Figure 4-10, the eighth bit (x) is known as the L flag, or the local flag, and it can be either 0 or 1. This means that the ULA address range is divided into two parts:

fc00::/8 (1111 1100): When the L flag is set to 0, may be defined in the future.

fd00::/8 (1111 1101): When the L flag is set to 1, the address is locally assigned.

Because the only legitimate value for the L flag is 1, the only valid ULA addresses today are in the fd00::/8 prefix.

### 2.3 List all commands that you used to add static addresses to lab1, lab2 and lab3. Explain one of the add address commands.

lab3: sudo ip -6 address add fd01:2345:6789:abc2::0001/64 dev enp0s8

router:
    sudo ip -6 route add fd01:2345:6789:abc1:0000:0000:0000:0001 via fd01:2345:6789:abc2:0000:0000:0000:0002

lab2: sudo ip -6 address add fd01:2345:6789:abc1::0001/64 dev enp0s8

router:
    sudo ip -6 route add fd01:2345:6789:abc2:0000:0000:0000:0001 via fd01:2345:6789:abc1:0000:0000:0000:0002

lab1:

    sudo ip -6 address add fd01:2345:6789:abc1::0002/64 dev enp0s8
    sudo ip -6 address add fd01:2345:6789:abc2::0002/64 dev enp0s9

### 2.4 Show the command that you used to add the route to lab3 on lab2, and explain it.

lab3:
    sudo ip -6 route add fd01:2345:6789:abc1:0000:0000:0000:0001 via fd01:2345:6789:abc2:0000:0000:0000:0002

lab2: 
    sudo ip -6 route add fd01:2345:6789:abc2:0000:0000:0000:0001 via fd01:2345:6789:abc1:0000:0000:0000:0002


### 2.5 Show enp0s8 interface information from lab2, as well as the IPv6 routing table. Explain the IPv6 information from the interface and the routing table. What does a double colon (::) indicate?

!!!

valid fit: how long the ipv6 address

forever fit: 

it represent contiguous 16-bit fields of zeros.

### 2.6 Start tcpdump to capture ICMPv6 packets on each machine. From lab2, ping the lab1 and lab3 IPv6 addresses using ping6(8).. You should get a return packet for each ping you have sent. If not, recheck your network configuration. Show the headers of a successful ping return packet. Show ping6 output as well as tcpdump output.

listening

lab1 and lab3:
    sudo tcpdump -i enp0s8
lab2 to lab1: ping -6 fd01:2345:6789:abc1:0000:0000:0000:0002

lab3 to lab1: ping -6 fd01:2345:6789:abc2:0000:0000:0000:0002

lab2 to lab3:  ping -6 fd01:2345:6789:abc2:0000:0000:0000:0001

lab3 to lab2: ping -6 fd01:2345:6789:abc1:0000:0000:0000:0001

lab1 log:

    lab2 to lab1:
    22:28:08.298145 IP6 fd01:2345:6789:abc1::1 > lab1: ICMP6, echo request, seq 1, length 64
    22:28:08.298267 IP6 lab1 > fd01:2345:6789:abc1::1: ICMP6, echo reply, seq 1, length 64

    lab2 to lab3:
    22:28:13.368122 IP6 lab1 > fd01:2345:6789:abc1::1: ICMP6, neighbor solicitation, who has fd01:2345:6789:abc1::1, length 32
    22:28:13.368254 IP6 fd01:2345:6789:abc1::1 > lab1: ICMP6, neighbor advertisement, tgt is fd01:2345:6789:abc1::1, length 24
    22:29:08.962811 IP6 fd01:2345:6789:abc1::1 > fd01:2345:6789:abc2::1: ICMP6, echo request, seq 1, length 64
    22:29:08.963432 IP6 fd01:2345:6789:abc2::1 > fd01:2345:6789:abc1::1: ICMP6, echo reply, seq 1, length 64

## 3

lab2 and lab3:
    sudo ifconfig enp0s8 down
lab1:
    sudo apt install radvd
radvd.conf

    interface enp0s8
    {
    MinRtrAdvInterval 3;
    MaxRtrAdvInterval 4;
    AdvSendAdvert on;
    AdvManagedFlag on;
    prefix fd01:2345:6789:abc1::/64
    { AdvValidLifetime 14300; AdvPreferredLifetime 14200; }
    ;
    };
    interface enp0s9
    {
    MinRtrAdvInterval 3;
    MaxRtrAdvInterval 4;
    AdvSendAdvert on;
    AdvManagedFlag on;
    prefix fd01:2345:6789:abc2::/64
    { AdvValidLifetime 14300; AdvPreferredLifetime 14200; }
    ;
    };
    
    sudo service radvd restart

    systemctl status radvd
lab1:
    sudo tcpdump -i enp0s8

    sudo tcpdump -i enp0s9

lab2:
    sudo tcpdump -i enp0s8
lab2 and lab3
    sudo ifconfig enp0s8 up
lab2 log

    08:18:57.342063 IP6 _gateway > ip6-allnodes: ICMP6, router advertisement, length 56
    08:18:57.351235 IP6 lab2 > ff02::16: HBH ICMP6, multicast listener report v2, 1 group record(s), length 28
    08:18:57.351670 IP6 _gateway > ff02::16: HBH ICMP6, multicast listener report v2, 5 group record(s), length 108
    08:18:57.695156 IP6 _gateway > ff02::16: HBH ICMP6, multicast listener report v2, 5 group record(s), length 108
    08:18:58.024164 IP6 lab2 > ff02::16: HBH ICMP6, multicast listener report v2, 1 group record(s), length 28

    ping -6 fd01:2345:6789:abc1:a00:27ff:fe70:a406

### 3.1 Explain your modifications to radvd.conf. Which options are mandatory?

Prefix (needed)  It must be noted that the prefix must be /64. This is because 64 bits are used to generate the last part of the address using the network cards ID

Lifetime of the prefix

Frequency of sending advertisements (optional)

interface name {    list of interface specific options
    list of prefix definitions
    list of clients (IPv6 addresses) to advertise to
    list of route definitions
    list of RDNSS definitions
};

radvd.conf

    interface enp0s8
    {
    MinRtrAdvInterval 3;
    MaxRtrAdvInterval 4;
    AdvSendAdvert on;
    AdvManagedFlag on;
    prefix fd01:2345:6789:abc1::/64
    { AdvValidLifetime 14300; AdvPreferredLifetime 14200; }
    ;
    };
    interface enp0s9
    {
    MinRtrAdvInterval 3;
    MaxRtrAdvInterval 4;
    AdvSendAdvert on;
    AdvManagedFlag on;
    prefix fd01:2345:6789:abc2::/64
    { AdvValidLifetime 14300; AdvPreferredLifetime 14200; }
    ;
    };

optional:
AdvManagedFlag - This option specifies whether hosts on the network should use stateless address autoconfiguration to obtain IPv6 addresses.

AdvOtherConfigFlag - This option specifies whether hosts on the network should obtain additional configuration information, such as DNS server addresses, through stateless autoconfiguration.

AdvRouterAddr - This option specifies whether the router address should be included in the router advertisement.

mandatory:

interface - This option specifies the network interface that radvd will use to advertise router and prefix information.

AdvSendAdvert - This option specifies whether radvd should send periodic router advertisements.

prefix - This option specifies the IPv6 prefix that radvd should advertise on the network.

### 3.2 Analyze captured packets and explain what happens when you set up the interface on lab2

    tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
    listening on enp0s8, link-type EN10MB (Ethernet), capture size 262144 bytes
    11:13:37.012563 IP6 _gateway > ip6-allnodes: ICMP6, router advertisement, length 56
    11:13:37.025829 IP6 _gateway > ff02::16: HBH ICMP6, multicast listener report v2, 5 group record(s), length 108
    11:13:37.027645 IP6 lab2 > ff02::16: HBH ICMP6, multicast listener report v2, 1 group record(s), length 28
    11:13:37.207376 IP6 lab2 > ff02::16: HBH ICMP6, multicast listener report v2, 1 group record(s), length 28
    11:13:37.803310 IP6 _gateway > ff02::16: HBH ICMP6, multicast listener report v2, 5 group record(s), length 108
    11:13:38.031703 IP6 :: > ff02::1:ff70:a406: ICMP6, neighbor solicitation, who has lab2, length 32
    11:13:41.016688 IP6 _gateway > ip6-allnodes: ICMP6, router advertisement, length 56
    
    08:18:57.342063 IP6 _gateway > ip6-allnodes: ICMP6, router advertisement, length 56 (radvd periodically multicasts RA packets to the attached link to update network hosts)
    08:18:57.351235 IP6 lab2 > ff02::16: HBH ICMP6, multicast listener report v2, 1 group record(s), length 28  ( Sent by lab2 when joining a multicast group)
    08:18:57.351670 IP6 _gateway > ff02::16: HBH ICMP6, multicast listener report v2, 5 group record(s), length 108 (update the state of the multicast listeners, or their interfaces.)

In addition, radvd periodically multicasts RA packets to the attached link to update network hosts.

These messages are sent to all the nodes to report (to neighboring routers) the current status of the multicast listeners or to change the state of the multicast listeners, or their interfaces.

### 3.3 How is the host-specific part of the address determined in this case?

With these advertisements hosts can automatically configure their addresses and some other parameters.

The host-specific part of theaddress is determined by the host generating a random interfaceidentifier (llD) and concatenating it with the prefix obtained from therouter advertisement. The llD isusually generated from the MACaddress of the interface

### 3.4 Show and explain the output of a traceroute(1) from lab2 to lab3.

    sudo traceroute -6 fd01:2345:6789:abc2:a00:27ff:feac:9420

    traceroute to fd01:2345:6789:abc2:a00:27ff:feac:9420 (fd01:2345:6789:abc2:a00:27ff:feac:9420), 30 hops max, 80 byte packets
    1  fd01:2345:6789:abc1:a00:27ff:fe6d:d98f (fd01:2345:6789:abc1:a00:27ff:fe6d:d98f)  2.995 ms  3.381 ms  3.172 ms (go to lab1 enp0s8 first)
    2  fd01:2345:6789:abc2:a00:27ff:feac:9420 (fd01:2345:6789:abc2:a00:27ff:feac:9420)  6.508 ms  6.331 ms  7.156 ms (from lab1 enp0s8 to lab3)

## 4  Cofigure IPv6 over IPv4

### 4.1 

lab3
    sudo sysctl -w net.ipv6.conf.default.forwarding=1
    sudo sysctl -w net.ipv6.conf.all.forwarding=1
    sudo sysctl -w net.ipv4.ip_forward=1

    sudo ip6tables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE
    sudo iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

    ping6 ipv6.google.com

lab3
    sudo ip -6 route del default via fe80::1 dev enp0s8
    sudo ip -6 route add default via 2001:708:30:15b0::e dev enp0s8 (tracert -6 2a00:1450:400f:803::200e)


    sudo modprobe sit

    sudo ip tunnel add 6rd mode sit local 192.168.2.1 ttl 64   

    sudo ip tunnel 6rd dev 6rd 6rd-prefix 2001:db8::/32

    printf "%02x%02x:%02x%02x\n" 192 168 1 1 --> c0a8:0101

    sudo ip tunnel add 6rd mode sit local 192.168.2.1 ttl 64
    sudo ip tunnel 6rd dev 6rd 6rd-prefix 2001:db8::/32
    sudo ip addr add 2001:db8:c0a8:0201::1/32 dev 6rd
    sudo ip link set 6rd up
    sudo ip route add fd01:2345:6789:abc1::/64 via ::192.168.1.1 dev 6rd
    sudo ip route add fd01:2345:c0a8:0101::/64 via ::192.168.1.1 dev 6rd


lab1
    sudo sysctl -w net.ipv6.conf.default.forwarding=1
    sudo sysctl -w net.ipv6.conf.all.forwarding=1
    sudo sysctl -w net.ipv4.ip_forward=1
    sudo ip route del default via 10.0.2.2
    sudo route add default via 192.168.1.2 dev enp0s8
    sudo modprobe sit
    sudo ip tunnel add 6rd mode sit local 192.168.1.1 ttl 64
    sudo ip tunnel 6rd dev 6rd 6rd-prefix 2001:db8::/32
    sudo ip addr add 2001:db8:c0a8:0101::1/32 dev 6rd
    ip link set 6rd up
    sudo ip route add ::/0 via ::192.168.2.1 dev 6rd

lab2

    sudo ip route add ::/0 via fd01:2345:6789:abc1::1 dev enp0s8

lab4

    sudo ip route add ::/0 via fd01:2345:6789:abc2::1 dev enp0s8

### 4.1 Show that you can ping6 lab2 from lab4

    ping6 fd01:2345:6789:abc1::2

### 4.2 Show that you can ping 8.8.8.8 from lab1 and lab4

    lab1:
    sudo ip route del default via 10.0.2.2
    sudo route add default via 192.168.1.2 dev enp0s8
    ping 8.8.8.8

    lab3:
    sudo /sbin/ip tunnel add dev4in6 mode ip4ip6 remote fd01:2345:6789:abc2::2 local fd01:2345:6789:abc2::1
    sudo /sbin/ip link set dev dev4in6 up
    sudo /sbin/ip -6 route add  fd01:2345:6789:abc2:: dev dev4in6 metric 1
    sudo ip addr add 10.0.3.5/24 dev dev4in6

    
    lab4:
    sudo ip route add 0/0 nexthop via inet6 fd01:2345:6789:abc2::1 dev enp0s8

    sudo /sbin/ip tunnel add dev4in6 mode ip4ip6 remote fd01:2345:6789:abc2::1 local fd01:2345:6789:abc2::2
    sudo /sbin/ip link set dev dev4in6 up 
    sudo /sbin/ip -6 route add  fd01:2345:6789:abc2:: dev dev4in6 metric 1
    sudo ip addr add 10.0.3.10/24 dev dev4in6
    sudo ip route add default via 10.0.3.10/24 dev dev4in6

### 4.3 Show that you can open https://ipv6.google.com/ on lab4.
    
    sudo apt install lynx
    lynx -dump https://ipv6.google.com/
lab4 
    ping6 ipv6.google.com

### 4.4 Explain your solution, why did you use this method over the other options

NAT64: I tried Jool and tayga, the doucument is not so good, and it is complicated.

DNS64: I built one but it didnt work well bind9

6to4: Every side/host with an public IPv4 address is able to use 6to4 IPv6 for everyone

6rd is easy and simple to use it. 6rd is a technology that enables the rapid deployment of IPv6 by encapsulating IPv6 packets inside IPv4 packets, allowing them to traverse an IPv4-only network.  IPv6 Rapid Deployment on IPv4 Infrastructures

### 4.5 Are there security issues with your solution? what and how to fix them

One of the main security concerns with 6rd is the potential for spoofing attacks. Because 6rd tunnels encapsulate IPv6 packets inside IPv4 packets, an attacker could potentially spoof the IPv4 header and send malicious traffic to the destination. This could result in a denial of service attack or compromise of the target system.

1. Implement IPsec: One of the most effective ways to secure 6rd traffic is to use IPsec (Internet Protocol Security). IPsec provides end-to-end encryption and authentication of IP packets, ensuring that only authorized parties can access the traffic.

2. Implement firewall rules: Configure firewall rules to limit the types of traffic that can be sent over the 6rd tunnel. This can help prevent attacks by blocking unauthorized traffic and limiting the attack surface.