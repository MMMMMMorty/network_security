# Web Server

This lab activity involved multiple tasks centered around web server configuration and management, specifically with Apache2 and Node.js, as well as securing these services using SSL and configuring a reverse proxy with Nginx.

## 1 Apache2

### lab2 command

Serve a default web page using Apache2

    sudo apt update
    sudo apt install apache2
    sudo ufw app list
    sudo ufw allow 'Apache'
    sudo ufw status
    sudo ufw enable
    sudo ufw allow 'OpenSSH'
    sudo systemctl status apache2

Show that the web page can be loaded on local browser (your machine or Niksula) using SSH port forwarding.

    # use ssh -L bind the port to localhost port
    vagrant ssh lab2 -- -L 8081:localhost:80
    ssh -L 8081:127.0.0.1:80 -i D:/Projects/vagrant_new/.vagrant/machines/lab2/virtualbox/private_key -p 2200 vagrant@127.0.0.1

## Serve a web page using Node.js

### lab3

Provide a working web page with the text "Hello World!"

    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.39.0/install.sh | bash
    # logout and login
    nvm --version
    # install latest
    nvm install --lts
    npm init

Index.js

    const http = require('http');

    const hostname = '192.168.2.2';
    const port = 8080;

    const server = http.createServer((req, res) => {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');
    res.end('Hello World');
    });

    server.listen(port, hostname, () => {
    console.log(`Server running at http://${hostname}:${port}/`);
    });

### What does it mean that Node.js is event driven? What are the advantages in such an approach?

Events are records of something that has happened, a change in state.

Event-driven programming is used to synchronize the occurrence of multiple events and to make the program as simple as possible. The basic components of an Event-Driven Program are:

A callback function ( called an event handler) is called when an event is triggered.
An event loop that listens for event triggers and calls the corresponding event handler for that event.

Flexibility: It is easier to alter sections of code as and when required.

Suitability for graphical interfaces: It allows the user to select tools (like radio buttons etc.) directly from the toolbar

Programming simplicity: It supports predictive coding, which improves the programmer’s coding experience.

Easy to find natural dividing lines: Natural dividing lines for unit testing infrastructure are easy to come by.

A good way to model systems: Useful method for modeling systems that must be asynchronous and reactive.

Allows for more interactive programs: It enables more interactive programming. Event-driven programming is used in almost all recent GUI apps.

Using hardware interrupts: It can be accomplished via hardware interrupts, lowering the computer’s power consumption.

Allows sensors and other hardware: It makes it simple for sensors and other hardware to communicate with software.

## 3 Configuring SSL for Apache2

### 3.1 Provide and explain your solution

Creating a private key

First of all, create a private key to make your public certificate.

To create a private key, use the OpenSSL client:

    sudo openssl genrsa -aes128 -out private.key 2048

N.B. This command is used to specify the creation of a private key with a length of 2048 bits which will be saved in the private.key file

Creating a Certificate Signing Request (CSR)

After generating your private key, create a certificate signing request (CSR) which will specify the details for the certificate.

    sudo openssl req -new -days 365 -key private.key -out request.csr

Generating the SSL Certificate

At this point, proceed with the generation of the certificate:

    sudo openssl x509 -in request.csr -out certificate.crt -req -signkey private.key -days 365

Where :

for the -in parameter specify the certificate signing request

for the parameter -out specify the name of the file that will contain the certificate

for the -signkey parameter specify your private key

for the parameter -days specify the number of days of validity of the certificate that is going o be created

Important note:

During the creation of the certificate, enter your server’s IP address and or domain name when asked for the Common Name:

    Common Name (e.g. server FQDN or YOUR name) []: domain.com

Insert the password of private.key

    sudo mkdir /etc/certificate

    sudo nano /etc/apache2/sites-available/default-ssl.conf

Set up the **ServerAdmin directive correctly by entering your email and add the ServerName directive followed by your domain or your server's IP address**.

Finally, change the path indicated by the **SSLCertificateFile and SSLCertificateKeyFile** directives, entering respectively the path of your certificate and private key.

configure the Firewall

    sudo ufw app list

    sudo ufw app info "Apache Full"

    sudo ufw allow in "Apache Full"

configure Apache

Enable the mod_ssl and mod_headers modules:

    sudo a2enmod ssl
    
    sudo a2enmod headers

Enable reading of the SSL configuration created earlier:

    sudo a2enconf ssl-params
Enable the default SSL Virtual Host:

    sudo a2ensite default-ssl
Check that you have not made syntax errors in the Apache configuration files:

    sudo apache2ctl configtest
If the message "Syntax OK" appears on the screen, proceed by restarting Apache:

    sudo systemctl restart apache2

check the secure connection

    ssh -L 443:10.0.2.15:443 -i D:/Projects/vagrant_new/.vagrant/machines/lab2/virtualbox/private_key -p 2200 vagrant@127.0.0.1

enter this to the bar address
    https://localhost/

### What information can a certificate include? What is necessary for it to work in the context of a web server?

    Country Name (2 letter code) [AU]: IT

    State or Province Name (full name) [Some-State]: Lazio

    Locality Name (eg, city) []: Rome

    Organization Name (eg, company) [Internet Widgits Pty Ltd]: My Society

    Organizational Unit Name (eg, section) []: Security

    Common Name (e.g. server FQDN or YOUR name) []: example.it

    Email Address []: mymail@email.com
                    Please enter the following 'extra' attributes

    to be sent with your certificate request

    A challenge password []: An optional company name []:

The necessary to work is: Common Name, Email Address

You need to enter either the hostname you’ll use to access the server by, or the public IP of the server.

### What do PKI and requesting a certificate mean?

**Public Key Infrastructure** (PKI) is a system of processes, technologies, and policies that allows you to encrypt and/or sign data. With PKI, you can issue digital certificates that authenticate the identity of users, devices, or services.

A certificate signing request (CSR) is one of the first steps towards getting your own SSL/TLS certificate. Generated on the same server you plan to install the certificate on, the CSR contains information (e.g. common name, organization, country) the Certificate Authority (CA) will use to create your certificate. It also contains the public key that will be included in your certificate and is signed with the corresponding private key. We’ll go into more details on the roles of these keys below.

## 4 Enforcing HTTPS

### Provide and explain your solution.

    sudo a2enmod userdir
    cd ~
    mkdir public_html
    cd public_html
    mkdir secure_secrets
    sudo systemctl restart apache2

    https://localhost/~vagrant/secure_secrets/

    sudo a2enmod rewrite && sudo service apache2 restart

Test

    lynx -dump localhost/~vagrant/secure_secrets 80

    Looking up localhost
    Making HTTP connection to localhost
    Sending HTTP request.
    HTTP request sent; waiting for response.
    HTTP/1.1 301 Moved Permanently
    Data transfer complete
    HTTP/1.1 301 Moved Permanently
    Using https://localhost/~vagrant/secure_secrets
    Looking up localhost
    Making HTTPS connection to localhost

### What is HSTS?

HTTP Strict Transport Security (HSTS) is a policy mechanism that helps to protect websites against man-in-the-middle attacks such as protocol downgrade attacks[1] and cookie hijacking. It allows web servers to declare that web browsers (or other complying user agents) should automatically interact with it using only HTTPS connections, which provide Transport Layer Security (TLS/SSL), unlike the insecure HTTP used alone. 

### When to use .htaccess?

There is only one good reason to use .htaccess files. The reason is this. You don't have access to the main server configuration file.

This is a common problem. Most shared hosting accounts don't have access to the main server configuration file. Therefore, they need distributed configuration files in each hosting account. The .htaccess file is a distributed configuration file that allows configuration changes only in the directory that it resides in.

If you are using shared hosting you will likely need to use a .htaccess file to make configuration changes to your server.

### In contrast, when not to use it?

If you are using a virtual private server or a dedicated server, you should have access to the **main server configuration file** (usually called httpd.conf). If you do have access to that file, you should **make all server configuration changes** there. It is much more efficient. It can even be done on a per-directory basis just like the .htaccess file.

The server must execute the .htaccess file to use it. This means that the server will need to use extra RAM, CPU power, and computing time to process a .htaccess file. This means each request that runs through a .htaccess file will take more resources and time.

You can see how adding one .htaccess file increases the server load. If you use several .htaccess files you multiply the server load exponentially.

## 5 Install nginx as a reverse proxy

    sudo apt-get install nginx -y

    sudo ufw allow 'Nginx HTTP'

    systemctl status nginx

    sudo unlink /etc/nginx/sites-enabled/default    

    cd /etc/nginx/sites-available/  

    sudo vim reverse-proxy.conf

The file is

    server {
        listen 80;

        root /var/www/html;
        index index.html index.htm index.nginx-debian.html;

        server_name lab1;

        location /apache {
                proxy_pass http://192.168.1.2:80;
                rewrite ^/(.*) http://192.168.1.2/~vagrant/secure_secrets/ permanent;
                include /etc/nginx/proxy_params;
        }
         location /node {
                proxy_pass http://192.168.2.2:8080;
                include /etc/nginx/proxy_params;
        }
    }

Then,

    sudo ln -s /etc/nginx/sites-available/reverse-proxy.conf /etc/nginx/sites-enabled/reverse-proxy.conf

    sudo nginx -t

    sudo systemctl restart nginx

    lynx -dump http://lab1/apache/

    lynx -dump http://lab1/node/

### Explain the contents of the nginx configuration file

    events {
    # events context
    # The “events” context is contained within the “main” context. It is used to set global options that affect how Nginx handles connections at a general level. There can only be a single events context defined within the Nginx configuration.

    . . .

    }

    http {
        # http context
        # Defining an HTTP context is probably the most common use of Nginx. When configuring Nginx as a web server or reverse proxy, the “http” context will hold the majority of the configuration. This context will contain all of the directives and other contexts necessary to define how the program will handle HTTP or HTTPS connections.

        # The http context is a sibling of the events context, so they should be listed side-by-side, rather than nested. They both are children of the main context
        . . .

    }


    # main context

    http {

        # http context

        upstream upstream_name {

            # upstream context

            # This context defines a named pool of servers that Nginx can then proxy requests to. This context will likely be used when you are configuring proxies of various types.

            server proxy_server1;
            server proxy_server2;

            . . .

        }

        server {

            # server context

            # listen: The IP address / port combination that this server block is designed to respond to. If a request is made by a client that matches these values, this block will potentially be selected to handle the connection.

            # server_name: This directive is the other component used to select a server block for processing. If there are multiple server blocks with listen directives of the same specificity that can handle the request, Nginx will parse the “Host” header of the request and match it against this directive.

            location /other/criteria {

                # second location context

                location nested_match {

                    # first nested location

                }

                location other_nested {

                    # second nested location

                    if (test_condition) {

                        # if context

                    }


                }

        }

        }

    }

### What is commonly the primary purpose of an nginx server and why?

Because it can handle a high volume of connections, NGINX is commonly used as a reverse proxy and load balancer to manage incoming traffic and distribute it to slower upstream servers

It provides a single entry point- within the containerized environment, you can deploy or destroy the containers whenever required, but having a single entry point for the users to access the services is a better approach. NGINX is a better solution to provide it. You can NGINX servers at your disposal that will help you to load the balance and route the traffic with a stable public IP address. NGINX server will get the user’s request and then forward it to the appropriate container.

Caching- NGINX server provides a cache for both static and dynamic content, which enhances the performance.

Consolidated logging- NGINX comes with standard HTTP log format. It allows you to log the complete web traffic on the NGINX front end rather than having a separate log for each microservice traffic and merging them later. Using NGINX, you can reduce the complexity of creating and maintaining access logs.

Scalability and fault tolerance- the load balancing, health checks features of NGINX allow you to scale your back-end infrastructure so that adding or removing any microservice will not impact the user’s experience. If you want to deploy more microservices, you only have to inform the NGINX server that you have added a new instance to the load-balanced pool. In case of a failed instance, NGINX will not route the traffic to that instance until it recovers.

Zero downtime- NGINX ensures smooth working of the webserver. You can even update or upgrade the system software seamlessly without interruption to the connection and avoid any application downtime.

Mitigate DoS attacks- NGINX is well-known for handling tons of incoming requests or HTTP traffic, ensuring application safety during high traffic, common cache response, and deliver request smoothly. NGINX works as a shock absorber for your application. It also controls traffic that will protect the vulnerable APIs and URLs from being overloaded with requests. This can be achieved by applying a concurrency limit and queuing requests to avoid overload of the server.

## 5 Test Damn Vulnerable Web Application

    git clone https://github.com/digininja/DVWA.git

    cd DVMA

    cp config/config.inc.php.dist config/config.inc.php

    sudo apt update

    sudo apt install -y apache2 mariadb-server mariadb-client php php-mysqli php-gd libapache2-mod-php

### Using Nmap, enumerate the lab2, and detect the os version, php version, apache version and open ports

    nmap -A localhost

    Starting Nmap 7.80 ( https://nmap.org ) at 2023-01-28 20:41 UTC
    Nmap scan report for localhost (127.0.0.1)
    Host is up (0.000049s latency).
    Not shown: 996 closed ports
    PORT     STATE SERVICE VERSION
    22/tcp   open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.5 (Ubuntu Linux; protocol 2.0)
    80/tcp   open  http    Apache httpd 2.4.41 ((Ubuntu))
    |_http-server-header: Apache/2.4.41 (Ubuntu)
    |_http-title: Apache2 Ubuntu Default Page: It works
    443/tcp  open  ssl/ssl Apache httpd (SSL-only mode)
    |_http-server-header: Apache/2.4.41 (Ubuntu)
    |_http-title: Apache2 Ubuntu Default Page: It works
    | ssl-cert: Subject: commonName=10.0.2.15/organizationName=Internet Widgits Pty Ltd/stateOrProvinceName=Some-State/countryName=FI
    | Not valid before: 2023-01-28T10:42:41
    |_Not valid after:  2023-02-27T10:42:41
    | tls-alpn:
    |_  http/1.1
    3306/tcp open  mysql   MySQL 5.5.5-10.3.37-MariaDB-0ubuntu0.20.04.1
    | mysql-info:
    |   Protocol: 10
    |   Version: 5.5.5-10.3.37-MariaDB-0ubuntu0.20.04.1
    |   Thread ID: 38
    |   Capabilities flags: 63486
    |   Some Capabilities: SupportsCompression, ConnectWithDatabase, IgnoreSpaceBeforeParenthesis, Support41Auth, DontAllowDatabaseTableColumn, Speaks41ProtocolOld, SupportsTransactions, SupportsLoadDataLocal, InteractiveClient, LongColumnFlag, Speaks41ProtocolNew, IgnoreSigpipes, ODBCClient, FoundRows, SupportsMultipleResults, SupportsMultipleStatments, SupportsAuthPlugins
    |   Status: Autocommit
    |   Salt: cbA^4)ou}5.'u>qA0h>>
    |_  Auth Plugin Name: mysql_native_password
    Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

    Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
    Nmap done: 1 IP address (1 host up) scanned in 13.16 seconds

    php -varsion
    PHP 7.4.3-4ubuntu2.17 (cli) (built: Jan 10 2023 15:37:44) ( NTS )
    Copyright (c) The PHP Group
    Zend Engine v3.4.0, Copyright (c) Zend Technologies with Zend OPcache v7.4.3-4ubuntu2.17, Copyright (c), by Zend Technologies

### Using Nikto, to detect vulnerabilities on lab2

    sudo apt-get install nikto -y

    nikto -h localhost

The result is

    - Nikto v2.1.5
    ---------------------------------------------------------------------------
    + Target IP:          127.0.0.1
    + Target Hostname:    localhost
    + Target Port:        80
    + Start Time:         2023-01-28 20:50:40 (GMT0)
    ---------------------------------------------------------------------------
    + Server: Apache/2.4.41 (Ubuntu)
    + Server leaks inodes via ETags, header found with file /, fields: 0x2aa6 0x5f32ef4432ebe
    + The anti-clickjacking X-Frame-Options header is not present.
    + No CGI Directories found (use '-C all' to force check all possible dirs)
    + Allowed HTTP Methods: GET, POST, OPTIONS, HEAD
    + OSVDB-561: /server-status: This reveals Apache information. Comment out appropriate line in httpd.conf or restrict access to allowed hosts.
    + 6544 items checked: 0 error(s) and 4 item(s) reported on remote host
    + End Time:           2023-01-28 20:50:52 (GMT0) (12 seconds)
    ---------------------------------------------------------------------------
    + 1 host(s) tested

Specify the port

    nikto -h localhost -p 443

    - Nikto v2.1.5
    ---------------------------------------------------------------------------
    + Target IP:          127.0.0.1
    + Target Hostname:    localhost
    + Target Port:        443
    + Start Time:         2023-01-28 20:52:23 (GMT0)
    ---------------------------------------------------------------------------
    + Server: Apache/2.4.41 (Ubuntu)
    + The anti-clickjacking X-Frame-Options header is not present.
    + No CGI Directories found (use '-C all' to force check all possible dirs)
    + 6544 items checked: 13 error(s) and 1 item(s) reported on remote host
    + End Time:           2023-01-28 20:52:30 (GMT0) (7 seconds)
    ---------------------------------------------------------------------------
    + 1 host(s) tested

