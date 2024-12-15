# DNS Server

This exercise is designed to teach you about setting up and configuring a DNS server with various functionalities:

1. Logging Configuration: Understanding how to log DNS queries and manage logging configurations for monitoring and debugging purposes.

2. Caching-only Nameserver (Forwarding): Learning how to set up a DNS server to act as a caching-only server that forwards queries to other DNS servers. This is useful for enhancing DNS query performance and privacy.

3. Creating a New Top-Level Domain (TLD): Gaining experience in setting up and managing custom TLDs, which allows you to manage DNS records for your own domain namespace.

4. Creating a Slave DNS Server: Demonstrating how to set up a secondary (slave) DNS server to allow for redundancy and load balancing in DNS management. This is crucial for ensuring high availability and disaster recovery.

5. Subdomain Configuration: Understanding how to add subdomains to an existing DNS server, which is useful for organizing different sections of a domain or managing different services under different subdomains.

## 1. Monitor log

Add the log:

chown bind:bind /var/log/bind9/query.log
/var/log/bind9/query.log rw,
Stanza to /etc/apparmor.d/usr.sbin.named, restart apparmor and bind services, and you're good to go.

All the ns1 needs -p 5353


## 2. Caching-only nameserver （Forwarding (a.k.a Proxy) Name Servers

### 2.1 Explain the configuration you used.

configuration : ns1 /etc/bind/named.conf.options

change the nameserver for ns1 and client : /etc/resolv.conf

    nameserver 192.168.1.2
    search ns1

check it in client.sh and ns1.sh

dig is a flexible tool for interrogating DNS name servers. It performs DNS lookups and displays the answers that are returned from the name server(s) that were queried.

    dig linuxfoundation.org -p 5353

    ; <<>> DiG 9.16.1-Ubuntu <<>> linuxfoundation.org
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 41267
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ; COOKIE: 8d6daf36041331a00100000063f1ec5ce9d6d52cefe8fd24 (good)
    ;; QUESTION SECTION:
    ;linuxfoundation.org.           IN      A

    ;; ANSWER SECTION:
    linuxfoundation.org.    560     IN      A       3.13.31.214

    ;; Query time: 0 msec
    ;; SERVER: 192.168.1.2#53(192.168.1.2)
    ;; WHEN: Sun Feb 19 09:31:06 UTC 2023
    ;; MSG SIZE  rcvd: 92

Nslookup is a program to query Internet domain name servers.

    nslookup linuxfoundation.org

    Server:         192.168.1.2
    Address:        192.168.1.2#53

    Non-authoritative answer:
    Name:   linuxfoundation.org
    Address: 3.13.31.214

### 2.2 What is a recursive query? How does it differ from an iterative query?

A recursive query is one where the DNS server will fully answer the query (or give an error).  DNS servers are not required to support recursive queries and both the resolver (or another DNS acting recursively on behalf of another resolver) negotiate use of recursive service using a bit (RD) in the query header.

A Iterative (or non-recursive) query is one where the DNS server may provide an answer or a partial answer (a referral) to the query (or give an error). All DNS servers must support non-recursive (Iterative) queries. 

An Iterative query is technically simply a normal DNS query that does not request Recursive Services.

![avatar](https://www.zytrax.com/books/dns/ch2/recursive-query.png)

## 3. Create your own tld .insec

### 3.1 Explain your configuration.

/etc/bind/zones/forward.insec

    ;
    ; BIND data file for local loopback interface
    ;
    $TTL    60s
    ; Start of Authority RR defining the key characteristics of the zone (domain)
    @       IN      SOA     ns.insec. hostmaster.insec. (
                                1         ; Serial
                            60s         ; Refresh
                            60s         ; Retry
                            2419200         ; Expire
                            604800 )       ; Negative Cache TTL
    ;

    ; name server RR for the domain
            IN      NS      ns1.insec.
    ; the second name server is external to this zone (domain)
    ;          IN      NS      ns2.example.net.

    ; domain hosts includes NS and MX records defined above
    ; plus any others required
    ; for instance a user query for the A RR of joe.example.com will
    ; return the IPv4 address 192.168.254.6 from this zone file
    ns1        IN      A       192.168.1.2
    ns2        IN      A       192.168.1.1
    ; ns3        IN      A       192.168.1.3
    ; client     IN      A       192.168.1.4

/etc/bind/zones/reverse.insec

    ;
    ; BIND reverse data file for local loopback interface
    ;
    $TTL    60s
    @       IN      SOA     ns1.insec. hostmaster.insec. (
                                1         ; Serial
                            60s         ; Refresh
                            60s         ; Retry
                            2419200         ; Expire
                            604800 )       ; Negative Cache TTL
    ;

    ; Name Server Info for ns1.insec
    @       IN      NS      ns1.insec.
    ns1     IN      A      192.168.1.2


    ; Reverse DNS or PTR Record for ns1.insec
    ; Using the last number of DNS Server IP address: 192.168.1.2
    2      IN      PTR     ns1.insec.


    ; Reverse DNS or PTR Record for ns2.insec
    ; Using the last block IP address: 192.168.1.1
    1      IN      PTR     ns2.insec.
    ;3      IN      PTR     ns3.insec.
    ;4      IN      PTR     client.insec.

/etc/bind/named.conf.default-zones

This configuration defines the forward zone (/etc/bind/zones/forward.insec), and the reverse zone (/etc/bind/zones/reverse.insec) for the insec domain name.

    zone "insec" {
        type master;
        file "/etc/bind/zones/forward.insec";
    };

    zone "1.168.192.in-addr.arpa" {
        type master;
        file "/etc/bind/zones/reverse.insec";
    };


    # Checking the main configuration for BIND
    sudo named-checkconf

    # Checking forward zone forward.insec
    sudo named-checkzone insec /etc/bind/zones/forward.insec

    # Checking reverse zone reverse.insec
    sudo named-checkzone insec /etc/bind/zones/reverse.insec

restart service

    # Restart named service
    sudo systemctl restart named

    # Verify named service
    sudo systemctl status named

### 3.2 Provide the output of dig(1) for a successful query.

Test the result in client

    dig @192.168.1.2 ns2.insec -p 5353

    ;; ANSWER SECTION:
    ns2.insec.              60      IN      A       192.168.1.1

### 3.3 How would you add an IPv6 address entry to a zone file?

Edit the appropriate DNS zone file by adding AAAA records for each IPv6–enabled host, as follows.
    host-name  IN   AAAA 	host-address(ipv6)
Edit the DNS reverse zone file and add PTR records, using the following format.
    host-address(ipv6) IN   PTR   host-name


## 4. Create a slave server for .insec

### 4.1 Demonstrate the successful zone file transfer.

default-zones

    zone "insec" {
        type master;
        file "/etc/bind/zones/forward.insec";
        allow-transfer {192.168.1.1;};
    };

For slave

ns2 uses the same options

default-zones:

    zone "insec" in{
    type slave;
    file "/var/lib/bind/slave/slave.insec";
    masters {192.168.1.2;};
    };

    sudo chmod 777 /var/lib/bind/slave/

    sudo systemctl restart named

### 4.2 Explain the changes you made.

forward.insec
    ; the second name server is external to this zone (domain)
            IN      NS      ns2.insec.

    ; domain hosts includes NS and MX records defined above
    ; plus any others required
    ; for instance a user query for the A RR of joe.example.com will
    ; return the IPv4 address 192.168.254.6 from this zone file
    ns2        IN      A       192.168.1.1

reverse.insec
    ; Reverse DNS or PTR Record for ns2.insec
    ; Using the last block IP address: 192.168.1.1
    1      IN      PTR     ns2.insec.

default-zones

    zone "insec" {
        type master;
        file "/etc/bind/zones/forward.insec";
        allow-transfer {192.168.1.1;};
    };

For slave

ns2 uses the same options

default-zones:

    zone "insec" in{
    type slave;
    file "/var/lib/bind/slave/slave.insec";
    masters {192.168.1.2;};
    };

    sudo chmod 777 /var/lib/bind/slave/

    sudo systemctl restart named

### 4.3 Provide the output of dig(1) for a successful query from the slave server. Are there any differences to the queries from the master?


To slave:
    dig @192.168.1.1 -t SOA insec +norecurs
    
    dig @server name type
    
    SOA A start of authority record (abbreviated as SOA record) is a type of resource record in the Domain Name System (DNS) containing administrative information about the zone, especially regarding zone transfers. The SOA record format is specified in RFC 1035.
    
    The +norecurs flag at the end of the command instructs dig to perform a non-recursive query.

    ;; ANSWER SECTION:
    insec.                  60      IN      SOA     ns.insec. hostmaster.insec. 5 60 60 2419200 604800

    ; <<>> DiG 9.16.1-Ubuntu <<>> @192.168.1.1 -t SOA insec +norecurs
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 38654
    ;; flags: qr aa ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ; COOKIE: 091cdefabf56e3740100000063f274a1f58a35d60489b7f9 (good)
    ;; QUESTION SECTION:
    ;insec.                         IN      SOA

    ;; ANSWER SECTION:
    insec.                  60      IN      SOA     ns.insec. hostmaster.insec. 5 60 60 2419200 604800

    ;; AUTHORITY SECTION:
    insec.                  60      IN      NS      ns1.insec.
    insec.                  60      IN      NS      ns2.insec.

    ;; ADDITIONAL SECTION:
    ns1.insec.              60      IN      A       192.168.1.2
    ns2.insec.              60      IN      A       192.168.1.1

    ;; Query time: 0 msec
    ;; SERVER: 192.168.1.1#53(192.168.1.1)
    ;; WHEN: Sun Feb 19 19:12:33 UTC 2023
    ;; MSG SIZE  rcvd: 180

change the serial number of the master, to master

    dig @192.168.1.2 -t SOA insec +norecurs

    ;; ANSWER SECTION:
    insec.                  60      IN      SOA     ns.insec. hostmaster.insec. 2 60 60 2419200 604800

    ; <<>> DiG 9.16.1-Ubuntu <<>> @192.168.1.2 -t SOA insec +norecurs
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 54693
    ;; flags: qr aa ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ; COOKIE: 29f9da8ceeaa6ea10100000063f274ab5d646ee765121796 (good)
    ;; QUESTION SECTION:
    ;insec.                         IN      SOA

    ;; ANSWER SECTION:
    insec.                  60      IN      SOA     ns.insec. hostmaster.insec. 2 60 60 2419200 604800

    ;; AUTHORITY SECTION:
    insec.                  60      IN      NS      ns1.insec.
    insec.                  60      IN      NS      ns2.insec.

    ;; ADDITIONAL SECTION:
    ns1.insec.              60      IN      A       192.168.1.2
    ns2.insec.              60      IN      A       192.168.1.1

    ;; Query time: 0 msec
    ;; SERVER: 192.168.1.2#53(192.168.1.2)
    ;; WHEN: Sun Feb 19 19:12:44 UTC 2023
    ;; MSG SIZE  rcvd: 180


serial number is different


## 5

### 5.1 Explain the changes you made.

Adding a subdomain to a DNS server is a simple matter of insec

add ns1 : 

/etc/bind/zones/forward.insec
    ; sub-domain definitions
    ; zone fragment for us.example.com
    $ORIGIN not.insec.
    ; we define two name servers for the sub-domain
    @   IN    NS    ns2.not.insec.
    ns2   IN    A     192.168.1.1  ; 'glue' record

creating an additional master entry in the named.conf file

add ns2: /etc/bind/named.conf.default-zones

    zone "not.insec" in{
            type master;
            file "/var/lib/bind/master/master.not.insec";
    // explicitly allow zone transfer from slave
            allow-transfer {192.168.1.3;};
    };
    zone "1.168.192.in-addr.arpa" {
        type master;
        file "/var/lib/bind/master/master.reverse.not.insec";
    };

placing name server and authority entries for that subdomain in your primary DNS server's zone file. The subdomain, in turn, has its own zone file with its SOA record and entries listing hosts, which are part of its subdomain.

add ns2: /var/lib/bind/master/master.not.insec

    ;
    ; BIND data file for local loopback interface
    ;
    $TTL    60s
    ; Start of Authority RR defining the key characteristics of the zone (domain)
    @       IN      SOA     ns.insec. hostmaster.insec. (
                            8         ; Serial
                            60s         ; Refresh
                            60s         ; Retry
                            2419200         ; Expire
                            604800 )       ; Negative Cache TTL
    ;

    ; name server RR for the domain
            IN      NS      ns2.not.insec.
    ; the second name server is external to this zone (domain)
            IN      NS      ns3.not.insec.

    ; domain hosts includes NS and MX records defined above
    ; plus any others required
    ; for instance a user query for the A RR of joe.example.com will
    ; return the IPv4 address 192.168.254.6 from this zone file
    ns2        IN      A       192.168.1.1
    ns3        IN      A       192.168.1.3

add ns2: /var/lib/bind/master/master.reverse.not.insec

    ;
    ; BIND reverse data file for local loopback interface
    ;
    $TTL    60s
    @       IN      SOA     ns1.insec. hostmaster.insec. (
                                8       ; Serial
                            60s         ; Refresh
                            60s         ; Retry
                            2419200         ; Expire
                            604800 )       ; Negative Cache TTL
    ;

    ; Name Server Info for ns1.insec
    @       IN      NS      ns2.not.insec.
    ns2     IN      A      192.168.1.1


    ; Reverse DNS or PTR Record for ns2.insec
    ; Using the last number of DNS Server IP address: 192.168.1.1
    1      IN      PTR     ns2.not.insec.



    ; Reverse DNS or PTR Record for ns3.insec
    ; Using the last block IP address: 192.168.1.3
    3      IN      PTR     ns3.not.insec.

Adding the slave in ns3

adding the options(only difference is the listenning port changing to ns2)

    acl goodclients {
            192.168.1.0/24;
            localhost;
            localnets;
    };

    options {
            directory "/var/cache/bind";

            // If there is a firewall between you and nameservers you want
            // to talk to, you may need to fix the firewall to allow multiple
            // ports to talk.  See http://www.kb.cert.org/vuls/id/800113

            // If your ISP provided one or more IP addresses for stable
            // nameservers, you probably want to use them as forwarders.
            // Uncomment the following block, and insert the addresses replacing
            // the all-0's placeholder.

            // forwarders {
            //      0.0.0.0;
            // };
            recursion yes;
            
            allow-recursion { goodclients; };

            listen-on port 53 { localhost; 192.168.1.1; };

            allow-query { goodclients; };

            forwarders {
                    8.8.8.8;
            };

            forward only;
            auth-nxdomain no;    # conform to RFC1035
            //========================================================================
            // If BIND logs error messages about the root key being expired,
            // you will need to update your keys.  See https://www.isc.org/bind-keys
            //========================================================================
            dnssec-validation auto;

            listen-on-v6 { any; };
    };

Adding the slave zone

    zone "not.insec" in{
        type slave;
        file "/var/lib/bind/slave/slave.insec";
        masters {192.168.1.1;};
    };

Restart the three machines, and change the serial number of ns2.not.insec after ns3 is set up

### 5.2 Provide the output of dig(1) for successful queries from all the three name servers.

For ns1
    dig @192.168.1.2 -t SOA insec +norecurs

    ;; ANSWER SECTION:
    insec.                  60      IN      SOA     ns.insec. hostmaster.insec. 2 60 60 2419200 604800
For ns2.insec
    dig @192.168.1.1 -t SOA insec +norecurs

    ;; ANSWER SECTION:
    insec.                  60      IN      SOA     ns.insec. hostmaster.insec. 5 60 60 2419200 604800

For ns2.not.insec
    dig @192.168.1.1 -t SOA not.insec +norecurs
    ; <<>> DiG 9.16.1-Ubuntu <<>> @192.168.1.1 -t SOA not.insec +norecurs
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 50548
    ;; flags: qr aa ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ; COOKIE: 5fc9ed87f83905ba0100000063f36e8d254a253ba58708f0 (good)
    ;; QUESTION SECTION:
    ;not.insec.                     IN      SOA
    ;; ANSWER SECTION:
    not.insec.              60      IN      SOA     ns.insec. hostmaster.insec. 8 60 60 2419200 604800

For ns3.not.insec
    dig @192.168.1.3 -t SOA not.insec +norecurs
    ; <<>> DiG 9.16.1-Ubuntu <<>> @192.168.1.3 -t SOA not.insec +norecurs
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 56169
    ;; flags: qr aa ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ; COOKIE: 386ca6214f02b2950100000063f36e431a6c1ad3f393bad5 (good)
    ;; QUESTION SECTION:
    ;not.insec.                     IN      SOA

    ;; ANSWER SECTION:
    not.insec.              60      IN      SOA     ns.insec. hostmaster.insec. 9 60 60 2419200 604800

DIG response header:

    Flags:
    QR specifies whether this message is a query (0), or a response (1)
    
    AA = Authoritative Answer

    TC = Truncation

    RD = Recursion Desired (set in a query and copied into the response if recursion is supported)

    RA = Recursion Available (if set, denotes recursive query support is available)

    AD = Authenticated Data (for DNSSEC only; indicates that the data was authenticated)

    CD = Checking Disabled (DNSSEC only; disables checking at the receiving server)

    Response code:

    0 = NOERR, no error

    1 = FORMERR, format error (unable to understand the query)

    2 = SERVFAIL, name server problem

    3= NXDOMAIN, domain name does not exist

    4 = NOTIMPL, not implemented

    5 = REFUSED (e.g., refused zone transfer requests)


## 6

### 6.1 Explain the changes you made. Show the successful and the unsuccessful zone transfer in the log.

    tsig-keygen -a hmac-sha1 subDomainKey

    key keyname {
        algorithm hmac-sha1;
        secret "generated key";
    };

For ns2:  /etc/bind/named.conf
    include "/etc/bind/subDomainKey.key";
    server 192.168.1.3 {                   ;slave server
        keys { subDomainKey.; };
    };

/etc/bind/named.conf.default-zones

    zone "not.insec" in{
        type master;
        file "/var/lib/bind/master/master.not.insec";
    // explicitly allow zone transfer from slave
            allow-transfer {key subDomainKey.;};
    };

For ns3: /etc/bind/named.conf

    include "/etc/bind/subDomainKey.key";
    server 192.168.1.1 {                  ; master server
        keys { subDomainKey.; };
    };


Failed one:
    dig axfr not.insec @ns3
    dig axfr insec @ns3
    ; <<>> DiG 9.16.1-Ubuntu <<>> @192.168.1.3 insec axfr
    ; (1 server found)
    ;; global options: +cmd
    ; Transfer failed.

    Feb 20 20:13:31 ubuntu-focal named[43774]: client @0x7f4eb40249e0 192.168.1.1#47925 (not.insec): zone transfer 'not.insec/AXFR/IN' denied

    Feb 20 20:36:29 ubuntu-focal named[44003]: client @0x7f7cf8014de0 192.168.1.1#42883 (insec): bad zone transfer request: 'insec/IN': non-authoritative zone (NOTAUTH)

Successful one:

    dig @192.168.1.3 not.insec axfr -k /etc/bind/subDomainKey.key

    ; <<>> DiG 9.16.1-Ubuntu <<>> @192.168.1.3 not.insec axfr
    ; (1 server found)
    ;; global options: +cmd
    not.insec.              60      IN      SOA     ns.insec. hostmaster.insec. 9 60 60 2419200 604800
    not.insec.              60      IN      NS      ns2.not.insec.
    not.insec.              60      IN      NS      ns3.not.insec.
    ns2.not.insec.          60      IN      A       192.168.1.1
    ns3.not.insec.          60      IN      A       192.168.1.3
    not.insec.              60      IN      SOA     ns.insec. hostmaster.insec. 9 60 60 2419200 604800
    ;; Query time: 0 msec
    ;; SERVER: 192.168.1.3#53(192.168.1.3)
    ;; WHEN: Mon Feb 20 20:36:19 UTC 2023
    ;; XFR size: 6 records (messages 1, bytes 220)

    Feb 20 20:37:44 ubuntu-focal named[44003]: client @0x7f7cf8013dd0 192.168.1.1#50468 (not.insec): transfer of 'not.insec/IN': AXFR started (serial 9)
    Feb 20 20:37:44 ubuntu-focal named[44003]: client @0x7f7cf8013dd0 192.168.1.1#50468 (not.insec): transfer of 'not.insec/IN': AXFR ended: 1 messages, 6 records, 181 bytes, 0.001 secs (181000 bytes/sec)


    dnsrecon -d not.insec -t axfr
    [*] Testing NS Servers for Zone Transfer
    [*] Checking for Zone Transfer for not.insec name servers
    [*] Resolving SOA Record
    [-] Error while resolving SOA record.
    [*] Resolving NS Records
    [*] NS Servers found:
    [*]     NS ns3.not.insec 192.168.1.3
    [*]     NS ns2.not.insec 192.168.1.1
    [*] Removing any duplicate NS server IP Addresses...
    [*]
    [*] Trying NS server 192.168.1.1
    [+] 192.168.1.1 Has port 53 TCP Open
    [-] Zone Transfer Failed!
    [-] Zone transfer error: REFUSED
    [*]
    [*] Trying NS server 192.168.1.3
    [+] 192.168.1.3 Has port 53 TCP Open
    [+] Zone Transfer was successful!!
    [*]      NS ns2.not.insec 192.168.1.1
    [*]      NS ns3.not.insec 192.168.1.3
    [*]      A ns2.not.insec 192.168.1.1
    [*]      A ns3.not.insec 192.168.1.3

### 6.2 TSIG is one way to implement transaction signatures. DNSSEC describes another, SIG(0). Explain the differences

TSIG Keys

TSIG (transmission signatures) also provide secure DNS communications, but they **share the private key** instead of a private/public key pair. They are usually used for communications between two local DNS servers, and to provide authentication for dynamic updates such as those between a DNS server and a DHCP server.

A TSIG key is a symmetric key (or a shared key) that both parties (i.e. client and server) must know.

TSIG keys have to be configured in named.conf, which means that whenever the key is changed, you have to update your server’s configuration.

DNSSEC

DNSSEC(The DNS Security Extensions) provides encrypted authentication to DNS. With DNSSEC, you can create **a signed zone** that is securely identified with an encrypted signature. This form of security is used primarily to secure the connections between master and slave DNS servers, so that a master server transfers update records only to authorized slave servers and does so with a secure encrypted communication. Two servers that establish such a secure connection do so using **a pair of public and private keys**. In effect, you have a parent zone that can securely authenticate child zones, using encrypted transmissions. This involves creating zone keys for each child and having those keys used by the parent zone to authenticate the child zones.

SIG(0)

Signing using SIG(0) is more complicated. It requires a **private/public key** to be generated. Both can be generated using the dnssec-keygen tool. This tool produces both the public key, which will be advertised via the domain zone, and a private key which is passed to the signSIG0() function.

SIG(0) keys are asymmetric key-pairs to authenticate messages

When a SIG(0) signed message is received, it is only verified if the key is known and trusted by the server. The server does not attempt to recursively fetch or validate the key.

## 7

### 7.1 Based on the dig-queries, how does Pi-hole block domains on a DNS level?

    sudo service named status
    sudo systemctl restart pihole-FTL

Pi-hole blocks domains on a DNS level by acting as a DNS sinkhole. When a device on the network makes a DNS query for a domain name, Pi-hole intercepts the query and checks if the domain is on its blocklist. If the domain is on the blocklist, Pi-hole responds with a null or "sinkhole" IP address (typically 0.0.0.0 or 127.0.0.1) instead of the IP address associated with the domain. This prevents the device from connecting to the requested domain

Alongside the block lists that Pi-hole uses to filter DNS requests, you can also target individual domains with blacklists. Blacklists automatically drop outgoing and incoming requests to and from specific domains. This can be particularly useful to businesses and other organizations who need to block domains that contain content that isn’t appropriate for work or are known for hosting viruses and other malware.

A regular expression, or RegEx for short, is a pattern that can be used for building arbitrarily complex filter rules in FTLDNS.

### 7.2 How could you use Pi-hole in combination with your own DNS server, such as your caching-only nameserver?

You can use Pi-hole in combination with your own DNS server, such as a caching-only nameserver, by configuring your DNS server as an upstream DNS resolver for Pi-hole. This allows Pi-hole to forward DNS queries to your DNS server for resolution if the requested domain is not on its blocklist or safe list.

1 change the port of named in ns1

2 set up pihole-FTL (maybe set ns1's named as upstram dns server?)

vagrant ssh ns1 -- -L 8080:10.0.2.15:80

3 add the client ns1 client

4 add the blacklist

**The Pi-hole works by replacing your router in that chain**. Once up and running, a Pi-hole will first check a blacklist and whitelist to determine if the domain should be resolved. If a URL is on the blacklist, it will immediately return a block page, which prevents that request from even leaving your local network. If the Pi-hole otherwise approves the request, then it will first check a local cache to avoid sending the same request to an upstream DNS provider over and over again.

If it doesn't have the IP address in its cache, then the Pi-hole will request the IP from the upstream DNS provider you decide on. The upstream DNS provider can be anything such as Google's public DNS or OpenDNS or **custom** **DNS** **service**. These DNS providers then use recursive resolvers to work through the URL and come up with an IP address.

    vagrant@client:~$ dig @192.168.1.2 ns1.insec

    ; <<>> DiG 9.16.1-Ubuntu <<>> @192.168.1.2 ns1.insec
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 27936
    ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;ns1.insec.                     IN      A

    ;; ANSWER SECTION:
    ns1.insec.              2       IN      A       0.0.0.0

    ;; Query time: 0 msec
    ;; SERVER: 192.168.1.2#53(192.168.1.2)
    ;; WHEN: Tue Feb 21 13:33:09 UTC 2023
    ;; MSG SIZE  rcvd: 54

    vagrant@client:~$ dig @192.168.1.1 ns1.insec

    ; <<>> DiG 9.16.1-Ubuntu <<>> @192.168.1.1 ns1.insec
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 54150
    ;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ; COOKIE: d9a07fbd2cade4f70100000063f4c81a4a007d77043821bb (good)
    ;; QUESTION SECTION:
    ;ns1.insec.                     IN      A

    ;; ANSWER SECTION:
    ns1.insec.              60      IN      A       192.168.1.2

    ;; Query time: 4 msec
    ;; SERVER: 192.168.1.1#53(192.168.1.1)
    ;; WHEN: Tue Feb 21 13:33:14 UTC 2023
    ;; MSG SIZE  rcvd: 82